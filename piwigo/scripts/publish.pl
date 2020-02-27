#!/usr/bin/perl

# Auto publish script for piwigi and piwigo JS
# by cateye
# https://github.com/cateye0/motion
# v 0.1
# */10 * * * * /home/.../scripts/publish.pl >> /var/log/publish.log

use warnings;
use strict;
use DBI;
use File::Copy;

# required libfile-nfslock-perl - perl module to do NFS (or not) locking package
use Fcntl qw(LOCK_EX LOCK_NB);
use File::NFSLock;

# Try to get an exclusive lock on myself.
my $lock = File::NFSLock->new($0, LOCK_EX|LOCK_NB);
die "$0 is already running!\n" unless $lock;

# need to modify
my $sourcedir="/home/src/.../images";
my $destdir="/home/dst/.../piwigo/galleries/garden";
#

# init empty values
my $id="";
my $imagedir="";
my $fullfilename="";
#

print "START\n";

#in localhost:
my $modsn = "dbi:mysql:dbname=motion";
my $mouser = "motion";
my $mopassword = "secretpass";

my $modbh = DBI->connect($modsn, $mouser, $mopassword)
    or die "Can't connect to database: $moDBI::errstr";

my $mosth = $modbh->prepare(
    q{ SELECT filename FROM security2 WHERE downloaded='1' AND published='0' }
    )
    or die "Can't prepare statement: $moDBI::errstr";

my $morc = $mosth->execute()
    or die "Can't execute statement: $moDBI::errstr";


while (my($filename) = $mosth->fetchrow()) {
	print "START\n";
	print "$filename\n";


	my $f ="$filename";
	my $fullfilename  = substr $f, 18;
	print "fullfilename\n";
		   print "$fullfilename\n";
	print "----------\n";

	my $imagedir = substr $fullfilename, 0, 10;
	print "imagedir\n";
		   print "$imagedir\n";
	print "----------\n";


	my $pidsn = "dbi:mysql:dbname=piwigo";
	my $piuser = "piwisql";
	my $pipassword = "secretpass";



	my $pidbh = DBI->connect($pidsn, $piuser, $pipassword)
		or die "Can't connect to database: $piDBI::errstr";

	my $pisth = $pidbh->prepare(
		q{ SELECT id FROM piwigo_categories WHERE name = ? }
		)
		or die "Can't prepare statement: $piDBI::errstr";

	my $pirc = $pisth->execute($imagedir)
		or die "Can't execute statement: $piDBI::errstr";


	my $id = "";
	my $data = $pisth->fetchall_arrayref();
	$pisth->finish;

		foreach $data ( @$data) {

			($id ) = @$data;
			print "DEBUG -11- Found ID in database: ";
			print "$id\n";
			print "DEBUG -12- Need to move images to the gallery\n";
			my $do_move_image = move_image($sourcedir, $fullfilename, $destdir, $imagedir);
			print "DEBUG -12- Need to update piwigo database\n";
			my $do_update_piwigo = update_piwigo();
			print "DEBUG -13- Need to update piwigo JS database\n";
			my $do_update_piwigo_videojs = update_piwigo_videojs($id);
			print "DEBUG -14- Need to update image to published\n";
			print "$filename\n";

			my $publishupdate = "update security2 set published='1' where filename = ?";

			my $do_publishupdate  = $modbh->do($publishupdate, undef, $filename) or die "Can't do statement: $DBI::errstr";

			my $id = "";

		}

	$pidbh->disconnect();

		if ($id eq "")
		{
			print "DEBUG -2- ID not found but found images and it's waiting to publish\n";
			print "DEBUG -21- Need to create directory structure\n";
			my $do_create_directory = create_directory($destdir, $imagedir);
			my $do_create_thumb_directory = create_thumb_directory($destdir, $imagedir);
			print "DEBUG -22- Need to update piwigo database\n";
			my $do_update_piwigo = update_piwigo();

		}


}


sub create_directory
{
	$destdir = $_[0];
	$imagedir = $_[1];
	my $subjob = join '', $destdir, '/', $imagedir;
		if (-d $subjob) {
			print "$subjob exists\n";
		} else {
			print "$subjob does not exist!";
		mkdir  $subjob or die "Error creating directory: $subjob";
		}
}

sub create_thumb_directory
{
	$destdir = $_[0];
	$imagedir = $_[1];
	my $subjob = join '', $destdir, '/', $imagedir, '/', 'pwg_representative';
		if (-d $subjob) {
			print "$subjob exists\n";
		} else {
			print "$subjob does not exist!";
		mkdir  $subjob or die "Error creating directory: $subjob";
		## 33 = www-data uid ang guid
		chown 33, 33, $subjob or die "Error modify owner: $subjob";
		}
}

sub move_image
{
	$sourcedir = $_[0];
	$fullfilename = $_[1];
	$destdir = $_[2];
	$imagedir = $_[3];
	my $sourcepath = join '', $sourcedir, '/', $fullfilename;
	my $destpath = join '', $destdir, '/', $imagedir, '/';

	move($sourcepath, $destpath) or die "The move operation failed: $sourcepath";
}

sub update_piwigo
{

	system("/home/.../scripts/piwigo_refresh.pl --user=siteadmin --password=sitepass --caddie=1 --privacy_level=2 --cat=5 --subcat=1");

}

sub update_piwigo_videojs
{
	$id = $_[0];
	system("/home/.../scripts/piwigo_refresh_videojs.pl --cat=$id");

}


# check for problems which may have terminated the fetch early
#warn $sqliteDBI::errstr if $sqliteDBI::err;

$mosth->finish();
$modbh->disconnect();
