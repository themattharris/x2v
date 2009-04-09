# Class for testing the hCalendar XSLT
#
# Copyright 2006-07 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::Driver::Microformats::hCalendar;

use strict;
use warnings;
use base qw(XSLTest::Driver::Microformats);

use File::Basename;

sub new {              # Constructor
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    bless( $self, $class );
}

sub get_test_list {    # Get a list of all tests
    my $self = shift;
    my ( @file_names, @list );
    my %params = ( Source => "http://example.com/" );

    @file_names = glob('hcalendar/*.html');

    my $i = 1;
    for (@file_names) {
        my ( $output, $input, $test ) = ( $_, $_, $_ );
        $output =~ s/\.html$/.ics/;
        $test   =~ s/\.html$//;
        my $entry = {
            number                  => $i,
            test_name               => basename($test),
            orginal_input_filename  => $input,
            orginal_result_filename => $output,
            params                  => \%params
        };

        push @list, $entry;
        ++$i;
    }

    return @list;
}

1;
