#include <conio.h>
#include "cmslpt.h"

void cmslpt_init(void)
{
  int i;
  for (i = 0; i < 32; i++) {
    cmslpt_output(CMS_LEFT_ADDRESS, i);
    cmslpt_output(CMS_LEFT_CONTROL, 0);
    cmslpt_output(CMS_RIGHT_ADDRESS, i);
    cmslpt_output(CMS_RIGHT_CONTROL, 0);
  }
}
