<cftry>
    <cfobject component="code/core" name="core">
    <cfobject component="code/deals" name="deals">
    <cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
    <cfset parm.datasource = getDatasource()>
	<cfset parm.form = form>
    <cfset parm.form.source = "product">
	<!--- <cfset product = deals.LoadProductByBarcode(parm.barcode)> --->
   <!--- <cf_dumptofile var="#parm#">--->
    <cfset lookup = pstock.FindProduct(parm)>
	<cfoutput>#SerializeJSON(lookup)#</cfoutput>
<cfdump var="#lookup#" label="lookup" expand="yes" format="html" 
	output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">

	<cfcatch type="any">
		<cf_dumptofile var="#cfcatch#">
	</cfcatch>
</cftry>