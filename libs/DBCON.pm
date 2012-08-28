package libs::DBCON;
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
use Getopt::Std;
use Switch '__';
use File::Path;
use File::Copy;
#################################################
# External Modules
##
# These will need to be installed on the system
# running this script
##
use DBI;
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use libs::LogHandle;
use libs::CMDHandle;
use libs::GenDate;
use libs::FileHandler;
use libs::AuthHandler;
use libs::LDAPCON;
use libs::QRHandler;
use libs::UserDetails;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&db_connect %user_db $username $passwd $ssh_type $ssh_key $ssh_mail $is_admin $is_deleted $expires);
use vars qw(%user_db $db_name $db_hid $db_host $username $passwd $ssh_type $ssh_key $ssh_mail $is_admin $is_deleted $expires);
#################################################
# Variables Exported From Module - Definitions
##
## DataBase Values
%user_db=();
$username='';
$passwd='';
$ssh_type='';
$ssh_key='';
$ssh_mail='';
$is_admin='';
$is_deleted='';
$expires='';
##$db_type='';
#################################################
# Local Internal Variables for this Module
##
my $myname=":: module DBCON.pm";
#################################################
#  Sub-Routines / Functions Definitions
##
# connect to database and write info
# log into db:
##
sub db_connect {
  my $subname="sub db_connect";
  my $caller=$myname." :: ".$subname;
  &log_it("In db_connect","debug","3","$caller");
  my $db_type=$dbi;

  if ($use_db=~/no/i) {
    &log_it ("Database usage is disabled from the configuration, ".
             "Database subsystem will not be used","debug","1","$caller");
  } elsif ($use_db=~/yes/i) {
    switch ($db_type) {
      case "mysql" {
        my $dsn = "dbi:${dbi}:host=${db_host};database=${db_name}:${db_host}:${db_port}";
        my $dbh = DBI->connect($dsn,$db_user,$db_pass)
          or &log_it("cant connect :: $! $DBI::errstr","error","1");
        &db_write($dbh);
        &db_read($dbh);
        &log_it("dsn == $dsn dbh == $dbh Leaving db_connect","debug","3","$caller");
        $dbh->disconnect;
      } case "sqlite" {
        my $db_pwd='';
        my $db_file='';
        if ($auth_name eq 'root' or $sys_user eq 'root') {
          $db_pwd="$goog_store";
          $db_file="$db_pwd/$db_name.db";
        } else {
          $db_pwd="$auth_dir/.gauth";
          $db_file="$db_pwd/$db_name.db";
        }

        &log_it("Creating directory $db_pwd ".
                "if it doesnt exist","debug","3", "$caller");
        if ( ! -e "$db_pwd") {
          eval { mkpath("$db_pwd" ,1, 0700) }
            or &log_it("Unable to make path :: ".
                       "$db_pwd :: $!",
                       "error","2","$caller");
        }

        my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","")
          or &log_it("Error :: $!","error","1","$caller");
        &db_write($dbh,$db_type);
        &db_read($dbh);
        &log_it("dbh == $dbh Leaving db_connect","debug","3","$caller");
        $dbh->disconnect;

        my $mode=0700; chmod $mode, "$db_file"
          or &log_it("Unable to change mode of file :: ".
                     "$db_file :: $!",
                     "error","2","$caller");
      } else {
        &log_it("Sorry the dbi is set to unknown value :: ".
                "$dbi, this is not supported. :: ".
                "Bombing out","error","1","$caller");
      }
    }
  }
}

sub db_write {
  my $subname="sub db_write";
  my $caller=$myname." :: ".$subname;
  my $dbh = shift(@_);
  my $db_type = shift(@_);

  #my $table_test = $dbh->prepare("select * from $db_table");

  my $table_test=$dbh->table_info("", "", $db_table, "TABLE");
  &log_it ("table test currently ::".$table_test."::","debug","3","$caller");

  if ($table_test->fetch) {
  #if ($table_test){
    &log_it( "Table $db_table exists skipping creation","debug","2","$caller");
  } else {
    switch ($db_type) {
      case "mysql" {
        $dbh->do( "CREATE TABLE $db_table (skey         VARCHAR(19) PRIMARY KEY,
                                           uid          VARCHAR(255),
                                           cn           VARCHAR(255),
                                           email        VARCHAR(255),
                                           qrurl        VARCHAR(255),
                                           qrcode       BLOB,
                                           qrcode_png   BLOB,
                                           vcode        VARCHAR(9),
                                           scratch1     VARCHAR(9),
                                           scratch2     VARCHAR(9),
                                           scratch3     VARCHAR(9),
                                           scratch4     VARCHAR(9),
                                           scratch5     VARCHAR(9)");
      } case "sqlite" {
        $dbh->do( "CREATE TABLE $db_table (skey         TEXT PRIMARY KEY,
                                           uid          TEXT,
                                           cn           TEXT,
                                           email        TEXT,
                                           qrurl        TEXT,
                                           qrcode       BLOB,
                                           qrcode_png   BLOB,
                                           vcode        INTEGER,
                                           scratch1     INTEGER,
                                           scratch2     INTEGER,
                                           scratch3     INTEGER,
                                           scratch4     INTEGER,
                                           scratch5     INTEGER)");
      }
    }
  }
  &log_it("dbh == $dbh IN db_gather","debug","2","$caller");

  ### Should older entries be deleted ??
  ### They should ideally be deleted / pruned will leave this for the time being.

  my $sth = $dbh->prepare("INSERT INTO $db_table(skey,
                                                  uid,
                                                  cn,
                                                  email,
                                                  qrurl,
                                                  qrcode,
                                                  qrcode_png,
                                                  vcode,
                                                  scratch1,
                                                  scratch2,
                                                  scratch3,
                                                  scratch4,
                                                  scratch5) VALUES (\"$sec_key\",
                                                                    \"$gauth_uid\",
                                                                    \"$gauth_cn\",
                                                                    \"$gauth_mail\",
                                                                    \"$qr_url\",
                                                                    \"@qr_code\",
                                                                    ?,
                                                                    \"$ver_code\",
                                                                    \"$scratch[0]\",
                                                                    \"$scratch[1]\",
                                                                    \"$scratch[2]\",
                                                                    \"$scratch[3]\",
                                                                    \"$scratch[4]\")");
  $sth->bind_param(1, $qrcode_png, DBI::SQL_BLOB);
  $sth->execute();

  my $read_db = $dbh->selectall_arrayref("SELECT * FROM $db_table");
  foreach my $row (@$read_db) {
    my ($skey,$uid,$cn,$email,$qrurl,$qrcode,$qrcpng,$vcode) = @$row;
  }
}

sub db_read {
  ## This sub should not be called read as it writes the QRCODE pngs to file from the DB.
  ## but it does it by reading the db, terrible name still.

  my $subname="sub db_read";
  my $caller=$myname." :: ".$subname;
  my $dbh = shift(@_);
  my $qrimg='';
  my $qrimg_pwd='';
  my $qrimg_file='';

  my $stm = $dbh->prepare("SELECT qrcode_png FROM $db_table WHERE uid=\'$gauth_uid\'");
  $stm->execute();

  ### goog store is created by either the config file
  ### or via command line -G option, we only need to call it here,
  ### its actually exported from CMDHandle.
  ## auth_name is created and exported by UserDetails.pm

  if ($auth_name eq 'root' or $sys_user eq 'root') {
    $qrimg_pwd="$goog_store/users/$auth_name";
    $qrimg_file="$qrimg_pwd/$auth_name.png";
  } else {
    $qrimg_pwd="$auth_dir/.gauth";
    $qrimg_file="$qrimg_pwd/$auth_name.png";
  }

  &log_it("Creating directory $qrimg_pwd ".
          "if it doesnt exist",
          "debug","3", "$caller");
  if ( ! -e "$qrimg_pwd") {
    eval { mkpath("$qrimg_pwd" ,1, 0700) }
      or &log_it("Unable to make path :: ".
                 "$qrimg_pwd :: $!",
                 "error","2","$caller");
  }

  if (!$goog_store or !$auth_dir) {
    ## The config location has not been specified
    ## or the user has no home path specified
    &log_it("Not going to create image in :: $qrimg_pwd ".
            "either the path :: $goog_store is empty ".
            "or the users home path :: $auth_dir",
            "debug","1", "$caller");
  } else {
    while (my @qrimages = $stm->fetchrow_array()){
      &log_it("qrimages = @qrimages\n\n","debug","3","$caller");
      $qrimg = shift(@qrimages);
    }
    open IMAGE, ">$qrimg_file"
      or &log_it("Error :: $!","error","1","$caller");
    print IMAGE $qrimg;
    close(IMAGE);
    $stm->finish();

    my $mode=0700; chmod $mode, "$qrimg_file"
      or &log_it("Unable to change mode of file :: ".
                 "$qrimg_file :: $!",
                 "error","2","$caller");
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
# To access documentation please use perldoc DBCON.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

DBCON.pm - Automaton Framework: Forensic Auditing Toolkit
         - Major updates for Google Authenticator Automator

=head1 SYNOPSIS

 Database Connection Handler

=head1 DESCRIPTION

This consists of 3 main functions,

        1. db_connect
           This connects to the database, using either the command line options passed to it,
           or the information from /opt/gauth/cfgs/gauth.cfg
           Currently this is Connecting to a local Sqlite DB, which it creates, future revisions will bring back MySQL connectivity.
        2. db_write
           This collects all of the information supplied by the different components of gauth and writes them to the gauthers table within the current SQLite DB.
        3. db_read
           This reads the current SQLite DB and extracts the QRCode_PNG field and creates the relevant user QRCODE png image and saves it to /var/log/gauth/<uid>.png.
           Future revisions will disable this functionality, as it should only be needed for testing purposes.

The db_connect function should only ever be called from a script or another module.

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
