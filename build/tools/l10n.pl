#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;
use autodie;
use utf8;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

#init
local $| = 1;
binmode STDOUT, ":encoding(utf8)";

our %OPTIONS = ();
Getopt::Long::Configure("bundling");
GetOptions(\%OPTIONS, 'make=s', 'debug|d', 'help|h|?:s', 'language|l=s', 'file|f=s');

if (
     not keys %OPTIONS
  or exists $OPTIONS{help}
  or (not $OPTIONS{make}
    or $OPTIONS{make} !~ /^(language|update|wrap)$/)
  )
{
  pod2usage(
    -verbose   => 2,
    -noperldoc => 1
  );
}

#actions
sub language;

#run action
my $action = $OPTIONS{make};

say $action . ': ' . Data::Dumper->Dump([\%OPTIONS], ['OPTIONS']) if $OPTIONS{debug};

__PACKAGE__->$action();


#code

#text wrapping(format) for translated files
# cd sections_bg/
# ../build/tools/l10n.pl --make wrap -f chapter_00.pod>chapter_00.pod
sub wrap {
  require Text::Wrap;
  no warnings qw(once);
  local $Text::Wrap::columns = 88;
  local $Text::Wrap::separator=" \n";
  open(my $f, "<:utf8", $OPTIONS{file});
  print Text::Wrap::wrap("", "", <$f>);
}

sub language {
  say $action;
}


sub update {
  say $action;
}


=head1 NAME

l10n.pl - a tool to generate new files from originals ready for translation


=head1 DESCRIPTION

This script will copy all files from the book into a directory 
named after the language in which you want to translate the book.


=head1 SYNOPSIS

    #create a copy of the file-tree for translation
    cd modernperlbooks
    ./l10n.pl --make=language --language=bg
    
    #check for updates of the original files and update them
    ./l10n.pl --make update
    