#!/usr/bin/env perl
use strict;
use FindBin;

use lib "$FindBin::Bin/../LIB/";

require XSLTest::Driver::Microformats::hCard;
require XSLTest::OutputHandler::RFC2425;

my $driver = XSLTest::Driver::Microformats::hCard->new(
    {   xslt1_filename => $FindBin::Bin . '/xhtml2vcard.xsl',
        output_handler => XSLTest::OutputHandler::RFC2425->new(),
        lib_dir        => "$FindBin::Bin/../LIB/"
    }
);

$driver->run();
exit 0;
