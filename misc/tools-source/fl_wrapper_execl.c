/*
 *  Copyright (C) 1991, 92, 94, 97, 98, 99 Free Software Foundation, Inc.
 *  This file is part of the GNU C Library.
 *
 *  --- NO-ROCK-COPYRIGHT-NOTE ---
 *
 *  glibc-2.2.5/posix/execl.c
 */

/* Execute PATH with all arguments after PATH until
   a NULL pointer and environment from `environ'.  */
int
execl (const char *path, const char *arg, ...)
{
  size_t argv_max = 1024;
  const char **argv = alloca (argv_max * sizeof (const char *));
  unsigned int i;
  va_list args;

  argv[0] = arg;

  va_start (args, arg);
  i = 0;
  while (argv[i++] != NULL)
    {
      if (i == argv_max)
	{
	  const char **nptr = alloca ((argv_max *= 2) * sizeof (const char *));

#ifndef _STACK_GROWS_UP
	  if ((char *) nptr + argv_max == (char *) argv)
	    {
	      /* Stack grows down.  */
	      argv = (const char **) memcpy (nptr, argv,
					     i * sizeof (const char *));
	      argv_max += i;
	    }
	  else
#endif
#ifndef _STACK_GROWS_DOWN
	    if ((char *) argv + i == (char *) nptr)
	    /* Stack grows up.  */
	    argv_max += i;
	  else
#endif
	    /* We have a hole in the stack.  */
	    argv = (const char **) memcpy (nptr, argv,
					   i * sizeof (const char *));
	}

      argv[i] = va_arg (args, const char *);
    }
  va_end (args);

  return execve (path, (char *const *) argv, __environ);
}

/*
 *  Copyright (C) 1991, 92, 94, 97, 98, 99 Free Software Foundation, Inc.
 *  This file is part of the GNU C Library.
 *
 *  glibc-2.2.5/posix/execle.c
 */

/* Execute PATH with all arguments after PATH until a NULL pointer,
   and the argument after that for environment.  */
int
execle (const char *path, const char *arg, ...)
{
  size_t argv_max = 1024;
  const char **argv = alloca (argv_max * sizeof (const char *));
  const char *const *envp;
  unsigned int i;
  va_list args;
  argv[0] = arg;

  va_start (args, arg);
  i = 0;
  while (argv[i++] != NULL)
    {
      if (i == argv_max)
	{
	  const char **nptr = alloca ((argv_max *= 2) * sizeof (const char *));

#ifndef _STACK_GROWS_UP
	  if ((char *) nptr + argv_max == (char *) argv)
	    {
	      /* Stack grows down.  */
	      argv = (const char **) memcpy (nptr, argv,
					     i * sizeof (const char *));
	      argv_max += i;
	    }
	  else
#endif
#ifndef _STACK_GROWS_DOWN
	    if ((char *) argv + i == (char *) nptr)
	    /* Stack grows up.  */
	    argv_max += i;
	  else
#endif
	    /* We have a hole in the stack.  */
	    argv = (const char **) memcpy (nptr, argv,
					   i * sizeof (const char *));
	}

      argv[i] = va_arg (args, const char *);
    }

  envp = va_arg (args, const char *const *);
  va_end (args);

  return execve (path, (char *const *) argv, (char *const *) envp);
}

/*
 *  Copyright (C) 1991, 92, 94, 97, 98, 99 Free Software Foundation, Inc.
 *  This file is part of the GNU C Library.
 *
 *  glibc-2.2.5/posix/execlp.c
 */

/* Execute FILE, searching in the `PATH' environment variable if
   it contains no slashes, with all arguments after FILE until a
   NULL pointer and environment from `environ'.  */
int
execlp (const char *file, const char *arg, ...)
{
  size_t argv_max = 1024;
  const char **argv = alloca (argv_max * sizeof (const char *));
  unsigned int i;
  va_list args;

  argv[0] = arg;

  va_start (args, arg);
  i = 0;
  while (argv[i++] != NULL)
    {
      if (i == argv_max)
	{
	  const char **nptr = alloca ((argv_max *= 2) * sizeof (const char *));

#ifndef _STACK_GROWS_UP
	  if ((char *) nptr + argv_max == (char *) argv)
	    {
	      /* Stack grows down.  */
	      argv = (const char **) memcpy (nptr, argv,
					     i * sizeof (const char *));
	      argv_max += i;
	    }
	  else
#endif
#ifndef _STACK_GROWS_DOWN
	    if ((char *) argv + i == (char *) nptr)
	    /* Stack grows up.  */
	    argv_max += i;
	  else
#endif
	    /* We have a hole in the stack.  */
	    argv = (const char **) memcpy (nptr, argv,
					   i * sizeof (const char *));
	}

      argv[i] = va_arg (args, const char *);
    }
  va_end (args);

  return execvp (file, (char *const *) argv);
}

/*
 *  Copyright (C) 1991, 92, 94, 97, 98, 99 Free Software Foundation, Inc.
 *  This file is part of the GNU C Library.
 *
 *  glibc-2.2.5/posix/execvp.c
 */

/* The file is accessible but it is not an executable file.  Invoke
   the shell to interpret it as a script.  */
static void
script_execute (const char *file, char *const argv[])
{
  /* Count the arguments.  */
  int argc = 0;
  while (argv[argc++])
    ;

  /* Construct an argument list for the shell.  */
  {
    char *new_argv[argc + 1];
    new_argv[0] = (char *) "/bin/sh";
    new_argv[1] = (char *) file;
    while (argc > 1)
      {
	new_argv[argc] = argv[argc - 1];
	--argc;
      }

    /* Execute the shell.  */
    execve (new_argv[0], new_argv, __environ);
  }
}


/* Execute FILE, searching in the `PATH' environment variable if it contains
   no slashes, with arguments ARGV and environment from `environ'.  */
int
execvp (file, argv)
     const char *file;
     char *const argv[];
{
  if (*file == '\0')
    {
      /* We check the simple case first. */
      errno = ENOENT;
      return -1;
    }

  if (strchr (file, '/') != NULL)
    {
      /* Don't search when it contains a slash.  */
      execve (file, argv, __environ);

      if (errno == ENOEXEC)
	script_execute (file, argv);
    }
  else
    {
      int got_eacces = 0;
      char *path, *p, *name;
      size_t len;
      size_t pathlen;

      path = getenv ("PATH");
      if (path == NULL)
	{
	  /* There is no `PATH' in the environment.
	     The default search path is the current directory
	     followed by the path `confstr' returns for `_CS_PATH'.  */
	  len = confstr (_CS_PATH, (char *) NULL, 0);
	  path = (char *) alloca (1 + len);
	  path[0] = ':';
	  (void) confstr (_CS_PATH, path + 1, len);
	}

      len = strlen (file) + 1;
      pathlen = strlen (path);
      name = alloca (pathlen + len + 1);
      /* Copy the file name at the top.  */
      name = (char *) memcpy (name + pathlen + 1, file, len);
      /* And add the slash.  */
      *--name = '/';

      p = path;
      do
	{
	  char *startp;

	  path = p;
	  p = strchrnul (path, ':');

	  if (p == path)
	    /* Two adjacent colons, or a colon at the beginning or the end
	       of `PATH' means to search the current directory.  */
	    startp = name + 1;
	  else
	    startp = (char *) memcpy (name - (p - path), path, p - path);

	  /* Try to execute this name.  If it works, execv will not return.  */
	  execve (startp, argv, __environ);

	  if (errno == ENOEXEC)
	    script_execute (startp, argv);

	  switch (errno)
	    {
	    case EACCES:
	      /* Record the we got a `Permission denied' error.  If we end
		 up finding no executable we can use, we want to diagnose
		 that we did find one but were denied access.  */
	      got_eacces = 1;
	    case ENOENT:
	    case ESTALE:
	    case ENOTDIR:
	      /* Those errors indicate the file is missing or not executable
		 by us, in which case we want to just try the next path
		 directory.  */
	      break;

	    default:
	      /* Some other error means we found an executable file, but
		 something went wrong executing it; return the error to our
		 caller.  */
	      return -1;
	    }
	}
      while (*p++ != '\0');

      /* We tried every element and none of them worked.  */
      if (got_eacces)
	/* At least one failure was due to permissions, so report that
           error.  */
	errno = EACCES;
    }

  /* Return the error from the last attempt (probably ENOENT).  */
  return -1;
}
