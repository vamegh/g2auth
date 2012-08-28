package libs::CMDHandle;
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
use Getopt::Std;
use Pod::Usage;
#################################################
# My Modules
##
# All provided in the ./libs directory
##
##use libs::UserDetails;
use libs::GenDate;
use libs::Colour;
use libs::LogHandle;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT   = qw(cmd_handle $opt_Q $opt_D $opt_C $opt_c $opt_L $opt_l $opt_h $opt_i $opt_f $opt_d $opt_t $opt_u $opt_U $opt_p $opt_P $opt_v $opt_l $opt_b $opt_n $opt_s $opt_S $opt_w $opt_G $cfg_file $use_db $db_name $db_table $db_hid $db_host $db_user $db_pass $dbi $db_port $max_fsize $image_dd $image_size $image_dd_store $image_compress $opt_E $opt_m $opt_M $opt_H $use_mail $mail_to $mail_from $mail_host $remote_host $use_ldap $ldap_base $ldap_bind $ldap_pass $ldap_search $ldap_server $pam_user $goog_store $qrcode_title);
use vars qw($opt_Q $opt_D $opt_C $opt_c $opt_L $opt_l $opt_h $opt_i $opt_f $opt_d $opt_t $opt_u $opt_U $opt_p $opt_P $opt_v $opt_l $opt_b $opt_n $opt_s $opt_S $opt_w $opt_G $cfg_file $use_db $db_name $db_table $db_hid $db_host $db_user $db_pass $dbi $db_port $opt_E $opt_m $opt_M $opt_H $use_mail $mail_to $mail_from $mail_host $remote_host $use_ldap $ldap_base $ldap_bind $ldap_pass $ldap_search $ldap_server $pam_user $goog_store $qrcode_title);
#################################################
# Variables Exported From Module - Definitions
##
## Full list of currently supported command line switches
$opt_D='';
$opt_C='';
$opt_c='';
$opt_L='';
$opt_h='';
$opt_i='';
$opt_f='';
$opt_d='';
$opt_t='';
$opt_u='';
$opt_U='';
$opt_p='';
$opt_P='';
$opt_v='';
$opt_E='';
$opt_m='';
$opt_M='';
$opt_H='';

$opt_l='';
$opt_b='';
$opt_n='';
$opt_w='';
$opt_S='';
$opt_s='';
$opt_G='';
$opt_Q='';

$cfg_file='/opt/gauth/cfgs/gauth.cfg';
$use_db='';
$db_name='';
$db_table='';
$db_hid='';
$db_host='';
$db_user='';
$db_pass='';
$dbi='';
$db_port="3206";
$use_mail='';
$mail_to='';
$mail_from='';
$mail_host='';
$remote_host='';
$use_ldap='';
$ldap_base='';
$ldap_bind='';
$ldap_pass='';
$ldap_search='';
$ldap_server='';
$pam_user='';
$goog_store='';
$qrcode_title='';

#################################################
# Local Internal Variables for this Module
##
### generate the date and user info first
&make_date;

# SCRIPT VERSION AND NAME INFORMATION
##
my $ScriptVer="v0.11";
my $ScriptTitle="Google Authenticator Automater";
my $Name="Vamegh Hedayati";
my $modDate="2012";
my $modName="Vamegh Hedayati";
my $scriptName="Gauth";

## INIT VARS
## set this to a decent value to allow for proper alignment -
## max no. of characters you are probably going to encounter.
my $nLen = 50;
my $myname="module CMDHandle.pm ";
#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##
$Getopt::Std::STANDARD_HELP_VERSION = 0;
$Getopt::Std::STANDARD_HELP_VERSION = 1;
## Full list of currently supported command line switches
getopts('v:E:Q:m:M:H:L:l:b:n:w:S:s:h:d:i:p:u:U:G:P:f:cCD') || pod2usage(2);



############ COMMAND LINE SETUP #################
############ & INITIALISE SCRIPT ################
# --help output
##
sub main::HELP_MESSAGE {
# arguments are the output file handle,
# the name of option-processing package, its version, and the switches string
## idea and design taken from linblock.pl script
  pod2usage( { -exitval => "1", -output => $_[0], -verbose => 1} );
  pod2usage(1);
}

#### --version output
sub main::VERSION_MESSAGE {
  print $blue."\n\t$ScriptTitle".$yellow." - ".
        $blue."$ScriptVer\n".$reset;
  print $blue."\tCreated by ".$yellow."$Name\n";
  print $blue."\tCurrent Date: ".
        $yellow." $date\n";
  print $reset."\n\n";
}

sub cmd_handle {
  my $subname="sub cmd_handle";
  my $caller=$myname." :: ".$subname;
  if ($opt_C) {
    &Colour(1);
    &log_it("Colour settings enabled",
            "debug","2",
            "$caller :: using -c adding colour");
  }

  if ($opt_v ne '')  {
    &log_it("opt_v currently $opt_v",
            "debug","3","$caller :: using -v");
    pod2usage("Error: verbose (-v) value outside of range, ".
              "type --help for correct usage options")
      if (("$opt_v" > "3") or ("$opt_v" < "1"));
    $globlev=$opt_v;
  }

 #   if ($opt_l =~ /(\w+)/) {
 #     &log_it("opt_l currently $opt_l","debug","3","$caller :: using -l");
 #     $ldap_server=$opt_l;
 #   } else {
 #     &log_it("using default ldap server $ldap_server, ".
 #             "since none specified", "debug", "3", "$caller :: using -l");
 #   }
 # }

  if ($opt_U ne '') {
      &log_it("User Specified :: opt_U currently $opt_U",
              "debug","3","$caller :: using -U");
      $pam_user=$opt_U;
  } else {
    $pam_user="$>";
  }

  if ($opt_G ne '') {
      &log_it("Google authenticator file Store specified :: ".
              "opt_G currently $opt_G",
              "debug","3","$caller :: using -G");
      $goog_store=$opt_G;
  }

  if ($opt_E ne '') {
    &log_it("You have chosen to specify email details manually, ".
            "for help type --help or perldoc Gauth",
            "debug","2","$caller :: using -E");
    pod2usage("Error: Send emails can either be yes or no, ".
              "type --help for correct usage options")
      if (("$opt_E" ne 'yes') or ("$opt_E" ne 'no'));
    $use_mail=$opt_E;
    switch ("$use_mail") {
      case("yes") {
        &log_it("Enabling the Mail Subsystem, use_mail is $use_mail",
                "debug","3","$caller :: using -E $use_mail");
        if (defined($opt_m)) {
          $mail_to=$opt_m;
          &log_it("Mail to address set to $mail_to",
                  "debug","3","$caller :: using -m $mail_to");
        }
        if (defined($opt_M)) {
          $mail_from=$opt_M;
          &log_it("Mail from address set to $mail_from",
                  "debug","3","$caller :: using -M $mail_from");
        }
        if (defined($opt_H)) {
          $mail_host=$opt_H;
          &log_it("Mail Host set to $mail_host",
                  "debug","3","$caller :: using -H $mail_host");
        }
      } case("no") {
        &log_it("Disabling the Mail Subsystem, ".
                "use_mail is $use_mail",
                "debug","3",
                "$caller :: using -E $use_mail");
      } else {
        &log_it ("Error: A correct value was not passed ".
                 "to the use_mail routine",
                 "error","1","$caller");
      }
    }
  }

  if ($opt_Q=~ /(\w+)/) {
    &log_it("Setting The QRCode Title to $opt_Q",
            "debug","3","$caller :: using -Q");
    $qrcode_title = $opt_Q;
  }

  if ($opt_D) {
    &log_it("Not logging to file as requested",
            "debug","2","$caller :: using -D");
    $log_dir="none";
  } elsif ($opt_L =~ /(\w+)/) {
    $log_dir=$opt_L;
  } else {
    &log_it("Writing to $log_dir, since none specified",
            "debug", "3", "$caller :: using -L");
  }

  if ($opt_l ne '') {
    &log_it("You have chosen to specify ldap details manually, ".
            "for help type --help or perldoc Gauth",
            "debug","2","$caller :: using -l");
    pod2usage("Error: use ldap can either be yes or no, ".
              "type --help for correct usage options")
      if (("$opt_l" ne 'yes') or ("$opt_l" ne 'no'));
    $use_ldap=$opt_l;
    switch("$use_ldap") {
      case("yes") {
        &log_it("Enabling the LDAP Subsystem :: ".
                "use_ldap is $use_ldap",
                "debug","3",
                "$caller :: using -l $use_ldap");
        if (!$opt_s or !$opt_n or !$opt_b or !$opt_S or !$opt_w) {
          pod2usage("Error: ldapserver(-s), ".
                    "\nldap bind address(-n), ".
                    "\nldap base address(-b),".
                    "\nldap search string(-S)".
                    "\n ldap password (-w)".
                    "\n must be specified if you manually".
                    "specify the ldap subsystem, ".
                    "\nplease use anon for user and password".
                    "if you intend to do an anonymous bind");
        } else {
          $ldap_server="$opt_s";
          $ldap_base="$opt_b";
          $ldap_search="$opt_S";
          $ldap_bind="$opt_n";
          $ldap_pass="$opt_w";
          &log_it("ldap_server = $ldap_server, ldap_base = $ldap_base,
                   ldap_search= $ldap_search, ldap_bind = $ldap_bind,
                   ldap_pass = $ldap_pass ",
                   "debug", "2", "$caller :: using -l");
        }
      } case("no") {
        &log_it("Disabling the ldap Subsystem, ".
                "use_ldap is $use_ldap",
                "debug","3",
                "$caller :: using -l $use_ldap");
      } else {
        &log_it ("Error: A correct value was not passed ".
                 "to the use_ldap routine",
                 "error","1","$caller");
      }
    }
  }

  if ($opt_c ne '') {
    &log_it("You have chosen to specify database details manually, ".
            "for help type --help or perldoc Gauth",
            "debug", "2", "$caller :: using -c");
    pod2usage("Error: use database(-c) can either be yes or no, ".
              "type --help for correct usage options")
      if (("$opt_c" ne 'yes') or ("$opt_c" ne 'no'));
    $use_db=$opt_c;

    switch("$use_db") {
      case("yes") {
      &log_it("Enabling the DB Subsystem :: ".
                "use_db is $use_db",
                "debug","3",
                "$caller :: using -c $use_db");
      if (!$opt_h or !$opt_d or !$opt_P or !$opt_u or !$opt_p or !$opt_i) {
        pod2usage("Error: host(-h), ".
                  "host_id (-i), ".
                  "database(-d), ".
                  "database_tablename(-t), ".
                  "port(-P), ".
                  "username(-u) ".
                  "and password(-p) ".
                  "must be specified if specifying use ".
                  "database via Command Line(-c)");
      } else {
        $dbi='mysql';
        $db_name=$opt_d;
        $db_table=$opt_t;
        $db_host=$opt_h;
        $db_user=$opt_u;
        $db_pass=$opt_p;
        $db_port=$opt_P;
        $db_hid=$opt_i;
        &log_it("db_hid = $db_hid, ".
                "db_user = $db_user, ".
                "db_pass = \'$db_pass\', ".
                "db_name = $db_name, ".
                "db_host = $db_host, ".
                "dbi = $dbi, ".
                "db_port = $db_port",
                "debug", "2",
                "$caller :: using -c");
        }
      } case "no" {
        &log_it("Disabling the db Subsystem, ".
                "use_db is $use_db",
                "debug","3",
                "$caller :: using -c $use_db");
      } else {
        &log_it ("Error: A correct value was not passed ".
                 "to the use_db routine",
                 "error","1","$caller :: using -c $use_db");
      }
    }
  }

  if ($opt_f=~ /(\w+)/) {
    &log_it("opt_f = $opt_f",
            "debug", "2",
            "$caller :: using -f");
    $cfg_file=$opt_f;
    &log_it("Reading in cfg file - $cfg_file ",
            "debug", "3",
            "$caller :: using -f");
  } else {
    $opt_f="none";
    &log_it("using default cfg $cfg_file :: ".
            "This maybe overridden in the main program",
            "debug", "3", "$caller");
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
# To access documentation please use perldoc CMDHandle.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

CMDHandle.pm - Automaton FrameWork
             - Major updates for Google Authenticator Automator

=head1 SYNOPSIS

Command Line options Handler


=head1 DESCRIPTION

This is a sub-routine (function) That handles all of the command line arguement processing.
All of the command line options are optional, the -U option is very useful please read about it below.
The majority of these should be set in the configuration file,
rather than being invoked directly from the command line,
but the choice is ultimately yours.

=head1 OPTIONS

The command line options are as follows:

=over

=item -C I<add colour>

Uses Term::Ansicolor to colourise the logging. If not specified, no colour is output.

=item -D I<dont log to file>

Doesnt log to file, instead outputs everything to the command line.
With this specified -L will be ignored

=item -f I<Specify config file location>

Specify a different config file to use default - /opt/gauth/cfgs/gauth.cfg

=item -v I<Specify Verbosity Level>

Verbosity Level

I<1> verbosity low C<(-v 1)>

I<2> Verbosity medium C<(-v 2)>

I<3> Verbosity High C<(-v 3)>

=item -U I<Specify the Username to Check>

This option is very useful / bordering necessary.
This sets the username that should be checked,
if this option is not set the person running the script will be used for username.
When this program is invoked by the PAM scripts,
this option is set to the PAM_USER environment variable i.e -U is called.
If you do not set this option, please run this program as the user you wish it to configure for.

=item -Q I<Specify the Title for the QR Cocde>

This will be the default title the QR Code generator will use to generate the qr code images
and this will be displayed on all client devices that scan the barcode. There are special values
@@@NAME@@@, @@@EMAIL@@, @@@UNAME@@@ if the qrcode is set to any of these values then the title
will be changed to either be the users name, email or username as stored in LDAP. This option should
really be set in the gauth configuration file.

=item -G I<Google authenticator file store location>

This option specifies where the .google_authenticator
file should be stored.
This option should ideally be set in the configuration file.
:: Please Note :: If this is changed or a new location is specified
the PAM password-auth file will also need to be updated to use this new location.

=item -l I<Use LDAP>

Specify whether or not to use ldap to do user verification.
This must be either yes or no. By default the configuration values from the config file are read in.
Please do not set this via the command line, please use the configuration file.
Please also note the search field is currently ignored.
If you specify this you need to specify the following:

LDAP Base C<(-b)>

LDAP Bind C<(-n)>

LDAP Server C<(-s)>

LDAP Search C<(-S)>

LDAP Pass C<(-w)>

Along with the mentioned flags,  this will not work without all of the above information

=item -b I<LDAP Base>

Specify the Base LDAP Tree to examine.
This must be used in conjuction with -l, the use ldap option detailed above.

=item -n I<LDAP Bind>

Specify the Bind address, This is the username bind.
Please set this to anon, if you wish to bind anonymously.
This must be used in conjuction with -l, the use ldap option detailed above.

=item -s I<LDAP Server>

Specify the Server address to use.
This must be used in conjuction with -l, the use ldap option detailed above.

=item -S I<LDAP Search>

Specify the LDAP Search string, (this is currently ignored)
This must be used in conjuction with -l, the use ldap option detailed above.

=item -w I<LDAP Pass>

Specify the Bind Password, This is the password for the username specified in bind address.
Please set this to anon, if you wish to bind anonymously.
This must be used in conjuction with -l, the use ldap option detailed above.

=item -E I<Use Email>

Specify whether or not to use Email Subsystem.
This must be either yes or no. By default the configuration values from the config file are read in.
Please do not set this via the command line, please use the configuration file.
If you specify this you can also specify the following:

=item -m I<Mail To>

Specify the email address to send emails to.

=item -M I<Mail From>

Specify the email address to send emails from.

=item -H I<Mail Host>

Specify the mail server Host.

=item -c I<database command line input>

Specify whether or not to use a databasee method to store information.
This must be either yes or no. By default the configuration values from the config file are read in.
Please do not set this via the command line, please use the configuration file.
If you specify this you need to specify the following:

hostname C<(-h)>

port C<(-P)>

database C<(-d)>

database table C<(-t)>

username C<(-u)>

password C<(-p)>

database host_id C<(-i)>

Along with the mentioned flags,  this will not work without all of the above information

=item -L I<Logging>

Specifiy where to log to. If not specified logs to default location.

=item -h I<database host>

Specify which database host to connect to, used when the -c option is specified

=item -d I<database>

Specify which database to use, used when the C<(-c)> option is specified.

=item -t I<database_table>

Specify which database table to use, used when the C<(-c)> option is specified.

=item -i I<databse host_id>

Specify which host_id to use, used when the C<(-c)> option is specified

=item -u I<database username>

Specify Username to connect to the database used when the C<(-c)> option is specified

=item -p I<database password>

Specifiy password to connect to the database with.  used when the C<(-c)> option is specified

=item -P I<database port>

Specifiy port to connect to the database.  used when the C<(-c)> option is specified

=item --help

Print command line options summary.  For more detailed help, type C<perldoc -F gauth>.

=item --version

Prints the version information.

=back

=head1 AUTHOR

=over

=item Vamegh Hedayati <vamegh AT gmail DOT com>

=back

=head1 LICENSE

Copyright (C) 2010 / 2012  Vamegh Hedayati <vamegh AT gmail DOT com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

Please refer to the COPYING file which is distributed with Gauth
for the full terms and conditions

=cut
#
#################################################
#
######################################### EOF  #######################################################
