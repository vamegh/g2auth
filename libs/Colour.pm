package libs::Colour;
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
use Switch '__';
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
use Term::ANSIColor;
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
@EXPORT   = qw(&Colour $blink $blue $cyan $green $yellow $red $reset);
use vars qw($blink $blue $cyan $green $yellow $red $reset);
#################################################
# Variables Exported From Module - Definitions
##
$blink="";
$blue="";
$cyan="";
$green="";
$yellow="";
$red="";
$reset="";
#################################################
# Local Internal Variables for this Module
##
my $opt_C='';
#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##

sub Colour {
  my $opt_C=shift(@_);
  if ($opt_C) {
    ## Color settings for Term::AnsiColor
    ## enabling colour.
    $blink=color("blink");
    $blue=color("bold blue on_black");
    $cyan=color("bold cyan on_black");
    $green=color("bold green on_black");
    $yellow=color("bold yellow on_black");
    $red=color("bold red on_black");
    $reset=color("reset");
  } else {
    ## Color settings for Term::AnsiColor
    ## blanking since colour is off
    $blink="";
    $blue="";
    $cyan="";
    $green="";
    $yellow="";
    $red="";
    $reset="";
  }
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
# To access documentation please use perldoc GenDate.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

Colour.pm - Automaton Framework: Forensic Auditing Toolkit

=head1 SYNOPSIS

 Colour.pm - Colourizer
 A sub-routine (function) to handle log file colouring,
 Adds colour to Black and white text.. why not ?

=head1 DESCRIPTION

 Provides &Colour which adds colour to b&w text in logfiles,
 good for adding colour, if printing output to command line.
 Especially good for fault finding as it makes it easier to spot.

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
