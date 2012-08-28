package libs::RCON;
#
##
##########################################################################
#                                                                        #
#       Automaton Framework                                              #
#                                                                        #
#       Forensic Auditing Toolkit                                        #
#                                                                        #
#       Forensic Auditing System - Designed to build an audit trail      #
#       and health check on all systems                                  #
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
use Getopt::Std;
use Switch '__';
use Term::ReadKey;
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use libs::LogHandle;
use libs::ChkMods;
use libs::GenDate;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&ssh_rcon $rcon_user $rcon_pass $host_name);
use vars qw($rcon_user $rcon_pass $host_name);
#################################################
# Variables Exported From Module - Definitions
##
$rcon_user='';
$rcon_pass='';
$host_name='';
#################################################
# Local Internal Variables for this Module
##
my $myname="module RCON.pm";
#################################################
# External Modules
##
# These will need to be installed on the system
# running this script
##
# Rrefer to the installation directory which will
# provide auto installation scripts for all
# required perl modules
##

#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##
# CONNECT TO Remote Machine
# and start the communication process
##
sub ssh_rcon {
  my $subname="sub ssh_rcon";
  my $caller=$myname." :: ".$subname;

  &chkmod_exists("Net::OpenSSH","Net::SSH::Perl","Net::SSH2");
  my $ssh_mod="$mod_name";
  &log_it("In $myname :: Appears $mod_use is available using this","debug","3","$caller");
  eval {
    require "$mod_use.pm";
    "$mod_use.pm"->import();
  };
  &log_it("In $myname :: Using $mod_name loaded $mod_use, eval returned $@","debug","3","$caller");

  my $rcon_meth=shift(@_);
  my $rcon_host=shift(@_);
  my $rcon_port=shift(@_);

  my $debug_level;
  my $debug_flag="";
  my $cmd = "uname -n";
  my $ssh;
  my @host_output;
  my $err="NULL";

  my %un_key;
  $caller="$myname :: sub ssh_rcon";
  &log_it("In $caller","debug","3","$caller");
  &log_it("Current rcon method = $rcon_meth and host $rcon_host and ssh_mod is $ssh_mod and port is $rcon_port","debug","3","$caller");

  ## Determining the priority of logging to determine whether or not to set the verbose flag for the ssh connection
  ## This requires the LogHandle.pm module.
  if ("$globlev" == "3") {
    $debug_level="1";
    $debug_flag="true";
    &log_it("verbosity flag for ssh = $debug_level, should be 1","debug","3","$caller");
  } else {
    $debug_level="0";
    $debug_flag="false";
    &log_it("verbosity flag for ssh  = $debug_level, should be 0","debug","3","$caller");
  }

  switch ($ssh_mod) {
    ##
    # 3 Different SSH Modules - Net::OpenSSH, Net::SSH::Perl & Net::SSH2
    # Check to see what is available. and then use the 1 that is available
    # Also need other connection method.
    ##
    case "Net::OpenSSH" {
      ##
      # I have been looking for a good Net::SSH::Perl replacement
      # This is the top choice, Net::SSH::Perl, is an absolute pain to install
      ##
      my $caller=$caller." :: Net::OpenSSH";
      &log_it("Using $ssh_mod, Attempting to ssh into server $rcon_host","debug","1","$caller");
      switch ($rcon_meth) {
        case  "rsa" {
          ##
          # Need to grab the location of the key or read the key into a variable from the db..
          # Generally really bad idea to store private key in the DB, need to avoid this for security.
          ##
          #$ssh = $ssh_mod->new("$rcon_host", port=>"$rcon_port", stdin_pipe => 1, stdout_pipe => 1, stdin_pty => 1, );
          $ssh = $ssh_mod->new("$rcon_host", port=>"$rcon_port");
          &log_it("Attempting to ssh into server $rcon_host","debug","3","$caller");
        } case "pass" {
          ##
          # For security reasons plaintext un/pwd also bad idea, will be allowed but need to encrypt password in db.
          # So will need a decryption routine  Probably lib::endecrypt added soon as in encrypt/decrypt.
          ##
          $ssh = $ssh_mod->new("$rcon_host", {user=>$rcon_user,passwd=>$rcon_pass,ssh_opts=>$debug_flag});
          &log_it("RCON Method :: Password Method Selected - This is not recommended","debug","3","$caller");
        } case "sftp" {
          &log_it("Attempting to sftp into server $rcon_host","debug","3","$caller");
          my $sftp = $ssh->sftp();
          $sftp->error and &log_it("SFTP failed: ".$sftp->error, "error","1","$caller");
        }
      }

      my $autpwd="/opt/Automaton";
      my $locpath="/opt/Automaton/remote";
      my $motepath="/home/host";

      $host_name=$ssh->capture("uname -n") ;
      chomp($host_name);
      my $host_output=$ssh->capture("cat /etc/redhat-release && free && df -h && du -sh /usr/bin && tar -cvvzf $motepath/ssh2.tar.gz $motepath/.ssh") ;
      #my $host_output=$ssh->capture("ls /") ;
      $ssh->error and die "remote command failed: " . $ssh->error;

      &log_it("hostname is $host_name","debug","3","$caller");
      &log_it("Some General data about host $host_name is as follows: \n $host_output","debug","3","$caller");
      my $mac_path="$locpath/$host_name";

      if (! -e "$mac_path" ) {
        eval { mkpath ("$mac_path/",1,0755) } or &log_it("Cannot make path :: $mac_path $!","error","1","$caller");
        #system("mkdir -p $mac_path/");
      }

      $ssh->scp_get("/home/host/ssh2.tar.gz", "$mac_path/");
      $ssh->scp_put("/home/host/Projects/Automaton/Rules/test-data-gather.sh", "$autpwd");

      $host_output=$ssh->capture( { tty=>"true" }, "sudo /bin/sh $autpwd/test-data-gather.sh") ;
      $ssh->error and die "remote command failed: " . $ssh->error;
      &log_it("\n$host_output","debug","3","$caller");

      $host_output=$ssh->capture( { tty=>"true" }, "sudo chown -R host:wheel $autpwd/audit && tar -cvvzf $autpwd/audit.tar.gz $autpwd/audit") ;
      $ssh->error and die "remote command failed: " . $ssh->error;
      &log_it("\n$host_output","debug","3","$caller");
      $ssh->scp_get("$autpwd/audit.tar.gz", "$mac_path/");

    } case "Net::SSH::Perl" {
      ##
      # Multiple possibilities for ssh connectivity.
      # Keys / username & password / Keys with a password
      # Keys can be Public  RSA/DSA
      # Using 2 simple scenarios , un&pw or rsa keys. Everything else ignored
      ##
      my $caller=$caller." :: Net::SSH::Perl";
      &log_it("This method is currently disabled because its an absolute pain to install the module","error","1","$caller");
      $ssh = $ssh_mod->new("$rcon_host", debug => $debug_level);
      switch ($rcon_meth) {
        case  "rsa" {
          ##
          # Need to grab the location of the key or read the key into a variable from the db..
          # Generally really bad idea to store private key in the DB, need to avoid this for security.
          ##
          my $auth = Net::SSH::Perl::Auth->new('RSA', $ssh);
          $ssh->login or die "$!";
          &log_it("RCON Method :: RSA Method Selected","debug","3","$caller");
        } case "pass" {
          ##
          # For security reasons plaintext un/pwd also bad idea, will be allowed but need to encrypt password in db.
          # So will need a decryption routine  Probably lib::endecrypt added soon as in encrypt/decrypt.
          ##
          my $auth = Net::SSH::Perl::Auth->new('Password', $ssh);
          $ssh->login($rcon_user, $rcon_pass) or die "$!";
          &log_it("RCON Method :: Password Method Selected - This is not recommended","debug","3","$caller");
        }
      }

      if (!defined($err)) { $err="No Errors" }
      &log_it("out=@host_output - err=$err","debug","1","$caller");

    } case "Net::SSH2" {
      my $caller=$caller." :: Net::SSH2";
      die (&log_it("This method is currently disabled as it is quite unstable still","error","1","$caller"));

    }
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
# To access documentation please use perldoc RCON.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

RCON.pm - Automaton Framework: Forensic Auditing Toolkit

=head1 SYNOPSIS

Remote Connection Manager - SSH Module

=head1 DESCRIPTION

This module imports the users from either a database or specified file imports the associated keys for said users and
uses these accounts to initiate remote connections to the provided servers to begin the auditing process.

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
