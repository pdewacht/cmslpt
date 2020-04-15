#include <conio.h>
#include "cmslpt.h"

static const char CTRL[4] = {
  0x0D, // left control
  0x0C, // left address
  0x07, // right control
  0x06, // right address
};

void cmslpt_output(int io, int byte)
{
  int port = cmslpt_port;
  char ctrl;
  outp(port, byte);
  port += 2;
  ctrl = CTRL[io & 3];
  outp(port, ctrl);
  ctrl ^= 4;
  outp(port, ctrl);
  ctrl ^= 4;
  outp(port, ctrl);
}

