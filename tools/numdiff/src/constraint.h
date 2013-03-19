#ifndef CONSTRAINT_H
#define CONSTRAINT_H

/*
 o---------------------------------------------------------------------o
 |
 | Numdiff
 |
 | Copyright (c) 2012+ laurent.deniau@cern.ch
 | Gnu General Public License
 |
 o---------------------------------------------------------------------o
  
   Purpose:
     create constraints content
     print, scan constraints from file
 
 o---------------------------------------------------------------------o
*/

#include <stdio.h>
#include <string.h>
#include "slice.h"
#include "error.h"

// ----- constants

enum eps_cmd {
  eps_invalid =   0u,  // invalid command

// must be firsts (weak commands)
  eps_abs    =    1u,  // absolute eps
  eps_rel    =    2u,  // relative eps
  eps_dig    =    4u,  // relative input eps
  eps_equ    =    8u,  // equal string
  eps_ign    =   16u,  // ignore value
  eps_any    =   32u,  // any qualifier

// intermediate (other commands)
  eps_omit   =   64u,  // omit indentifier
  eps_trace  =  128u,  // trace rule

// must be lasts (strong commands)
  eps_skip   =  256u,  // skip line
  eps_goto   =  512u,  // goto line
  eps_last,

// unions
  eps_dra     =  eps_abs|eps_rel|eps_dig
};

// ----- types

struct eps {
  enum eps_cmd cmd;
  double dig, rel, abs;
  char   tag[48];
};

struct constraint {
  struct slice row;
  struct slice col;
  struct eps   eps;
  int          line;
};

// ----- interface

#define T struct constraint

static inline struct eps
eps_init(enum eps_cmd cmd, double val)
{
  ensure(cmd > eps_invalid && cmd < eps_last, "invalid eps command");
  return (struct eps) { cmd, cmd&eps_dig ? val : 0, cmd&eps_rel ? val : 0, cmd&eps_abs ? val : 0, {0} };
}

static inline struct eps
eps_initNum(enum eps_cmd cmd, double dig, double rel, double abs)
{
  ensure(cmd > eps_invalid && cmd < eps_last, "invalid eps command");
  return (struct eps) { cmd, dig, rel, abs, {0} };
}

static inline struct eps
eps_initTag(enum eps_cmd cmd, const char *tag)
{
  ensure((cmd & eps_goto) || (cmd & eps_omit), "invalid eps goto or omit command");
  struct eps eps = (struct eps) { .cmd = cmd };
  enum { sz = sizeof eps.tag };
  strncpy(eps.tag, tag, sz); eps.tag[sz-1] = 0;
  return eps;
}

static inline T
constraint_init(const struct slice row, const struct slice col, const struct eps eps, int line)
{
  return (T){ row, col, eps, line };
}

void constraint_print(const T* cst, FILE *out);
void constraint_scan (      T* cst, FILE *in, int *row);

#undef T

#endif

