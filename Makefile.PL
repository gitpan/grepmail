#!/usr/bin/perl
# use perl                                  -*- mode: Perl; -*-

use strict;

use ExtUtils::MakeMaker;

require 5.004;

# --------------------------------------------------------------------------

sub GetVersionPreference
{
  print <<'  EOF';
Two versions of grepmail are included in this distribution:
1) grepmail.DP uses Date::Parse, quick parsing engine.
2) grepmail.DM uses Date::Manip, a more flexible date parsing module that has
   better error checking than Date::Parse, but which causes grepmail to run
   about 60% slower. Date::Manip understands leap years and support date
   specifications like "2nd Thursday in July".

  EOF

  print 'Which do you prefer? ';

  my $version;

  {
    my $choice;
    while (($choice ne '1') && ($choice ne '2'))
    {
      $choice = <STDIN>;
      chomp $choice;
      print "1 or 2, please: " unless $choice eq '1' || $choice eq '2';
    }

    $version = 'grepmail.DP' if $choice eq '1';
    $version = 'grepmail.DM' if $choice eq '2';
  }

  return $version;
}

# --------------------------------------------------------------------------

my @exe_files;
my %prereqs;

if ($ARGV[0] eq 'dist')
{
  @exe_files = qw(grepmail.DP grepmail.DM);
  %prereqs = ('Date::Manip' => 0,'Date::Parse' => 0);
}
else
{
  my $version = GetVersionPreference;
  system("cp $version grepmail");

  @exe_files = ('grepmail');
  %prereqs = ('Date::Manip' => 0) if $version eq 'grepmail.DM';
  %prereqs = ('Date::Parse' => 0) if $version eq 'grepmail.DP';
}

WriteMakefile(
  # For debugging
  #'NOECHO' => '',
  'NAME'  => 'grepmail',
  # finds $VERSION
  'VERSION_FROM' => $exe_files[0],
  #'VERSION' => $VERSION,

  'dist'  => { COMPRESS => 'gzip -9', SUFFIX => 'gz' },
  'EXE_FILES' => \@exe_files,
  'PREREQ_PM' => \%prereqs,
);
