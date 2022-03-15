#include "mmap_soc.h"
#include "typedef.h"
#include "util.h"
#include "spi.h"

__U8 __dma_spi_mem_cpy(__U8P __buff, __U32 len) {
    *DMA_DEST_32P = (__U32) __buff;
    *DMA_LEN_32P  = len;
    
    *DMA_CON_32P  = 0;
    // Set SRC SPI / DEST INCR
    *DMA_CON_32P  |= 0x6 << 4;

    // Set SRC BYTE / DEST WORD
    *DMA_CON_32P  |= 0x8 << 8;

    // Start
    *DMA_CON_32P  |= 0x1;

    while (*DMA_CON_32P & 0x80000000);
    return 1;
}

__U8 __spi_init(__U32 __br) {
    *SPI_CR1_32P = 0;
    *SPI_CR1_32P = (          1  << __SPI_CR1_SPE_BIT     )|
                   (          1  << __SPI_CR1_MSTR_BIT    )|
                   ((__br & 0x7) << __SPI_CR1_BR_BIT      )|
                   (          0  << __SPI_CR1_DFF_BIT     )|
                   (          0  << __SPI_CR1_LSBFIRST_BIT)|
                   (          0  << __SPI_CR1_CPOL_BIT    )|
                   (          0  << __SPI_CR1_CPHA_BIT    );
    return 1;
}

__U8 __spi_rwbyte(__U8 __byte) {
    while (!(*SPI_SR_32P & 0x1));
    *SPI_DR_32P = __byte;
    while (!(*SPI_SR_32P & 0x2));
    return *SPI_DR_32P;
}


__U8 __sd_getresp(__U8P buff, __U32 n) {
    for (__U32 i = 0; i < n; ++i) {
        buff[i] = __spi_rwbyte(__DUMMY_DATA);
    }
    return 1;
}

__U8 __sd_sendcmd(__U8 cmd, __U32 arg, __U8 crc) {
    __U32 retry = 0;
    __U8   r1;
    __spi_rwbyte(cmd | 0x40);
    __spi_rwbyte((__U8) (arg >> 24));
    __spi_rwbyte((__U8) (arg >> 16));
    __spi_rwbyte((__U8) (arg >>  8));
    __spi_rwbyte((__U8) (arg      ));
    __spi_rwbyte(crc | 0x1);
    r1 = __spi_rwbyte(__DUMMY_DATA);
    while (r1 & 0x8 && retry++ < 5000)
        r1 = __spi_rwbyte(__DUMMY_DATA);
    return r1;
}

__U8 __sd_rcvdata(__U8P buff, __U32 size, __U8 release) {
    __U32 retry = 0;
    __U8  r1;

    __CS_ENABLE();
    do {
        r1 = __spi_rwbyte(__DUMMY_DATA);
        if (retry++ > 5000) return r1;
    } while (r1 != 0xfe);
    
    // while (size--) 
    //     *buff++ = __spi_rwbyte(__DUMMY_DATA);
    __dma_spi_mem_cpy(buff, 512);

    __spi_rwbyte(__DUMMY_DATA);
    __spi_rwbyte(__DUMMY_DATA);
    
    if (release) {
        __CS_DISABLE();
        __spi_rwbyte(__DUMMY_DATA);
    }
        
    return 1;
}

__U8 __sd_readblk(__U32 sector, __U8P buff) {
#ifndef FAKE_SD
    __CS_ENABLE();
    *TMDL_TM_DCACHE_FLUSH_64P = 1;
    if (__sd_sendcmd(__CMD17, sector, 0)) return 0;
    return __sd_rcvdata(buff, 512, 1);
#else
    *TMDL_TM_SD_SECT_64P = sector;
    *TMDL_TM_SD_DEST_64P = (__U64) buff;
    *TMDL_TM_SD_RBLK_64P = 1;
    *TMDL_TM_DCACHE_FLUSH_64P = 1;
    return 1;
#endif
}

__U8 __sd_init(__U8P __sd_type) {
    __U8  stat;
    __U32 retry;
    __U8  r1;
    __U8  buff[8];

    stat = __STAT_UNKNOWN;

    // Enable SPI and set baud rate f/256
    __spi_init(7);

    // Wait SD card power up
    __delay(1);
    __CS_DISABLE();

    // Send 80 sclk to SD card for initialize
    for (__U8 __i = 0; __i < 10; ++__i)
        __spi_rwbyte(0xff);

    __CS_ENABLE();

    stat = __STAT_NO_INIT;

    retry = 0;
    do {
        r1 = __sd_sendcmd(__CMD0, 0, 0x95);
        if (retry++ > 1000)
           return stat;
    } while (r1 != 0x01);

    r1 = __sd_sendcmd(__CMD8, 0x1aa, 0x87);
    if (r1 == 0x5) {
        // SDSCv1.0 or MMC
        __sd_getresp(buff, 4);
        *__sd_type = __SD_V1;
    }
    else if (r1 == 0x1) { 
        // SDHCv2.0
        __sd_getresp(buff, 4);
        retry = 0;
        do {
            r1 = __sd_sendcmd(__CMD55, 0, 0x0);
            r1 = __sd_sendcmd(__ACMD41, 0x40000000, 0x0);
        } while (retry++ < 1000 && r1 != 0x0);
        retry = 0;
        do {
            r1 = __sd_sendcmd(__CMD58, 0, 0x0);
        } while (retry++ < 1000 && r1 != 0x0);
        __sd_getresp(buff, 4);
        *__sd_type = (buff[0] & 0x40) ? __SD_SDHC : __SD_SDSC;
    }

    // Set baud rate high speed
    __spi_init(2);

    // Disable CRC
    r1 = __sd_sendcmd(__CMD59, 0, 0x95);

    // Set block size 512 bytes
    r1 = __sd_sendcmd(__CMD16, 512, 0x95);

    stat = __STAT_INIT_OK;
    return stat;
}

