package libs::ChkMods;
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
# My Modules
##
# All provided in the ./libs directory
##
use libs::LogHandle;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&chkmod_exists $mod_use $mod_name);
use vars qw($mod_use $mod_name);
#################################################
# Variables Exported From Module - Definitions
##
$mod_use='';
$mod_name='';
#################################################
# Local Internal Variables for this Module
##
my $myname="module ChkMods.pm";
#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##
# Lets check to see what modules to use shall we .. !!
# Possibly a good idea to write an independant module from this
# that can check all requried modules and report if the prog will
# run and also set which ones to use.
# For time being left as is.
##
#################################################
sub chkmod_exists {
  my $subname="chkmod_exists";
  my $caller=$myname." :: ".$subname;
  $mod_use='';
  $mod_name='';

  &log_it("List of modules passed is @_","debug","3","$caller");

  foreach my $modcheck(@_) {
    foreach my $include (@INC) {
      my $modpwd="$modcheck";
      $modpwd=~s/[:]./\//g;
      &log_it("Checking $include/$modpwd","debug","3","$caller");
      if (-e "$include/$modpwd") {
        &log_it("module $modcheck exists in $include/$modpwd","debug","3","$caller");
        $mod_use="$modpwd";
        $mod_name="$modcheck";
        &log_it("Using module $mod_use ignoring all other modules, as 1st provided module is priority module ","debug","3","$caller");
        last;
      }
    }
    if ("$mod_use" ne ''){
      &log_it("Using module $mod_use as it exists, skipping all other path checks","debug","3","$caller");
      last;
    }
  }

  if ("$mod_use" eq '' ) {
    &log_it("None of the modules provided, which are: @_ exist in the system paths, this program will now terminate","error","1","$caller");
    die "Bye now :(\n";
  } else {
    &log_it("Sending back $mod_use so that it can be loaded by calling module","debug","3","$caller");
  }
  ##&log_it("ubname","debug","3","$caller");
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
# To access documentation please use perldoc ChkMod.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

ChkMod.pm - Automaton Framework: Forensic Auditing Toolkit

=head1 SYNOPSIS

Module Checker

=head1 DESCRIPTION

This module is used to check for the existence of third party modules.
It can check for multiple similar modules, but it will only use the 1st one that exists,
so given a list of 10 modules, only 1 will load and that will be the 1st that it finds within the global systm paths for perl.

usage &checkmod_exists(Mod::SSH::Perl,Mod::SSH2,Mod::SSH);

This will go through all default perl include paths and the 1st module it finds from the provided list is the one that it will load
If Mod::SSH::Perl exists, it will be loaded and this will end.

This module has not been extensively tested and will fail if the module is in a different directory structure than the call structure.

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
