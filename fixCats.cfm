<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Cats</title>
<style>
	.red {color:#FF0000;}
</style>
</head>

<body>
<cftry>
	<cfquery name="QCats" datasource="#application.site.datasource1#">
		SELECT *
		FROM `tblProductCats`
		WHERE `pcatTitle` LIKE '%(%'
		ORDER BY `pcatTitle` ASC
	</cfquery>
	<cfoutput>
		<table>
		<cfloop query="QCats">
			<cfset origCat = pcatID>
			<cfset words = ListLen(pcatTitle," ")>
			<cfset shortTitle = ListDeleteAt(pcatTitle,words," ")>
			<cfquery name="QCat" datasource="#application.site.datasource1#">
				SELECT * FROM tblProductCats WHERE pcatTitle LIKE '#shortTitle#' LIMIT 1;
			</cfquery>
			<cfif QCat.recordcount eq 1>
				<cfquery name="QCatUpdate" datasource="#application.site.datasource1#" result="QCatResult">
					UPDATE tblProducts 
					SET prodCatID=#QCat.pcatID#
					WHERE prodCatID=#origCat#
				</cfquery>
				<cfset move = "Moved to: #QCat.pcatID# #QCat.pcatTitle# #QCatResult.recordcount#">
			<cfelse>
				<cfset move = "<span class='red'>dest not found</span>">
			</cfif>
			<tr>
				<td>#origCat#</td>
				<td>#pcatTitle#</td>
				<td>#words#</td>
				<td>#shortTitle#</td>
				<td>#move#</td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</body>
</html>