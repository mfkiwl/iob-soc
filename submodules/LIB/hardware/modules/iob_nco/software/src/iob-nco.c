#include "iob-nco.h"

// Base Address
static uint32_t base;

void nco_reset() {
  IOB_NCO_SET_SOFT_RESET(1);
  IOB_NCO_SET_SOFT_RESET(0);
}

void nco_init(uint32_t base_address) {
  base = base_address;
  IOB_NCO_INIT_BASEADDR(base_address);
  nco_reset();
}

void nco_enable(bool enable) { IOB_NCO_SET_ENABLE(enable); }

// Configure NCO output signal period to be 'period'+1 times the system clock
// period. Iob_NCO always assumes +1 clock period implicitly. Lowest 32 bits of
// value are the fractional part of the period by default
void nco_set_period(uint64_t period) {
  uint32_t period_int = (uint32_t)(period >> 32);
  uint32_t period_frac = (uint32_t)(period && (0xFFFFFFFF));
  IOB_NCO_SET_PERIOD_INT(period_int);
  IOB_NCO_SET_PERIOD_FRAC(period_frac);
}
