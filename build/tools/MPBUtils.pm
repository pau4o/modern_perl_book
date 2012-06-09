package MPBUtils;
use strict;
use warnings;
use utf8;
use File::Path 'mkpath';
use File::Spec::Functions qw( catfile catdir splitpath );

my $LANGUAGES = [qw(bg)];
sub new {
    my $class = shift;
    my $language = '';
    if(not (($ARGV[0]||'') ~~ $LANGUAGES)){
        warn "Language '$ARGV[0]' is not supported.".$/
        .'Building original...';
    }else{
        $language = '_'.lc($ARGV[0]);
    }

    my $self = bless {l=>$language}, $class;
    return $self;
}

###############build_chapters
#the iteration from build_chapters.pl
sub build_chapters {
    my $self = shift;
    for my $chapter ($self->get_chapter_list())
    {
        my $text = $self->process_chapter( $chapter );
        $self->write_chapter( $chapter, $text );
    }
}

sub get_chapter_list
{
    my $self = shift;
    my $glob_path = catfile( 'sections'.$self->{l}, 'chapter_??.pod' );
    return glob( $glob_path );
}

sub process_chapter
{
    my ($self,$path) = @_;
    my $text                 = read_file( $path );

    $text =~ s/^L<(\w+)>/_insert_section( $self->get_section_list(), $1, $path )/emg;

    $text =~ s/(=head1 .*)\n\n=head2 \*{3}/$1/g;
    return $text;
}

sub _insert_section
{
    my ($sections_href, $name, $chapter) = @_;

    die "Unknown section '$name' in '$chapter'\n"
        unless exists $sections_href->{ $1 };

    my $text = read_file( $sections_href->{ $1 } );
    delete $sections_href->{ $1 };
    return $text;
}

sub read_file
{
    my $path = shift;
    open my $fh, '<:utf8', $path or die "Can't read '$path': $!\n";
    return scalar do { local $/; <$fh>; };
}

sub write_chapter
{
    my ($self, $path, $text) = @_;
    my $name          = ( splitpath $path )[-1];
    my $chapter_dir   = catdir( 'build', 'chapters'.$self->{l} );
    my $chapter_path  = catfile( $chapter_dir, $name );

    mkpath( $chapter_dir ) unless -e $chapter_dir;

    open my $fh, '>:utf8', $chapter_path
        or die "Cannot write '$chapter_path': $!\n";

    print {$fh} $text;

    warn "Writing '$chapter_path'\n";
}

sub get_section_list
{
    my $self = shift;
    $self->{sections} && return $self->{sections};
    
    my $sections_path = catfile( 'sections'.$self->{l}, '*.pod' );

    for my $section (glob( $sections_path ))
    {
        next if $section =~ /\bchapter_??/;
        my $anchor = get_anchor( $section );
        $self->{sections}{ $anchor } = $section;
    }
    return $self->{sections};
}

sub get_anchor
{
    my $path = shift;

    open my $fh, '<:utf8', $path or die "Can't read '$path': $!\n";
    while (<$fh>) {
        next unless /Z<(\w*)>/;
        return $1;
    }

    die "No anchor for file '$path'\n";
}

###############build_html
sub get_build_chapter_list
{
    my $self = shift;
    my $glob_path = catfile( 'build', "chapters$self->{l}", 'chapter_??.pod' );
    return glob $glob_path;
}

sub get_html_output_fh
{
    my $self = shift;
    my $chapter = shift;
    my $name    = ( splitpath $chapter )[-1];
    my $htmldir = catdir( 'build', 'html', $self->{l} );
    mkpath( $htmldir ) unless -e $htmldir;
    $name       =~ s/\.pod/\.html/;
    $name       = catfile( $htmldir, $name );

    open my $fh, '>:utf8', $name
        or die "Cannot write to '$name': $!\n";

    return $fh;
}
1;
