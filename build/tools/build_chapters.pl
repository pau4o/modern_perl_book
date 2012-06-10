#!/usr/bin/perl
use strict;
use warnings;
# input/output default encoding will be UTF-8
use open ':encoding(utf8)';
use File::Path 'mkpath';
use File::Spec::Functions qw( catfile catdir splitpath );
use lib('./build/tools');
use MPBUtils;
use Data::Dumper;
my $util = MPBUtils->new(); 
my $sections_href = $util->get_section_list();
warn Dumper(\@ARGV,$sections_href,$util->get_chapter_list());
#exit;
$util->build_chapters();

die( "Scenes missing from chapters:", join "\n\t", '', keys %$sections_href )
    if keys %$sections_href;

exit;









