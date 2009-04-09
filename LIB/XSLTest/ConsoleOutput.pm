# Module for (colored) console output
#
# Copyright 2007 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::ConsoleOutput;

use strict;
use warnings;
use Carp qw();
use POSIX qw(isatty);

sub new {    # Constructor
    my $class = shift;
    my $args = shift || {};

    my $self = {};
    bless $self, $class;

    # get required arguments
    foreach (qw(use_color)) {
        if ( exists $args->{$_} ) {
            $self->{$_} = $args->{$_};
        }
        else {
            Carp::croak("Missing required argument $_\n");
        }
    }

    if ( $self->{use_color} eq 'auto' ) {
        if ( isatty( \*STDOUT ) ) {
            $self->{use_color} = 1;
        }
        else {
            $self->{use_color} = 0;
        }
    }
    if ( $self->{use_color} && $^O eq "MSWin32" ) {
        eval { require Win32::Console::ANSI };
        $self->{use_color} = 1 unless ($@);
    }

    return $self;
}

sub print_summary {    # print a summary table
    my ( $self, $test_data ) = @_;
    my $width_left = 68;

    # get the used engines
    my @used_engines;
    for ( keys %{ $test_data->[0] } ) {
        next unless /-result$/;
        my $engine = $_;

        $engine =~ s/-result$//;
        push @used_engines, $engine;
    }
    @used_engines = sort(@used_engines);

    # print header
    my %engine_lut = (
        '4XSLT'   => '4X',
        'LibXSLT' => 'LX',
        'Xalan-C' => 'XC',
        'Xalan-J' => 'XJ',
        'Saxon'   => 'SA'
    );
    for ( my $i = 0; $i < 2; $i++ ) {
        print ' ' x 68;
        for my $engine (@used_engines) {
            my $char = substr( $engine_lut{$engine}, $i, 1 );
            print "$char ";
        }
        print "\n";
    }
    print "\n";

    # print body
    for my $test ( @{$test_data} ) {
        my $name = $test->{'test-name'};

        print $name;
        print ' ' x ( $width_left - length($name) );

        for my $engine (@used_engines) {
            my $result = $test->{ $engine . '-result' };

            if (!defined($result)) {
                $self->color_print( '?', 'red' );
            }
            elsif ( $result eq 'PASS' ) {
                $self->color_print( 'P', 'lime' );
            }
            else {
                $self->color_print( 'F', 'red' );
            }
            print ' ';
        }
        print "\n";
    }
}

sub color_print {    # print with colors if appropriate
    my ( $self, $text, $text_color ) = @_;
    my %color = (
        black   => "\e[0;30;47m",
        maroon  => "\e[0;31;40m",
        green   => "\e[0;32;40m",
        olive   => "\e[0;33;40m",
        navy    => "\e[0;34;40m",
        purple  => "\e[0;35;40m",
        teal    => "\e[0;36;40m",
        silver  => "\e[0;37;40m",
        grey    => "\e[1;30;40m",
        red     => "\e[1;31;40m",
        lime    => "\e[1;32;40m",
        yellow  => "\e[1;33;40m",
        blue    => "\e[1;34;40m",
        fuchsia => "\e[1;35;40m",
        aqua    => "\e[1;36;40m",
        white   => "\e[1;37;40m",
    );

    if ( $self->{use_color} ) {
        if ( !exists $color{$text_color} ) {
            warn( 'Unknown color ', $text_color );
        }
        print $color{$text_color}, $text, "\e[0m";
    }
    else {
        print $text;
    }
}

sub print_diff {    # print unified diff output
    my $self         = shift;
    my @lines        = split /\r?\n/, $_[0];
    my $screen_width = 80 - 5;

    if ( $self->{use_color} ) {
        for (@lines) {
            my $color;

            if ( /^\+\+\+/ || /^---/ ) { $color = "\e[0;30;43m" }
            elsif (/^\+/) { $color = "\e[0;30;42m" }
            elsif (/^-/)  { $color = "\e[0;30;41m" }

            if ($color) {
                my $line = $_;
                my $len  = length($line);
                if ( $len < $screen_width ) {
                    $line .= ' ' x ( $screen_width - $len );
                }
                print "    $color$line\e[m\n";
            }
            else {
                print "    $_\n";
            }
        }
    }
    else {
        print "    $_\n" for @lines;
    }
}

1;
