// Memory Mapped Defination
#ifndef UINT32P
#define UINT32P volatile unsigned int *
#endif
#ifndef UINT64P
#define UINT64P volatile unsigned long long *
#endif

// ==============================
//  BROM_BASE
// ==============================
#define BROM_BASE 0x00000000

// ==============================
//  SRAM_BASE
// ==============================
#define SRAM_BASE 0x00020000

// ==============================
//  CFGREG_BASE
// ==============================
#define CFGREG_BASE 0x04000000
#define CFGREG_RSTN (CFGREG_BASE + 0x000)
#define CFGREG_RSTN_32P ((UINT32P) (CFGREG_BASE + 0x000))
#define CFGREG_RSTN_64P ((UINT64P) (CFGREG_BASE + 0x000))
#define CFGREG_BOOTVEC (CFGREG_BASE + 0x004)
#define CFGREG_BOOTVEC_32P ((UINT32P) (CFGREG_BASE + 0x004))
#define CFGREG_BOOTVEC_64P ((UINT64P) (CFGREG_BASE + 0x004))
#define CFGREG_DDROFFSET (CFGREG_BASE + 0x008)
#define CFGREG_DDROFFSET_32P ((UINT32P) (CFGREG_BASE + 0x008))
#define CFGREG_DDROFFSET_64P ((UINT64P) (CFGREG_BASE + 0x008))
#define CFGREG_RSVREG0 (CFGREG_BASE + 0x010)
#define CFGREG_RSVREG0_32P ((UINT32P) (CFGREG_BASE + 0x010))
#define CFGREG_RSVREG0_64P ((UINT64P) (CFGREG_BASE + 0x010))
#define CFGREG_RSVREG1 (CFGREG_BASE + 0x014)
#define CFGREG_RSVREG1_32P ((UINT32P) (CFGREG_BASE + 0x014))
#define CFGREG_RSVREG1_64P ((UINT64P) (CFGREG_BASE + 0x014))

// ==============================
//  CLINT_BASE
// ==============================
#define CLINT_BASE 0x08000000
#define CLINT_MSIP (CLINT_BASE + 0x0000)
#define CLINT_MSIP_32P ((UINT32P) (CLINT_BASE + 0x0000))
#define CLINT_MSIP_64P ((UINT64P) (CLINT_BASE + 0x0000))
#define CLINT_TIMECMP (CLINT_BASE + 0x4000)
#define CLINT_TIMECMP_32P ((UINT32P) (CLINT_BASE + 0x4000))
#define CLINT_TIMECMP_64P ((UINT64P) (CLINT_BASE + 0x4000))
#define CLINT_TIME (CLINT_BASE + 0xbff8)
#define CLINT_TIME_32P ((UINT32P) (CLINT_BASE + 0xbff8))
#define CLINT_TIME_64P ((UINT64P) (CLINT_BASE + 0xbff8))

// ==============================
//  PLIC_BASE
// ==============================
#define PLIC_BASE 0x0c000000
#define PLIC_INT_PRIOR (PLIC_BASE + 0x0000000)
#define PLIC_INT_PRIOR_32P ((UINT32P) (PLIC_BASE + 0x0000000))
#define PLIC_INT_PRIOR_64P ((UINT64P) (PLIC_BASE + 0x0000000))
#define PLIC_INT_PEND (PLIC_BASE + 0x0001000)
#define PLIC_INT_PEND_32P ((UINT32P) (PLIC_BASE + 0x0001000))
#define PLIC_INT_PEND_64P ((UINT64P) (PLIC_BASE + 0x0001000))
#define PLIC_INT_TYPE (PLIC_BASE + 0x0001080)
#define PLIC_INT_TYPE_32P ((UINT32P) (PLIC_BASE + 0x0001080))
#define PLIC_INT_TYPE_64P ((UINT64P) (PLIC_BASE + 0x0001080))
#define PLIC_INT_POL (PLIC_BASE + 0x0001100)
#define PLIC_INT_POL_32P ((UINT32P) (PLIC_BASE + 0x0001100))
#define PLIC_INT_POL_64P ((UINT64P) (PLIC_BASE + 0x0001100))
#define PLIC_INT_EN (PLIC_BASE + 0x0002000)
#define PLIC_INT_EN_32P ((UINT32P) (PLIC_BASE + 0x0002000))
#define PLIC_INT_EN_64P ((UINT64P) (PLIC_BASE + 0x0002000))
#define PLIC_PRIOR_TH (PLIC_BASE + 0x0200000)
#define PLIC_PRIOR_TH_32P ((UINT32P) (PLIC_BASE + 0x0200000))
#define PLIC_PRIOR_TH_64P ((UINT64P) (PLIC_BASE + 0x0200000))

// ==============================
//  UART_BASE
// ==============================
#define UART_BASE 0x10000000
#define UART_TXFIFO (UART_BASE + 0x00)
#define UART_TXFIFO_32P ((UINT32P) (UART_BASE + 0x00))
#define UART_TXFIFO_64P ((UINT64P) (UART_BASE + 0x00))
#define UART_RXFIFO (UART_BASE + 0x04)
#define UART_RXFIFO_32P ((UINT32P) (UART_BASE + 0x04))
#define UART_RXFIFO_64P ((UINT64P) (UART_BASE + 0x04))
#define UART_TXCTRL (UART_BASE + 0x08)
#define UART_TXCTRL_32P ((UINT32P) (UART_BASE + 0x08))
#define UART_TXCTRL_64P ((UINT64P) (UART_BASE + 0x08))
#define UART_RXCTRL (UART_BASE + 0x0C)
#define UART_RXCTRL_32P ((UINT32P) (UART_BASE + 0x0C))
#define UART_RXCTRL_64P ((UINT64P) (UART_BASE + 0x0C))
#define UART_IE (UART_BASE + 0x10)
#define UART_IE_32P ((UINT32P) (UART_BASE + 0x10))
#define UART_IE_64P ((UINT64P) (UART_BASE + 0x10))
#define UART_IP (UART_BASE + 0x14)
#define UART_IP_32P ((UINT32P) (UART_BASE + 0x14))
#define UART_IP_64P ((UINT64P) (UART_BASE + 0x14))
#define UART_IC (UART_BASE + 0x18)
#define UART_IC_32P ((UINT32P) (UART_BASE + 0x18))
#define UART_IC_64P ((UINT64P) (UART_BASE + 0x18))
#define UART_DIV (UART_BASE + 0x1C)
#define UART_DIV_32P ((UINT32P) (UART_BASE + 0x1C))
#define UART_DIV_64P ((UINT64P) (UART_BASE + 0x1C))
#define UART_LCR (UART_BASE + 0x20)
#define UART_LCR_32P ((UINT32P) (UART_BASE + 0x20))
#define UART_LCR_64P ((UINT64P) (UART_BASE + 0x20))

// ==============================
//  SPI_BASE
// ==============================
#define SPI_BASE 0x10001000
#define SPI_CR1 (SPI_BASE + 0x00)
#define SPI_CR1_32P ((UINT32P) (SPI_BASE + 0x00))
#define SPI_CR1_64P ((UINT64P) (SPI_BASE + 0x00))
#define SPI_CR2 (SPI_BASE + 0x04)
#define SPI_CR2_32P ((UINT32P) (SPI_BASE + 0x04))
#define SPI_CR2_64P ((UINT64P) (SPI_BASE + 0x04))
#define SPI_SR (SPI_BASE + 0x08)
#define SPI_SR_32P ((UINT32P) (SPI_BASE + 0x08))
#define SPI_SR_64P ((UINT64P) (SPI_BASE + 0x08))
#define SPI_DR (SPI_BASE + 0x0C)
#define SPI_DR_32P ((UINT32P) (SPI_BASE + 0x0C))
#define SPI_DR_64P ((UINT64P) (SPI_BASE + 0x0C))

// ==============================
//  DDR_BASE
// ==============================
#define DDR_BASE 0x80000000

// ==============================
//  TMDL_BASE
// ==============================
#define TMDL_BASE 0x87fff000
#define TMDL_TM_INFO (TMDL_BASE + 0x000)
#define TMDL_TM_INFO_32P ((UINT32P) (TMDL_BASE + 0x000))
#define TMDL_TM_INFO_64P ((UINT64P) (TMDL_BASE + 0x000))
#define TMDL_TM_ERROR (TMDL_BASE + 0x008)
#define TMDL_TM_ERROR_32P ((UINT32P) (TMDL_BASE + 0x008))
#define TMDL_TM_ERROR_64P ((UINT64P) (TMDL_BASE + 0x008))
#define TMDL_TM_ARGS (TMDL_BASE + 0x010)
#define TMDL_TM_ARGS_32P ((UINT32P) (TMDL_BASE + 0x010))
#define TMDL_TM_ARGS_64P ((UINT64P) (TMDL_BASE + 0x010))
#define TMDL_TM_SIMEND (TMDL_BASE + 0x018)
#define TMDL_TM_SIMEND_32P ((UINT32P) (TMDL_BASE + 0x018))
#define TMDL_TM_SIMEND_64P ((UINT64P) (TMDL_BASE + 0x018))

