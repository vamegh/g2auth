package libs::AuthHandler;
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
# External Modules
##
use Expect;
use File::Path;
use File::Copy;
use Switch '__';
use MIME::Base32 qw( RFC );

#################################################
# My Modules
##
##
use libs::LogHandle;
use libs::CMDHandle;
use libs::UserDetails;
use libs::GenDate;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&gauth_run &key_gen &mv_googfile @scratch @qr_code $auth_command $qr_url $sec_key $ver_code);
use vars qw(@scratch $auth_command @qr_code $qr_url $sec_key $ver_code);
#################################################
# Variables Exported From Module - Definitions
##
@scratch=();
@qr_code=();
$auth_command = '/usr/bin/google-authenticator';
$qr_url='';
$sec_key='';
$ver_code='';
#################################################
# Local Internal Variables for this script
##
my $myname=":: module AuthHandler";
my $caller="$myname";
my $timeout = 10;
my @gauth_values=();

# Uncomment the following line if you want to see what expect is doing
#$Expect::Exp_Internal = 1;

# Uncomment the following line if you don't want to see any output from the script
$Expect::Log_Stdout = 0;

sub gauth_run {
  my $subname="gauth_run";
  my $caller=$myname." :: ".$subname;
  my $gauthkey_pwd='';
  my $gauthkey_file='';
  my $command_run='';

  if ("@_" ne '') {
    $gauthkey_pwd=shift(@_);
  }

  if (! -e $auth_command) {
      &log_it("Cannot find $auth_command :: $! :: Aborting",
      "error","1","$caller");
  }

  if ($gauthkey_pwd) {
    $gauthkey_file="$gauthkey_pwd/.google_authenticator";
    &log_it("Creating directory $gauthkey_pwd ".
            "if it doesnt exist",
            "debug","3", "$caller");
    if (! -e "$gauthkey_pwd") {
      eval { mkpath("$gauthkey_pwd" ,1, 0700) }
        or &log_it("Cannot make path :: ".
                   "$gauthkey_pwd :: $!",
                   "error","1","$caller");
    }

    $command_run = "$auth_command -s $gauthkey_file";
  } else {
    $command_run = "$auth_command";
  }

  # Create the Expect object
  my $exp = Expect->spawn($command_run)
    or &log_it("Cannot spawn $command_run","error","1","$caller");

  ## Checking to see if it asks about whether
  ## it should be time based or host based :
  if ($exp->expect(10, '-re','.*time-based \(y/n\)\s*')) {
    $exp->send("y\r");
  }

  # Checking to see if it asks to update password file
  if ($exp->expect(10, '-re','.*file \(y/n\)\s*')) {
    $exp->send("y\r");
  }

  my $gauth_out=$exp->before();
  &log_it("Google Authenticator output currently :: $gauth_out",
          "debug","3","$caller");
  @gauth_values = split /\r/, $gauth_out;
  &gauth_parse;

  &log_it("\nAllowing multiple Logins","debug","2","$caller");
  if ($exp->expect(10, '-re', '.*attacks \(y/n\)\s*')) {
    $exp->send("n\r");
  }

  &log_it("\nLeaving key change time at default 30 seconds",
          "debug","2","$caller");
  if ($exp->expect(10, '-re', '.*to do so \(y/n\)\s*')) {
    $exp->send("n\r");
  }

  &log_it("\nEnabling rate limiting","debug","2","$caller");
  if ($exp->expect(10, '-re', '.*rate-limiting \(y/n\)\s*')) {
    $exp->send("y\r");
  }

  # Destroy the expect object
  $exp->soft_close();
}

sub key_gen {
  my $subname="sub key_gen";
  my $caller=$myname." :: ".$subname;
  my @chars=();

  ### goog store is created by either the config file or via command line -G option,
  ### we only need to call it here, its actually exported from CMDHandle.
  ## auth_name is created and exported by UserDetails.pm
  my $key_pwd='';
  my $key_file='';
  ##my $keyfile_loc = '';
  my $scratch_num=5;
  my $count=0;

  &log_it("This generates a 16 Character secret key ".
          "which can be used directly with google authenticator",
          "debug","3", "$caller");
  &log_it("It also generates the scratch codes",
          "debug","3", "$caller");

  ### This module is not fully realised yet
  #$sec_key = &gen_string("string","16");

  ## A more secure method to generate the key using /dev/random

  my $seed=`dd if=/dev/urandom bs=1 count=10`;
  $sec_key = MIME::Base32::encode( "$seed" );

  &log_it("seed currently ::".$seed.
          ":: code is ::".$sec_key."::\n\n",
          "debug","3","$caller");

  for ($count=0; $count < $scratch_num; $count++) {
    $scratch[$count] = &gen_string("digit","8");
  }

  $qr_url="Not Generated";
  @chars=("Not Generated");

  ## google authenticator file layout.
  ## after the secret key :
  ## " RATE_LIMIT 3 30 1341582502
  ## " TOTP_AUTH
  ## which is simple enough except I have no idea what the last number for the rate limit line is
  ## Turns out its a time stamp and it is auto generated by the PAM module, which I had no idea about.
  ## Also turns out the scratch codes are auto generated everytime they are used.
  ## If the user is root the file is automatically copied into place
  ## if the user is anyone else it is copied to their home directory

  &log_it("auth_name :: $auth_name ".
          "sysuser :: $sys_user ",
          "debug","3", "$caller");

  if ($auth_name eq 'root' or $sys_user eq 'root') {
    $key_pwd= "$goog_store/users/$auth_name";
    $key_file= "$key_pwd/.google_authenticator";
    &log_it("auth_name :: $auth_name ".
            "sysuser :: $sys_user ".
            "Working with $key_file",
            "debug","3", "$caller");
  } else {
    $key_pwd = "$auth_dir";
    $key_file = "$key_pwd/.google_authenticator";
    &log_it("auth_name $auth_name is not root ".
            "Working with $key_file",
            "debug","3", "$caller");
  }

  &log_it("Creating directory $key_pwd ".
          "if it doesnt exist",
          "debug","3", "$caller");
  if (! -e "$key_pwd") {
    eval { mkpath("$key_pwd" ,1, 0700) }
      or &log_it("Cannot make path :: ".
                 "$key_pwd :: $!",
                 "error","1","$caller");

  }

  if (!$goog_store or !$auth_dir) {
    ## The config location has not been specified  or the user has no home path specified
    &log_it("Not going to move to :: $key_pwd ".
            "either the path :: $goog_store is empty ".
            "or the users home path :: $auth_dir",
            "debug","1", "$caller");
  } else {
    if (-e $key_file) {
      &log_it("It appears a $key_file already exists :: ".
              "Moving it out of the way ",
              "debug","1", "$caller");
      my $mode=0600; chmod $mode, "$key_file";
      move("$key_file","$key_file.$date.$time");
      $mode=0400; chmod $mode, "$key_file.$date";
    }

    open KEYFILE, ">$key_file"
      or &log_it("Cannot open $key_file: $! ::".
                 "This is not good !\n",
                 "error","1","$caller");
        print KEYFILE "$sec_key\n".
                      "\" RATE_LIMIT 3 30\n".
                      "\" TOTP_AUTH\n";
        foreach(@scratch) {
          print KEYFILE "$_\n";
        }
    close(KEYFILE);
    #my $mode=0400; chmod $mode, "$key_file";
    my $mode=0400; chmod $mode, "$key_file"
      or &log_it("Unable to change mode of directory :: ".
                 "$key_file :: $!",
                 "error","2","$caller");
  }
}

sub gen_string {
  my $subname="gen_string";
  my $caller=$myname." :: ".$subname;
  ## The idea taken from
  ## http://speeves.erikin.com/2007/01/perl-random-string-generator.html
  ## This generates the key and passwords
  ## ready for dumping into location the key is base32 check the char pool.
  my @chars=();
  my $pass='';
  my $pwtype='';
  my $string_len='';

  if ("@_" ne '') {
    $pwtype=shift(@_);
  } if ("@_" ne '') {
    $string_len=shift(@_);
  }

  switch ($pwtype) {
    case "string" {
      @chars=('A'..'Z','2'..'7');
      &log_it("pwtype :: $pwtype creating base32 secret",
              "debug","3", "$caller");
    } case "digit" {
      @chars=('0'..'9');
      &log_it("pwtype :: $pwtype creating scratch codes",
              "debug","3", "$caller");
    } else {
      &log_it("Not creating password, ".
              "invalid pwtype :: $pwtype",
              "debug","1","$caller");
    }
  }

  foreach (1..$string_len) {
     $pass.=$chars[rand @chars];
  }
 return $pass;
}

sub gauth_parse {
  my $subname="gauth_parse";
  my $caller=$myname." :: ".$subname;
  my $counter=0;

  foreach(@gauth_values) {
    chomp;
    next if $_=~ /^\s*#/;
    next if $_=~ /^[#]/;
    if ($_ =~ /https/) {
      $_ =~ s/%3F/&/g;
      $_ =~ s/%3D/=/g;
      $qr_url=$_;
      &log_it("Google Auth QR URL currently :: $qr_url",
              "debug","3", "$caller");
    }

    if ($_ =~ /30\;47\;27m/) {
      push(@qr_code, $_);
      ##&log_it("Google Auth QR Code currently :: @qr_code","debug","3", "$caller");
    }

    if ($_ =~ /secret key/) {
      (undef, $sec_key) = split /[:]/;
      ##$sec_key =~ s/(\s*)(\w+)/$2/;
      $sec_key =~ s/(\W+)(\w+)/$2/;
      &log_it("Secret Key currently :: $sec_key",
              "debug","3", "$caller");
    }

    if ($_ =~ /verification code/) {
      &log_it("Verification code currently :: $_",
              "debug","3", "$caller");
      $ver_code = $_;
      $ver_code =~ s/(\D+)(\d+)/$2/;
      &log_it("Verification code currently :: $ver_code",
              "debug","3", "$caller");
    }

    if ($_ =~ /[0-9]{8}/) {
      $scratch[$counter] = $_;
      $scratch[$counter] =~ s/(\s*)(\d+)/$2/;
      &log_it("Scratch code currently :: $scratch[$counter]",
              "debug","3", "$caller");
      $counter++;
    }
  }
  foreach(@scratch){
    &log_it("Checking Scratch array independantly :: ".
            "scratch code currently :: $_",
            "debug","3","$caller");
  }
}


sub mv_googfile {
  my $subname="sub mv_googfile";
  my $caller=$myname." :: ".$subname;

  ### goog store is created by either the config file
  ### or via command line -G option, we only need to call it here,
  ### its actually exported from CMDHandle.
  ## auth_name is created and exported by UserDetails.pm
  #my $gofile_location="$goog_store/$auth_name";
  #my $gofile_name=".google_authenticator";
  my $key_pwd='';
  my $key_file='';
  my $key_name='.google_authenticator';
  my $mode='';

  ## Checking to see if this script is being called by root,
  ## if not then dont move the file,
  ## only root has permissions to access the file forced by pam,
  ## so it must be put in place by root.

  if ($auth_name eq 'root' or $sys_user eq 'root') {
    $key_pwd= "$goog_store/users/$auth_name";
    $key_file= "$key_pwd/$key_name";
    &log_it("auth_name :: $auth_name ".
            "sysuser :: $sys_user ".
            "Working with $key_file",
            "debug","3", "$caller");

    if (!$goog_store) {
      &log_it("Not going to move to $key_pwd :: ".
              "the path $goog_store is empty",
              "debug :: $!","1", "$caller");
    } else {
      if (-e $key_file) {
        &log_it("It appears a $key_file already exists :: ".
                "Moving it out of the way ",
                "debug","1", "$caller");
        $mode=0600; chmod $mode, "$key_file";
        eval { move("$key_file","$key_file.$date.$time") }
          or &log_it("move failed for $key_file :: $!",
                     "error","2","$caller");
        $mode=0400; chmod $mode, "$key_file.$date";
      }

      &log_it("Creating directory $key_pwd ".
              "if it doesnt exist",
              "debug","3", "$caller");
      if ( ! -e "$key_pwd") {
        eval { mkpath("$key_pwd" ,1, 0700) }
          or &log_it("Cannot make path :: ".
                     "$key_pwd :: $!",
                     "error","1","$caller");
      }
      &log_it("Currently in $subname :: ".
              "Moving file from /$sys_user/$key_name :: ".
              "Moving file to $key_file",
              "debug","3", "$caller");
      $mode=0600; chmod $mode, "$key_file";
      eval { move("/$sys_user/$key_name","$key_file") }
        or &log_it("move failed to $key_file :: $!",
                   "error","1","$caller");
      $mode=0400; chmod $mode, "$key_file.$date";
    }
  } else {
      &log_it("Not going to move the $key_name into $goog_store :: ".
              "gauth must be called by root for the file to be moved",
              "debug","1","$caller");
    ## Has the actual path been set in the config file ?
    ## if not dont move anything.
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
# To access documentation please use perldoc AuthHandler.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

AuthHandler.pm - Google Authenticator Automater : Gauth

=head1 SYNOPSIS

Main wrapper around the Google-Authenticator application

=head1 DESCRIPTION

This Module has two modes of operation :

1. Uses expect to call the google-authenticator program, it grabs the information created by the
google-authenticator program and stores the information to later be stored and processed by other modules.
this is done by the following subs (functions):

  * gauth_run
  * gauth_parse
  * mv_googfile

gauth_run executes the google_authenticator program via expect.
gauth_parse parses through all of the data generated by the expect run and grabs only relevant information.
mv_googfile can then be called to move the generated file by google_authenticator into place.
the mv_googfile method is now pretty redundant the google_authenticator program is called with the -s
option which allows the .google_authenticator file to be generated in a user specified location which is
passed to the sub from the main program.


2. Generates all of the information required directly without relying on google_authenticator.
It works with the following subs (functions) :

  * key_gen
  * gen_string

key_gen calls gen_string, which generates a base 32 random secret key and also generates an 8 digit random scratch code.
A more secure method is now in operation, key_gen does a command line call to /dev/urandom and generates a seed which is
then converted to base32 and this becomes the secret key, but the scratch code is still generated by gen_string which uses
the inbuilt perl rand() function.

The data generated is stored in :

  * @scratch
  * @qr_code
  * $auth_command
  * $qr_url
  * $sec_key
  * $ver_code

these are then handled by DBCON

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
