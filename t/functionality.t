#!/usr/bin/perl

# These tests operate on a mail archive I found on the web at
# http://el.www.media.mit.edu/groups/el/projects/handy-board/mailarc.txt
# and then broke into pieces

# You must have bzip2 and gunzip installed for all the tests to work.

# The tested version of grepmail is assumed to be in the current directory.
# Any differences between the expected (t/results/test#.real) and actual
# (t/results/test#.out) outputs are stored in test#.diff in the current
# directory.

use strict;
use Test;

my @tests = (
'grepmail library -d "before July 9 1998" t/mailarc-1.txt',
'grepmail -v "(library|job)" t/mailarc-1.txt',
'grepmail -b mime t/mailarc-1.txt',
'grepmail -h Wallace t/mailarc-1.txt',
'grepmail -h "^From.*aarone" t/mailarc-1.txt',
'grepmail -br library t/mailarc-1.txt t/mailarc-2.txt',
'grepmail -hb library t/mailarc-1.txt',
'grepmail -b library t/mailarc-1.txt',
'grepmail -h library t/mailarc-1.txt',
'grepmail library t/mailarc-1.txt',
'grepmail -hbv library t/mailarc-1.txt',
'grepmail -bv library t/mailarc-1.txt',
'grepmail -hv library t/mailarc-1.txt',
'grepmail -v library t/mailarc-1.txt',
'cat t/mailarc-1.txt | grepmail -v library',
'cat t/mailarc-2.txt.gz | grepmail -v library',
'grepmail -v library t/mailarc-2.txt.gz',
'grepmail -l library t/mailarc-1.txt t/mailarc-2.txt',
'grepmail -e library t/mailarc-1.txt',
'grepmail -e library -l t/mailarc-1.txt t/mailarc-2.txt',
'cat t/mailarc-2.txt.bz2 | grepmail -v library',
'grepmail -v library t/mailarc-2.txt.bz2',
'grepmail -d "before July 15 1998" t/mailarc-1.txt',
'grepmail library t/mailarc-2.txt.gz t/mailarc-1.txt',
'grepmail -h',
'grepmail -h',
'cat t/mailarc-2.txt.tz | grepmail library',
'grepmail library no_such_file',
'cat no_such_file 2>/dev/null | grepmail library',
'grepmail -d "after armageddon" library t/mailarc-1.txt',
'grepmail library -s 2000 t/mailarc-1.txt',
'grepmail library -u t/mailarc-1.txt',
'grepmail -u t/mailarc-1.txt',
'grepmail -bi imagecraft -u t/mailarc-1.txt',
);

# Tests for certain supported options.
my @date_parse = (23,25);
my @date_manip = (26);
my @bzip2 = (21,22);
my @gzip = (16,17,18,20,24);
my @tzip = (27);
my @error_cases = (28,29,30);

my $version = GetVersion();

my $bzip2 = 0;
my $gzip = 0;
my $tzip = 0;

{
  my $temp;

  # Save old STDERR and redirect temporarily to nothing. This will prevent the
  # test script from emitting a warning if the backticks can't find the
  # compression programs
  use vars qw(*OLDSTDERR);
  open OLDSTDERR,">&STDERR" or die "Can't save STDOUT: $!\n";
  open STDERR,">/dev/null" or die "Can't redirect STDOUT to /dev/null: $!\n";

  $temp = `bzip2 -h 2>&1`;
  $bzip2 = 1 if $temp =~ /usage/;

  $temp = `gzip -h 2>&1`;
  $gzip = 1 if $temp =~ /usage/;

  $temp = `tzip -h 2>&1`;
  $tzip = 1 if $temp =~ /usage/;

  open STDERR,">&OLDSTDERR" or die "Can't restore STDOUT: $!\n";
}

print "Testing $version version of grepmail.\n";

plan (tests => $#tests+1);

print "\n";

my $testNumber = 1;
foreach my $test (@tests)
{
  $test =~ s#grepmail#blib/script/grepmail#sg;
  print "$test\n";

  next if CheckSkip($testNumber);

  system "$test > t/results/test$testNumber.out 2>&1";

  if ($? && (!grep {$_ == $testNumber} @error_cases))
  {
    print "Error executing test.\n";
    ok(0);
    next;
  }

  my $diffstring = "diff t/results/test$testNumber.out t/results/test$testNumber.real";
  system "$diffstring > t/results/test$testNumber.diff";

  if ($? == 2)
  {
    print "Couldn't do diff.\n";

    ok(0);

    next;
  }

  my $numdiffs = `cat t/results/test$testNumber.diff | wc -l`;
  $numdiffs =~ s/[\n ]//g;
  $numdiffs = $numdiffs/2;

  if ($numdiffs != 0)
  {
    print "Failed, with $numdiffs differences.\n";
    print "  See t/results/test$testNumber.out and t/results/test$testNumber.diff.\n";
    ok(0);

    next;
  }

  if ($numdiffs == 0)
  {
    print "Succeeded.\n";
    ok(1);

#    unlink "t/results/test$testNumber.out";
    unlink "t/results/test$testNumber.diff";
  }
}
continue
{
  print "\n";
  $testNumber++;
}

# ---------------------------------------------------------------------------

sub GetVersion
{
  open CODE, "blib/script/grepmail" or die "Can't open grepmail script: $!\n";
  my $code = join '',<CODE>;
  close CODE;

  return 'Date::Manip' if $code =~ /require Date::Manip/s;
  return 'Date::Parse' if $code =~ /require Date::Parse/s;
}

# ---------------------------------------------------------------------------

sub CheckSkip
{
  my $testNumber = shift;

  if((grep {$_ == $testNumber} @date_parse) && $version eq 'Date::Parse')
  {
    print "Skipping test for Date::Parse version.\n";
    skip(1,1);
    return 1;
  }

  if((grep {$_ == $testNumber} @date_manip) && $version eq 'Date::Manip')
  {
    print "Skipping test for Date::Manip version\n";
    skip(1,1);
    return 1;
  }

  if((grep {$_ == $testNumber} @bzip2) && !$bzip2)
  {
    print "Skipping test using bzip2\n";
    skip(1,1);
    return 1;
  }

  if((grep {$_ == $testNumber} @gzip) && !$gzip)
  {
    print "Skipping test using gzip\n";
    skip(1,1);
    return 1;
  }

  if((grep {$_ == $testNumber} @tzip) && !$tzip)
  {
    print "Skipping test using tzip\n";
    skip(1,1);
    return 1;
  }

  return 0;
}
