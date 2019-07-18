<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<title>Export Barcodes</title>
</head>

<cfset parm = {}>
<cfset parm.outFile = "#application.site.dir_data#stock\barcodes.txt">
<cfset parm.datasource = application.site.datasource1>
<cfset parm.dayNo = DayofWeek(Now())>
<cfif parm.dayNo gt 1 AND parm.dayNo lt 5>
	<cfset parm.nextDel = 'Thursday'>
<cfelse>
	<cfset parm.nextDel = 'Monday'>
</cfif>

<cfquery name="QBarcodes" datasource="#parm.datasource#">
	SELECT barcode,prodTitle, prodUnitSize,prodReorder
	FROM tblProducts
	INNER JOIN tblBarcodes ON barProdID=prodID
	AND barType = 'product'
	WHERE prodReorder IN ('#parm.nextDel#','Every')
</cfquery>
<cfif FileExists(parm.outFile)>
	<cffile action="delete" file="#parm.outFile#">
</cfif>
<cfoutput>
	<b>Data exported to #parm.outFile#</b>
	<table width="500" class="tableList" border="1">
		<tr>
			<th>Barcode</th>
			<th>Product Title</th>
			<th>Size</th>
			<th>Reorder</th>
		</tr>
	<cfloop query="QBarcodes">
		<cffile action="append" file="#parm.outFile#" 
			output="#DateFormat(NOW(),'mm/dd/yy')#,#TimeFormat(NOW(),'HH:mm:ss')#,OB,#barcode#" addnewline="yes">
		<tr>
			<td>#barcode#</td>
			<td>#prodTitle#</td>
			<td>#prodUnitSize#</td>
			<td>#prodReorder#</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>
<body>
</body>
</html>