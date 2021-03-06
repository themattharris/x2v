<?php
/* --------------------------------------------

Brian Suda
brian@suda.co.uk
20-Sept-2004

version 1.0

NOTES:
This required PHP XSLT libraries installed

--------------------------------------------- */

// Include shared properties:
require_once('configuration.php');

// Check for URL or a referrer
$uri='';
if (isset($_GET['referer'])) {
  if (getenv("HTTP_REFERER") != '') { 
      $uri = getenv("HTTP_REFERER"); 
  }
}

// if a url is specified then use that
if (isset($_GET['uri'])){
  if ($_GET['uri'] != '') {
      $uri = $_GET['uri'];
  }
}


if ((substr($uri, 0,7) == "http://") || (substr($uri, 0,8) == "https://")) {
    
    set_time_limit(90);

	// check to see if a filename is specified
	if (isSet($_GET['filename'])){
	  if ($_GET['filename'] != ''){ $logfile = $_GET['filename']; }
	} else { $logfile = "X2V";}

	// explode on the '#' to separate the anchor link from the page
	$temp = explode("#",$uri);
    if(isSet($temp[1])){ 
        $anchor = $temp[1];
    } else {
        $anchor = '';
    }
    $temp = $temp[0];
    
	$c = curl_init();
	curl_setopt($c, CURLOPT_RETURNTRANSFER,1);
	curl_setopt($c, CURLOPT_URL, str_replace('&amp;','&',$uri));
	curl_setopt($c, CURLOPT_CONNECTTIMEOUT, 2);
	curl_setopt($c, CURLOPT_TIMEOUT, 4);
	curl_setopt($c, CURLOPT_USERAGENT, X2V_USER_AGENT);
	curl_setopt($c, CURLOPT_FOLLOWLOCATION,1);
	$xml_string = curl_exec($c);
	$info = curl_getinfo($c);


    // $config = array('indent' => TRUE,
    //                'output-xhtml' => TRUE,
    //                'wrap' => 200);
    // $tidy = tidy_parse_string($xml_string, $config, 'UTF8');
    // 
    // $tidy->cleanRepair();
    // $xml_string = $tidy;

	$doc = new DOMDocument();
	$xsl = new XSLTProcessor();
	
	if (isset($_GET['type'])){
		switch(strtolower($_GET['type'])){
		    case "rdf":     
		        $extension .= "rdf";
		        $contentType = 'application/xml+rdf';
		        $filename = X2V_ROOT_PATH . '/hcard/xhtml2vcardrdf.xsl';
		        break;
		    default:
		        $filename = X2V_ROOT_PATH . '/hcard/xhtml2vcard.xsl';
		        $contentType = "text/x-vcard";
		        $extension = 'vcf';
		        break;
		}
	} else { 
	    $filename = X2V_ROOT_PATH . '/hcard/xhtml2vcard.xsl';
	    $contentType = "text/x-vcard"; $extension = 'vcf';
	}
	
	$doc->load($filename);
	$xsl->importStyleSheet($doc);
	$xsl->setParameter('', 'Source', $uri);
	$xsl->setParameter('', 'Anchor', $anchor);
	$xsl->setParameter('', 'Encoding', X2V_CHARSET);

	$doc->loadHTML($xml_string);
	$doc->formatOutput = true;
	$Str = $xsl->transformToXML($doc);

	if (FALSE == $Str){
		print 'No vCards found';
		//print '<!-- '.htmlentities($xml_string).' -->';
	} else {
		header("Content-Disposition: attachment; filename=$logfile.$extension");
	//	header("Content-Length: ".mb_strlen($Str)+1);
		header("Connection: close");
		header("Content-Type: $contentType; charset=".X2V_CHARSET."; name=$logfile.$extension");
		echo $Str;
		exit();
	}
} else {
	print 'invalid URI!';
}
?>