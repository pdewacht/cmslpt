extern int cmslpt_port;

void cmslpt_init(void);

void cmslpt_left_address(int byte);
void cmslpt_left_data(int byte);
void cmslpt_right_address(int byte);
void cmslpt_right_data(int byte);

#ifdef _M_I86
#pragma aux cmslpt_left_address parm [ax] modify [dx]
#pragma aux cmslpt_left_data parm [ax] modify [dx]
#pragma aux cmslpt_right_address parm [ax] modify [dx]
#pragma aux cmslpt_right_data parm [ax] modify [dx]
#endif
