<cftry>
<cfobject component="code/payroll" name="pr">
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.content = content>
<cfset parm.output = "">
<cfset parm.useName = "Payroll_Report_#Year(Now())##Month(Now())##Day(Now())#_#CreateUUID()#">
<cfset parm.fileName = "#application.site.dir_data#\payroll\reports\#parm.useName#.pdf">
<cfset parm.baseDir = "#application.site.dir_data#\payroll\reports">

<cfoutput>
	<cfdocument 
		format = "PDF" 
		filename = "#parm.fileName#" 
		mimeType = "text/html" 
		name = "parm.output" 
		orientation = "portrait" 
		overwrite = "yes" 
		saveAsName = "#parm.useName#" 
		src = "#parm.baseDir#">
		
		<cfdocumentitem type="header" evalAtPrint="true">
			<h1 style="font-size:22px;font-family: Arial, Helvetica, sans-serif;">Report</h1>
		</cfdocumentitem>
		<cfdocumentitem type="footer" evalAtPrint="true">
			<div style="font-size:12px;font-family: Arial, Helvetica, sans-serif;text-align:right;">#cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</div>
		</cfdocumentitem>
		
		#parm.content#
		
	</cfdocument>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>