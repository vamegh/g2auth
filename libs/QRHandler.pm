package libs::QRHandler;
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
use GD::Barcode::QRcode;
use File::Path;
use File::Copy;
#################################################
# My Modules
##
##
use libs::LogHandle;
use libs::CMDHandle;
use libs::UserDetails;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&qrgen &qrimg_write $qrident $qrkey $qrcode_png);
use vars qw($qrident $qrkey $qrcode_png);
#################################################
# Variables Exported From Module - Definitions
##
$qrident='';
$qrkey='';
$qrcode_png='';
#################################################
# Local Internal Variables for this script
##
my $myname=":: module QRHandler";

sub qrgen {
  my $subname="qrgen";
  my $caller=$myname." :: ".$subname;
  if ("@_" ne '') {
    $qrident=shift(@_);
  } if ("@_" ne '') {
    $qrkey=shift(@_);
  }
  binmode(STDOUT);
  $qrcode_png = GD::Barcode::QRcode->new("otpauth://totp/$qrident?secret=$qrkey",{ Ecc=> 'Q',Version=>9,  ModuleSize => 5 })->plot->png;
  &log_it("QR CODE PNG :: \n $qrcode_png \n","debug","3","$caller");
}

sub qrimg_write {
  ## This sub should not be called read as it writes the QRCODE pngs to file from the DB.
  ## but it does it by reading the db, terrible name still.
  my $subname="sub qrimg_write";
  my $caller=$myname." :: ".$subname;
  my $qrimg_pwd='';
  my $qrimg_file='';

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
    ## The config location has not been specified  or the user has no home path specified
    &log_it("Not going to create image in :: $qrimg_pwd ".
            "either the path :: $goog_store is empty ".
            "or the users home path :: $auth_dir",
            "debug","1", "$caller");
  } else {
    open IMAGE, ">$qrimg_file"
      or &log_it("Error :: $!","error","1","$caller");
    print IMAGE $qrcode_png;
    close(IMAGE);

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
# To access documentation please use perldoc AuthHandler.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

QRHandler.pm - Google Authenticator Automater : Gauth-run

=head1 SYNOPSIS

QRCode Generator, generates PNG images of the TOTP QRCode.

=head1 DESCRIPTION

This Module generates the QR Code for the TOTP generated by the google-authenticator program. It grabs the information gathered about the user and created by the google-authenticator program and calls GD::Barcode::QRcode to generate the qrcode for that users specific secret key. It outputs the resultant qrcode as a png image which is stored to later be processed by either DBCON or by the qrimg_write sub.

The data generated is stored in :

  * $qrcode_png -- This is the actual QRCODE as a png image

The main function is qrgen and it requires the following input:

  * $qrident -- This is the user identifier for the google-authenticator mobile app.
  * $qrkey -- This is the users secret key.

the qrccode_png is then either handled by DBCON, which sends / stores the data to a db or by qrimg_write
which writes the image file directly to a png image file on disk, depending on if gauth has been called by root
or by another user, if user is not root the image is stored in the users home directory otherwise it is created
in the goog_store directory which is set in the configuration file.

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
