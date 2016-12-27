<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Barcode</title>
	<style>
		body {font:Arial, Helvetica, sans-serif;}
		.red {color:#FF0000;}
		.blue {color:#00F;}
		.header {background-color:#CCCCCC;}
		.tranheader {background-color:#eee;}
		.chart {
			border-spacing: 0px;
			border-collapse: collapse;
			border: 1px solid #CCC;
			font-size: 14px;
			font:Arial, Helvetica, sans-serif;
		}
		.chart th {padding: 5px; background:#eee; border-color: #ccc;}
		.chart td {padding: 5px; border-color: #ccc;}
	</style>
</head>

<body>
<cfif NOT StructKeyExists(session,"mods")>
	<cfset StructInsert(session,"mods",[])>
</cfif>
<cfif StructKeyExists(form,"fieldnames")>
	<cftry>
		<cfquery name="QB" datasource="#application.site.datasource1#">
			SELECT tblBarcodes.*, prodRef,prodTitle,prodLastBought
			FROM tblBarcodes
			INNER JOIN tblProducts ON prodID=barProdID
			WHERE barID IN (#form.deleteme#,#form.fixme#)
			AND bartype='product'
		</cfquery>
		<cfloop query="QB">
			<cfset ArrayAppend(session.mods,{"barID" = QB.barID, "barcode" = QB.barcode, "product" = QB.barprodID,
				"prodRef" = QB.prodRef,"prodTitle" = QB.prodTitle, "prodLastBought" = LSDateFormat(QB.prodLastBought)})>
		</cfloop>
		<cfquery name="QBarDelete" datasource="#application.site.datasource1#">
			DELETE FROM tblBarcodes
			WHERE barID = '#form.deleteme#'
			AND bartype='product'
		</cfquery>
		<cfif len(form.fixbarcode) gt 13 AND left(form.fixbarcode,2) eq "00">
			<cfset newBarcode = right(form.fixbarcode,13)>
			<cfquery name="QBarFix" datasource="#application.site.datasource1#">
				UPDATE tblBarcodes
				SET barcode = '#newBarcode#'
				WHERE barID = '#form.fixme#'
				AND bartype='product'
			</cfquery>
		</cfif>
	<cfcatch type="any">
		<cfoutput>Error updating record. #cfcatch.Detail#</cfoutput>
		<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
	</cfcatch>
	</cftry>
</cfif>

<!---
	<cfif StructKeyExists(url,"delete")>
	<cfif NOT StructKeyExists(session,"mods")>
		<cfset StructInsert(session,"mods",[])>
	</cfif>
	<cfquery name="QB" datasource="#application.site.datasource1#">
		SELECT tblBarcodes.*, prodRef,prodTitle,prodLastBought
		FROM tblBarcodes
		INNER JOIN tblProducts ON prodID=barProdID
		WHERE barcode ='#url.delete#'
		AND bartype='product'
	</cfquery>
	<cfset ArrayAppend(session.mods,{"barcode" = QB.barcode, "product" = QB.barprodID,"prodRef" = QB.prodRef,
		"prodTitle" = QB.prodTitle, "prodLastBought" = LSDateFormat(QB.prodLastBought), "status" = "deleted"})>
	
	<cfquery name="QBarDelete" datasource="#application.site.datasource1#">
		DELETE FROM tblBarcodes
		WHERE barcode = '#url.delete#'
		AND bartype='product'
	</cfquery>

	<cfoutput>#url.delete# deleted.</cfoutput>
</cfif>
<cfif StructKeyExists(url,"fix")>
	<cftry>
		<cfif len(url.fix) eq 15 AND left(url.fix,2) eq "00">
			<cfset newBarcode = mid(url.fix,3,13)>
		</cfif>
<!---
		<cfquery name="QBarDelete" datasource="#application.site.datasource1#">
			UPDATE tblBarcodes
			SET barcode = '#newBarcode#'
			WHERE barcode = '#url.fix#'
			AND bartype='product'
		</cfquery>
--->
	<cfcatch type="any">
		Error updating record. #cfcatch.Detail#
		<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
	</cfcatch>
	</cftry>
</cfif>
--->
<cfquery name="QBars" datasource="#application.site.datasource1#">
	SELECT tblBarcodes.*, prodRef,prodTitle,prodLastBought
	FROM tblBarcodes
	INNER JOIN tblProducts ON prodID=barProdID
	WHERE bartype='product'
</cfquery>
<cfset orig = {}>
<cfset dupes = {}>
<cfset oddies = []>
<cfoutput>
	#QBars.recordcount# record<br />
	<table class="chart">
		<tr>
			<td colspan="6">MODS</td>
		</tr>
		<cfloop array="#session.mods#" index="rec">
			<tr>
				<td align="right">#rec.barcode#</td>
				<td align="right">#rec.product#</td>
				<td align="right">#rec.prodRef#</td>
				<td>#rec.prodTitle#</td>
				<td align="right">#rec.prodLastBought#</td>
			</tr>
		</cfloop>
	</table>
	<cfloop query="QBars">
		<cfif len(barcode) lte 15>
			<cfset newcode = "#mid('0000000000',1,15 - len(barcode))##barcode#">
		<cfelse>
			<cfset newcode = barcode>
		</cfif>
		<cfif StructKeyExists(orig,newcode)>
			<cfif StructKeyExists(dupes,newcode)>
				<cfset dupe = StructFind(dupes,newcode)>
				<cfset ArrayAppend(dupe,{"barID" = barID, "barcode" = barcode, "product" = barprodID,"prodRef" = prodRef,
					"prodTitle" = prodTitle, "prodLastBought" = LSDateFormat(prodLastBought)})>
			<cfelse>
				<cfset StructInsert(dupes,newcode,[])>
				<cfset dupe = StructFind(dupes,newcode)>
				<cfset rec = StructFind(orig,newcode)>
				<cfset ArrayAppend(dupe,rec)>
				<cfset ArrayAppend(dupe,{"barID" = barID, "barcode" = barcode, "product" = barprodID,"prodRef" = prodRef,
					"prodTitle" = prodTitle, "prodLastBought" = LSDateFormat(prodLastBought)})>
				<cfset StructUpdate(dupes,newcode,dupe)>
				<cfif rec.product neq barprodID>
					<cfset ArrayAppend(oddies,dupe)>
				</cfif>
			</cfif>
		<cfelse>
			<cfset StructInsert(orig,newcode,{"barID" = barID, "barcode" = barcode, "product" = barprodID,"prodRef" = prodRef,
				"prodTitle" = prodTitle, "prodLastBought" = LSDateFormat(prodLastBought)})>
		</cfif>
	</cfloop>
	<table class="chart">
	<cfloop array="#oddies#" index="set">
		<form method="post">
		<cfloop array="#set#" index="rec">
			<tr>
				<td align="right">#rec.barID#</td>
				<td align="right">#rec.barcode#</td>
				<td align="right">#rec.product#</td>
				<td align="right">#rec.prodRef#</td>
				<td>#rec.prodTitle#</td>
				<td align="right">#rec.prodLastBought#</td>
				<td>
					<cfif len(rec.barcode) gt 13>
						fix <input type="text" name="fixme" value="#rec.barID#" />
						<input type="text" name="fixbarcode" value="#rec.barcode#" />
					<cfelse>
						delete <input type="text" name="deleteme" value="#rec.barID#" />
						<input type="text" name="deletebarcode" value="#rec.barcode#" />
					</cfif>				
				</td>
			</tr>
		</cfloop>
		<tr><td colspan="6" align="right"><input type="submit" name="btnSubmit" value="Fix" /></td></tr>
		</form>
	</cfloop>
	</table>
</cfoutput>
<!---
<cfdump var="#session.mods#" label="mods" expand="yes">
<cfdump var="#dupes#" label="dupes" expand="false">
<cfdump var="#orig#" label="orig" expand="false">
<cfdump var="#oddies#" label="oddies" expand="true">--->
</body>
</html>