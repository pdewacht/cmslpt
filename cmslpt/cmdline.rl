#include <stddef.h>
#include "resident.h"
#include "cmdline.h"

%%{

machine cmdline;

action mode_load       { mode = MODE_LOAD; }
action mode_unload     { mode = MODE_UNLOAD; }
action mode_status     { mode = MODE_STATUS; }
action opt_lpt         { config.bios_id = *p - '1'; }
action opt_port        { config.base_port = 0x200 + 0x10 * (p[-1] - '0'); }
action opt_cms         { config.emulation = EMULATION_CMS; }
action opt_sb          { config.emulation = EMULATION_SB; }

# accept C NUL-terminated strings and DOS CR-terminated strings
end = (0 | 13) @{ fbreak; };
sep = " "+;

load_opt =
  ( /LPT[123]/i  @opt_lpt
  | /2[1-6]0/i   @opt_port
  | /CMS/i       @opt_cms
  | /SB/i        @opt_sb
  );

load   = (load_opt . (sep . load_opt)*)?  %mode_load;
unload = /UNLOAD/i                        @mode_unload;
status = /STATUS/i                        @mode_status;

main := sep? . (load | unload | status) . sep? . end;

}%%


enum mode parse_command_line (char _WCI86FAR *p)
{
  enum mode mode;
  int cs;
  %%write data;
  %%write init;
  %%write exec noend;
  if (cs < cmdline_first_final) {
    mode = MODE_USAGE;
  }
  return mode;
}
