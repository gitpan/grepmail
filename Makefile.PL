#!/usr/bin/perl
# use perl                                  -*- mode: Perl; -*-

use strict;

use ExtUtils::MakeMaker;

require 5.004;

# --------------------------------------------------------------------------

WriteMakefile(
  # For debugging
  #'NOECHO' => '',
  'NAME'  => 'grepmail',
  # finds $VERSION
  'VERSION_FROM' => 'grepmail',
  #'VERSION' => $VERSION,

  'dist'  => { COMPRESS => 'gzip -9', SUFFIX => 'gz' },
  'EXE_FILES' => ['grepmail'],
  'PREREQ_PM' => {'Date::Parse' => 0},
);
