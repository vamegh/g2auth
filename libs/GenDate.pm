package libs::GenDate;
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
use POSIX qw(strftime);
#################################################
# External Modules
##
# These will need to be installed on the system
# running this script
#
# Rrefer to the installation directory which will
# provide auto installation scripts for all
# required perl modules
##
#################################################
# My Modules
##
# All provided in the ./libs directory
##
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT   = qw(&make_date $date $year $month $week $day $time $hour $min $sec $uxtime $fdate);
use vars qw($date $year $month $week $day $time $hour $min $sec $uxtime $fdate);
#################################################
# Variables Exported From Module - Definitions
##
$date='';
$year='';
$month='';
$week='';
$day='';
$time='';
$hour='';
$min='';
$sec='';
$uxtime='';
$fdate='';
#################################################
# Local Internal Variables for this Module
##
#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##
sub make_date {
  my ($sec,$min,$hour,$mday,$amon,$ayear,$wday,$yday,$isdst)=localtime(time);
  $fdate = strftime('%a %b %e %X %Y', localtime());
  #printf "%4d-%02d-%02d %02d:%02d:%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec;
  $year=$ayear+1900;
  $month=$amon+1;
  $uxtime=time();
  if ($mday <= 9) {
          $day="0".$mday ;
  } else {
          $day=$mday ;
  }
  if ($month <= 9) { $month="0".$month ; }
  $date="$year-$month-$day";
  $time = sprintf("%02d%02d%02d",$hour,$min,$sec);
  if ($hour <= 9 ) { $hour="0".$hour ; }
  if ($min <= 9 ) { $min="0".$min ; }
  if ($sec <= 9 ) { $sec="0".$sec ; }
}

END { }  #  Global Destructor

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
# To access documentation please use perldoc GenDate.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

GenDate.pm - Automaton Framework

=head1 SYNOPSIS

Date Stamp Handler - This works out the time and date in Gregorian and Unix time formats.

=head1 DESCRIPTION

This a module that provides one sub_routine, make_date()

make_date, uses localtime to generate the date & time in many formats, for
comparison and logging mainly.

This has to be called by a perl script or module.

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

Please refer to the COPYING file which is distributed with vFATS
for the full terms and conditions

=cut
#
#################################################
#
######################################### EOF  #######################################################

