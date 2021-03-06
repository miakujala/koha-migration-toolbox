#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use YAML::XS qw/LoadFile/;
$|=1;

$ENV{ORACLE_SID} = $config->{sid};
$ENV{ORACLE_HOME} = $config->{oracle_home};
our $host = $config->{host};
our $username = $config->{username};
our $password = $config->{password};
our $sid = $config->{sid};
our $port = $config->{port};

my $dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port;", $username, $password) || die "Could no connect: $DBI::errstr";
my $query = "SELECT   item_vw.barcode,item_status.item_status
               FROM   item_status
               JOIN   item_vw ON (item_vw.item_id = item_status.item_id)";


my $sth=$dbh->prepare($query) || die $dbh->errstr;
$sth->execute() || die $dbh->errstr;

my $i=0;
open my $out,">","item_status_data.csv" || die "Can't open the output!";

while (my @line = $sth->fetchrow_array()){
   $i++;
   print ".";
   print "\r$i" unless ($i % 100);
   for my $k (0..scalar(@line)-1){
      if ($line[$k]){
         $line[$k] =~ s/"/'/g;
         if ($line[$k] =~ /,/){
            print $out '"'.$line[$k].'"';
         }
         else{
            print $out $line[$k];
         }
      }
      print $out ',';
   }
   print $out "\n";
}   

close $out;
print "\n\n$i items exported\n";