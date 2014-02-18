#!/usr/bin/perl

use strict;
use warnings;

$ARGV[0] eq '-h' and usage();
my @notes = @ARGV;

foreach my $notes (@notes) {
    if (! -e $notes) {
        print "file not found: $notes\n";
        usage();
    }
}

my $courseware_dir = "$ENV{HOME}/git/courseware-fundamentals";
if (! -e $courseware_dir) {
    print "expected courseware-fundamentals to be checked out ";
    print "at $courseware_dir\n";
    exit 1;
}

my %data = ();

# %data = (
#    'Course_Overview/Course_Overview.md' => "The course is ...",
#    'Course_Overview/Table_of_contents.md' => ...
# );

my $slide;

foreach my $notes (@notes) {
    print "reading $notes ";
    open NOTES, "<$notes" or die "open: $! ($notes)";
    while (<NOTES>) {
        next if /^# /;
        if ($. == 0 and !m#/.*\.md:#) {
            print "error: $notes line $.: first line must be a slide name + ':'\n";
            exit 1;
        }
        if (m#/.*\.md:#) {
            print '.';
            chomp;
            $slide = $_;
            $slide =~ s/:$//;
            die("$courseware_dir/$slide not found") if (!slide_exists("$courseware_dir/$slide"));
            next;
        }
        $data{$slide} .= $_;
    }
    close NOTES;
}
print "ok\n";

# add notes to slides.

system("cd $courseware_dir; git checkout -- .");
system("./patch.sh");
system("cd $courseware_dir; rm -rf stats; mkdir stats");

print 'adding notes to slides ';
foreach my $slide (keys %data) {
    my $s = "$courseware_dir/$slide";
    #print '.';
    system("sed '/^\.notes/d' $s >tmp.$$");
    system("mv -f tmp.$$ $s");
    system("sed '/^~~~SECTION:notes~~~/,/^~~~ENDSECTION~~~/d' $s >tmp.$$");
    system("mv -f tmp.$$ $s");
    my $c;
    open FILE1, "<$s";
    open FILE2, ">tmp.$$";
    while (<FILE1>) {
        if (/SLIDE/ and !$c) {
            ++$c;
        } elsif (/SLIDE/ and $c == 1) {
            print FILE2 "\n~~~SECTION:notes~~~\n";
            print FILE2 $data{$slide};
            print FILE2 "~~~ENDSECTION~~~\n\n";
            ++$c;
        }
        print FILE2 $_;
    }
    close FILE2;
    close FILE1;
    system("mv -f tmp.$$ $s");
    if (!$c or $c == 1) {
        system("echo '' >>$s");
        system("echo '~~~SECTION:notes~~~' >>$s");
        open FILE, ">>$s" or die "open: $!";
        print FILE $data{$slide};
        close FILE;
        system("echo '~~~ENDSECTION~~~' >>$s");
        print '-';
    } elsif ($c > 1) {
        print '+';
    }
}
print "\n";

# subroutines.

sub slide_exists {
    my $slide = shift;
    if (! -e $slide) {
        print "slide '$slide' not found, aborting\n";
    }
    return (-e $slide);
}

sub usage {
    print <<EOF;
usage: $0 <notes_file> [-h]

Notes file format:

Course_Overview/Course_Overview.md:

The course is intended for system administrators who
want a grounding in the fundamentals of the Puppet language.

Course_Overview/Table_of_contents.md:

Etc
EOF
    exit 1;
}

# end of script
