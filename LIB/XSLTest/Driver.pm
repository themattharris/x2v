# Abstract class for testing XSLTs
#
# Copyright 2006-07 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::Driver;

use warnings;
use strict;
use utf8;

use Carp qw();
use Cwd qw(cwd);
use Data::Dumper;
use File::Basename qw(basename);
use File::Temp qw(tempdir);
use IO::Socket;

require XSLTest::ConsoleOutput;

sub new {                 # Constructor
    my $class = shift;
    my $args = shift || {};

    my $self = {
        engines => {
            '4XSLT'   => 0,
            'LibXSLT' => 0,
            'Saxon'   => 0,
            'Xalan-C' => 0,
            'Xalan-J' => 0,
        },
        'xalan_j_instance' => undef,
        'saxon_instance'   => undef,
    };
    bless $self, $class;

    # get required arguments
    foreach (qw(xslt1_filename output_handler lib_dir)) {
        if ( exists $args->{$_} ) {
            $self->{$_} = $args->{$_};
        }
        else {
            Carp::croak("Missing required argument $_\n");
        }
    }

    eval { require XML::LibXML; require XML::LibXSLT };
    if ($@) {
        print STDERR "Please install XML::LibXSLT.\n",
            "If you're using Windows see ",
            "<http://cpan.uwinnipeg.ca/module/XML::LibXSLT>\n",
            "If you're using MacOSX see ",
            "<http://p5-xml-libxslt.darwinports.com/>\n";
        exit 1;
    }

    eval { require Getopt::Long };
    if ($@) {
        print STDERR "Please install Getopt::Long.\n",
            "See <http://search.cpan.org/~JV/Getopt-Long/>\n";
        exit 1;
    }

    $self->{inital_cwd}  = cwd();
    $self->{test_dir}    = undef;

    $self->make_tempfiles();

    return $self;
}

sub DESTROY {             # Destructor
    my $self = shift;

    if ($self->{'4xslt_socket'}) {

        if ( $self->{'4xslt_daemon'} ) {
            # quit daemon
            $self->{'4xslt_socket'}->send("QUIT\n");
        }
        else {
            # only close session
            $self->{'4xslt_socket'}->send("CLOSE\n");
        }

        close( $self->{'4xslt_socket'} );
    }

    return unless exists $self->{temp_dir};

    # remove tempfiles
    unlink( $self->{temp_in} )  if ( -e $self->{temp_in} );
    unlink( $self->{temp_out} ) if ( -e $self->{temp_out} );
    rmdir( $self->{temp_dir} );
}

sub make_tempfiles {      # Create temp directory and temp filenames
    my $self = shift;
    $self->{temp_dir} = tempdir( 'xsltest-XXXXXXXX', TMPDIR => 1 );
    $self->{temp_in}  = $self->{temp_dir} . "/input";
    $self->{temp_out} = $self->{temp_dir} . "/output";
}

sub parse_cmdline_args {  # Parse the commandline arguments from ARGV
    my $self = shift;
    my $p = Getopt::Long::Parser->new( config => ['bundling'] );
    my $numbers_were_given = 0;
    my %opt;
    $opt{color} = 'auto';

    if (@ARGV) {
        $p->getoptions(
            \%opt,          '4xslt|4',     'libxslt|x', 'saxon|s',
            'xalan-c|c',    'xalan-j|j', 'q|quiet',   'all|A',
            'list-tests|l', 'color|C:1', 'dump=s',    'exclude|e=s@',
            'no-trax',      'table|t',   'die|d',     'help',
            'no-4xslt-server'
        );
    }
    else {
        $opt{help} = 1;
    }

    if ( $opt{help} ) {
        $self->display_help();
        exit 0;
    }

    if ( $opt{'list-tests'} ) {
        my @test_list = $self->get_test_list();

        print "Test list\n\n";
        for my $test ( @test_list ) {
            printf "%2d  %s\n", $test->{number}, $test->{test_name};
        }

        print "\n";
        exit 0;
    }

    $self->{dump_file}             = $opt{dump};
    $self->{display_summary_table} = $opt{table};
    $self->{use_color}             = $opt{color};
    $self->{quiet}                 = 1 if ( $opt{q} );
    $self->{die_on_error}          = 1 if ( $opt{die} );

    if ($self->{dump_file} && $self->{die_on_error}) {
        print STDERR "$0: Can not use --dump with --die\n";
        exit 1;
    }

    $self->{engines}->{'4XSLT'}   = 1 if ( $opt{'4xslt'} );
    $self->{engines}->{'LibXSLT'} = 1 if ( $opt{libxslt} );
    $self->{engines}->{'Saxon'}   = 1 if ( $opt{saxon} );
    $self->{engines}->{'Xalan-C'} = 1 if ( $opt{'xalan-c'} );
    $self->{engines}->{'Xalan-J'} = 1 if ( $opt{'xalan-j'} );

    $self->{try_4xslt_server} =!$opt{'no-4xslt-server'};
    $self->{try_java_trax} = !$opt{'no-trax'};

    if ( $opt{all} ) {
        foreach ( keys %{ $self->{engines} } ) {
            $self->{engines}->{$_} = 1;
        }
    }

    my $max_nr = @{ $self->{test_list} };
    foreach (@ARGV) {
        if (/^(\d+)$/) {
            $numbers_were_given = 1;
            my $no1 = $1;
            if ( $no1 <= 0 or $no1 > $max_nr ) {
                print STDERR "$0: Invalid test number: $no1\n"
                    . "Valid numbers are in the range from 1 to $max_nr \n";
                exit 1;
            }
            $self->{test_list}[ $no1 - 1 ]->{enabled} = 1;
        }
        elsif (/^(\d+)-(\d+)$/) {
            $numbers_were_given = 1;
            my ( $no1, $no2 ) = ( $1, $2 );

            if ( $no1 <= 0 or $no2 <= $no1 or $no2 > $max_nr ) {
                print STDERR "$0: Invalid test range: $no1-$no2\n"
                    . "Valid numbers are in the range from 1 to $max_nr \n";
                exit 1;
            }
            for ( $no1 .. $no2 ) {
                $self->{test_list}[ $_ - 1 ]->{enabled} = 1;
            }
        }
        else {
            print STDERR "$0: unrecognized option `$_'\n"
                . "Try `$0 --help' for more information.\n";
            exit 1;
        }
    }

    if ( !$numbers_were_given ) {
        $_->{enabled} = 1 for @{ $self->{test_list} };
    }

    unless ( grep { $_ == 1 } values %{ $self->{engines} } ) {
        print STDERR "$0: No engine selected\n"
            . "Try `$0 --help' for more information.\n";
        exit 1;
    }

    return unless ( $opt{exclude} );

    my @numbers_to_exclude;

    for my $compound_rule ( @{ $opt{exclude} } ) {
        $compound_rule =~ s/,/ /g;
        my @rules = split /\s+/, $compound_rule;
        for (@rules) {
            if (/^(\d+)$/) {
                my $no1 = $1;
                if ( $no1 <= 0 or $no1 > $max_nr ) {
                    print STDERR "$0: Invalid test number: $no1\n"
                        . "Valid numbers are in the range from 1 to $max_nr \n";
                    exit 1;
                }
                push @numbers_to_exclude, $no1;
            }
            elsif (/^(\d+)-(\d+)$/) {
                my ( $no1, $no2 ) = ( $1, $2 );

                if ( $no1 <= 0 or $no2 <= $no1 or $no2 > $max_nr ) {
                    print STDERR "$0: Invalid test range: $no1-$no2\n"
                        . "Valid numbers are in the range from 1 to $max_nr \n";
                    exit 1;
                }
                push @numbers_to_exclude, $no1 .. $no2;
            }
            else {
                print STDERR "$0: Not a number `$_'\n"
                    . "Try `$0 --help' for more information.\n";
                exit 1;
            }
        }
    }

    for (@numbers_to_exclude) {
        $self->{test_list}[ $_ - 1 ]->{enabled} = 0;
    }
}

sub display_help {        # Show help and exit
    print <<"HELP";
Usage: $0: [OPTIONS] [TEST-NUMBERS]...
Run the test suite with the supported XSLT engines.

  -l, --list-tests         List test numbers and exit
  -e, --exclude            Exclude test(s)
  -q, --quiet              Supress uppress nonessential output
  -C, --color [1|0]        Display colors if value is ommited or 1.
  -d, --die                Die on first failed test
      --dump FILENAME      Write machine-readable test results to FILENAME
  -t  --table              Display a summary table after the tests
  -A, --all                Run the tests with all engines
  -x, --libxslt            Run the tests with libxslt (via `XML::LibXSLT')
  -4, --4xslt              Run the tests with 4XSLT
  -s, --saxon              Run the tests with Saxon
  -c, --xalan-c            Run the tests with Xalan-C
  -j, --xalan-j            Run the tests with Xalan-J
      --no-trax            Do not use Java's TrAX for Saxon and Xalan-J
      --no-4xslt-server    Do not start 4XsltServer.py for 4XSLT
      --help               Display this help and exit
      
Examples:
 $0 -x               
    Run all tests with libxslt
 $0 --saxon --4xslt  1-3 12 15
    Run test 1,2,3,12,15 with Saxon and 4XSLT
 $0 --xalan-c 8-18 -e 12-14
    Run test 8-11 and 15-18 with Xalan-C

HELP
}

sub write_file {          # Write scalar into a (new) file
    my ( $self, $filename, $data ) = @_;

    open my $f, '>:utf8', $filename or die "Can't open file: $filename\n";
    print {$f} $data;
    close $f;
}

sub load_xslt {        # Load XSLT file and engines
    my $self = shift;

    # get product id
    my $parser = XML::LibXML->new();
    my $doc = $parser->parse_file( $self->{xslt1_filename} )
        or Carp::croak "Error in XSLT file (libXML)";

    $self->{output_handler}->set_product_id(
        $self->get_product_id($doc)
    );


    # Try to use Java's TrAX for Saxon and Xalan-J
    my $use_trax = 0;
    if ( $self->{try_java_trax} &&
        ($self->{engines}->{Saxon} || $self->{engines}->{'Xalan-J'})
       ) {
        if ($ENV{PERL_INLINE_JAVA_DIRECTORY}) {
            my $dir = cwd();

            chdir ($ENV{PERL_INLINE_JAVA_DIRECTORY})
                or Carp::croak "Can't chdir to ", 
                $ENV{PERL_INLINE_JAVA_DIRECTORY}, "\n";

            eval { require XSLTest::JavaTrAX; };

            chdir($dir) or Carp::croak "Can't chdir to $dir\n";

            if (! $@) {
                $use_trax = 1;
            }
            elsif ($ENV{XSLTEST_DEBUG}) {
                print "\$@ = $@\n"; exit 1;
            }
        }
        else {
            print "--- PERL_INLINE_JAVA_DIRECTORY not ",
                  "set - not using TrAX for Saxon and Xalan-J\n";
        }
    }

    if ( $self->{engines}->{'LibXSLT'} ) {
        $self->_load_libxslt($doc);
    }

    if ( $self->{engines}->{'Saxon'} && $use_trax) {
        $self->_load_saxon();
    }

    if ( $self->{engines}->{'Xalan-J'} && $use_trax) {
        $self->_load_xalan_j();
    }

    if ( $self->{engines}->{'4XSLT'} && $self->{try_4xslt_server}) {
        $self->_load_4xslt();
    }
}

sub _load_libxslt {
    my $self = shift;
    my $doc  = shift;
    my $libxslt = XML::LibXSLT->new();

    $self->{libxslt} = $libxslt->parse_stylesheet($doc)
        or Carp::croak "Error in XSLT file (libXSLT)";
}

sub _load_xalan_j {
    my $self = shift;
    
    $self->{console_out}->color_print( 
        '---- Trying to load Xalan-J via Inline::Java ... ',
        'teal'
    );

    my $obj = eval {
        XSLTest::JavaTrAX->new(
            {
             factory_name =>
             'org.apache.xalan.processor.TransformerFactoryImpl'
            }
        );
    };

    if ($@) {
        $self->{console_out}->color_print('error','red');
        print "\n";
    }
    else {
        $self->{console_out}->color_print('ok','lime');
        print "\n";

        $obj->load_xslt($self->{xslt1_filename})
            or Carp::croak "Error in XSLT file (Xalan-J)\n";
        $self->{xalan_j_instance} = $obj;
    }
}

sub _load_saxon {
    my $self = shift;

    $self->{console_out}->color_print( 
        '---- Trying to load Saxon via Inline::Java ... ',
        'teal'
    );

    my $obj = eval {
        XSLTest::JavaTrAX->new(
            {
             factory_name => 'net.sf.saxon.TransformerFactoryImpl'
            }
        );
    };

    if ($@) {
        $self->{console_out}->color_print('error','red');
        print "\n";
        $self->{saxon_instance} = undef;
    }
    else {
        $self->{console_out}->color_print('ok','lime');
        print "\n";

        $obj->load_xslt($self->{xslt1_filename})
            or Carp::croak "Error in XSLT file (Saxon)\n";
        $self->{saxon_instance} = $obj;
    }
}

sub _load_4xslt {
    my $self = shift;
    
    if ($^O !~ m/win32/i) {
        $self->{console_out}->color_print( 
            '---- Trying to spawn 4XsltServer.py ... ',
            'teal'
        );
        
        my $script_path = $self->{lib_dir} . '4XsltServer.py';
        my $r = system($script_path, '--daemonize');
        $self->{'4xslt_daemon'} = 1;
        
        if ($r == 0) {
            $self->{console_out}->color_print('ok','lime');
            print "\n";
        }
        else {
            $self->{console_out}->color_print('error','red');
            print "\n";
        }
    }

    $self->{console_out}->color_print( 
        '---- Trying to connect to 4XsltServer.py ... ',
        'teal'
    );

    my $socket = new IO::Socket::INET (
        PeerAddr => 'localhost', PeerPort => '40800',
        Proto => 'tcp'
    );

    if ($socket) {
        $self->{console_out}->color_print('ok','lime');
        print "\n";
    }
    else {
        $self->{console_out}->color_print('error','red');
        print "\n";
        return;
    }

    $socket->autoflush();
    binmode($socket, ':utf8');
    $self->{'4xslt_socket'} = $socket;

    my $r = $self->_msg_4xslt('LOAD_XSLT '. $self->{xslt1_filename});

    if ($r !~ /^ok/i) {
        Carp::croak("Problem with 4XSLT: $r\n");
    }
}

sub _msg_4xslt {
    my ($self, $msg) = @_;
    my $socket = $self->{'4xslt_socket'};
    my $data = '';
    my $buffer;

    $socket->send($msg . "\n");

    while (1) {
        $socket->recv($buffer, 2048);
        $data .= $buffer;
        last if ( index($buffer, "\n\0\0\0\0") != -1 );
    }

    return substr($data,0, length($data) - 5);
}

sub dump_results {        # Dump results into file
    my ( $self, $results_ref ) = @_;
    my $s;
    my $esc = sub() {
        my $str = shift;

        $str =~ s/&/&amp;/g;
        $str =~ s/"/&quot;/g;
        $str =~ s/>/&lt;/g;
        $str =~ s/</&gt;/g;

        return $str;
    };

    my $program = $esc->(basename $self->{xslt1_filename});

    my @engines = grep { $self->{engines}->{$_} }
        sort keys %{ $self->{engines} };

    $s .= qq{<test-results program="$program">\n};
    $s .= qq{ <engines>\n};

    for my $e (@engines) {
        $s .= qq{  <engine>$e</engine>\n};
    }

    $s .= qq{ </engines>\n};

    for my $t ( @{$results_ref} ) {
        my $name = $esc->( $t->{'test-name'} );
        $s .= qq{ <test name="$name">\n};

        for my $e (@engines) {
            my $result = $t->{"$e-result"};

            if ( $result eq "FAIL" ) {
                $s .= qq{  <engine name="$e" result="FAIL">\n};
                $s .= qq{   <diff xml:space="preserve">\n};
                $s .= $esc->( $t->{"$e-diff"} );
                $s .= qq{</diff>\n};
                $s .= qq{  </engine>\n};
            }
            else {
                $result = $esc->($result);
                $s .= qq{  <engine name="$e" result="$result"/>\n};
            }
        }

        $s .= qq{ </test>\n};
    }
    $s .= qq{</test-results>\n};

    chdir( $self->{inital_cwd} );
    $self->write_file( $self->{dump_file}, $s );
}

sub prepare_input {     # Prepare input file
    my $self = shift;
    my $test = shift;
    
    return $test->{orginal_input_filename};
}

sub run {                 # Run all tests
    my $self = shift;
    my @results;
    my $test_failed = 0;

    binmode(*STDOUT, ':utf8');

    my $console_out = XSLTest::ConsoleOutput->new({
        use_color => $self->{use_color} 
    });
    $self->{console_out} = $console_out;

    my $output_handler = $self->{output_handler};

    $self->load_xslt();

    foreach my $test ( @{ $self->{test_list} } ) {
        next unless $test->{enabled};

        my %test_result = ( 'test-name' => $test->{test_name} );

        my $expected = $output_handler->get_expected_result($test->{orginal_result_filename});

        $test->{input_filename} = $self->prepare_input($test);

        foreach my $engine ( sort keys %{ $self->{engines} } ) {
            next unless $self->{engines}->{$engine};

            my ($passed, $got);

            $got = $self->execute_engine( $engine, $test );

            if ( !defined($got) ) {    # engine error
                $test_result{ $engine . "-result" } = 'FAIL (ENGINE)';

                $console_out->color_print( 'FAIL (ENGINE)', 'red' );
                print " ", $test->{test_name}, " [$engine]\n";

                $test_failed = 1;
            }
            elsif ( $output_handler->compare_result( $expected, $got ) ) {

                $console_out->color_print( 'PASS', 'lime' );
                print " ", $test->{test_name}, " [$engine]\n";

                $test_result{ $engine . "-result" } = 'PASS';
            }
            else {

                $console_out->color_print( 'FAIL', 'red' );
                print " ", $test->{test_name}, " [$engine]\n";

                if ( !$self->{quiet} || $self->{dump_file} ) {
                    my $diff = $output_handler->make_diff( $expected, $got );

                    $test_result{ $engine . "-diff" } = $diff
                        if ( $self->{dump_file} );

                    $console_out->print_diff($diff)
                        unless ( $self->{quiet} );
                }
                $test_failed = 1;
                $test_result{ $engine . "-result" } = 'FAIL';
            }

            if ($test_failed && $self->{die_on_error}) {
                last;
            }
        }
        push @results, \%test_result;

        if ($test_failed && $self->{die_on_error}) {
            last;
        }
    }

    $console_out->print_summary( \@results )
        if $self->{display_summary_table};

    $self->dump_results( \@results )
        if ( $self->{dump_file} );

    if ($test_failed && $self->{die_on_error}) {
        print "\n";
        $console_out->color_print( 
            'Test failed, aborting as requested', 'red' 
        );
        print "\n";
    }
}

sub execute_engine {      # Execute an XSLT engine
    my ( $self, $engine, $test ) = @_;

    if   ( $engine eq "4XSLT" )   { return $self->execute_4xslt($test); }
    if   ( $engine eq "LibXSLT" ) { return $self->execute_libxslt($test); }
    if   ( $engine eq "Saxon" )   { return $self->execute_saxon($test); }
    if   ( $engine eq "Xalan-C" ) { return $self->execute_xalan_c($test); }
    if   ( $engine eq "Xalan-J" ) { return $self->execute_xalan_j($test); }
    else                          { die "Unknwon engine ($engine)"; }
}

sub execute_4xslt {       # Execute 4XSLT
    my ( $self, $test ) = @_;
    my $result;

    if (! $self->{'4xslt_socket'}) { # use CLI version
        my @cmd;
        push @cmd, '4xslt';

        foreach my $name ( keys %{ $test->{params} } ) {
            my $value = $test->{params}->{$name};
            push( @cmd, '-D' );
            push( @cmd, $name . '=' . $value );
        }

        push @cmd, '-o';
        push @cmd, $self->{temp_out};
        push @cmd, $test->{input_filename};
        push @cmd, $self->{xslt1_filename};

        unless ( system(@cmd) == 0 ) {
            warn "Could not execute 4XSLT";
            return;
        }
        $result = $self->{output_handler}->read_file( $self->{temp_out} );
        unlink( $self->{temp_out} );
    } else {
        my $response;

        foreach my $name ( keys %{ $test->{params} } ) {
            my $value = $test->{params}->{$name};

            $response = $self->_msg_4xslt("SET_PARAM $name=$value");
        }

        $response = $self->_msg_4xslt('TRANSFORM '. $test->{input_filename});
        unless ( $response =~ m/^OK/i ) {
            warn "Could not execute 4XSLT";
            return;
        }

        $result = substr( $response, length("OK "));
    }
    return $result;
}

sub execute_libxslt {     # Execute LibXSLT
    my ( $self, $test ) = @_;
    my @params;

    foreach my $name ( keys %{ $test->{params} } ) {
        my $value = $test->{params}->{$name};
        push @params, ( $name, $value );
    }

    my $results = $self->{libxslt}->transform_file( $test->{input_filename},
        XML::LibXSLT::xpath_to_string(@params) );

    my $result_string = $self->{libxslt}->output_string($results);

    return $result_string;
}

sub execute_saxon {       # Execute Saxon
    my ( $self, $test ) = @_;
    my $result;
    
    if (! $self->{saxon_instance}) { # use CLI version
        my @cmd;
        push @cmd, qw(java net.sf.saxon.Transform);
        push @cmd, '-novw';
        push @cmd, '-o';
        push @cmd, $self->{temp_out};
        push @cmd, $test->{input_filename};
        push @cmd, $self->{xslt1_filename};
        foreach my $name ( keys %{ $test->{params} } ) {
            my $value = $test->{params}->{$name};
            push( @cmd, $name . '=' . $value );
        }

        # make sure there's always a $self->{temp_out}
        # even if Saxon doesn't create one
        # because the XSLT ouputs nothing
        $self->write_file( $self->{temp_out}, '' );

        unless ( system(@cmd) == 0 ) {
            warn "Could not execute Saxon";
            return;
        }

        $result = $self->{output_handler}->read_file( $self->{temp_out} );
        unlink( $self->{temp_out} );
    }
    else { # use TrAX via Inline::Java
        foreach my $name ( keys %{ $test->{params} } ) {
            my $value = $test->{params}->{$name};
            $self->{saxon_instance}->set_param($name, $value);
        }
        $result = $self->{saxon_instance}->transform(
            $test->{input_filename}
        );
    }
    return $result;
}

sub execute_xalan_c {     # Execute Xalan-C
    my ( $self, $test ) = @_;

    my @cmd;
    push @cmd, 'Xalan';
    push @cmd, '-o';
    push @cmd, $self->{temp_out};

    foreach my $name ( keys %{ $test->{params} } ) {
        my $value = $test->{params}->{$name};
        push @cmd, '-p';
        push @cmd, $name;
        push @cmd, q{'} . $value . q{'};
    }
    push @cmd, $test->{input_filename};
    push @cmd, $self->{xslt1_filename};

    unless ( system(@cmd) == 0 ) {
        warn "Could not execute Xalan-C";
        return;
    }

    my $s = $self->{output_handler}->read_file( $self->{temp_out} );
    unlink( $self->{temp_out} );

    return $s;
}

sub execute_xalan_j {     # Execute Xalan-J
    my ( $self, $test ) = @_;
    my $result;

    if (! $self->{xalan_j_instance}) { # use CLI version
        my @cmd;
        push @cmd, 'java';

        # Make sure Xalan-J always uses Xalan-J and not an other JAXP 
        # compilant XSLT enginge for transforming. See:
        # <http://xml.apache.org/xalan-j/usagepatterns.html#plug>
        push @cmd,
            '-D'
            . 'javax.xml.transform.TransformerFactory' . '='
            . 'org.apache.xalan.processor.TransformerFactoryImpl';
        push @cmd, 'org.apache.xalan.xslt.Process';
        push @cmd, '-IN';
        push @cmd, $test->{input_filename};
        push @cmd, '-OUT';
        push @cmd, $self->{temp_out};
        push @cmd, '-XSL', $self->{xslt1_filename};

        foreach my $name ( keys %{ $test->{params} } ) {
            my $value = $test->{params}->{$name};
            push @cmd, ( '-PARAM', $name, $value );
        }

        unless ( system(@cmd) == 0 ) {
            warn "Could not execute Xalan-J";
            return;
        }
    
        $result = $self->{output_handler}->read_file( $self->{temp_out} );
        unlink( $self->{temp_out} );
    }
    else { # use TrAX via Inline::Java
        foreach my $name ( keys %{ $test->{params} } ) {
            my $value = $test->{params}->{$name};
            $self->{xalan_j_instance}->set_param($name, $value);
        }
        $result = $self->{xalan_j_instance}->transform(
            $test->{input_filename}
        );
        $result =~ s/\r*\n/\n/g;
    }
    return $result;
}

sub get_product_id {       # Get the product_id of the XSLT file
    return "";
}

sub get_test_list {       # Get a list of all tests (abstract)
    die "Abstract method";
}


1;
