#!/usr/bin/perl

use strict;
use warnings;

my $courseware_dir = "$ENV{HOME}/git/courseware-fundamentals";

my $notes = $ARGV[0] ? $ARGV[0] : 'notes.txt';
$notes eq '-h' and usage();

if (! -e $notes) {
    print "file not found: $notes\n";
    usage();
}

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

print "reading $notes ";
open NOTES, "<$notes" or die "open: $! ($notes)";
while (<NOTES>) {
    if ($. == 0 and !m#/.*\.md:#) {
        print "error: $notes line $.: first line must be a slide name + ':'\n";
        exit 1;
    }
    if (m#/.*\.md:#) {
        print '.';
        chomp;
        $slide = $_;
        $slide =~ s/:$//;
        exit 1 if (!slide_exists("$courseware_dir/$slide"));
        next;
    }
    $data{$slide} .= $_;
}
close NOTES;
print "ok\n";

# add notes to slides.

print 'adding notes to slides ';
foreach my $slide (keys %data) {
    my $s = "$courseware_dir/$slide";
    print '.';
    system("sed '/^\.notes/d' $s >tmp.$$");
    system("mv -f tmp.$$ $s");
    system("sed '/^~~~SECTION:notes~~~/,/^~~~ENDSECTION~~~/d' $s >tmp.$$");
    system("mv -f tmp.$$ $s");
    system("echo '' >>$s");
    system("echo '~~~SECTION:notes~~~' >>$s");
    open FILE, ">>$s" or die "open: $!";
    print FILE $data{$slide};
    close FILE;
    system("echo '~~~ENDSECTION~~~' >>$s");
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
