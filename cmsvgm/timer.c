#include <i86.h>
#include <dos.h>
#include <conio.h>

static void (__interrupt __far * prev_timer_handler) ();
static volatile unsigned timer_ticks;
static unsigned timer_counter;
static unsigned timer_sum;

void __interrupt __far timer_handler()
{
  unsigned old_sum = timer_sum;

  ++timer_ticks;

  timer_sum += timer_counter;
  if (timer_sum < old_sum) {
    _chain_intr(prev_timer_handler);
  } else {
    outp(0x20, 0x20);
  }
}

void timer_setup(unsigned frequency)
{
  timer_ticks = 0;
  timer_counter = 0x1234DD / frequency;
  timer_sum = 0;

  prev_timer_handler = _dos_getvect(0x08);
  _dos_setvect(0x08, timer_handler);

  _disable();
  outp(0x43, 0x34);
  outp(0x40, timer_counter & 256);
  outp(0x40, timer_counter >> 8);
  _enable();
}

void timer_shutdown(void)
{
  _disable();
  outp(0x43, 0x34);
  outp(0x40, 0);
  outp(0x40, 0);
  _enable();

  _dos_setvect(0x08, prev_timer_handler);
}

unsigned timer_get_elapsed(void)
{
  unsigned result;
  _disable();
  result = timer_ticks;
  timer_ticks = 0;
  _enable();
  return result;
}
