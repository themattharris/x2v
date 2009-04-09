# Abstract for handling test ouput
#
# Copyright 2006-07 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::OutputHandler;

use strict;
use warnings;

sub new {                  # Constructor
    my $class = shift;
    my $self = {};

    bless( $self, $class );

    eval { require Text::Diff };
    if ($@) {
        print STDERR "Please install Text::Diff.\n",
            "See <http://search.cpan.org/~RBS/Text-Diff/>\n";
        exit 1;
    }

    return $self;
}

sub set_product_id {
    my $self = shift;
    $self->{product_id} = shift;
}

sub normalize_data {      # Normalize data (abstract)
    die "Abstract method";
}

sub make_diff {           # Generate an unified diff
    my ( $self, $exp, $got ) = @_;

    $got = $self->normalize_data($got);

    if ( substr( $exp, -1, 1 ) ne "\n" ) { $exp .= "\n" }
    if ( substr( $got, -1, 1 ) ne "\n" ) { $got .= "\n" }

    return Text::Diff::diff( \$exp, \$got,
        { FILENAME_A => 'expected', FILENAME_B => 'got' } );
}

sub compare_result {      # Compare two results
    my ( $self, $exp, $got ) = @_;

    $got = $self->normalize_data($got);
    return $got eq $exp;
}

sub get_expected_result { # Get expected result
	my $self = shift;
	my $file_name = shift;

	my $s = $self->read_file( $file_name );
	utf8::decode($s);
	return $self->normalize_data($s);
}

sub read_file {          # Return the contents of a file as a scalar
    my ( $self, $filename ) = @_;

    open my $f, '<:utf8', $filename or Carp::croak "Can't open file: $filename\n";
    my @lines = <$f>;
    close $f;

    return join '', @lines;
}


1;
