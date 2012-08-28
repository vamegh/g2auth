package libs::UserDetails;
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
##
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
#
# Refer to the installation directory which will
# provide auto installation scripts for all
# required perl modules
##
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use libs::CMDHandle;
use libs::LogHandle;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&user_info $auth_name $auth_pass $auth_uid $auth_gid $auth_quota $auth_comment $auth_gcos $auth_dir $auth_shell $auth_expire $sys_user $sys_pam);
use vars qw($auth_name $auth_pass $auth_uid $auth_gid $auth_quota $auth_comment $auth_gcos $auth_dir $auth_shell $auth_expire $sys_user $sys_pam);
#################################################
# Variables Exported From Module - Definitions
##
##$pam_user="$>";
$auth_name='';
$auth_pass='';
$auth_uid='';
$auth_gid='';
$auth_quota='';
$auth_comment='';
$auth_gcos='';
$auth_dir='';
$auth_shell='';
$auth_expire='';
$sys_user='';
$sys_pam='';
#################################################
# Local Internal Variables for this Module
##
my $myname="module UserDetails.pm";
my $caller="$myname";
#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##

sub user_info {
  my $subname="sub user_info";
  my $caller=$myname." :: ".$subname;

  ## over-riding the pam_user stuff so we know that pam is calling
  ## ie that it is actually root, because pam doesnt
  ## set the env USER variable instead it sets PAM_USER
  ## se we get around this by setting this and letting the system
  ## know it is actually root,
  $sys_user = $ENV{'PAM_USER'};
  if (!$sys_user) {
    ## if PAM_USER is not set then env USER must be set
    ## we need to make sure the rest of the system
    ## knows who the actual user is
    $sys_user = $ENV{'USER'};
    &log_it("System env PAM_USER not set :: ".
            "system user now set to env USER :: $sys_user",
            "debug","1","$caller");
  } else {
    &log_it("System env PAM_USER is set :: ".
            "System user is set to :: $sys_user",
            "debug","3","$caller");
    $sys_pam = $sys_user;
    $pam_user = $sys_user;
    $sys_user = 'root';
    &log_it("System user now set to $sys_user :: ".
            "sys_pam invoked and set to $sys_pam",
            "debug","3","$caller");
  }
  ## first check if we have a uid rather than a username
  ## being set for pam_user, if uid check uid info,
  ## else check name info.
  if ($pam_user =~ /^(\d+)/) {
    #print "uname currently $pam_user, matches digits";
    #print "\n\nusername currently $pam_user\n\n";
    &log_it("userid currently $pam_user :: ".
            "matches digits","debug","3","$caller");
    ($auth_name,
     $auth_pass,
     $auth_uid,
     $auth_gid,
     $auth_quota,
     $auth_comment,
     $auth_gcos,
     $auth_dir,
     $auth_shell,
     $auth_expire) = getpwuid($pam_user)
      or &log_it("ERROR :: User does not exist on System :: ".
                 "Will not Bomb Out until LDAP verification ::$!\n",
                 "error","2","$caller");
    &log_it("userid :: $pam_user\n".
            "auth_name :: $auth_name\n".
            "auth_uid :: $auth_uid\n".
            "auth_gid :: $auth_gid\n".
            "auth_gcos :: $auth_gcos\n".
            "auth_dir :: $auth_dir\n".
            "auth_shell :: $auth_shell",
            "debug","3","$caller");
  } elsif ($pam_user =~ /(\w+)/) {
    #print("uname currently $pam_user, matches a word");
    #print "\n\nusername currently $pam_user\n\n";
    &log_it("uname currently $pam_user :: ".
            "matches a word","debug","3","$caller");
    &log_it("username currently $pam_user",
            "debug","3","$caller");;
    ($auth_name,
     $auth_pass,
     $auth_uid,
     $auth_gid,
     $auth_quota,
     $auth_comment,
     $auth_gcos,
     $auth_dir,
     $auth_shell,
     $auth_expire) = getpwnam($pam_user)
      or $auth_name = $pam_user
      && &log_it("ERROR :: User does not exist on System :: ".
                 "Will not Bomb Out until LDAP verification ::$!\n",
                 "error","2","$caller");
    ## if user doesnt exist the or clause above doesnt seem to be matched.
    ## Instead a 1 seems to be set,
    ## so we need to check for this explicitly and just pass the username.
    if ("$auth_name" eq '' or "$auth_name" eq "1") {
      $auth_name = $pam_user;
      ##print "\n\nusername currently $auth_name it was $pam_user\n\n";
      &log_it("username currently $auth_name it was $pam_user",
              "debug","1","$caller");
    }
    &log_it("userid :: $pam_user\n".
            "auth_name :: $auth_name\n".
            "auth_uid :: $auth_uid\n".
            "auth_gid :: $auth_gid\n".
            "auth_gcos :: $auth_gcos\n".
            "auth_dir :: $auth_dir\n".
            "auth_shell :: $auth_shell",
            "debug","3","$caller");
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
# To access documentation please use perldoc UserDetails.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#

__END__

=head1 NAME

UserDetails.pm - Google Authenticator Automater : Gauth

=head1 SYNOPSIS

Grabs the user information of the person calling this module.

=head1 DESCRIPTION

This is a very basic module. The main function is user_info, this can either take a uid or name as input and generate details for that user or its default behaviour is to assume the person calling the module is the one whose information is required. It outputs / stores the following information:

  $auth_name
  $auth_pass
  $auth_uid
  $auth_gid
  $auth_quota
  $auth_comment
  $auth_gcos
  $auth_dir
  $auth_shell
  $auth_expire

It is mainly used to grab the username of the user running the script to send to LDAP to grab further information about the user, for later processing.

=head1 AUTHOR

=over

=item Vamegh Hedayati <vamegh AT gmail DOT com>

=back

=head1 LICENSE

Copyright (C) 2012  Vamegh Hedayati <vamegh AT gmail DOT com>

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
