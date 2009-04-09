#!/usr/bin/env perl
use strict;
use FindBin;

use lib "$FindBin::Bin/../LIB/";

require XSLTest::Driver::Microformats::hAtom;
require XSLTest::OutputHandler::XML;

my $driver = XSLTest::Driver::Microformats::hAtom->new(
    {   xslt1_filename => $FindBin::Bin . '/hAtom2Atom.xsl',
        output_handler => XSLTest::OutputHandler::XML->new(),
        lib_dir        => "$FindBin::Bin/../LIB/"
    }
);

$driver->run();
exit 0;
