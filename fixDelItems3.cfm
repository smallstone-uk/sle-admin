<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Delete Specific Mags on a day</title>
</head>

<body>
<p>This function deletes duplicate magazine delivery items for 27th Jan 2021 only.</p>

<cfflush interval="200">
<cfset loopCount = 0>
<cfquery name="QDelItems" datasource="#application.site.datasource1#">
	SELECT a.diID, a.diDate, a.diPrice, b.pubTitle
	FROM tbldelitems a, tblPublication b
	WHERE b.pubID=a.diPubID
	AND a.diDate = '2021-01-27' 
	AND b.pubGroup = 'Magazine'
	ORDER BY a.diClientID, a.diOrderID, a.diPubID, a.diID ASC
</cfquery>
<cfoutput>
	<cfloop query="QDelItems">
		<cfset loopCount++>
		<cfset thisID = diID>
		<cfquery name="QDelete" datasource="#application.site.datasource1#">
			DELETE FROM tbldelitems
			WHERE diID = #thisID#
		</cfquery>
		<p>Deleted record:#loopCount# - #thisID#</p>
		<!---<cfbreak>--->
	</cfloop>
</cfoutput>

</body>
</html>