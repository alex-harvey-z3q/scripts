#!/usr/bin/perl

use strict;
use warnings;

my $notes = $ARGV[0] ? $ARGV[0] : 'notes.txt';
$notes eq '-h' and usage();

my $courseware_dir = "$ENV{HOME}/git/courseware-fundamentals";

my %data = ();

# %data = (
#    'Course_Overview/Course_Overview.md' => "The course is ...",
#    'Course_Overview/Table_of_contents.md' => ...
# );

my $slide;

open NOTES, "<$notes" or die "open: $! ($notes)";
while (<NOTES>) {
    if ($. == 0 and !m#/.*\.md:#) {
        print "error: first line must be a slide name + ':'\n";
        exit 1;
    }
    if (m#/.*\.md:#) {
        chomp;
        $slide = $_;
        $slide =~ s/:$//;
        exit 1 if (!slide_exists("$courseware_dir/$slide"));
        next;
    }
    $data{$slide} .= $_;
}
close NOTES;

# add notes to slides.

foreach my $slide (keys %data) {
    my $s = "$courseware_dir/$slide";
    print "processing '$slide' ...\n";
    system("sed '/^\.notes/d' $s >tmp.$$");
    system("mv -f tmp.$$ $s");
    system("sed '/^~~~SECTION:notes~~~/,/^~~~ENDSECTION~~~/d' $s >tmp.$$");
    system("mv -f tmp.$$ $s");
    system("echo '~~~SECTION:notes~~~' >>$s");
    open FILE, ">>$s" or die "open: $!";
    print FILE $data{$slide};
    close FILE;
    system("echo '~~~ENDSECTION~~~' >>$s");
}

# subroutines.

sub slide_exists {
    my $slide = shift;
    if (! -e $slide) {
        print "slide '$slide' not found, aborting\n";
        print "\n";
        print "(Make sure this script is run from the courseware-fundamentals directory.)\n";
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
