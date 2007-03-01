#line 1 "inc/File/HomeDir.pm - /Library/Perl/5.8.6/File/HomeDir.pm"
package File::HomeDir;

# See POD at end for docs

use 5.005;
use strict;
use Carp       ();
use File::Spec ();

# Globals
use vars qw{$VERSION @ISA @EXPORT @EXPORT_OK $IMPLEMENTED_BY};
BEGIN {
	$VERSION = '0.58';

	# Inherit manually
	require Exporter;
	@ISA       = ( 'Exporter' );
	@EXPORT    = ( 'home'     );
	@EXPORT_OK = qw{
		home
		my_home
		my_desktop
		my_documents
		my_data
		};

	# %~ doesn't need (and won't take) exporting, as it's a magic
	# symbol name that's always looked for in package 'main'.
}

# Don't do platform detection at compile-time
if ( $^O eq 'MSWin32' ) {
	$IMPLEMENTED_BY = 'File::HomeDir::Windows';
	require File::HomeDir::Windows;
} elsif ( $^O eq 'darwin' ) {
	$IMPLEMENTED_BY = 'File::HomeDir::Darwin';
	require File::HomeDir::Darwin;
} elsif ( $MacPerl::VERSION || $MacPerl::VERSION ) {
	$IMPLEMENTED_BY = 'File::HomeDir::MacOS9';
	require File::HomeDir::MacOS9;
} else {
	$IMPLEMENTED_BY = 'File::HomeDir::Unix';
	require File::HomeDir::Unix;
}





#####################################################################
# Current User Methods

sub my_home {
	$IMPLEMENTED_BY->my_home;
}

sub my_desktop {
	$IMPLEMENTED_BY->my_desktop;
}

sub my_documents {
	$IMPLEMENTED_BY->my_documents;
}

sub my_data {
	$IMPLEMENTED_BY->my_data;
}





#####################################################################
# General User Methods

# Find the home directory of an arbitrary user
sub home (;$) {
	# Allow to be called as a method
	if ( $_[0] and $_[0] eq 'File::HomeDir' ) {
		shift();
	}

	# No params means my home
	return my_home() unless @_;

	# Check the param
	my $name = shift;
	if ( ! defined $name ) {
		Carp::croak("Can't use undef as a username");
	}
	if ( ! length $name ) {
		Carp::croak("Can't use empty-string (\"\") as a username");
	}

	# A dot also means my home
	### Is this meant to mean File::Spec->curdir?
	if ( $name eq '.' ) {
		return my_home();
	}

	# Now hand off to the implementor
	$IMPLEMENTED_BY->users_home($name);
}





#####################################################################
# Tie-Based Interface

# Okay, things below this point get scary

CLASS: {
	# Make the class for the %~ tied hash:
	package File::HomeDir::TIE;

	# Make the singleton object.
	# (We don't use the hash for anything, though)
	### THEN WHY MAKE IT???
	my $SINGLETON = bless {};

	sub TIEHASH { $SINGLETON }

	sub FETCH {
		# Get our homedir
		if ( ! defined $_[1] or ! length $_[1] ) {
			return File::HomeDir::my_home();
		}

		# Get a named user's homedir
		return File::HomeDir::home($_[1]);
	}

	sub STORE    { _bad('STORE')    }
	sub EXISTS   { _bad('EXISTS')   }
	sub DELETE   { _bad('DELETE')   }
	sub CLEAR    { _bad('CLEAR')    }
	sub FIRSTKEY { _bad('FIRSTKEY') }
	sub NEXTKEY  { _bad('NEXTKEY')  }

	sub _bad ($) {
		Carp::croak("You can't $_[0] with the %~ hash")
	}
}

# Do the actual tie of the global %~ variable
tie %~, 'File::HomeDir::TIE';

1;

__END__

#line 372
