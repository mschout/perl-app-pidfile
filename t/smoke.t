#!/usr/bin/env perl
#

use strict;
use File::Temp qw(tempdir);
use Test::More;

use_ok('App::PidFile') or exit 1;

my $dir = tempdir(CLEANUP => 1);

my $path = "$dir/me.pid";

{
    my $pid = App::PidFile->new(path => "$dir/me.pid");
    isa_ok $pid, 'App::PidFile';

    ok !$pid->is_running; # haven't written the pid file yet.

    ok !$pid->running;

    # running() should have written the PID.
    ok $pid->is_running;
}

ok ! -e $path, 'pid file was unlinked';

{
    # test read/write
    my $pf = App::PidFile->new(path => "$dir/me.pid");

    ok !$pf->is_running;

    my $pid = $pf->write;
    ok $pid;

    cmp_ok $pid, '==', $pf->read;
}

ok ! -e $path, 'pid file was unlinked';

subtest 'set_permissions' => sub {
    plan skip_all => 'chown requires superuser privileges'
        unless $> == 0;

    my ($uid,$gid) = (getpwnam('nobody'))[2,3];

    plan skip_all => 'user nobody does not exist on this system'
        unless defined $uid;

    # test permissions
    my $pf = App::PidFile->new(path => $path, uid => $uid, gid => $gid);

    ok !$pf->running;

    my ($fuid,$fgid) = (stat($path))[4,5];

    cmp_ok $uid, '==', $fuid, 'File UID was changed';
    cmp_ok $gid, '==', $fgid, 'File GID was changed';
};

done_testing;
