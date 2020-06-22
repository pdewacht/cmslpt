#include <conio.h>
#include "cmslpt.h"

static void cmslpt_output(int byte, int ctrl);

void cmslpt_left_address(int byte)
{
  cmslpt_output(byte, 0x0C);    // CS1, A0
}

void cmslpt_left_data(int byte)
{
  cmslpt_output(byte, 0x0D);    // CS1, ~A0
}

void cmslpt_right_address(int byte)
{
  cmslpt_output(byte, 0x06);    // CS2, A0
}

void cmslpt_right_data(int byte)
{
  cmslpt_output(byte, 0x07);    // CS2, ~A0
}

static void cmslpt_output(int byte, int ctrl)
{
  int port = cmslpt_port;
  outp(port, byte);
  port += 2;
  outp(port, ctrl);
  outp(port, ctrl ^ 4);         // toggle WR
  inp(port);
  if (ctrl & 1) {
    inp(port);
    inp(port);
    inp(port);
    inp(port);
    inp(port);
  }
  outp(port, ctrl);
}
