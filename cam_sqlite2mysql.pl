#!/usr/bin/perl

use strict;
use DBI;

my $sqlitedsn = "dbi:SQLite:dbname=/var/lib/motion/security.db";
my $sqliteuser = '';
my $sqlitepassword = '';

my $sqlitedbh = DBI->connect($sqlitedsn, $sqliteuser, $sqlitepassword)
    or die "Can't connect to database: $sqliteDBI::errstr";

my $sqlitesth = $sqlitedbh->prepare(
    q{ SELECT camera, filename, frame, file_type, time_stamp, text_event, downloaded FROM security WHERE downloaded='0' }
    )
    or die "Can't prepare statement: $sqliteDBI::errstr";

my $sqliterc = $sqlitesth->execute()
    or die "Can't execute statement: $sqliteDBI::errstr";

while (my($camera, $filename, $frame, $file_type, $time_stamp, $text_event, $downloaded) = $sqlitesth->fetchrow()) {
    print "$camera $filename $frame $file_type $time_stamp $text_event $downloaded\n";


print "lofasz1\n";

my $dsn = "dbi:mysql:dbname=motion;host=10.0.0.1";
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

#       while (my($filename) = $sth->fetchrow()) {
#    print "$filename\n";
#    print "1\n";

#       insert into security(camera, filename, frame, file_type, time_stamp, text_event) values('0', '/var/www/html/cam/2020-01-09-131301-01.jpg', '2', '1', '2020-01-09 22:38:36', '20200109131301')

my $mysqlinsert = "insert into security2(camera, filename, frame, file_type, time_stamp, text_event) values(?, ?, ?, ?, ?, ?)";

#my $statement = "update security set downloaded='1' where filename = ?";

my $rv  = $dbh->do($mysqlinsert, undef, $camera, $filename, $frame, $file_type, $time_stamp, $text_event) or die "Can't do statement: $DBI::errstr";
    print "$mysqlinsert\n";


#}


my $sqliteupdate = "update security set downloaded='1' where filename = ?";

my $rv  = $sqlitedbh->do($sqliteupdate, undef, $filename) or die "Can't do statement: $DBI::errstr";
    print "$sqliteupdate\n";

# check for problems which may have terminated the fetch early
warn $DBI::errstr if $DBI::err;
$sth->finish();
$dbh->disconnect();


}

# check for problems which may have terminated the fetch early
warn $sqliteDBI::errstr if $sqliteDBI::err;

$sqlitesth->finish();
$sqlitedbh->disconnect();


