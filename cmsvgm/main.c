#include <conio.h>
#include <dos.h>
#include <stdbool.h>
#include <stdlib.h>
#include "zlib/zlib.h"
#include "cmslpt.h"
#include "vgm.h"

#define STR(x) #x
#define XSTR(x) STR(x)

int cmslpt_port;

static volatile int interrupted = 0;

static void __interrupt __far ctrlc_handler()
{
  interrupted = 1;
}

static short get_lpt_port(int i)
{
  return *(short __far *)MK_FP(0x40, 6 + 2 * i);
}

static short setup(void)
{
  char num_ports, port, i;

  num_ports = 0;
  for (i = 1; i < 4; i++) {
    if (get_lpt_port(i)) {
      num_ports++;
      port = i;
    }
  }

  if (num_ports == 0) {
    cputs("Sorry, no printer port found...\r\n");
    exit(1);
  }

  if (num_ports == 1) {
    cprintf("Found one printer port: LPT%d\r\n", port);
    return get_lpt_port(port);
  }

  cputs("Found multiple printer ports:");
  for (i = 1; i < 4; i++) {
    if (get_lpt_port(i)) {
      cprintf(" LPT%d", i);
    }
  }
  cputs("\r\nWhich one is the CMSLPT connected to? [");
  for (i = 1; i < 4; i++) {
    if (get_lpt_port(i)) {
      cprintf("%d", i);
    }
  }
  cputs("]? ");
  do {
    port = getch() - '0';
  } while (port < 1 || port > 3 || !get_lpt_port(port));
  cprintf("LPT%d\r\n", port);
  return get_lpt_port(port);
}

void warnx(const char *fmt, ...)
{
  va_list ap;
  va_start(ap, fmt);
  vcprintf(fmt, ap);
  cprintf("\r\n");
  va_end(ap);
}

int main(int argc, char *argv[])
{
  gzFile f;
  char *filename;
  short lpt_base;

  cputs("== CMSLPT test program (" XSTR(VERSION) ") ==\r\n\r\n");

  if (argc > 1) {
    filename = argv[1];
  } else {
    filename = "CLPTTEST.VGZ";
  }
  f = gzopen(filename, "rb");
  if (!f) {
    cprintf("Can't open file \"%s\"\r\n", filename);
    return 1;
  }
  if (!music_setup(f)) {
    cputs("Not a CMS VGM file\r\n");
    return 1;
  }

  cmslpt_port = setup();
  cmslpt_init();

  cputs("\r\nPress any key to start the music...");
  do {
    getch();
  } while (kbhit());
  cputs("\r\n\r\nPress any key to stop...");
  _dos_setvect(0x23, ctrlc_handler);

  music_start();
  while (!interrupted && music_loop() && !kbhit()) {
  }
  music_shutdown();

  while (kbhit()) {
    getch();
  }
  cputs("\r\n\r\n");
  return 0;
}
