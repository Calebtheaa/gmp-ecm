/* Auxiliary functions for GMP-ECM.

  Copyright 2001, 2002, 2003 Paul Zimmermann and Alexander Kruppa.

  This program is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by the
  Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  more details.

  You should have received a copy of the GNU General Public License along
  with this program; see the file COPYING.  If not, write to the Free
  Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include "gmp.h"
#include "ecm.h"

/******************************************************************************
*                                                                             *
*                            Auxiliary functions                              *
*                                                                             *
******************************************************************************/

/* returns the number of decimal digits of n */
unsigned int
nb_digits (const mpz_t n)
{
   unsigned int size;
   char *str;
 
   str = mpz_get_str (NULL, 10, n);
   size = strlen (str);
   FREE (str, size + 1);
   return size;
}

unsigned int
gcd (unsigned int a, unsigned int b)
{
  unsigned int t;

  while (b != 0)
    {
      t = a % b;
      a = b;
      b = t;
    }

  return a;
}

void 
mpz_sub_si (mpz_t r, mpz_t s, int i)
{
  if (i >= 0)
    mpz_sub_ui (r, s, (unsigned int) i);
  else
    mpz_add_ui (r, s, (unsigned int) (-i));
}

/* returns ceil(log(n)/log(2)) */
unsigned int
ceil_log2 (unsigned int n)
{
  unsigned int k;

  /* f(1)=0, f(n)=1+f((n+1)/2) */
  for (k=0; n>1; n = (n + 1) / 2, k++);
  return k;
}

/* Return user CPU time measured in milliseconds. Thanks to Torbjorn. */
#if defined (ANSIONLY) || defined (USG) || defined (__SVR4) || defined (_UNICOS) || defined(__hpux)

int
cputime ()
{
  return (int) ((double) clock () * 1000 / CLOCKS_PER_SEC);
}
#else
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>

int
cputime ()
{
  struct rusage rus;

  getrusage (0, &rus);
  return rus.ru_utime.tv_sec * 1000 + rus.ru_utime.tv_usec / 1000;
}
#endif

/* Produces a random unsigned int value */
#if defined (_MSC_VER) || defined (__MINGW32__)
#include <windows.h>
unsigned int 
get_random_ui ()
{
  SYSTEMTIME tv;
  GetSystemTime(&tv);
  /* This gets us 27 bits of somewhat "random" data based on the time clock.
     It would probably do the program justice if a better random mixing was done
     in the non-MinGW get_random_ui if /dev/random does not exist */
  return ((tv.wHour<<22)+(tv.wMinute<<16)+(tv.wSecond<<10)+tv.wMilliseconds) ^
         ((tv.wMilliseconds<<17)+(tv.wMinute<<11)+(tv.wHour<<6)+tv.wSecond);
}
#else
unsigned int 
get_random_ui ()
{
  FILE *rndfd;
  struct timeval tv;
  unsigned int t;

  /* Try /dev/urandom */
  rndfd = fopen ("/dev/urandom", "r");
  if (rndfd != NULL)
    {
      if (fread (&t, sizeof(unsigned int), 1, rndfd) == 1)
        {
#ifdef DEBUG
          printf ("Got seed for RNG from /dev/urandom\n");
#endif
          fclose (rndfd);
          return t;
        }
      fclose (rndfd);
    }

  if (gettimeofday (&tv, NULL) == 0)
    {
#ifdef DEBUG
      printf ("Got seed for RNG from gettimeofday()\n");
#endif
      return tv.tv_sec + tv.tv_usec;
    }

#ifdef DEBUG
  printf ("Got seed for RNG from time()+getpid()\n");
#endif
  return time (NULL) + getpid ();
}
#endif
