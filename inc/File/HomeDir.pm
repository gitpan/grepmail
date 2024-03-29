#line 1
package File::HomeDir;

# See POD at end for docs

use 5.005;
use strict;
use Carp       ();
use File::Spec ();

# Globals
use vars qw{$VERSION @ISA @EXPORT @EXPORT_OK $IMPLEMENTED_BY};
BEGIN {
	$VERSION = '0.69';

	# Inherit manually
	require Exporter;
	@ISA       = qw{ Exporter };
	@EXPORT    = qw{ home     };
	@EXPORT_OK = qw{
		home
		my_home
		my_desktop
		my_documents
		my_music
		my_pictures
		my_videos
		my_data
		users_home
		users_desktop
		users_documents
		users_music
		users_pictures
		users_videos
		users_data
		};

	# %~ doesn't need (and won't take) exporting, as it's a magic
	# symbol name that's always looked for in package 'main'.
}

# Don't do platform detection at compile-time
if ( $^O eq 'MSWin32' ) {
	# All versions of Windows
	$IMPLEMENTED_BY = 'File::HomeDir::Windows';
	require File::HomeDir::Windows;

} elsif ( $^O eq 'darwin' ) {
	# Modern Max OS X
	$IMPLEMENTED_BY = 'File::HomeDir::Darwin';
	require File::HomeDir::Darwin;

} elsif ( $^O eq 'MacOS' ) {
	# Legacy Mac OS
	$IMPLEMENTED_BY = 'File::HomeDir::MacOS9';
	require File::HomeDir::MacOS9;

} else {
	# Default to Unix semantics
	$IMPLEMENTED_BY = 'File::HomeDir::Unix';
	require File::HomeDir::Unix;
}





#####################################################################
# Current User Methods

sub my_home {
	$IMPLEMENTED_BY->my_home;
}

sub my_desktop {
	$IMPLEMENTED_BY->can('my_desktop')
		? $IMPLEMENTED_BY->my_desktop
		: Carp::croak("The my_desktop method is not implemented on this platform");
}

sub my_documents {
	$IMPLEMENTED_BY->can('my_documents')
		? $IMPLEMENTED_BY->my_documents
		: Carp::croak("The my_documents method is not implemented on this platform");
}

sub my_music {
	$IMPLEMENTED_BY->can('my_music')
		? $IMPLEMENTED_BY->my_music
		: Carp::croak("The my_music method is not implemented on this platform");
}

sub my_pictures {
	$IMPLEMENTED_BY->can('my_pictures')
		? $IMPLEMENTED_BY->my_pictures
		: Carp::croak("The my_pictures method is not implemented on this platform");
}

sub my_videos {
	$IMPLEMENTED_BY->can('my_videos')
		? $IMPLEMENTED_BY->my_videos
		: Carp::croak("The my_videos method is not implemented on this platform");
}

sub my_data {
	$IMPLEMENTED_BY->can('my_data')
		? $IMPLEMENTED_BY->my_data
		: Carp::croak("The my_data method is not implemented on this platform");
}





#####################################################################
# General User Methods

sub users_home {
	$IMPLEMENTED_BY->can('users_home')
		? $IMPLEMENTED_BY->users_home( $_[-1] )
		: Carp::croak("The users_home method is not implemented on this platform");
}

sub users_desktop {
	$IMPLEMENTED_BY->can('users_desktop')
		? $IMPLEMENTED_BY->users_desktop( $_[-1] )
		: Carp::croak("The users_desktop method is not implemented on this platform");
}

sub users_documents {
	$IMPLEMENTED_BY->can('users_documents')
		? $IMPLEMENTED_BY->users_documents( $_[-1] )
		: Carp::croak("The users_documents method is not implemented on this platform");
}

sub users_music {
	$IMPLEMENTED_BY->can('users_music')
		? $IMPLEMENTED_BY->users_music( $_[-1] )
		: Carp::croak("The users_music method is not implemented on this platform");
}

sub users_pictures {
	$IMPLEMENTED_BY->can('users_pictures')
		? $IMPLEMENTED_BY->users_pictures( $_[-1] )
		: Carp::croak("The users_pictures method is not implemented on this platform");
}

sub users_videos {
	$IMPLEMENTED_BY->can('users_videos')
		? $IMPLEMENTED_BY->users_videos( $_[-1] )
		: Carp::croak("The users_videos method is not implemented on this platform");
}

sub users_data {
	$IMPLEMENTED_BY->can('users_data')
		? $IMPLEMENTED_BY->users_data( $_[-1] )
		: Carp::croak("The users_data method is not implemented on this platform");
}






#####################################################################
# Legacy Methods

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
		# Catch a bad username
		unless ( defined $_[1] ) {
			Carp::croak("Can't use undef as a username");
		}

		# Get our homedir
		unless ( length $_[1] ) {
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

#line 612
