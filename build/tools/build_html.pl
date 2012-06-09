#!/usr/bin/perl

use strict;
use warnings;

use Pod::PseudoPod::HTML;
use File::Spec::Functions qw( catfile catdir splitpath );
use lib('./build/tools');
use MPBUtils;
use Data::Dumper;
# P::PP::H uses Text::Wrap which breaks HTML tags
local *Text::Wrap::wrap;
*Text::Wrap::wrap = sub { $_[2] };
my $util = MPBUtils->new(); 



my @chapters = $util->get_build_chapter_list();

warn Dumper(\@ARGV,\@chapters);
#exit;

my $anchors  = get_anchors(@chapters);

sub Pod::PseudoPod::HTML::end_L
{
    my $self = shift;
    if ($self->{scratch} =~ s/\b(\w+)$//)
    {
        my $link = $1;
        die "Unknown link $link\n" unless exists $anchors->{$link};
        $self->{scratch} .= '<a href="' . $anchors->{$link}[0] . "#$link\">"
                                        . $anchors->{$link}[1] . '</a>';
    }
}

for my $chapter (@chapters)
{
    my $out_fh = $util->get_html_output_fh($chapter);
    my $parser = Pod::PseudoPod::HTML->new();

    $parser->output_fh($out_fh);

    # output a complete html document
    $parser->add_body_tags(1);

    # add css tags for cleaner display
    $parser->add_css_tags(1);

    $parser->no_errata_section(1);
    $parser->complain_stderr(1);

    $parser->parse_file($chapter);
}

exit;

sub get_anchors
{
    my %anchors;

    for my $chapter (@_)
    {
        my ($file)   = $chapter =~ /(chapter_\d+)./;
        my $contents = slurp( $chapter );

        while ($contents =~ /^=head\d (.*?)\n\nZ<(.*?)>/mg)
        {
            $anchors{$2} = [ $file . '.html', $1 ];
        }
    }

    return \%anchors;
}

sub slurp
{
    return do { local @ARGV = @_; local $/ = <>; };
}




