package libs::FileHandler;
#
##
##########################################################################
#                                                                        #
#       Automaton Framework  / Google Authenticator Automator            #
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
use File::Path;
use File::Copy;
use File::stat;
#################################################
# My Modules
##
# All provided in the ./libs directory
##
##use libs::DBCON;
use libs::LogHandle;
use libs::CMDHandle;
use libs::UserDetails;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&read_cfg $cfg_type @default_accounts @mail_body @system_accounts @write_file %file_user %shad_user %cfg_values @wheel $host_cfg);
use vars qw($cfg_type @default_accounts @mail_body @system_accounts @write_file %file_user %shad_user %cfg_values @wheel $host_cfg);
#################################################
# Variables Exported From Module - Definitions
##
$cfg_type='cmspars';
@default_accounts=();
@system_accounts=();
%file_user=();
%shad_user=();
%cfg_values=();
@wheel=();
$host_cfg='';
@mail_body=();
@write_file=();

#################################################
# Local Internal Variables for this Module
##
my $handle="none";
my $act_expires;
my $group_wheel="none";
my $myname="module FileHandle.pm";

#################################################
#  Sub-Routines / Functions Definitions
##
# This is the actual Body of the module
##
################## READ_CFG #####################
#
# Read in /etc/Automaton/automaton.cfg and start gathering
# database connection information
#
##

sub clean_var {
  my $subname="sub clean_var";
  my $caller=$myname." :: ".$subname;
  my $var='varnull';
  if ("@_" ne '') {
    $var=shift(@_);
  }

  if ( $var eq "varnull" ) {
    &log_it("Empty variable sent to be cleaned ?? ".
            "ERROR :: Bombing OUT ","error","1", "$caller");
  } else {
    $var =~ s/^["]//;
    $var =~ s/["][#]?(\s+)?$//;
    return $var;
  }
}


sub read_cfg {
  my $subname="sub read_cfg";
  my $caller=$myname." :: ".$subname;
  my $n_line;
  my $read_conf='';

  if ("@_" ne '') {
    $cfg_type=shift(@_);
  } if ("@_" ne '') {
    $cfg_file=shift(@_);
  } if ("@_" ne '') {
    $handle=shift(@_);
  }

  if ("$cfg_type" eq "mailpars") {
    $read_conf=$cfg_file."/".$handle."_email.tmplt";
  } else {
    $read_conf="$cfg_file";
  }

  open (readCFG, "$read_conf")
    or die &log_it("Cant open $read_conf :: $!","error","1","$caller");
      my @cfg_params=<readCFG>;
  close (readCFG);

  switch($cfg_type) {
    case "cfgpars" {
      my $caller = "$caller :: cfgpars";
      my $var='';
      foreach (@cfg_params) {
        chomp;
        next if $_=~ /^\s*#/;
        next if $_=~ /^[#]/;

        if ($_=~/logfile_location/) {
          if (!$opt_D) {
            ##$log_dir =~ s/(\w+)(\s).*/$1/;
            (undef, $log_dir)=split /[=]/;
            $log_dir = &clean_var($log_dir);
            &log_it("logfile_location currently $log_dir...","debug","3", "$caller");
          }
        }

        if ($_=~/log_verbosity/) {
          if (!$opt_v) {
            ##$_ =~ s/(\w*)[=](\d+).*/$2/;
            ##$opt_v=$_;
            (undef, $opt_v)=split /[=]/;
            $opt_v = &clean_var($opt_v);
            $globlev=$opt_v;
            &log_it("log_verbosity currently $opt_v :: ".
                    "global level $globlev...",
                    "debug","3", "$caller");
          }
        }

        if ($_=~/host_files/) {
          #$host_cfg =~ s/(\w+)(\s).*/$1/;
          (undef, $host_cfg)=split /[=]/;
          $host_cfg = &clean_var($host_cfg);
          &log_it("host_files currently $host_cfg...","debug","3", "$caller");
        }

        if ($_=~/keystore_location/) {
          if (!$opt_G) {
            (undef, $goog_store)=split /[=]/;
            $goog_store = &clean_var($goog_store);
            &log_it("Google Key file location is currently $goog_store...",
                    "debug","3", "$caller");
          }
        }

        if ($_=~/qrcode_title/) {
          if (!$opt_Q) {
            (undef, $qrcode_title)=split /[=]/;
            $qrcode_title = &clean_var($qrcode_title);
            &log_it("QRCode Title is now set to $qrcode_title...",
                    "debug","3", "$caller");
          }
        }

        if ($_=~/site_url/) {
          if (!$opt_r) {
            (undef, $site_url)=split /[=]/;
            $site_url = &clean_var($site_url);
            &log_it("Site URL currently $site_url...","debug","3", "$caller");
          }
        }

        if ($_=~/use_database/) {
          if (!$opt_c) {
            (undef, $use_db)=split /[=]/;
            $use_db = &clean_var($use_db);
            &log_it("use_database currently $use_db...","debug","3", "$caller");
          }
        }

        if ($_=~/database_dbi/) {
          if (!$opt_c) {
            #$dbi =~ s/(\w+)(\s).*/$1/;
            (undef, $dbi)=split /[=]/;
            $dbi = &clean_var($dbi);
            &log_it("database_dbi currently $dbi...","debug","3", "$caller");
          }
        }

        if ($_=~/database_name/) {
          if (!$opt_c) {
            #$db_name =~ s/(\w+)(\s).*/$1/;
            (undef, $db_name)=split /[=]/;
            $db_name = &clean_var($db_name);
            &log_it("database_name currently $db_name...","debug","3", "$caller");
          }
        }

        if ($_=~/database_table/) {
          if (!$opt_c) {
            (undef, $db_table)=split /[=]/;
            $db_table = &clean_var($db_table);
            &log_it("database_table currently $db_table...","debug","3", "$caller");
          }
        }

        if ($_=~/database_host/) {
          if (!$opt_c) {
            (undef, $db_host) = split /[=]/;
            $db_host = &clean_var($db_host);
            &log_it("database_host currently $db_host...","debug","3", "$caller");
          }
        }

        if ($_=~/database_user/) {
          if (!$opt_c) {
            (undef, $db_user) = split /[=]/;
            $db_user = &clean_var($db_user);
            &log_it("database_user currently $db_user...","debug","3", "$caller");
          }
        }

        if ($_=~/database_pass/) {
          if (!$opt_c) {
            #$db_pass =~ s/^["]//;
            #$db_pass =~ s/["](\s+)?$//;
            (undef, $db_pass) = split /[=]/;
            $db_pass = &clean_var($db_pass);
            &log_it("database_pass currently $db_pass","debug","2", "$caller");
          }
        }

        if ($_=~/use_ldap/) {
          if (!$opt_l) {
            (undef, $use_ldap) = split /[=]/;
            $use_ldap = &clean_var($use_ldap);
            &log_it("USE LDAP currently $use_ldap...","debug","3", "$caller");
          }
        }

        if ($_=~/ldap_server/) {
          if (!$opt_l) {
            (undef, $ldap_server) = split /[=]/;
            $ldap_server = &clean_var($ldap_server);
            &log_it("LDAP Server currently $ldap_server...","debug","3", "$caller");
          }
        }

        if ($_=~/ldap_base/) {
          if (!$opt_l) {
            $_ =~ s/(\w*)[=](.*)/$2/;
            $ldap_base = $_;
            ##(undef, $ldap_base) = split /[=]/;
            $ldap_base = &clean_var($ldap_base);
            &log_it("LDAP Base currently $ldap_base...","debug","3", "$caller");
          }
        }

        if ($_=~/ldap_search/) {
          if (!$opt_l) {
            (undef, $ldap_search) = split /[=]/;
            $ldap_search = &clean_var($ldap_search);
            &log_it("LDAP Search currently $ldap_search...","debug","3", "$caller");
          }
        }

        if ($_=~/ldap_bind/) {
          if (!$opt_l) {
            (undef, $ldap_bind) = split /[=]/;
            $ldap_bind = &clean_var($ldap_bind);
            &log_it("LDAP bind currently $ldap_bind...","debug","3", "$caller");
          }
        }

        if ($_=~/ldap_pass/) {
          if (!$opt_l) {
            (undef, $ldap_pass) = split /[=]/;
            $ldap_pass = &clean_var($ldap_pass);
            &log_it("LDAP pass currently $ldap_pass...","debug","3", "$caller");
          }
        }

        if ($_=~/use_mail/) {
          if (!$opt_E) {
            (undef, $use_mail) = split /[=]/;
            $use_mail = &clean_var($use_mail);
            &log_it("use_mail is $use_mail...","debug","3", "$caller");
          }
        }

        if ($_=~/remote_host/) {
          (undef, $remote_host) = split /[=]/;
          $remote_host = &clean_var($remote_host);
          &log_it("remote host is $remote_host...","debug","3", "$caller");
        }

        if ($_=~/mail_host/) {
          if (!$opt_H) {
            (undef, $mail_host) = split /[=]/;
            $mail_host = &clean_var($mail_host);
            &log_it("mail host is $mail_host...","debug","3", "$caller");
          }
        }

        if ($_=~/mail_to/) {
          if (!$opt_m) {
            if ($use_mail eq 'no') {
              &log_it("ignoring mail_to option as use_mail is disabled",
                      "debug","3", "$caller");
            } else {
              (undef, $mail_to) = split /[=]/;
              $mail_to = &clean_var($mail_to);
              &log_it("mail_to address is $mail_to...","debug","3", "$caller");
            }
          }
        }

        if ($_=~/mail_from/) {
          if (!$opt_M) {
            if ($use_mail eq 'no') {
              &log_it("ignoring mail_from option as use_mail is disabled",
                      "debug","3", "$caller");
            } else {
              (undef, $mail_from) = split /[=]/;
              $mail_from = &clean_var($mail_from);
              &log_it("database_user currently $mail_from...","debug","3", "$caller");
            }
          }
        }
        if ($_=~/user_check/) {
          if (!$opt_U) {
            (undef, my $sys_user)=split /[=]/;
            if ($sys_user =~ /(\w+)/) {
              $pam_user = &clean_var($sys_user);
              &log_it("User To be scanned currently $pam_user...","debug","3", "$caller");
            #} elsif ($opt_U =~ /(\w+)/) {
            #  &log_it("User To be scanned currently $pam_user...","debug","3", "$caller");
            } else {
              $pam_user="$>";
              &log_it("User To be scanned currently $pam_user...","debug","3", "$caller");
            }
          }
        }
      }
    }

    case "gauth_logs" {
      ## Parser for the generated log files, first we read them in then we parse it through and destroy the log.
      my $caller = "$caller :: gauth_logs";
      my $counter = 0;
      ### These are read in by the filehandler and are parsed from the config file ready to be dumped to a db.
      my @scratch=();
      my $qr_url='';
      my $sec_key='';
      my $ver_code='';
      my $gauth_uid='';
      my $gauth_cn='';
      my $gauth_mail='';
      my $gauth_phone='';
      foreach (@cfg_params) {
        chomp;
        next if $_=~ /^\s*#/;
        next if $_=~ /^[#]/;
        &log_it("Line currently  :: $_","debug","3", "$caller");
        if ($_ =~ /https/) {
          $_ =~ s/%3F/&/g;
          $_ =~ s/%3D/=/g;
          $qr_url=$_;
          &log_it("Google Auth QR URL currently :: $qr_url","debug","3", "$caller");
        }
        if ($_ =~ /secret key/) {
          (undef, $sec_key) = split /[:]/;
          $sec_key =~ s/(\s*)(\d+)/$2/;
          &log_it("Secret Key currently :: $sec_key","debug","3", "$caller");
        }
        if ($_ =~ /verification code/) {
          &log_it("Verification code currently :: $_","debug","3", "$caller");
          $ver_code = $_;
          $ver_code =~ s/(\D+)(\d+)/$2/;
          &log_it("Verification code currently :: $ver_code","debug","3", "$caller");
        }
        if ($_ =~ /[0-9]{8}/) {
          &log_it("Scratch code currently :: $scratch[$counter]","debug","3", "$caller");
          $scratch[$counter] = $_;
          $scratch[$counter] =~ s/(\s*)(\d+)/$2/;
          &log_it("Scratch code currently :: $scratch[$counter]","debug","3", "$caller");
          $counter++;
        }
        if ($_ =~ /uid[:]/) {
          (undef, $gauth_uid) = split /[:]/;
          $gauth_uid =~ s/(\s*)(\w+)/$2/;
          &log_it("Users LDAP UID currently :: $gauth_uid","debug","3", "$caller");
        }
        if ($_ =~ /cn[:]/) {
          (undef, $gauth_cn) = split /[:]/;
          $gauth_cn =~ s/(\s*)(\w+)/$2/;
          &log_it("Users LDAP Name currently :: $gauth_cn","debug","3", "$caller");
        }
        if ($_ =~ /mail[:]/) {
          (undef, $gauth_mail) = split /[:]/;
          $gauth_mail =~ s/(\s*)(\w+)/$2/;
          &log_it("Users LDAP email currently :: $gauth_mail","debug","3", "$caller");
        }
        if ($_ =~ /telephoneNumber/) {
          (undef, $gauth_phone) = split /[:]/;
          $gauth_phone =~ s/(\s*)(\w+)/$2/;
          $gauth_phone =~ s/(\d+)(\s)(\d+)/$3/;
          &log_it("Users LDAP Phone extension currently :: $gauth_phone","debug","3", "$caller");
        }
      }
      foreach(@scratch){
        &log_it("scratch code currently :: $_","debug","3","$caller");
      }
    }

    case "genericpars" {
      my $caller = "$caller :: genericpars";
      #### simple generic parser
      ## produces simple hash that can be passed off to the correct module / sub and then processed there
      foreach (@cfg_params) {
        chomp;
        next if $_=~ /^\s*#/;
        next if $_=~ /^[#]/;
        if ($_ =~ /(\w+)=(\".+?\"|\'.+?\'|.+)\s*(#.*|)/) {
          my $varName=$1;
          my $varVal=$2;
          $varVal =~ s/^["]//;
          $varVal =~ s/["](\s+)?$//;
          $cfg_values{$varName} = $varVal ;
        }
      }
      while ( my ($key, $value) = each(%cfg_values) ) {
        &log_it("key $key => value $value","debug","3","$caller");
      }
    }

    case "rulespars" {
      my $caller = "$caller :: rulespars";
      &log_it("selected","debug","3","$caller");
    }

    case "oathpars" {
      my $caller = "$caller :: oathpars";
      &log_it("selected","debug","3","$caller");
      my $oath_user='NONE';

      foreach (@cfg_params) {
        chomp;
        next if $_=~ /^\s*#/;
        next if $_=~ /^[#]/;

        if ($sys_pam) {
          if ($_ =~ /$sys_pam/) {
            &log_it("pam user $sys_pam is in line $_, validating user\n",
                    "debug","3","$caller");
            $oath_user=$sys_pam;
            return $oath_user;
            last;
          }
        } else {
          if ($_ =~ /$auth_name/) {
            &log_it("auth user $auth_name is in line $_, validating user\n",
                    "debug","3","$caller");
            $oath_user=$auth_name;
            return $oath_user;
            last;
          }
        }
      }
      &log_it("user $auth_name does not appear to be in users.oath :: ".
              "returning oath_user as $oath_user",
              "debug","3","$caller");
      return $oath_user;
    }

    case "mailpars" {
      my $caller = "$caller :: mailpars";
      &log_it("selected","debug","3","$caller");
      my $mail_dir="$cfg_file";
      my $handler="$handle";

      ## Sticking all email templates into @mail_templates, maybe necessary later.
      chdir("$mail_dir")
        or die &log_it("Premature Evacuation :: Cannot chdir to $mail_dir ($!)\n",
                       "error","1","$caller");
      my @mail_templates=<*.tmplt>;
      my $mail_cfg=$mail_dir."/".$handler."_email.tmplt";

      my $user= $ENV{'PAM_USER'};
      my ($uname) = getpwnam("$user");

      ## This has been enabled,
      ## but this has been put into place so that multiple email templates can be read in and then the appropriate one
      ## can be passed to libs::MailHandler dependant on what the $mail_template is.
      ##
      switch("$handler"){
        case "generic" {
          &log_it("Scanning mail template directory, $handler defined","debug","3","$caller");
          if (-e "$mail_cfg") {
            foreach (@cfg_params) {
              chomp;
              next if $_=~ /^\s*#/;
              next if $_=~ /^[#]/;
              push(@mail_body, "$_");
            }
          } else {
            &log_it("Premature Evacuation :: config file $mail_cfg does not exist ($!)\n",
                    "error","1","$caller");
          }
        } case "gauthnotify" {
          &log_it("Scanning mail template directory, $handler defined","debug","3","$caller");
          if (-e "$mail_cfg") {
            foreach (@cfg_params) {
              #chomp;
              #next if $_=~ /^\s*#/;
              #next if $_=~ /^[#]/;
              push(@mail_body, "$_");
            }
          } else {
            &log_it("Premature Evacuation :: config file $mail_cfg does not exist ($!)\n",
            "error","1","$caller");
          }
        } case "notunix" {
          &log_it("Scanning mail template directory, $handler defined","debug","3","$caller");
          if (-e "$mail_cfg") {
            foreach (@cfg_params) {
              push(@mail_body, "$_");
            }
          } else {
            &log_it("Premature Evacuation :: config file $mail_cfg does not exist ($!)\n",
            "error","1","$caller");
          }
        } case "accountdisabled" {
          &log_it("Scanning mail template directory, $handler defined","debug","3","$caller");
          if (-e "$mail_cfg") {
            foreach (@cfg_params) {
              push(@mail_body, "$_");
            }
          } else {
            &log_it("Premature Evacuation :: config file $mail_cfg does not exist ($!)\n",
            "error","1","$caller");
          }
        } case "alert" {
          &log_it("Scanning mail template directory, $handler defined","debug","3","$caller");
          if (-e "$mail_cfg") {
            foreach (@cfg_params) {
              chomp;
              next if $_=~ /^\s*#/;
              next if $_=~ /^[#]/;
              push(@mail_body, "$_");
            }
          } else {
            &log_it("Premature Evacuation :: config file $mail_cfg does not exist ($!)\n",
            "error","1","$caller");
          }
        } else {
          &log_it("Handler specified is $handler, this is not valid",
          "error","1","$caller");
        }
      }
    }

    case "passpars" {
      my $caller = "$caller :: passpars";
      foreach (@cfg_params) {
        chomp;
        my ($sys_user,$user_status) = (split /[:]/,$_)[0,6] ;
        foreach (@system_accounts) {
          if ($sys_user eq $_) {
            &log_it("$sys_user matches $_ Account is a system account skipping",
                    "debug","3","$caller :: system_account");
            $sys_user="none";
          }
        }
        foreach(@default_accounts) {
          if ($sys_user eq $_) {
            &log_it("$sys_user matches $_ Account is a default account ignoring",
                    "debug","3","$caller :: passpars :: default_account");
            $sys_user="none";
          }
        }
        if ("$sys_user" eq "none") {
          &log_it("sys_user -> $sys_user == 0, skipping this as it is a system or default account",
                  "debug","3","$caller");
        } else {
          &log_it("sys_user -> $sys_user, adding this entry as this is not system account",
                  "debug","3","$caller");
          $file_user{$sys_user} = $user_status;
        }
      }
    }

    case "shadpars" {
      my $caller = "$caller :: shadpars";
      foreach (@cfg_params) {
        #&log_it("Parsing shadow file\n","debug","3","$caller :: shadpars");
        chomp;
        if ($handle eq "none") {
          &log_it("IGNORING :: Parsing shadow file, user currently $_","debug","2","$caller");
          #my ($shadname, $local_pass, $pass_sdate, $pass_bcdate, $pass_acdate, $pass_warn, $pass_expires, undef)=split /[:]/;
          #&log_it("user=$shadname password=$local_pass account expires=$act_expires \n","debug","3","$caller");
          #push (@{$shad_user{$shadname}}, $local_pass, $pass_sdate, $pass_bcdate, $pass_acdate, $pass_warn, $pass_expires);
        } else {
          if ($_ =~ /$handle/) {
            &log_it("Parsing shadow file, user currently $_","debug","2","$caller");
            my ($shadname, $local_pass, $pass_sdate, $pass_bcdate, $pass_acdate, $pass_warn, undef, $pass_expires, undef)=split /[:]/;
            &log_it("user=$shadname password=$local_pass account expires=$pass_expires","debug","3","$caller");
            push (@{$shad_user{$shadname}}, $local_pass, $pass_sdate, $pass_bcdate, $pass_acdate, $pass_warn, $pass_expires);
            $handle="none";
          }
        }
      }
    }

    case "grouppars" {
      my $caller = "$caller :: grouppars";
      foreach (@cfg_params) {
        #&log_it("Parsing group file","debug","3","$caller");
        chomp;
        if ($handle eq "none") {
          #$group_wheel=(split /[:]/,$_)[3];
          #@wheel=(split /[,]/,$group_wheel);
          &log_it("IGNORING :: Parsing group file handle $handle provided",
          "debug","3","$caller");
        } else {
          if ($_ =~ /$handle/) {
            $group_wheel=(split /[:]/,$_)[3];
            if (defined($group_wheel)) {
              @wheel=(split /[,]/,$group_wheel);
            }else{
              $group_wheel="none";
              @wheel="none";
              &log_it("Wheel Group completely empty","debug","2","$caller");
            }
            $handle="none";
          }
        }
      }
    }

    case "userpars" {
      my $caller = "$caller :: userpars";
      my $csys=0;
      my $cdef=0;
      foreach (@cfg_params) {
        chomp;
        next if $_=~ /^\s*#/;
        next if $_=~ /^[#]/;
        #$_=~ /^(\w+)(\s)?/$1/;
        if ($_ =~ /cfg_type/) {
          $handle=(split /[=]/,$_)[1];
          &log_it("type == $handle _ == $_",
                  "debug","3","$caller :: userpars");
        }
        switch ($handle) {
          case ("system_accounts") {
            &log_it("\$_ currently $_ currently in $cfg_file",
                    "debug","3","$caller :: HANDLE == SYSTEM_ACCOUNTS");
            $system_accounts[$csys]=$_;
            $csys++;
          } case ("default_accounts") {
            &log_it("\$_ currently $_ currently in $cfg_file",
                    "debug","3","$caller :: HANDLE == DEFAULT_ACCOUNTS");
            $default_accounts[$cdef]=$_;
            $cdef++;
          }
        }
      }
    }
    else {
      &log_it("Incorrect cfg_type passed :: $cfg_type ::".
              "This is not Valid ",
              "error","2",
              "$caller");
    }
  }
}

sub write_cfg {
  my $subname="sub write_cfg";
  my $caller=$myname." :: ".$subname;
  my $n_line='';
  my $read_conf='';
  my $write_type='';

  if ("@_" ne '') {
    $write_type=shift(@_);
  }

  ### This has not been fully realised / implemented, left here for a future revision.
  ### Not currently necessary

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
# To access documentation please use perldoc FileHandler.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

FileHandler.pm - Automaton Framework
               - Major updates for Google Authenticator Automator

=head1 SYNOPSIS

FileHandler.pm - File Handler
A sub-routine (function) to handle all of the file parsing events

=head1 DESCRIPTION

This consists of main function &read_cfg,
To use this function, the function requires 2 parameters:

  1. Type of file,
  Each file is evaluated according to type, these are currently:
    * cfgpars
    * genericpars
    * gauth_logs
    * mailpars
    * userpars
    * shadpars
    * grouppars
    * passpars
    * oathpars

  2. The file name,
  This should be the path and the filename to pars.

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
