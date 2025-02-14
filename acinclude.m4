dnl Various routines adapted from gmp-4.1.4

define(X86_PATTERN,
[[i?86*-*-* | k[5-8]*-*-* | pentium*-*-* | athlon-*-* | viac3*-*-*]])


dnl  GMP_INIT([M4-DEF-FILE])
dnl  -----------------------
dnl  Initializations for GMP config.m4 generation.
dnl
dnl  FIXME: The generated config.m4 doesn't get recreated by config.status.
dnl  Maybe the relevant "echo"s should go through AC_CONFIG_COMMANDS.

AC_DEFUN([GMP_INIT],
[ifelse([$1], , gmp_configm4=config.m4, gmp_configm4="[$1]")
gmp_tmpconfigm4=cnfm4.tmp
gmp_tmpconfigm4i=cnfm4i.tmp
gmp_tmpconfigm4p=cnfm4p.tmp
rm -f $gmp_tmpconfigm4 $gmp_tmpconfigm4i $gmp_tmpconfigm4p
])


dnl  GMP_FINISH
dnl  ----------
dnl  Create config.m4 from its accumulated parts.
dnl
dnl  __CONFIG_M4_INCLUDED__ is used so that a second or subsequent include
dnl  of config.m4 is harmless.
dnl
dnl  A separate ifdef on the angle bracket quoted part ensures the quoting
dnl  style there is respected.  The basic defines from gmp_tmpconfigm4 are
dnl  fully quoted but are still put under an ifdef in case any have been
dnl  redefined by one of the m4 include files.
dnl
dnl  Doing a big ifdef within asm-defs.m4 and/or other macro files wouldn't
dnl  work, since it'd interpret parentheses and quotes in dnl comments, and
dnl  having a whole file as a macro argument would overflow the string space
dnl  on BSD m4.

AC_DEFUN([GMP_FINISH],
[AC_REQUIRE([GMP_INIT])
echo "creating $gmp_configm4"
echo ["d""nl $gmp_configm4.  Generated automatically by configure."] > $gmp_configm4
if test -f $gmp_tmpconfigm4; then
  echo ["changequote(<,>)"] >> $gmp_configm4
  echo ["ifdef(<__CONFIG_M4_INCLUDED__>,,<"] >> $gmp_configm4
  cat $gmp_tmpconfigm4 >> $gmp_configm4
  echo [">)"] >> $gmp_configm4
  echo ["changequote(\`,')"] >> $gmp_configm4
  rm $gmp_tmpconfigm4
fi
echo ["ifdef(\`__CONFIG_M4_INCLUDED__',,\`"] >> $gmp_configm4
if test -f $gmp_tmpconfigm4i; then
  cat $gmp_tmpconfigm4i >> $gmp_configm4
  rm $gmp_tmpconfigm4i
fi
if test -f $gmp_tmpconfigm4p; then
  cat $gmp_tmpconfigm4p >> $gmp_configm4
  rm $gmp_tmpconfigm4p
fi
echo ["')"] >> $gmp_configm4
echo ["define(\`__CONFIG_M4_INCLUDED__')"] >> $gmp_configm4
])


dnl  GMP_PROG_M4
dnl  -----------
dnl  Find a working m4, either in $PATH or likely locations, and setup $M4
dnl  and an AC_SUBST accordingly.  If $M4 is already set then it's a user
dnl  choice and is accepted with no checks.  GMP_PROG_M4 is like
dnl  AC_PATH_PROG or AC_CHECK_PROG, but tests each m4 found to see if it's
dnl  good enough.
dnl 
dnl  See mpn/asm-defs.m4 for details on the known bad m4s.

AC_DEFUN([GMP_PROG_M4],
[AC_ARG_VAR(M4,[m4 macro processor])
AC_CACHE_CHECK([for suitable m4],
                gmp_cv_prog_m4,
[if test -n "$M4"; then
  gmp_cv_prog_m4="$M4"
else
  cat >conftest.m4 <<\EOF
dnl  Must protect this against being expanded during autoconf m4!
dnl  Dont put "dnl"s in this as autoconf will flag an error for unexpanded
dnl  macros.
[define(dollarhash,``$][#'')ifelse(dollarhash(x),1,`define(t1,Y)',
``bad: $][# not supported (SunOS /usr/bin/m4)
'')ifelse(eval(89),89,`define(t2,Y)',
`bad: eval() doesnt support 8 or 9 in a constant (OpenBSD 2.6 m4)
')ifelse(t1`'t2,YY,`good
')]
EOF
dnl ' <- balance the quotes for emacs sh-mode
  echo "trying m4" >&AC_FD_CC
  gmp_tmp_val=`(m4 conftest.m4) 2>&AC_FD_CC`
  echo "$gmp_tmp_val" >&AC_FD_CC
  if test "$gmp_tmp_val" = good; then
    gmp_cv_prog_m4="m4"
  else
    IFS="${IFS= 	}"; ac_save_ifs="$IFS"; IFS=":"
dnl $ac_dummy forces splitting on constant user-supplied paths.
dnl POSIX.2 word splitting is done only on the output of word expansions,
dnl not every word.  This closes a longstanding sh security hole.
    ac_dummy="$PATH:/usr/5bin"
    for ac_dir in $ac_dummy; do
      test -z "$ac_dir" && ac_dir=.
      echo "trying $ac_dir/m4" >&AC_FD_CC
      gmp_tmp_val=`($ac_dir/m4 conftest.m4) 2>&AC_FD_CC`
      echo "$gmp_tmp_val" >&AC_FD_CC
      if test "$gmp_tmp_val" = good; then
        gmp_cv_prog_m4="$ac_dir/m4"
        break
      fi
    done
    IFS="$ac_save_ifs"
    if test -z "$gmp_cv_prog_m4"; then
      AC_MSG_ERROR([No usable m4 in \$PATH or /usr/5bin (see config.log for reasons).])
    fi
  fi
  rm -f conftest.m4
fi])
M4="$gmp_cv_prog_m4"
AC_SUBST(M4)
])


dnl  GMP_DEFINE(MACRO, DEFINITION [, LOCATION])
dnl  ------------------------------------------
dnl  Define M4 macro MACRO as DEFINITION in temporary file.
dnl
dnl  If LOCATION is `POST', the definition will appear after any include()
dnl  directives inserted by GMP_INCLUDE.  Mind the quoting!  No shell
dnl  variables will get expanded.  Don't forget to invoke GMP_FINISH to
dnl  create file config.m4.  config.m4 uses `<' and '>' as quote characters
dnl  for all defines.

AC_DEFUN([GMP_DEFINE],
[AC_REQUIRE([GMP_INIT])
echo ['define(<$1>, <$2>)'] >>ifelse([$3], [POST],
                              $gmp_tmpconfigm4p, $gmp_tmpconfigm4)
])


dnl  GMP_TRY_ASSEMBLE(asm-code,[action-success][,action-fail])
dnl  ----------------------------------------------------------
dnl  Attempt to assemble the given code.
dnl  Do "action-success" if this succeeds, "action-fail" if not.
dnl
dnl  conftest.o and conftest.out are available for inspection in
dnl  "action-success".  If either action does a "break" out of a loop then
dnl  an explicit "rm -f conftest*" will be necessary.
dnl
dnl  This is not unlike AC_TRY_COMPILE, but there's no default includes or
dnl  anything in "asm-code", everything wanted must be given explicitly.

AC_DEFUN([GMP_TRY_ASSEMBLE],
[cat >conftest.s <<EOF
[$1]
EOF
gmp_assemble="$CCAS $CCASFLAGS -c conftest.s >conftest.out 2>&1"
if AC_TRY_EVAL(gmp_assemble); then
  cat conftest.out >&AC_FD_CC
  ifelse([$2],,:,[$2])
else
  cat conftest.out >&AC_FD_CC
  echo "configure: failed program was:" >&AC_FD_CC
  cat conftest.s >&AC_FD_CC
  ifelse([$3],,:,[$3])
fi
rm -f conftest*
])


dnl  GMP_ASM_TYPE
dnl  ------------
dnl  Can we say ".type", and how?
dnl
dnl  For i386 GNU/Linux ELF systems, and very likely other ELF systems,
dnl  .type and .size are important on functions in shared libraries.  If
dnl  .type is omitted and the mainline program references that function then
dnl  the code will be copied down to the mainline at load time like a piece
dnl  of data.  If .size is wrong or missing (it defaults to 4 bytes or some
dnl  such) then incorrect bytes will be copied and a segv is the most likely
dnl  result.  In any case such copying is not what's wanted, a .type
dnl  directive will ensure a PLT entry is used.
dnl
dnl  In GMP the assembler functions are normally only used from within the
dnl  library (since most programs are not interested in the low level
dnl  routines), and in those circumstances a missing .type isn't fatal,
dnl  letting the problem go unnoticed.  tests/mpn/t-asmtype.c aims to check
dnl  for it.

AC_DEFUN([GMP_ASM_TYPE],
[AC_CACHE_CHECK([for assembler .type directive],
                gmp_cv_asm_type,
[gmp_cv_asm_type=
for gmp_tmp_prefix in @ \# %; do
  GMP_TRY_ASSEMBLE([	.type	sym,${gmp_tmp_prefix}function],
    [if grep "\.type pseudo-op used outside of \.def/\.endef ignored" conftest.out >/dev/null; then : ;
    else
      gmp_cv_asm_type=".type	\$][1,${gmp_tmp_prefix}\$][2"
      break
    fi])
done
rm -f conftest*
])
echo ["define(<TYPE>, <$gmp_cv_asm_type>)"] >> $gmp_tmpconfigm4
])


dnl  GMP_ASM_GLOBL
dnl  -------------
dnl  Can we say `.global'?

AC_DEFUN([GMP_ASM_GLOBL],
[AC_CACHE_CHECK([how to export a symbol],
                gmp_cv_asm_globl,
[case $host in
  *-*-hpux*) gmp_cv_asm_globl=".export" ;;
  *)         gmp_cv_asm_globl=".globl" ;;
esac
])
echo ["define(<GLOBL>, <$gmp_cv_asm_globl>)"] >> $gmp_tmpconfigm4
])


dnl  GMP_ASM_TEXT
dnl  ------------

AC_DEFUN([GMP_ASM_TEXT],
[AC_CACHE_CHECK([how to switch to text section],
                gmp_cv_asm_text,
[case $host in
  *-*-aix*)  gmp_cv_asm_text=[".csect .text[PR]"] ;;
  *-*-hpux*) gmp_cv_asm_text=".code" ;;
  *)         gmp_cv_asm_text=".text" ;;
esac
])
echo ["define(<TEXT>, <$gmp_cv_asm_text>)"] >> $gmp_tmpconfigm4
])


dnl  GMP_ASM_LABEL_SUFFIX
dnl  --------------------
dnl  Should a label have a colon or not?

AC_DEFUN([GMP_ASM_LABEL_SUFFIX],
[AC_CACHE_CHECK([what assembly label suffix to use],
                gmp_cv_asm_label_suffix,
[case $host in 
  # Empty is only for the HP-UX hppa assembler; hppa gas requires a colon.
  *-*-hpux*) gmp_cv_asm_label_suffix=  ;;
  *)         gmp_cv_asm_label_suffix=: ;;
esac
])
echo ["define(<LABEL_SUFFIX>, <\$][1$gmp_cv_asm_label_suffix>)"] >> $gmp_tmpconfigm4
])


dnl  ECM_INCLUDE(FILE)
dnl  ---------------------
dnl  Add an include_mpn() to config.m4.  FILE should be a path
dnl  relative to the main source directory, for example
dnl
dnl      ECM_INCLUDE(`powerpc64/defs.m4')
dnl

AC_DEFUN([ECM_INCLUDE],
[AC_REQUIRE([GMP_INIT])
echo ["include($1)"] >> $gmp_tmpconfigm4
])


dnl  GMP_ASM_UNDERSCORE
dnl  ------------------
dnl  Determine whether global symbols need to be prefixed with an underscore.
dnl  A test program is linked to an assembler module with or without an
dnl  underscore to see which works.
dnl
dnl  This method should be more reliable than grepping a .o file or using
dnl  nm, since it corresponds to what a real program is going to do.  Note
dnl  in particular that grepping doesn't work with SunOS 4 native grep since
dnl  that grep seems to have trouble with '\0's in files.

AC_DEFUN([GMP_ASM_UNDERSCORE],
[AC_REQUIRE([GMP_ASM_TEXT])
AC_REQUIRE([GMP_ASM_GLOBL])
AC_REQUIRE([GMP_ASM_LABEL_SUFFIX])
AC_CACHE_CHECK([if globals are prefixed by underscore], 
               gmp_cv_asm_underscore,
[cat >conftes1.c <<EOF
#ifdef __cplusplus
extern "C" { void underscore_test(); }
#else
extern void underscore_test();
#endif
int main () { underscore_test(); return 1; }
EOF
for tmp_underscore in "" "_"; do
  cat >conftes2.s <<EOF
      	$gmp_cv_asm_text
	$gmp_cv_asm_globl ${tmp_underscore}underscore_test
${tmp_underscore}underscore_test$gmp_cv_asm_label_suffix
EOF
  case $host in
  *-*-aix*)
    cat >>conftes2.s <<EOF
	$gmp_cv_asm_globl .${tmp_underscore}underscore_test
.${tmp_underscore}underscore_test$gmp_cv_asm_label_suffix
EOF
    ;;
  esac
  gmp_compile="$CC $CFLAGS $CPPFLAGS -c conftes1.c >&AC_FD_CC && $CCAS $CCASFLAGS -c conftes2.s >&AC_FD_CC && $CC $CFLAGS $LDFLAGS conftes1.$OBJEXT conftes2.$OBJEXT >&AC_FD_CC"
  if AC_TRY_EVAL(gmp_compile); then
    eval tmp_result$tmp_underscore=yes
  else
    eval tmp_result$tmp_underscore=no
  fi
done

if test $tmp_result_ = yes; then
  if test $tmp_result = yes; then
    AC_MSG_ERROR([Test program unexpectedly links both with and without underscore.])
  else
    gmp_cv_asm_underscore=yes
  fi
else
  if test $tmp_result = yes; then
    gmp_cv_asm_underscore=no
  else
    AC_MSG_ERROR([Test program links neither with nor without underscore.])
  fi
fi
rm -f conftes1* conftes2* a.out
])
if test "$gmp_cv_asm_underscore" = "yes"; then
  GMP_DEFINE(GSYM_PREFIX, [_])
else
  GMP_DEFINE(GSYM_PREFIX, [])
fi    
])

# If we are not cross-compiling, do AC_RUN_IFELSE. If we are cross-compiling,
# do AC_COMPILE_IFELSE
AC_DEFUN([ECM_RUN_IFELSE], dnl
  [AC_RUN_IFELSE]([[$1]], [[$2]], [[$3]], dnl ok
    [[AC_COMPILE_IFELSE]]([[[$1]]], [[[$2]]], [[[$3]]]) dnl
  ) dnl
)

# A test program to check whether the compiler can compile SSE2 instructions 
# as inline assembly. If HAVE_SSE2 is defined, the code also includes
# emmintrin.h, which may need -sse2 to function
AC_DEFUN([ECM_C_INLINESSE2_PROG], dnl
[AC_LANG_PROGRAM([[#include <emmintrin.h>]], dnl
[[int v4[4] = {5,6,7,8};

  asm volatile (
    "movdqu %0, %%xmm0\n\t"
    "pmuludq %%xmm0, %%xmm0\n\t"
    "movdqu %%xmm0, %0\n\t"
    : "+m" (v4)
    : "r"(0)
    : "%xmm0"
  );
  if (v4[0] != 25 || v4[1] != 0 || v4[2] != 49 || v4[3] != 0) {
    return 1;
  }
]])])

dnl  NVCC_CHECK_COMPILE(body, flags, action-if-true, action-if-false)
dnl  Similiar to AC_LANG_PUSH(CUDA) AC_COMPILE_IFELSE($1+$2, $3, $4) AC_LANG_POP(CUDA)
dnl  Check if conftest.cu with <body> compiles with $NVCC $flags

m4_define([NVCC_CHECK_COMPILE],
[
   echo "$1" > conftest.cu
   $NVCC -c conftest.cu -o conftest.o $2 &> /dev/null
   ret=$?
   rm conftest.cu
   AS_IF([test "$ret" -eq "0"], [$3], [$4])
])

dnl  CU_CHECK_CUDA
dnl  Check if a GPU version is asked, for which GPU and where CUDA is install.
dnl  Includes are put in CUDA_INC_FLAGS
dnl  Libraries are put in CUDA_LIB_FLAGS
dnl  Path to nvcc is put in NVCC
dnl  the GPU architecture for which it is compiled is in GPU_ARCH

AC_DEFUN([CU_CHECK_CUDA],
[
# Is the GPU version requested?
AC_ARG_ENABLE(gpu,
  AS_HELP_STRING([--enable-gpu@<:@=GPU_ARCH@:>@],
                 [Build with support for CUDA stage 1, by default builds with all possible compute capabilities
                  to build with a single compute capability pass use --enable-gpu=XX [default=no]]),
  [ AS_IF([test "x$enableval" = "xno"],
    [ enable_gpu="no" ],
    [ enable_gpu="yes"
      AS_CASE(["x$enableval"],
        [ xyes ], [],
        [ x[[2-9]][[0-9]] ], [ WANTED_GPU_ARCH="$enableval" ],
        [ AC_MSG_ERROR([Didn't recognize GPU_ARCH="$enableval"]) ])
    ]) ])


AC_ARG_WITH(cuda,
  AS_HELP_STRING([--with-cuda=DIR],
                 [CUDA install directory [default=guessed]]),
  [ cuda_include=$withval/include
    # If $build_cpu contains "_64", append "lib64", else append "lib"
    AS_IF([echo $build_cpu | grep -q "_64"], 
      [cuda_lib=$withval/lib64],
      [cuda_lib=$withval/lib])
    cuda_bin=$withval/bin ])

AC_ARG_WITH(cuda_include,
  AS_HELP_STRING([--with-cuda-include=DIR],
                 [CUDA include directory [default=guessed]]),
  [ cuda_include=$withval ])

AC_ARG_WITH(cuda_lib,
  AS_HELP_STRING([--with-cuda-lib=DIR],
                 [CUDA lib directory [default=guessed]]),
  [ cuda_lib=$withval ])

AC_ARG_WITH(cuda_bin,
  AS_HELP_STRING([--with-cuda-bin=DIR],
                 [CUDA bin directory for nvcc [default=guessed]]),
  [ cuda_bin=$withval ])

AC_ARG_WITH(cuda_compiler, 
  AS_HELP_STRING([--with-cuda-compiler=DIR], 
            [a directory that contains a C and C++ compiler compatible with the CUDA compiler nvcc. If given, the value is used as '--compiler-bindir' argument for nvcc ]),
  [ cuda_compiler=$withval ])

AS_IF([test "x$enable_gpu" = "xyes" ],
  [
    AS_IF([test "x$cuda_include" != "x"],
      [
        AC_MSG_NOTICE([Using cuda.h from $cuda_include])
        AS_IF([test -d "$cuda_include"],
          [], 
          [ 
            AC_MSG_ERROR([Specified CUDA include directory "$cuda_include" does not exist])
          ])
        CFLAGS="-I$cuda_include $CFLAGS"
        CPPFLAGS="-I$cuda_include $CPPFLAGS"
        NVCCFLAGS="-I$cuda_include $NVCCFLAGS"
      ])
    AC_CHECK_HEADERS([cuda.h], [], AC_MSG_ERROR([required header file missing]))
    AC_MSG_CHECKING([that CUDA Toolkit version is at least 3.0])
    AC_RUN_IFELSE([AC_LANG_PROGRAM([
      [
        #include <stdio.h>
        #include <string.h>
        #include <cuda.h>
      ]],[[
        printf("(%d.%d) ", CUDA_VERSION/1000, (CUDA_VERSION/10) % 10);
        if (CUDA_VERSION < 3000)
          return 1;
        else
          return 0;
      ]])],
      [AC_MSG_RESULT([yes])],
      [
        AC_MSG_RESULT([no])
        AC_MSG_ERROR([a newer version of the CUDA Toolkit is needed])
      ],
      [
        AC_MSG_RESULT([cross-compiling: cannot test])
      ])

    CUDALIB="-lcudart -lstdc++"
    LIBS_BACKUP="$LIBS"
    LDFLAGS_BACKUP="$LDFLAGS"
    CUDARPATH=""
    AS_IF([test "x$cuda_lib" != "x"],
      [
        AC_MSG_NOTICE([Using CUDA dynamic library from $cuda_lib])
        AS_IF([test -d "$cuda_lib"],
          [], 
          [ 
            AC_MSG_ERROR([Specified CUDA lib directory "$cuda_lib" does not exist])
          ])
        CUDALDFLAGS="-L$cuda_lib"
        LDFLAGS="-L$cuda_lib $LDFLAGS"
        AS_CASE(["$host_os"], [*"linux"*], [ LDFLAGS="-Wl,-rpath,$cuda_lib $LDFLAGS" ])
        CUDARPATH="-R $cuda_lib"
      ])
    AC_CHECK_LIB([cuda], [cuInit], [], [AC_MSG_ERROR([Couldn't find CUDA lib])])
    LIBS="$CUDALIB $LIBS"
    AC_MSG_CHECKING([that CUDA Toolkit version and runtime version are the same])
    AC_RUN_IFELSE([AC_LANG_PROGRAM([
      [
        #include <stdio.h>
        #include <string.h>
        #include <cuda.h>
        #include <cuda_runtime.h>
      ]],[[
        int libversion;
        cudaError_t err;
        err = cudaRuntimeGetVersion (&libversion);
        if (err != cudaSuccess)
        {
          printf ("Could not get runtime version\n");
          printf ("Error msg: %s\n", cudaGetErrorString(err));
          return -1;
        }
        printf("(%d.%d/", CUDA_VERSION/1000, (CUDA_VERSION/10) % 10);
        printf("%d.%d) ", libversion/1000, (libversion/10) % 10);
        if (CUDA_VERSION == libversion)
          return 0;
        else
          return 1;
      ]])],
      [AC_MSG_RESULT([yes])],
      [
        AC_MSG_RESULT([no])
        AC_MSG_ERROR(['cuda.h' and 'cudart' library have different versions, you have to reinstall CUDA properly, or use the --with-cuda parameter to tell configure the path to the CUDA library and header you want to use])
      ],
      [
        AC_MSG_RESULT([cross-compiling: cannot test])
      ])

    AS_IF([test "x$cuda_bin" != "x"],
      [
        AC_MSG_NOTICE([Using nvcc compiler from from $cuda_bin])
        AS_IF([test -f "$cuda_bin/nvcc"],
          [
            NVCC="$cuda_bin/nvcc"
          ], 
          [ 
            AC_MSG_ERROR([Could not find nvcc in specified CUDA bin directory "$cuda_bin"])
          ])
      ],
      [
        AC_PATH_PROG(NVCC, nvcc, "no")
        AS_IF([test "x$NVCC" = "xno" ], [ AC_MSG_ERROR(nvcc not found) ])
      ])

    AS_IF([test "x$cuda_compiler" != "x" ], 
          [NVCCFLAGS=" --compiler-bindir $cuda_compiler NVCCFLAGS"])
 
    dnl check that gcc version is compatible with nvcc version
    dnl (seth) How is this checking if gcc and nvcc are compatible?
    AC_MSG_CHECKING([for compatibility between gcc and nvcc])
    NVCC_CHECK_COMPILE([], [$NVCCFLAGS],
      [AC_MSG_RESULT([yes])],
      [
        AC_MSG_RESULT([no])
        AC_MSG_ERROR(gcc version is not compatible with nvcc)
      ])
      
    dnl Check which GPU architecture nvcc knows
    GPU_ARCH=""
    m4_foreach_w([compute_capability], [30 32 35 37 50 52 53 60 61 62 70 72 75 80 86 87 90],
      [
        testcc=compute_capability
        AS_IF([test -z "$WANTED_GPU_ARCH" -o "$WANTED_GPU_ARCH" = "$testcc"],
          [
            AC_MSG_CHECKING([that nvcc know compute capability $testcc])
            NEW="--generate-code arch=compute_$testcc,code=sm_$testcc"
            NVCC_CHECK_COMPILE([], [$NVCCFLAGS --dryrun $NEW],
              [
                AC_MSG_RESULT([yes])
                GPU_ARCH="$GPU_ARCH $NEW"
                MIN_CC=${MIN_CC:-$testcc}
              ], [
                AC_MSG_RESULT([no])
              ])
          ])
      ])

    # Use JIT compilation of GPU code for forward compatibility
    AC_MSG_NOTICE([Setting MIN_CC=$MIN_CC  GPU_ARCH=$GPU_ARCH])

    AS_IF([test -z "$GPU_ARCH"],
        [AC_MSG_ERROR([No supported compute capabilities found])])

    dnl check that nvcc know ptx instruction madc
    AC_MSG_CHECKING([if nvcc knows ptx instruction madc])
    NVCC_CHECK_COMPILE(
      [
         __global__ void test (int *a, int b) {
         asm(\"mad.lo.cc.u32 %0, %0, %1, %1;\":
         \"+r\"(*a) : \"r\"(b));}
      ],
      [$NVCCFLAGS --generate-code arch=compute_${MIN_CC},code=compute_${MIN_CC}],
      [AC_MSG_RESULT([yes])],
      [
        AC_MSG_RESULT([no])
        AC_MSG_ERROR([nvcc does not recognize ptx instruction madc, you should upgrade it])
      ])

    AC_ARG_WITH(cgbn_include,
      AS_HELP_STRING([--with-cgbn-include=DIR], [CGBN include directory]),
      [
        cgbn_include=$withval
        AC_MSG_NOTICE([Using CGBN from $cgbn_include])
        AS_IF([test "x$with_cgbn_include" != "xno"],
          [
            AS_IF([test -d "$cgbn_include"],
              [],
              [AC_MSG_ERROR([Specified CGBN include directory "$cgbn_include" does not exist])])

            AC_MSG_CHECKING([if CGBN is present])

            dnl AC_CHECK_HEADER can't verify NVCC compilability hence NVCC_CHECK_COMPILE
            NVCC_CHECK_COMPILE(
              [
                #include <gmp.h>
                #include <cgbn.h>
              ],
              [-I$cgbn_include $GMPLIB],
              [AC_MSG_RESULT([yes])],
              [
                AC_MSG_RESULT([no])
                AC_MSG_ERROR([cgbn.h not found (check if /cgbn needed after <PATH>/include)])
              ]
            )
            AC_DEFINE([HAVE_CGBN_H], [1], [Define to 1 if cgbn.h exists])
            NVCCFLAGS="-I$with_cgbn_include $GMPLIB $NVCCFLAGS"
            want_cgbn="yes"
        ])
      ])

    LIBS="$LIBS_BACKUP"
    LDFLAGS="$LDFLAGS_BACKUP"

    NVCCFLAGS="$NVCCFLAGS $GPU_ARCH"
    CFLAGS="$CFLAGS -DWITH_GPU"
    CPPFLAGS="$CPPFLAGS -DWITH_GPU"

    NVCCFLAGS="$NVCCFLAGS --ptxas-options=-v"
    NVCCFLAGS="$NVCCFLAGS --compiler-options -fno-strict-aliasing"
    # If debug flag is set apply debugging compilation flags,
    # otherwise build compilation flags
    AS_IF([test "x$DEBUG" = "xtrue"],
      [
        #NVCCFLAGS="$NVCCFLAGS -keep -keep-dir gputmp"
        NVCCFLAGS="$NVCCFLAGS -g"
      ],
      [
        NVCCFLAGS="$NVCCFLAGS -O2"
      ])

  ])
#Set this conditional if cuda is wanted
AM_CONDITIONAL([WANT_GPU], [test "x$enable_gpu" = "xyes" ])
#Set this conditional if cuda & cgbn_include
AM_CONDITIONAL([WANT_CGBN], [test "x$want_cgbn" = "xyes" ])

AC_SUBST(NVCC)
AC_SUBST(NVCCFLAGS)
AC_SUBST(CUDALIB)
AC_SUBST(CUDALDFLAGS)
AC_SUBST(CUDARPATH)

])
