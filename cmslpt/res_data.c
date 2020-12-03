#include "resident.h"
#include "cmslpt.h"

#pragma data_seg("_TEXT", "CODE")

struct config config = {
  .base_port = 0x220,
  .emulation = EMULATION_CMS,
};

int cmslpt_port = 0;
