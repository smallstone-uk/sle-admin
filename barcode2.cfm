<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>fix</title>
</head>

<body>

<cfquery name="QBars" datasource="#application.site.datasource1#">
	SELECT barID, RIGHT(barcode,13) AS codey
	FROM tblBarcodes
	WHERE bartype='product'
	ORDER BY codey
</cfquery>
<cfdump var="#QBars#" label="QBars" expand="no">

</body>
</html>