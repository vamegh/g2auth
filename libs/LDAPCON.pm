package libs::LDAPCON;
#
##
##########################################################################
#                                                                        #
#       Google Authenticator Automater                                   #
#                                                                        #
#       Copyright (C) 2012 by Vamegh Hedayati                            #
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
#################################################
# External Modules
##
# These will need to be installed on the system
# running this script
##
use Switch '__';
use Net::LDAP;
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use libs::LogHandle;
use libs::CMDHandle;
use libs::UserDetails;
use libs::MailHandler;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&ldap_check $gauth_uid $gauth_cn $gauth_mail $ldap_method $ldap_serv:qer $ldap_base $ldap_search);
use vars qw($gauth_uid $gauth_cn $gauth_mail $ldap_method $ldap_server $ldap_base);
#################################################
# Variables Exported From Module - Definitions
##
$gauth_uid='NoUID';
$gauth_cn='NoName';
$gauth_mail='';
$ldap_method="auth";
$ldap_server="";
$ldap_base="";
$ldap_search="";
#################################################
# Local Internal Variables for this Module
##
my $myname=":: module LDAPCON.pm";
my $caller="$myname";
my $ldap='';
my $mesg='';
#################################################
#  Sub-Routines / Functions Definitions
##
# This is the actual Body of the module
##
#&user_info;

### We get the users username above, now that we have the username
### we can grab further information from ldap.
sub ldap_check {
  my $subname="sub ldap_check";
  my $caller=$myname." :: ".$subname;
  my $unix_uid="NoUnix";

  if ($use_ldap=~/no/i) {
    &log_it ("LDAP alerts are disabled from within the configuration,".
             " LDAP subsystem is disabled","debug","2","$caller");
  } elsif ($use_ldap=~/yes/i) {
    if ("@_" ne '') {
      $ldap_method=shift(@_);
    } if ("@_" ne '') {
      $ldap_server=shift(@_);
    } if ("@_" ne '') {
      $ldap_base=shift(@_);
    } if ("@_" ne '') {
      $ldap_search=shift(@_);
    }



    #### Intentionally blanked , need to rewrite the LDAP connector..
    switch($ldap_method) {
      case "verify" {
        $caller=$myname." :: ".$subname." :: Case verify ::";
        my $verify_method="auth";
        &log_it("Name: $auth_name \n","debug","2","$caller");
        my @entries = &ldap_verify("$verify_method","$ldap_base");
      } case "auth" {
        $caller=$myname." :: ".$subname." :: Case auth ::";
        &log_it ("In $ldap_method :: ".
                 "ldap_server = $ldap_server :: ".
                 "ldap_base = $ldap_base","debug","3","$caller");
        &log_it ("Runing ldap_verify","debug","3","$caller");
      }
    }
  }
}

sub ldap_verify {
  my $subname="sub ldap_verify";
  my $caller=$myname." :: ".$subname;
  my $unix_uid="NoUnix";
  &log_it ("ldap_method = $ldap_method :: ".
           "ldap_server = $ldap_server :: ".
           "ldap_base = $ldap_base","debug","3","$caller");
  my ($ldap_attr1, $ldap_attr2, $ldap_attr3);

  if ("@_" ne '') {
    $ldap_method=shift(@_);
  } if ("@_" ne '') {
    $ldap_base=shift(@_);
  } if ("@_" ne '') {
    $ldap_search=shift(@_);
  } if ("@_" ne '') {
    $ldap_server=shift(@_);
  }
  &log_it ("ldap_method = $ldap_method :: ".
           "ldap_server = $ldap_server :: ".
           "ldap_base = $ldap_base","debug","3","$caller :: after var fill");

  $ldap = Net::LDAP->new( "$ldap_server" )
    or &log_it("Cannot Connect :: $@","error","1","$caller");
  $mesg = $ldap->bind ;

  $ldap_attr1="uid";
  &log_it ("ldap_attr1 = $ldap_attr1","debug","3","$caller :: after var fill");
  $ldap_attr2="cn";
  &log_it ("ldap_attr2 = $ldap_attr2","debug","3","$caller :: after var fill");
  if ("$ldap_method" eq "auth") {
    $ldap_attr3="mail";
    &log_it ("ldap_attr3 = $ldap_attr3","debug","3","$caller :: after var fill");
  } elsif ("$ldap_method" eq "unix") {
    $ldap_attr3="loginShell";
    &log_it ("ldap_attr3 = $ldap_attr3","debug","3","$caller :: after var fill");
  }

  &log_it("User Being verified currently : $auth_name","debug","3","$caller");
  &log_it("LDAP entries as follows: ldap_method = $ldap_method","debug","3","$caller");
  &log_it("LDAP entries as follows: ldap_search = $ldap_search","debug","3","$caller");
  &log_it("LDAP entries as follows: ldap_base   = $ldap_base","debug","3","$caller");

  $mesg = $ldap->search(
                        base   => "ou=$ldap_method, $ldap_base",
                        filter => "(uid=$auth_name)",
                        attrs => [ $ldap_attr1,
                                   $ldap_attr2,
                                   $ldap_attr3 ],
                      );
  $mesg->code && &log_it("Somethings gone wrong :: ".$mesg->error,"error","1","$caller");
  my @entries = $mesg->entries;
  &log_it("Users Details as Follows :: @entries :: " ,"debug","2","$caller");
  &log_it ("ldap_method = $ldap_method :: ".
           "ldap_server = $ldap_server :: ".
           "ldap_base = $ldap_base","debug","3","$caller :: at end of ldap_verify");
  $mesg = $ldap->unbind;
  return @entries;
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
# To access documentation please use perldoc DBCON.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

LDAPCON.pm - Gauth : Google Authenticator Automator

=head1 SYNOPSIS

LDAP Connection Handler

=head1 DESCRIPTION

This consists of 2 main functions:

  1. ldap_check
     This checks ldap information and verifies the user account and populates variables based on returned ldap entries.

  2. ldap_verify
     This connects to the LDAP server, using either the command line options passed to it,
     or the information from the config file. It returns the user information gathered by the ldap search.

This module takes 2 variables / arguments in which are :

  1. $ldap_server  :: This is the ldap server to contact / establish communications with, currently this only support anonymous binds. This is imported from CMDHandle
  2. $auth_name    :: This is the user to check on the ldap tree (the same user which is running the script) / to gather information for. This is imported from UserDetails

This module outputs 3 variables , they are as follows:

  1. $gauth_uid  :: The users uid / username as stored within the LDAP server
  2. $gauth_cn   :: The users actual name as stored within the LDAP server
  3. $gauth_mail :: The users email address as stored within the LDAP server

The ldap_check function should only ever be called from a script or another module and the ldap_verify .

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
