package libs::LogHandle;
#
##
##########################################################################
#                                                                        #
#       Automaton Framework                                              #
#                                                                        #
#       Copyright (C) 2010 by Vamegh Hedayati                            #
#       vamegh <AT> gmail.com                                            #
#                                                                        #
#       Please see Copying for License Information                       #
#                               GNU/GPL v2 2010                          #
##########################################################################
##
#
#################################################
# Integrity Checks
##
use strict;
use warnings;
#################################################
# Builtin Modules
##
# These should be available by default
##
use File::Path;
use Switch '__';
#################################################
# External Modules
##
# These will need to be installed on the system
# running this script
#
# Refer to the Installation directory which will
# provide auto-installation scripts for all
# required perl modules
##
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use libs::Colour;
use libs::GenDate;
##use libs::UserDetails;
##
# Getting the latest date set
##
&make_date;
##&user_info;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
#@EXPORT   = qw(&log_it &log_loc $log_dir $log_file $message $logtype $caller $loglev $globlev);
#use vars qw($log_dir $log_file $message $logtype $caller $loglev $globlev);
@EXPORT   = qw(&log_it $log_dir &log_loc $log_lev $log_file $loglev $globlev);
use vars qw($log_dir $log_file $loglev $globlev);
#################################################
# Variables Exported From Module - Definitions
##
##$log_dir="/var/log/gauth";
$log_dir='';
$log_file='';

$globlev='';
$loglev="1";
#################################################
# Local Internal Variables for this Module
##
my $counterD=0;
my $counterE=0;
my $message='';
my $logtype="debug";
my $myname="module LogHandle.pm";
#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##

sub log_loc {
  my $subname="sub log_loc";
  my $caller=$myname." :: ".$subname;
  if ("@_" ne '') {
    $log_dir=shift(@_);
  } if ("@_" ne '') {
    $log_file=shift(@_);
    $log_file=$log_dir."/".$date."_".$log_file;
  }

  ## Need to check if pam_user env variable is set
  ## if it is pam_user used for username, otherwise
  ## user variable is used, which should always be set.
  #my $sys_uname = $ENV{'PAM_USER'};
  #if (!$sys_uname) {
  #  $sys_uname = $ENV{'USER'};
  #}

  print "\nLog file currently :: $log_file\n\n";

  if ($log_dir eq "none") {
    &log_it("log_file currently $log_file ".
            "Command line output -D enabled, ".
            "for help type --help or perldoc gauth",
            "debug","2","$caller");
  } else {
    if ( ! -e "$log_dir") {
      mkpath("$log_dir" ,1, 0777);
    }
    &log_it("logging to file $log_file","debug","3","sub log_loc");
    open (STDIN,">>$log_file")
      or die "Premature Evacuation :: Can't write to $log_file: $!\n";
    open (STDOUT,">>$log_file")
      or die "Premature Evacuation :: Can't write to $log_file: $!\n";
    open (STDERR, ">>$log_file")
      or die "Premature Evacuation :: Can't write to $log_file: $!\n";
  }
}

sub log_it {
  &make_date;
  my $caller;

  if ("$globlev" eq '') {
    $globlev="1";
  }

  if ("@_" ne '' ) {
    $message=shift(@_);
  }if ("@_" ne '') {
    $logtype=shift(@_);
  }if ("@_" ne '') {
    $loglev=shift(@_);
  }if ("@_" ne '') {
    $caller=shift(@_);
  }

  switch ($logtype){
    #print "caller $caller , counterD $counterD, counterE $counterE \n";
    case "debug" {
      #print "caller $caller , counterD $counterD, counterE $counterE \n";
      switch ($loglev) {
        #case [__ eq undef] {print "DEBUG :: $caller.$counterD :: $message\n"; }
        case [__ => 1] {
          print $green."$date.$time :: ".
                $blue."DEBUG :: ".
                $yellow."$counterD.$caller".
                $blue." :: $message\n".$reset;
        } case [__ => 2] {
          if ($globlev>=2) {
            print $green."$date.$time :: ".
                  $blue."DEBUG :: ".
                  $yellow."$counterD.$caller".
                  $blue." :: $message\n".$reset;
          }
        } case 3 {
          if ($globlev==3) {
            print $green."$date.$time :: ".
                  $blue."DEBUG :: ".
                  $yellow."$counterD.$caller".
                  $blue." :: $message\n".$reset;
          }
        } else {
          print "$date-$time :: Logging - should never get here \n";
        }
      }
    } case "error" {
      #print "caller $caller , counterD $counterD, counterE $counterE \n";
      switch ($loglev) {
        case [__ => 1] {
          print $green."$date-$time :: ".
                $red."ERROR :: ".
                $yellow."$counterE.$caller".
                $red." :: $message :: Premature Evacuation\n".$reset;
          print $green."$date-$time :: ".
                $yellow."Was it as Good for you as it was for me ?  ".
                "Clean as a Baby :: ".
                $red." Bye Now :) \n".$reset;
          exit 1;
        } case [__ => 2] {
          print $green."$date-$time :: ".
                $red."ERROR :: ".
                $yellow."$counterE.$caller".
                $red." :: $message :: Premature Evacuation\n".$reset;
        } case 3 {
          print $green."$date-$time :: ".
                $red."ERROR :: ".
                $yellow."$caller.$counterE".
                $red." :: $message :: Premature Evacuation\n".$reset;
        } else {
          print "$date-$time :: Logging - should never get here \n";
        }
      }
    } else {
      ##print "ERROR :: Log logtype should".
      ##"be one of error or debug currently $logtype\n";
      print $green."$date-$time :: ".
            $red."ERROR :: ".
            $yellow."$counterE.$caller".
            $red." :: Log logtype should be one of ".
            "error or debug currently $logtype  :: ".
            "Premature Evacuation\n".$reset;
    }
  }
  $counterD++;
  $counterE++;
}


END { }       # Global Destructor

1;

#################################################
#
################################### EO PROGRAM #######################################################
#
################################ MODULE HELP / DOCUMENTATION SECTION #################################
##
# Original implementation idea from linblock.pl http://www.dessent.net/linblock/ (c) Brian Dessent GNU/GPL
# This actually uses no code from linblock.pl, but the implementation was learnt by studying the above script
##
# To access documentation please use perldoc LogHandle.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

LogHandle.pm - Automaton Framework

=head1 SYNOPSIS

 LogHandle.pm - Log Handler
 Logging and reporting Module.

=head1 DESCRIPTION

LogHandle.pm consists of two main sub-routines (functions).

 Function log_it -- this is the main function.

 This is called by the main perl script or module(s) and sorts out the logging.
 when called it requires the following parameters:

        1.  The log message
                The message to print, the condition that has been met which warrants logging/debug info.

        2.  The Type of logging being performed, which are either:
                * debug -- when a condition has occured which warrants logging.
                * error -- when an error condition occurs this should be used.

        3.  The log level, This is set via CMDHandle.pm the < -v > option, these are as follows:
                * 1 -- level 1, the default level, This is used for low level logging
                * 2 -- level 2, This is used for medium level logging
                * 3 -- level 3, This is for full debugging/verbosity mode.
        4.  The caller,
                This can be anything, but should display the program trigger for the logging event.
                i.e from where within the program the call has been made, hence caller.

 Function log_loc

 This is called by the main perl script and sorts out the log destination.
 The default location for the logging can be overridden by the main perl script,
 via the $log_file variable.

 The log location can also be set via the command line (CMDHandle.pm) with the < -L > flag


=head1 AUTHOR

=over

=item Vamegh Hedayati <vamegh AT gmail DOT com>

=back

=head1 LICENSE

Copyright (C) 2010  Vamegh Hedayati <vamegh AT gmail DOT com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

Please refer to the COPYING file which is distributed with Automaton
for the full terms and conditions

=cut
#
#################################################
#
######################################### EOF  #######################################################
