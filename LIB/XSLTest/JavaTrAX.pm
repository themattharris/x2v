# Class for using Saxon and Xalan-J via Inline::Java
#
# Copyright 2007 Robert Bachmann <rbach@rbach.priv.at>
#
# This work is licensed under The W3C Open Source License
# <http://www.w3.org/Consortium/Legal/copyright-software-19980720>

package XSLTest::JavaTrAX;

use Inline (
    JAVA => <<'END',
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.*;

class JavaTrAXBackend {
    private TransformerFactory tfactory;
    private Transformer transformer;

    public JavaTrAXBackend(String factoryName) {
        System.setProperty(
            "javax.xml.transform.TransformerFactory", 
            factoryName
        );

        tfactory = TransformerFactory.newInstance();
        
        // Suppress warning when running Saxon
        // with an XSLT 1.0 stylesheet
        if (factoryName.equals("net.sf.saxon.TransformerFactoryImpl"))
            tfactory.setAttribute(
                "http://saxon.sf.net/feature/version-warning",
                Boolean.valueOf(false)
            );
    }

    public boolean LoadXSLT(String xsltFilename) {
        try {
            StreamSource xslSource = new StreamSource(xsltFilename);
            xslSource.setSystemId(xsltFilename);

            transformer = tfactory.newTransformer(
                new StreamSource(xsltFilename)
            );

        } catch (Exception e) {
            System.err.println(e.getMessage());
            return false;
        }
        return true;
    }

    public boolean SetParam(String param, String value) {
        try {
            transformer.setParameter(param, value);
        }
        catch (Exception e) {
            System.err.println(e.getMessage());
            return false;
        }
        return true;
    }

    public String Transform(String xmlFilename) {
        StringWriter stringWriter;
        StreamSource xmlSource;

        try {
            stringWriter = new StringWriter();
            xmlSource = new StreamSource(xmlFilename);
            transformer.transform(
                xmlSource, 
                new StreamResult(stringWriter)
            );
        }
        catch (Exception e) {
            System.err.println(e.getMessage());
            return "-";
        }

        return stringWriter.toString();
    }
}
END
);

use strict;
use warnings;

sub new {
    my $class = shift;
    my $args  = shift;
    my $self  = {};

    my $obj = 
        new XSLTest::JavaTrAX::JavaTrAXBackend(
            $args->{factory_name} 
        );

    $self->{backend} = $obj;

    return bless ($self, $class);
}

sub set_param {
    my ($self, $param, $value) = @_;
    $self->{backend}->SetParam($param, $value);
}

sub load_xslt {
    my ($self, $xslt_filename) = @_;
    $self->{backend}->LoadXSLT($xslt_filename);
}

sub transform {
    my ($self, $xml_filename) = @_;
    $self->{backend}->Transform($xml_filename);
}

1;
