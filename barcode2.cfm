<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>fix</title>
</head>

<body>

<cfquery name="QBars" datasource="#application.site.datasource1#">
	SELECT barID,barcode, barProdID, RIGHT(barcode,8) AS codey
	FROM tblBarcodes
	WHERE bartype='product'
	AND LEFT(barcode,5) = '00000'
	OR LENGTH(barcode) = 8
	ORDER BY codey
</cfquery>
<cfoutput>
	<cfset dupeCount = 0>
	<cfset lastBar = "">
	<cfset lastProdID = 0>
	<cfset deleteMe = []>
	<table>
	<cfloop query="QBars">
		<cfif len(lastBar) AND lastBar eq codey AND lastProdID eq barProdID>
			<cfset dupeCount++>
			<tr>
				<td>#lastRec.row#</td>
				<td>#lastRec.barID#</td>
				<td>#lastRec.barProdID#</td>
				<td>#lastRec.barcode#</td>
				<td>#lastRec.codey#</td>
			</tr>
			<tr>
				<td>#currentrow#</td>
				<td>#barID#</td>
				<td>#barProdID#</td>
				<td>#barcode#</td>
				<td>#codey#</td>
			</tr>
			<cfset ArrayAppend(deleteMe,lastRec)>
		</cfif>
		<cfset lastRec = {row=currentrow,barID=barID,barProdID=barProdID,barcode=barcode,codey=codey}>
		<cfset lastBar = codey>		
		<cfset lastProdID = barProdID>
	</cfloop>
	</table>
	#QBars.recordcount# records. #dupeCount# duplicates.
	<cfdump var="#deleteMe#" label="deleteMe" expand="false">
	<cfif StructKeyExists(form,"btnSubmit")>
		<cfloop array="#deleteMe#" index="item">
			<cfquery name="QBarDelete" datasource="#application.site.datasource1#">
				DELETE FROM tblBarcodes
				WHERE barID = #item.barID#
			</cfquery>
		</cfloop>
	</cfif>
	<form method="post">
		<input type="submit" name="btnSubmit" value="Delete 8 char Duplicates" />
	</form>
</cfoutput>
</body>
</html>