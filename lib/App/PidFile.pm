package App::PidFile;

# ABSTRACT: Yet Another PID File Manipulation Module

use Moose;
use Fatal qw(open);
use File::Basename qw(basename);
use File::Spec;
use namespace::autoclean;

=method new

 my $pid = App::PidFile->new(...)

Constructor args:

=begin :list

* path
The path to the pid file. Defaults to /var/run/basename($0).pid
* uid
(optional) the UID that should own the pid file
* gid
(optional) the GID that should own the file

=end :list

=cut

has path => (is => 'ro', isa => 'Str', lazy_build => 1);

has uid => (is => 'ro', isa => 'Int', lazy_build => 1);

has gid => (is => 'ro', isa => 'Int', lazy_build => 1);

sub DEMOLISH {
    my $self = shift;

    unlink $self->path;
}

=method running

  die 'already running!' if $pid->running;

If the PID file exists, and has a PID entry in it, check if that process is
running on the system.  If yes, return true.  If not, then create (or replace)
the PID file with the current process ID.

=cut

sub running {
    my $self = shift;

    return 1 if $self->is_running;

    $self->write;

    $self->change_permissions;

    return 0;
}

=method is_running

return true if the process id in the PID file is running.

=cut

sub is_running {
    my $self = shift;

    return 0 unless -s $self->path;

    my $pid = $self->read;

    return kill($pid, 0) == 0 ? 1 : 0;
}

=method read

Read the PID file and return the contents

=cut

sub read {
    my $self = shift;

    return unless -s $self->path;

    open my $fh, '<', $self->path;

    my ($pid) = <$fh>;
    chomp $pid;

    close $fh;

    return $pid;
}

=method write

Create or replace the PID file with the current pricess id.
Called automatically from running().

=cut

sub write {
    my $self = shift;

    open my $fh, '>', $self->path;

    print $fh "$$";

    close $fh;

    return $$;
}

=method change_permissions

Attempt to set permissions on the pid file if the uid and/or gid were given in
the constructor

=cut

sub change_permissions {
    my $self = shift;

    # attempt to set permissions
    if ($self->uid != -1 or $self->gid != -1) {
        chown $self->uid, $self->gid, $self->path;
    }
}

sub _build_path {
    File::Spec->catfile('/var/run', basename($0));
}

sub _build_uid { -1 }

sub _build_gid { -1 }

1;


=begin Pod::Coverage

DEMOLISH

=end Pod::Coverage

=head1 SYNOPSIS

 use App::PidFile;

 my $pf = App::PidFile->new;

 die "already running" if $pf->running;

 # pid file is automatically unlinked when $pf goes out of scope.

=head1 DESCRIPTION

This is yet another PID file library, of which there are several on CPAN.  I
wrote this library after getting ed up with various problems or bugs with
existing libraries on CPAN.

