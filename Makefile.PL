#!/usr/bin/perl

use strict;

# For PRIVATE Module::Install extensions
use lib 'lib';

use inc::Module::Install;

# Do all_from first to get the required perl version before
# check_custom_installation runs
name            ('grepmail');
all_from        ('grepmail');

check_custom_installation();

install_script  ('grepmail');

requires        (
                    'Date::Parse' => 0,
                    'Mail::Mbox::MessageParser' => '1.4001',
                );

test_requires   (
                    'Test::More' => 0,
                );

sub MY::postamble {
  return &Module::AutoInstall::postamble . <<'EOF';
testspeed :: pure_all
	PERL_DL_NONLAZY=1 $(PERLRUN) "-I$(INST_LIB)" \
	  "-I$(INST_ARCHLIB)" t/speed.pl
EOF
}

check_optional( 'Digest::MD5' => 0,
  "Digest::MD5 reduces memory consumption for the -u (unique) option\n");

check_optional( 'Date::Manip' => 0,
  "Date::Manip allows you to use complex date patterns for the -d option\n");

check_optional( 'Benchmark::Timer' => 0,
  "Benchmark::Timer is required for speed tests\n");

clean_files     ('t/temp');

WriteAll();

Update_Test_Version('grepmail','t/results/help');
