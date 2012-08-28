package libs::MailHandler;
#
##
##########################################################################
#                                                                        #
#       Automaton Framework / Google Authenticator Automator             #
#                                                                        #
#       Copyright (C) 2010 / 2012 by Vamegh Hedayati                     #
#       vamegh <AT> gmail.com                                            #
#                                                                        #
#       Please see Copying for License Information                       #
#                               GNU/GPL v2 or later 2010                 #
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
# Refer to the installation directory which will
# provide auto installation scripts for all
# required perl modules
##
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use libs::FileHandler;
use libs::CMDHandle;
use libs::GenDate;
use libs::LogHandle;
use libs::ChkMods;
use libs::UserDetails;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&send_mail $mailer $locate_mailer $mail_type $mail_template);
use vars qw($mailer $locate_mailer $mail_type $mail_template);
#################################################
# Variables Exported From Module - Definitions
##
$mailer="/usr/sbin/sendmail";
$locate_mailer=`which sendmail`;
##need to get rid of blank space/new line from system command hence chomp
chomp($locate_mailer);
$mail_type='gauthnotify';
$mail_template="/opt/gauth/templates/email-messages";
#################################################
# Local Internal Variables for this Module
##
my $myname=":: module MailHandler.pm";
my $mail_subject="Google Authenticator Automater Email System";
my $mail_ctype="Content-Type: text/plain; charset=UTF-8";
my $mail_cenc="Content-Transfer-Encoding: 8bit";
my $smtp='';
my %email_header=();
my @message_content='';
my $user="Vamegh Hedayati";
my @mail_header;

#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##

#$message_type = "
$user="Vamegh Hedayati";

## This module has been inspired by the following script:
## http://svn.apache.org/repos/asf/subversion/
## branches/1.6.x/contrib/hook-scripts/commit-email.pl.in $
## Which is licensed under the APACHE v2.0 License, terms available here:
## http://svn.apache.org/repos/asf/subversion/trunk/LICENSE
## None of the code is actually being used,
## to avoide breaking license terms,
## although GPLv3 and Apache v2 licensese are compatible.

##&send_mail('to@address',"users name","yes","gauthnotify",'from@address');

sub send_mail {
  my $subname="sub send_mail";
  my $caller=$myname." :: ".$subname;
  if ("@_" ne '') {
    $mail_type=shift(@_);
  } if ("@_" ne '') {
    $mail_to=shift(@_);
  } if ("@_" ne '') {
    $user=shift(@_);
  } if ("@_" ne '') {
    $mail_from=shift(@_);
  } if ("@_" ne '') {
    $use_mail=shift(@_);
  }
  &make_date;

  if ($use_mail=~/no/i) {
    &log_it ("eMail Alerts are disabled from within the configuration, ".
             "emails will not be sent","debug","2","$caller");
  } elsif ($use_mail=~/yes/i) {
    ##
    # This has been done this way for future expansion
    # Ideally several different templates need to be created
    # for different types of emails.
    ##
    # This is where the $mail_type comes in each type corresponds to a different mail_template file
    # Right now only generic is available in a future revision , many different template types
    # can be added and can be added to the below switch statement.
    ##
    &read_cfg("mailpars","$mail_template","$mail_type");
    switch($mail_type) {
      case "generic" {
        &log_it("Creating new email type $mail_type","debug","3","$caller");
        ## @mail_body is populated by libs::FileHandle, where the template file is read in.
        foreach (@mail_body) {
          chomp;
          s/\@\@\@DATE\@\@\@/$fdate/;
          s/\@\@\@USER\@\@\@/$user/;
          s/\@\@\@USERID\@\@\@/$auth_name/;
          s/\@\@\@BEGIN\@\@\@/@message_content/;
        }
        &log_it("Created new email body for $mail_type","debug","3","$caller");
        &log_it("email created which reads \n @mail_body","debug","3","$caller");
      } case "gauthnotify" {
        &log_it("Creating new email type $mail_type","debug","3","$caller");
        ## @mail_body is populated by libs::FileHandle, where the template file is read in.
        foreach (@mail_body) {
          chomp;
          s/\@\@\@DATE\@\@\@/$fdate/;
          s/\@\@\@USER\@\@\@/$user/;
          s/\@\@\@USERID\@\@\@/$auth_name/;
          s/\@\@\@BEGIN\@\@\@/@message_content/;
        }
        &log_it("Created new email body for $mail_type","debug","3","$caller");
        &log_it("email created which reads \n @mail_body","debug","3","$caller");
      } case "notunix" {
        &log_it("Creating new email type $mail_type","debug","3","$caller");
        ## @mail_body is populated by libs::FileHandle, where the template file is read in.
        foreach (@mail_body) {
          chomp;
          s/\@\@\@DATE\@\@\@/$fdate/;
          s/\@\@\@USER\@\@\@/$user/;
          s/\@\@\@USERID\@\@\@/$auth_name/;
          s/\@\@\@BEGIN\@\@\@/@message_content/;
        }
        &log_it("Created new email body for $mail_type","debug","3","$caller");
        &log_it("email created which reads \n @mail_body","debug","3","$caller");
      } case "accountdisabled" {
        &log_it("Creating new email type $mail_type","debug","3","$caller");
        ## @mail_body is populated by libs::FileHandle, where the template file is read in.
        foreach (@mail_body) {
          chomp;
          s/\@\@\@DATE\@\@\@/$fdate/;
          s/\@\@\@USER\@\@\@/$user/;
          s/\@\@\@USERID\@\@\@/$auth_name/;
          s/\@\@\@BEGIN\@\@\@/@message_content/;
        }
        &log_it("Created new email body for $mail_type","debug","3","$caller");
        &log_it("email created which reads \n @mail_body","debug","3","$caller");
      } else {
        &log_it("mail type $mail_type, not supported please verify",
                "debug","3","$caller");
      }
    }
    push(@mail_header, "Date: $fdate\n");
    push(@mail_header, "To: $mail_to\n");
    push(@mail_header, "From: $mail_from\n");
    push(@mail_header, "Subject: $mail_subject\n");
    push(@mail_header, "$mail_ctype\n");
    push(@mail_header, "$mail_cenc\n");
    push(@mail_header, "\n");

    &log_it("Remote host is currently $remote_host","debug","3","$caller");

    if ($remote_host=~/yes/i) {
      &mail_smtp;
    } else {
      &log_it("mail host currently $mail_host","debug","3","$caller");
      if (("$mail_host" eq "localhost")
           || ("$mail_host" eq "127.0.0.1")
           || (!defined("$mail_host"))
           || ("$mail_host" eq '')) {
        if (-e "$mailer") {
          &log_it("Mailer $mailer found, ".
                  "processing using \&mail_simple",
                  "debug","3","$caller");
          &mail_simple;
        } else {
          if ($locate_mailer !~ /sendmail/) {
            &log_it ("cant find sendmail binary, ".
                     "moving to Net::SMTP method",
                     "error","2","$caller");
            &mail_smtp;
          } else {
            $mailer="/usr/sbin/sendmail";
            $locate_mailer=`which sendmail`;
            &log_it("Mailer $mailer found, ".
                    "processing using \&mail_simple",
                    "debug","3","$caller");
            &log_it("Preparing email","debug","3","$caller");
            &mail_simple;
          }
        }
      } else {
        &log_it("Mailer $mailer found and remote_host ".
                "is disabled still will try using \&mail_smtp",
                "error","1","$caller");
        &mail_smtp;
      }
    }
  } else {
    &log_it("Use Emails currently set to $use_mail, ".
            "this is an unknown option, ".
            "emails will not be processed",
            "error","2","$caller");
  }
}


sub mail_simple {
  my $subname="sub mail_simple";
  my $caller=$myname." :: ".$subname;

  &log_it("date is $fdate, ".
          "mailto is $mail_to, ".
          "mailfrom is $mail_from, ".
          "subject is $mail_from",
          "debug","2","$caller");

  my $mailDate="Date: $fdate";
  my $mailTo="To: $mail_to";
  my $mailFrom="From: $mail_from";
  my $mailSubject="Subject: $mail_subject";
  my $syscommand="$mailer -f'$mail_from' $mail_to";

  &log_it("header is @mail_header ".
          "and mail body is @mail_body ".
          "message content is @message_content\n\n",
          "debug","3","$caller");

  if (open(MAILER, "| $syscommand")) {
    print MAILER @mail_header;
    foreach(@mail_body) {
      print MAILER $_."\n";
    }
    close MAILER or
      &log_it("Could not close MAILER :: $syscommand :: $!\n",
              "error","1","$caller");
  } else {
    &log_it(":: Could not open Mailer $mailer:: ".
            "Cannot send emails",
            "error","1","$caller");
  }
}

sub mail_smtp {
  my $subname="sub mail_smtp";
  my $caller=$myname." :: ".$subname;

  &chkmod_exists("Net::SMTP");
  &log_it("It appears $mod_use is available using this",
          "debug","3","$caller");
  eval {
    require "$mod_use.pm";
    "$mod_use.pm"->import();
  };
  &log_it("In $myname ::".
          "Using $mod_name loaded $mod_use".
          "eval returned $@",
          "debug","3","$caller");

  my $mailer = Net::SMTP->new(
                                Host => $mail_host,
                                Timeout => 10,
                                Debug   => 1,
                              );
  $mailer->mail($mail_from);
  $mailer->recipient($mail_to,
                     { Notify => ['FAILURE','DELAY'], SkipBad => 1});
  $mailer->data();
  $mailer->datasend(@mail_header);
  foreach(@mail_body) {
    $mailer->datasend($_."\n");
  }
  $mailer->dataend();
  $mailer->quit();
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
# To access documentation please use perldoc MailHandler.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

MailHandler.pm - Automaton Framework
               - Major updates for Google Authenticator Automator

=head1 SYNOPSIS

 This is the Mail Handler, It generates an email message as a user is processed

=head1 DESCRIPTION

This Module is a set of functions (sub routines), that handles emailis, it has the following functions:

  1.  send_mail  - This is the publicly exported function and processes the email to be sent.

  2. mail_simple - This uses the local MTA installed on the server to send emails

  3.  mail_smtp - This uses a perl Module (Net::SMTP) To send emails, with no reliance on a system MTA


This module reads in templates from /opt/gauth/templates/email-messages to generate the email messages to send throughi.
The different mail server settings and email address to send from can be set via command line and via the default configuration file.
The reciepient is extracted from ldap via the LDAPCON module.

This should not need to be changed, but if anyone feels like improving it, feel free.
Defaults should be overridden from the the calling script, so again shouldnt need to be modified.

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
