#include <conio.h>
#include "cmslpt.h"

void cmslpt_init(void)
{
  int i;
  for (i = 0; i < 32; i++) {
    cmslpt_left_address(i);
    cmslpt_left_data(0);
    cmslpt_right_address(i);
    cmslpt_right_data(0);
  }
}
