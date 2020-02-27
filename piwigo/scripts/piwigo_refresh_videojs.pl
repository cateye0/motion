#!/usr/bin/perl

# by https://github.com/darenwelsh
# https://github.com/xbgmsharp/piwigo-videojs/issues/44
# perl /directory/to/script/piwigo_refresh_videojs.pl --cat=catid


use strict;
use warnings;

# make it compatible with Windows, but breaks Linux
#use utf8;

use File::Find;
use Data::Dumper;
use File::Basename;
use LWP::UserAgent;
use JSON;
use Getopt::Long;
use Encode qw/is_utf8 decode/;
use Time::HiRes qw/gettimeofday tv_interval/;
use Digest::MD5 qw/md5 md5_hex/;

my %opt = ();
GetOptions(
    \%opt,
    qw/
          base_url=s
          username=s
          password=s
                  cat=s
      /
);

our $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/piwigo_vid_thumbs.pl 1.00');
$ua->cookie_jar({});

my %conf;
my %conf_default = (
    base_url => 'https://domain.tld',
    username => 'siteadmin',
    password => 'sitepass',
);

foreach my $conf_key (keys %conf_default) {
    $conf{$conf_key} = defined $opt{$conf_key} ? $opt{$conf_key} : $conf_default{$conf_key}
}

$ua->default_headers->authorization_basic(
    $conf{username},
    $conf{password}
);

my $result = undef;
my $query = undef;

binmode STDOUT, ":encoding(utf-8)";

# Login to Piwigo
piwigo_login();

piwigo_refresh();

#---------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------

sub piwigo_login {
    $ua->post(
        $conf{base_url}.'/ws.php?format=json',
        {
            method => 'pwg.session.login',
            username => $conf{username},
            password => $conf{password},
        }
    );
}

sub piwigo_refresh {
        $ua->post(
                $conf{base_url}.'/admin.php?page=plugin&section=piwigo-videojs/admin/admin.php&tab=sync',
                {
                        mediainfo => 'mediainfo',
                        ffmpeg => 'ffmpeg',
                        exiftool => 'exiftool',
                        ffprobe => 'ffprobe',
                        metadata => 1,
                        poster => 1,
                        postersec => 4,
                        output => 'jpg',
                        posteroverlay => 1,
                        #posteroverwrite => 0,
                        thumb => 0,
                        thumbsec => 5,
                        thumbsize => "128x68",
                        cat => $conf{cat},
                        subcats_included => 1,
                        submit => 1
                }
        );
}

