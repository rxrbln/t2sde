/* xeviedemo.c */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <X11/Xlib.h>
#include <X11/Xproto.h>
#include <X11/X.h>
#include <X11/extensions/Xevie.h>
#include <X11/Xutil.h>
//#include <xorg/atKeynames.h>

#include <string>
#include <iostream>

// as long as our target has X.org 6.8 without the above header:
#define MIN_KEYCODE     8

#define KEY_KP_7         /* 7           Home      0x47  */   71 
#define KEY_KP_8         /* 8           Up        0x48  */   72 
#define KEY_KP_9         /* 9           PgUp      0x49  */   73 
#define KEY_KP_4         /* 4           Left      0x4b  */   75
#define KEY_KP_5         /* 5                     0x4c  */   76
#define KEY_KP_6         /* 6           Right     0x4d  */   77
#define KEY_KP_1         /* 1           End       0x4f  */   79
#define KEY_KP_2         /* 2           Down      0x50  */   80
#define KEY_KP_3         /* 3           PgDown    0x51  */   81
#define KEY_KP_0         /* 0           Insert    0x52  */   82
#define KEY_KP_Decimal   /* . (Decimal) Delete    0x53  */   83 
#define KEY_KP_Enter     /* Enter                 0x64  */  100
#define KEY_Enter        /* Enter                 0x1c  */   28

static void
print_key_event (XEvent *ev)
{
  XKeyEvent *key_ev;
  char buffer[20];
  int bufsize = 19;
  KeySym key;
  XComposeStatus compose;
  int char_count;
  
  key_ev = (XKeyEvent *)ev;

  printf ("        State: 0x%x KeyCode: 0x%x(0x%x)\n",
	  key_ev->state & ShiftMask,
	  key_ev->keycode, key_ev->keycode - MIN_KEYCODE);
  char_count = XLookupString(key_ev, buffer, bufsize, &key, &compose);
  buffer[char_count] = '\0';
  printf ("        Char Count: %d KeySym: 0x%x char: |%c|\n", char_count, key, buffer[0]);
}

void child(int)
{
   wait(0); // do not let zombies accumulate
}

int main (int argc, char **argv)
{
  Display* dpy;
  int major, minor;
  XEvent  event;
  XClientMessageEvent *xcme;
  int ret;
  int debug = 0;
  
  std::string str;

  signal (SIGCHLD, &child);

  /* simple argument parsing ... */
  char* script = 0;
  for (argv++; *argv; argv++)
  {
    if (!strcmp(*argv, "--script")) {
      argv++;
      if (*argv) {
        script = *argv;
      }
      else {
        std::cout << "--script needs an argument!" << std::endl;
        exit (1);
      }
    }
    else {
      std::cout << "unknown option: " << *argv << std::endl;
      exit (1);
    }
  }

  dpy = XOpenDisplay (NULL);
  XevieQueryVersion (dpy, &major, &minor);
  printf("major = %d, minor = %d\n", major, minor);
  if (XevieStart (dpy))
    printf("XevieStart(dpy) finished\n");
  else {
    printf("XevieStart(dpy) failed, only one client is allowed to do event interception\n");
    exit(1);
  }
  
  XevieSelectInput (dpy, KeyPressMask | KeyReleaseMask);
  Time last_time = 0;
  while (1) {
    int pass_thru = 1;
    int this_time;
    
    XNextEvent (dpy, &event);
    xcme = (XClientMessageEvent *)&event;
    /* for read-only users, send events back to Xserver immediately */
    switch (event.type)
      {
      case KeyPress:
	if (debug) {
	  printf(" KeyPress\n");
	  print_key_event (&event);
	}
	
	{
	  XKeyEvent *key_ev;
	  key_ev = (XKeyEvent *)&event;
	  this_time = key_ev->time;
	  if (!last_time)
	    last_time = this_time;
	  
	  if (this_time > last_time + 10 * 1000) {
	    if (debug)
	      std::cout << "Time difference too big, resetting buffer."
			<< std::endl;
	    str.clear();
		  last_time = this_time;
	  }
	  
	  char c = 0;
	  switch (key_ev->keycode - MIN_KEYCODE)
	    {
	    case KEY_KP_0: c = '0' ; break;
	    case KEY_KP_1: c = '1' ; break;
	    case KEY_KP_2: c = '2' ; break;
	    case KEY_KP_3: c = '3' ; break;
	    case KEY_KP_4: c = '4' ; break;
	    case KEY_KP_5: c = '5' ; break;
	    case KEY_KP_6: c = '6' ; break;
	    case KEY_KP_7: c = '7' ; break;
	    case KEY_KP_8: c = '8' ; break;
	    case KEY_KP_9: c = '9' ; break;
	    case KEY_Enter:
	      // take enter if we already have content - some b0rked
	      // USB keypads send a non _KP_
	      if (str.empty())
		break;
	      
	    case KEY_KP_Enter: 
	      if (!str.empty()) {
		if (script) {
                  const char* c_args[10];
                  const char** ca = c_args; *ca++ = script;
                  *ca++ = "-2"; // compatible with AV220 button encoding
                  *ca++ = str.c_str();
                  *ca = NULL;
                  pid_t pid = fork ();
                  if (pid == 0) {
                     execv(script, (char* const*)c_args);
                     std::cout << "Error executing script." << std::endl;
                     exit (1);
                  }
                }
                else
                  std::cout << str << std::endl;

		str.erase();
	      }
	      pass_thru = 0;
	      break;

	    case KEY_KP_Decimal:
	      str.clear();
	      pass_thru = 0;
	      break;
	    }

	  if (c != 0) {
	    str.push_back(c);
	    pass_thru = 0;
	  }
	}
	
	break;
	
      case KeyRelease:
	if (debug) printf(" KeyRelease\n");
	  
	break;
	
      case ClientMessage:
	printf("ClientMessage: <%s>\n", &xcme->data.b[1]);
	break;

      default:
	printf(" unknown event %x\n", event.type);
	break;
      }
    
    if (pass_thru) {
      XevieSendEvent (dpy, &event, XEVIE_UNMODIFIED);
    }
    else // record time to reset the accumulated buffer
      last_time = this_time;
  }
  XevieEnd (dpy);
  exit(0);
} 
