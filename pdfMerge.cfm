<!DOCTYPE html>
<html>
<head>
<title>PDF Merge</title>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
</head>
<body>

<cfsetting requesttimeout="300">
<cfobject component="code/Invoicing" name="inv">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form.delDate="14-02-16">
<cfset parm.form.fromDate="14-01-19">
<cfset parm.form.toDate="14-02-15">
<cfset invoices=inv.LoadInvoiceRun(parm)>

<h1>PDF Merge</h1>
<cfif NOT DirectoryExists("#application.site.dir_invoices#compiled")>
	<cfdirectory directory="#application.site.dir_invoices#compiled" action="create">
</cfif>

<cfoutput>
	<cfloop array="#invoices.rounds#" index="r">
		<cfdocument format="PDF" name="cfdoc#r.RoundID#" pagetype="a4" margintop="1.5" marginbottom="1.5" unit="in">
			<h1 style="text-align:center;margin:250px 0 0 0;">#r.roundTitle#</h1>
		</cfdocument>
	</cfloop>
		
	<cfpdf action="merge" destination="#application.site.dir_invoices#compiled/#parm.form.toDate#.pdf" overwrite="yes">
		<cfset roundID=0>
		<cfloop array="#invoices.list#" index="item">
			<cfif roundID neq item.RoundID>
				<cfpdfparam source="cfdoc#item.RoundID#">
				<cfset roundID=item.RoundID>
			</cfif>
			<cfif FileExists("#application.site.dir_invoices##parm.form.toDate#/inv_#item.ID#.pdf")>
				<cfpdfparam source="#application.site.dir_invoices##parm.form.toDate#/inv_#item.ID#.pdf">
			</cfif>
		</cfloop>
	</cfpdf>
	<a href="#application.site.url_invoices#compiled/#parm.form.toDate#.pdf" target="_blank">View</a>
</cfoutput>

</body>
</html>