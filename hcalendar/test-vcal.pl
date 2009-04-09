#!/usr/bin/env perl
use strict;
use FindBin;

use lib "$FindBin::Bin/../LIB/";

require XSLTest::Driver::Microformats::hCalendar;
require XSLTest::OutputHandler::RFC2425;

my $driver = XSLTest::Driver::Microformats::hCalendar->new(
    {   xslt1_filename => $FindBin::Bin . '/xhtml2vcal.xsl',
        output_handler => XSLTest::OutputHandler::RFC2425->new(),
        lib_dir        => "$FindBin::Bin/../LIB/"
    }
);

$driver->run();
exit 0;
