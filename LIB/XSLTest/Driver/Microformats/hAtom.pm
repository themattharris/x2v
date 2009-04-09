# Class for testing the hAtom XSLT
#
# Copyright 2006-07 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::Driver::Microformats::hAtom;

use strict;
use warnings;
use base qw(XSLTest::Driver::Microformats);

use File::Basename;

sub new {    # Constructor
    my $class = shift;
    my $self  = $class->SUPER::new( @_ );
    bless( $self, $class );

    require XML::LibXSLT;

    return $self;
}

sub get_test_list {    # Get a list of all tests
    my $self = shift;

    my @list;
    my $testfile = 'hatom/tests.xml';
    die "$testfile does not exist" if not -e $testfile;
    my $parser = XML::LibXML->new();
    my $tree   = $parser->parse_file($testfile)
        or die "Can't parse $testfile";

    # Get default params
    my %default_params;
    my $root = $tree->getDocumentElement();
    foreach my $default_param_node ( $root->findnodes('default-param') ) {
        $default_params{ $default_param_node->findvalue('@name') }
            = $default_param_node->findvalue('.');
    }

    # Read all tests
    my $i = 1;
    foreach my $test_node ( $root->findnodes('test') ) {
        my $input  = $test_node->findvalue('input');
        my $output = $test_node->findvalue('output');
        my %params = %default_params;
        my $name   = do {
            my $s = basename($input);
            $s =~ s/\.html$//;
            sprintf( '%02d-%s', $i, $s );
        };

        foreach my $param_node ( $test_node->findnodes('param') ) {
            $params{ $param_node->findvalue('@name') }
                = $param_node->findvalue('.');
        }

        my $entry = {
            number                  => $i,
            test_name               => $name,
            orginal_input_filename  => 'hatom/' . $input,
            orginal_result_filename => 'hatom/' . $output,
            params                  => \%params
        };

        push @list, $entry;
        ++$i;
    }

    return @list;
}

1;
