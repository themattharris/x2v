# Class for handling RFC2425 test output (like iCal and vCard)
#
# Copyright 2006-07 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::OutputHandler::RFC2425;
use strict;
use warnings;
use base qw(XSLTest::OutputHandler);

sub new {               # Constructor
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    bless( $self, $class );
    return $self;
}

sub normalize_data {    # Normalize data
    my $self = shift;
    my $data = shift;

    my $source     = "http://example.com/";
    my $product_id = quotemeta($self->{product_id});

    my $data_ref = do { my @a = split /\r?\n/, $data; \@a };
    my @data = $self->_sort_object($data_ref);

    foreach (@data) {
        $_ =~ s{$product_id}{\$PRODID\$}g;
        $_ =~ s{\$SOURCE\$/([^\$]+)\$}{$source$1}g;
        $_ =~ s{\$SOURCE\$}{$source}g;
    }
    return join( "\n", @data );
}

sub _sort_object {

    # based on Ryan King's normalize.pl
    my $self            = shift;
    my $data_ref        = shift;
    my @buffer          = ();
    my @output          = ();
    my $sort_collection = sub() {
        foreach ( sort @buffer ) {
            push @output, $_;
        }
        @buffer = ();
        push @output, $_[0];
    };

    while ( @{$data_ref} != 0 ) {
        my $line = shift @{$data_ref};
        next if ( $line =~ /^\s*$/ );

        if ( $line =~ /^BEGIN\:[A-Z]+/ ) {
            $sort_collection->($line);

            # recurse to do nested objects
            push @output, $self->_sort_object($data_ref);
        }
        elsif ( $line =~ /^END\:[A-Z]+/ ) {
            $sort_collection->($line);
            last;
        }
        elsif ( $line =~ /^[A-Z]*/ ) {
            push @buffer, $line;    # collect lines in the object
        }
    }
    return @output;
}

1;
