# Abstract class for testing the microformat XSLTs
#
# Copyright 2006-07 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::Driver::Microformats;

use strict;
use warnings;
use base qw(XSLTest::Driver);

use Carp qw();

sub new {              # Constructor
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    bless( $self, $class );

    unless ( $ENV{MICROFORMATS_TESTS} ) {
        print STDERR
            "Please set the MICROFORMATS_TESTS environment variable\n",
            "to the path of the directory which contains the tests from http://hg.microformats.org/tests\n";
        exit 1;
    }

    $self->{test_dir} = $ENV{MICROFORMATS_TESTS};
    chdir( $self->{test_dir} )
        || Carp::croak("Can't change to Microformats test dir");

    my @test_list = $self->get_test_list();
    $self->{test_list} = \@test_list;

    $self->parse_cmdline_args();

    return $self;
}

sub get_product_id {       # Get the product_id of the XSLT file
    my ( $self, $doc ) = @_;
    my $xsl_ns = 'http://www.w3.org/1999/XSL/Transform';
    my @nodelist = $doc->getElementsByTagNameNS( $xsl_ns, 'param' );
    foreach my $n (@nodelist) {
        my ( $name, $v, $a );

        $name = $n->getAttribute('name');
        next unless $name eq 'Prodid';

        $a = $n->getAttribute('select');
        if ($a) {

            # remove first and last char
            return substr( $a, 1, length($a) - 2 );
        }
        else {
            return $n->textContent;
        }
    }
    return;
}

sub prepare_input {     # Prepare input file
    my $self = shift;
    my $test = shift;

    my $input = $self->{output_handler}->read_file( $test->{orginal_input_filename} );

    $self->_remove_doctype( \$input );
    $self->write_file( $self->{temp_in}, $input );
    
    return $self->{temp_in};
}

sub _remove_doctype {   # Remove DOCTYPE from HTML string
    my ( $self, $s_ref ) = @_;
    my $start = index( $$s_ref, '<!DOCTYPE' );
    return if ( $start == -1 );

    my $end = index( $$s_ref, '>', $start + length('<!DOCTYPE') );
    $$s_ref = substr( $$s_ref, 0, $start ) . substr( $$s_ref, $end + 1 );
}

1;
