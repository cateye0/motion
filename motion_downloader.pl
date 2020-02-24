#!/usr/bin/perl

# download image and video files from a remote server which is created by motion
# http://zetcode.com/db/sqliteperltutorial/err/

use warnings;
use strict;
use DBI;
use File::Fetch;


#
# required libfile-nfslock-perl - perl module to do NFS (or not) locking package
use Fcntl qw(LOCK_EX LOCK_NB);
use File::NFSLock;

# Try to get an exclusive lock on myself.
my $lock = File::NFSLock->new($0, LOCK_EX|LOCK_NB);
die "$0 is already running!\n" unless $lock;
#

#use this for remote host
#my $dsn = "dbi:mysql:dbname=motion;host=10.0.0.1";

#in localhost:
my $dsn = "dbi:mysql:dbname=motion";
my $user = "motion";
my $password = "secret";

my $dbh = DBI->connect($dsn, $user, $password)
    or die "Can't connect to database: $DBI::errstr";

my $sth = $dbh->prepare(
    q{ SELECT filename from security2 where downloaded='0' }
    )
    or die "Can't prepare statement: $DBI::errstr";

my $rc = $sth->execute()
    or die "Can't execute statement: $DBI::errstr";

while (my($filename) = $sth->fetchrow()) {
#    print "$filename\n";
#    print "1\n";

my $f ="$filename";
my $fullpath  = substr $f, 18;
#	print "$fullpath\n";

my $url = "http://10.10.10.20/cam/${fullpath}";
#	print "$url\n";

my $ff = File::Fetch->new(uri => $url);
my $file = $ff->fetch(to => '/home/www/cateye.hu/cam/') or die $ff->error;


my $statement = "update security2 set downloaded='1' where filename = ?";

my $rv  = $dbh->do($statement, undef, $filename) or die "Can't do statement: $DBI::errstr";



}

# check for problems which may have terminated the fetch early
warn $DBI::errstr if $DBI::err;

$sth->finish();
$dbh->disconnect();
