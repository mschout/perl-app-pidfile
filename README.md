# App::PidFile - Yet Another PID File Module for Perl

This module handles PID files in Perl.  This module is the result of
frustration with current CPAN offerings that do similar tasks. Frustrations include:

* Proc::PID::File
  - no way to chown the PID file (unless doing it by hand externally)
  - clunky interface once you try to do anything other than `->running`

* Pid::File
  - Seems to be abandoned by author.  Unfixed showstopper bugs with patches
    sent to rt.cpan.org long ago with no response.

There are other modules on CPAN, but I threw in the towel after using both of
these and decided to create this one instead.

## Will This Module Appear on CPAN?

I don't know.  If you find this module useful, and would like to see this
module released to CPAN, please let me know.  There are already various PID file
modules already on CPAN, it would be nice if one of them could simply be fixed
instead.

