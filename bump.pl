#!/usr/bin/perl -w

#
# TODO: Fix auto update of years too!
#

use strict;
use IO::Dir;
use IO::File;

my $month    = "February";
my $major    = 4;
my $minor    = 99;
my $revision = 44;
my $release  = 1;

sub readme {
    my $file  = shift;
    my $lines = shift;
    my $done  = 0;
    foreach my $line (@{$lines}) {
        if ($line =~ m/^ROBODoc\sVersion/) {
            print $line;
            $line =~ s/\d+\.\d+\.\d+\s\S+\s2/$major.$minor.$revision $month 2/;
            print $line;
            print $file $line;
            ++$done;
        } else {
            print $file $line;
        }
    }
    die if ($done != 1);
}

sub robodoc_h {
    my $file  = shift;
    my $lines = shift;
    my $done  = 0;
    foreach my $line (@{$lines}) {
        if ($line =~ m/define\sVERSION\s"/) {
            ++$done;
            $line = "#define VERSION \"$major.$minor.$revision\"\n";
            print $line;
            print $file $line;
        } else {
            print $file $line;
        }
    }
    die if ($done != 1);
}

sub configure_in {
    my $file  = shift;
    my $lines = shift;
    my $done  = 0;
    foreach my $line (@{$lines}) {
        if ($line =~ m/AM_INIT_AUTOMAKE/) {
            ++$done;
            $line = "AM_INIT_AUTOMAKE(robodoc, $major.$minor.$revision)\n";
            print $line;
            print $file $line;
        } elsif ($line =~ m/AC_INIT/) {
            ++$done;
            $line = "AC_INIT(robodoc, $major.$minor.$revision)\n";
            print $line;
            print $file $line;
        } else {
            print $file $line;
        }
    }
    die if ($done != 2);
}


sub robodoc_1 {
    my $file  = shift;
    my $lines = shift;
    my $done  = 0;
    foreach my $line (@{$lines}) {
        if ($line =~ m/TH\sROBODoc/) {
            print $line;
            $line =~ s/ROBODoc\s\d+\.\d+\.\d+/ROBODoc $major.$minor.$revision/;
            $line =~ s/"\S+\s2/"$month 2/;
            print $line;
            print $file $line;
            ++$done;
        } else {
            print $file $line;
        }
    }
    die if ($done != 1);
}


sub manual {
    my $file  = shift;
    my $lines = shift;
    my $done  = 0;
    foreach my $line (@{$lines}) {
        if ($line =~ m/title>ROBODoc\s\d/) {
            print $line;
            $line =~ s/title>ROBODoc\s\d+\.\d+\.\d+/title>ROBODoc $major.$minor.$revision/;
            print $line;
            print $file $line;
            ++$done;
        } else {
            print $file $line;
        }
    }
    die if ($done != 1);
}

sub rpm_mk {
    my $file  = shift;
    my $lines = shift;
    my $done  = 0;

    foreach my $line (@{$lines}) {
        if ($line =~ /^PROJECT\_VERSION/) {
            print $line;
            $line =~ s/\d+\.\d+\.\d+/$major.$minor.$revision/;
            print $line;
            print $file $line;
            ++$done;
        } elsif ($line =~ /^PROJECT\_RELEASE/) {
            print $line;
            $line =~ s/\d/$release/;
            print $line;
            print $file $line;
        } else {
            print $file $line;
        }
    }
    die if ($done != 1);
}

sub makefile_plain {
    my $file  = shift;
    my $lines = shift;
    my $done  = 0;

    foreach my $line (@{$lines}) {
        if ($line =~ /^VERS/) {
            print $line;
            $line =~ s/\d+\.\d+\.\d+/$major.$minor.$revision/;
            print $line;
            print $file $line;
            ++$done;
        } elsif ($line =~ /^RELEASE/) {
            print $line;
            $line =~ s/\d/$release/;
            print $line;
            print $file $line;
        } else {
            print $file $line;
        }
    }
    die if ($done != 1);
}

sub readme_cygwin {
    my $file  = shift;
    my $lines = shift;

    foreach my $line (@{$lines}) {
        # Ignore Port notes
        if ($line =~ /^----------\ robodoc-/) {
            print $file $line;
        # replace all other
        } elsif ($line =~ /robodoc-\d+\.\d+\.\d+-\d+/) {
            print $line;
            $line =~ s/\d+\.\d+\.\d+-\d+/$major.$minor.$revision-$release/;
            print $line;
            print $file $line;
        } elsif ($line =~ /robodoc-\d+\.\d+\.\d+/) {
            print $line;
            $line =~ s/\d+\.\d+\.\d+/$major.$minor.$revision/;
            print $line;
            print $file $line;
        # duplicate normal lines
        } else {
            print $file $line;
        }
    }
}

my %updaters = ();

$updaters{"Docs/manual.xml"}   = \&manual;
#$updaters{"Docs/robodoc.1"}    = \&robodoc_1;
$updaters{"Source/robodoc.h"}  = \&robodoc_h;
$updaters{"README"}            = \&readme;
$updaters{"configure.in"}      = \&configure_in;
# $updaters{"rpm.mk"}            = \&rpm_mk;
# $updaters{"Source/makefile.plain"} = \&makefile_plain;
# $updaters{"CYGWIN-PATCHES/robodoc.README"} = \&readme_cygwin;

foreach my $filename ( keys %updaters ) {
    print $filename, "\n";
    my $file = IO::File->new("<$filename") or die $filename;
    my @lines = <$file>;
    $file->close();
    $file = IO::File->new(">$filename.bup") or die $filename;
    $updaters{$filename}( $file, \@lines );
    $file->close();
    rename "$filename.bup", $filename;
}

__DATA__
Copyright (C) 1994-2021  Frans Slothouber, Jacco van Weert, Petteri Kettunen,
Bernd Koesling, Thomas Aglassinger, Anthon Pang, Stefan Kost, David Druffner,
Sasha Vasko, Kai Hofmann, Thierry Pierron, Friedrich Haase, and Gergely Budai.

This file is part of ROBODoc

ROBODoc is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

