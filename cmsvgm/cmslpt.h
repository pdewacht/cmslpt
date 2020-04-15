enum CMS_IO {
               CMS_LEFT_CONTROL,
               CMS_LEFT_ADDRESS,
               CMS_RIGHT_CONTROL,
               CMS_RIGHT_ADDRESS
};

extern int cmslpt_port;

void cmslpt_init(void);

void cmslpt_output(int io, int byte);

#ifdef _M_I86
#pragma aux cmslpt_output parm [dx] [ax] modify exact []
#else
#pragma aux cmslpt_output parm [edx] [eax] modify exact []
#endif
