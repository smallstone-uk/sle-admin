<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>test</title>
<style type="text/css">
    body {
        width: 100%;
        height: 100%;
        margin: 0;
        padding: 0;
        background-color: #ffffff;
        font: 12pt "Tahoma";
    }
    * {
        box-sizing: border-box;
        -moz-box-sizing: border-box;
    }
    .page {
        width: 210mm;
        min-height: 297mm;
        padding: 5mm;
        /*margin: 10mm auto;*/
        border: 1px #D3D3D3 solid;
        border-radius: 5px;
        background: white;
        box-shadow: 0 0 5px rgba(0, 0, 0, 0.1);
    }
    .subpage {
        padding: 1cm;
        border: 2px #3399CC solid;
        /*height: 257mm;*/
		height: 277mm;
       /* outline: 2cm #FFEAEA solid;*/
    }
	#footer {
		clear: both;
		height: 10mm;
		<!---margin-top: -3em;--->
		position: relative;
		z-index: 10;
		border:solid 2px #ccc;
		padding:4px;
		<!---margin:2px;--->
	}    
    @page {
        size: A4;
        margin: 0;
    }
    @media print {
        html, body {
            width: 210mm;
            height: 277mm;        
        }
        .page {
            margin: 0;
            border: initial;
            border-radius: initial;
            width: initial;
            min-height: initial;
            box-shadow: initial;
            background: initial;
            page-break-after: always;
        }
    }
</style>
</head>

<body>
<div class="book">
<cfoutput>
	<cfset loop=12>
	<cfloop from="1" to="#loop#" index="i">
		<div class="page">
			<div class="subpage">
				page content
			</div>    
			<div id="footer">Page #i#/#loop#</div>
		</div>
	</cfloop>
</cfoutput>
</div>
</body>
</html>
