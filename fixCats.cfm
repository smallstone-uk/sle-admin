<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Cats</title>
<style>
	.red {color:#FF0000;}
</style>
</head>
<cfparam name="doUpdate" default="false">
<body>
<h1>Product Category Cleanup</h1>
<p>Removes counters, unwanted spaces and 'Retail' from category titles.</p>
<cftry>
	<cfquery name="QTrimCats" datasource="#application.site.datasource1#">
		UPDATE tblProductCats
		SET pcatTitle = TRIM(pcatTitle)
		WHERE 1
	</cfquery>
	<cfquery name="QCats" datasource="#application.site.datasource1#">
		SELECT *
		FROM tblProductCats
		WHERE pcatTitle REGEXP '([[:digit:]]+))'
		OR pcatTitle LIKE '%Retail%'
		ORDER BY pcatTitle ASC
	</cfquery>
	<cfoutput>
		<table>
			<cfloop query="QCats">
				<cfset msg = "">
				<cfset origCat = pcatID>
				<cfset words = ListLen(pcatTitle," ")>
				<cfset shortTitle = ListDeleteAt(pcatTitle,words," ")>
				<cfset shortTitle = Trim(ReReplaceNoCase(shortTitle,'Retail',""))>
				<cfquery name="QCat" datasource="#application.site.datasource1#">
					SELECT * FROM tblProductCats WHERE pcatTitle LIKE '#shortTitle#' LIMIT 1;
				</cfquery>
				<cfif doUpdate>
					<cfif QCat.recordcount eq 0>
						<cfquery name="QAddCategory" datasource="#application.site.datasource1#">
							INSERT INTO tblProductCats (pcatTitle) 
							VALUES ('#shortTitle#')
						</cfquery>
						<cfset msg = "Created: #shortTitle#">
						<cfquery name="QCatNew" datasource="#application.site.datasource1#">
							SELECT * FROM tblProductCats WHERE pcatTitle LIKE '#shortTitle#' LIMIT 1;
						</cfquery>
						<cfset newCat = QCatNew.pcatID>
					<cfelse>
						<cfset newCat = QCat.pcatID>
					</cfif>
					<cfquery name="QCatUpdate" datasource="#application.site.datasource1#">
						UPDATE tblProducts 
						SET prodCatID=#newCat#
						WHERE prodCatID=#origCat#
					</cfquery>
					<cfset msg = "#msg# Moved to: #newCat# #shortTitle#">
				<cfelse>
					<cfif QCat.recordcount eq 1>
						<cfset msg = "Can move to: #QCat.pcatID# #QCat.pcatTitle#">
					<cfelse>
						<cfset msg = "Create: #shortTitle#">
					</cfif>
				</cfif>
				<tr>
					<td>#pcatID#</td>
					<td>#pcatTitle#</td>
					<td>#shortTitle#</td>
					<td>#msg#</td>
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