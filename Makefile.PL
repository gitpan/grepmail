#!/usr/bin/perl
# use perl                                  -*- mode: Perl; -*-

use strict;
use ExtUtils::MakeMaker;

require 5.004;

die "You don't need to specify options on the command line.\n"
  if $ARGV[0] =~ /^\w+=/;

my $use_fastreader = 1;

unless (@ARGV)
{
  $use_fastreader = Setup_Install();
}

my %makefile_attributes = Compute_Makefile_Attributes($use_fastreader);

WriteMakefile( %makefile_attributes );

# --------------------------------------------------------------------------

sub Setup_Install
{
  my $VERSION = shift;

  my ($install_type,$use_fastreader,$prefix) =
      Get_Unix_Install_Info();

  unless ($install_type eq 'system')
  {
    push @ARGV,'INSTALLDIRS=site';
    push @ARGV,"PREFIX=$prefix";
  }

  return $use_fastreader;
}

# --------------------------------------------------------------------------

sub Get_Unix_Install_Info
{
  my $response;

  print <<EOF;
Do you want to install the Mail::Folder::FastReader module? This
module was written to help speed up grepmail's mailbox processing. It
can speed things up by 10-20%
EOF
  print "=> [y] ";
  $response = <STDIN>;

  my $use_fastreader;

  if ($response =~ /^n/i)
  {
    $use_fastreader = 0;
  }
  else
  {
    $use_fastreader = 1;
  }


  print "\n","-"x78,"\n";
  print <<EOF;
Choose your installation type:
[1] normal Perl locations
[2] custom locations
EOF

  print "=> [1] ";
  $response = <STDIN>;
  chomp $response;
  $response = '1' if $response eq '';


  return ('system',$use_fastreader,undef) if $response eq '1';


  my $home = Get_Home_Directory();

  print "\n","-"x78,"\n";
  print "Where PREFIX should I use?\n";
  print "=> [$home] ";

  my $prefix = <STDIN>;
  chomp $prefix;
  $prefix = $home if $prefix eq '';


  return ('user',$use_fastreader,$prefix);
}

# --------------------------------------------------------------------------

# Figures out the user's home directory in Unix

sub Get_Home_Directory()
{
  # Get the user's home directory. First try the password info, then the
  # registry (if it's a Windows machine), then any HOME environment variable.
  my $home = eval { (getpwuid($>))[7] } || $ENV{HOME};

  die <<"  EOF"
Your home directory could not be determined. I tried to get your
home directory using both getpwuid and your HOME environment variable.
  EOF
    unless defined $home;

  return $home;
}

# --------------------------------------------------------------------------

sub Compute_Makefile_Attributes
{
  my $use_fastreader = shift;

  my %makefile_attributes = (
    'NAME'  => 'grepmail',
    'VERSION_FROM' => 'grepmail',

    'dist'  => { COMPRESS => 'gzip -9', SUFFIX => 'gz' },
    'clean' =>
      { FILES => 't/results/*.diff t/results/*.stdout t/results/*.stderr' },
    'EXE_FILES' => [ 'grepmail' ],
    'PREREQ_PM' => { 'Date::Parse' => 0},
  );

  $makefile_attributes{'DIR'} = [] unless $use_fastreader;

  return %makefile_attributes;
}

# --------------------------------------------------------------------------

sub MY::postamble
{
# Add a target for testing the speed, and one for testing
# functionality
'
testspeed :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERL) -I$(INST_ARCHLIB) -I$(INST_LIB) \
	  -I$(PERL_ARCHLIB) -I$(PERL_LIB) $(TEST_FILE)

testfunc :: pure_all
	PERL_DL_NONLAZY=1 $(FULLPERL) -I$(INST_ARCHLIB) -I$(INST_LIB) \
	  -I$(PERL_ARCHLIB) -I$(PERL_LIB) t/functionality.t
';
}

