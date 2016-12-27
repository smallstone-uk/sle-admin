<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.barcode = barcode>
<cfset product = epos.LoadProductByBarcode(parm.barcode)>

<cfoutput>
	<cfloop collection="#product#" item="key">
		<cfset value = StructFind(product, key)>
		@#LCase(key)#: #value#
	</cfloop>
	@basketBalance: #-val(session.epos_frame.result.balanceDue)#
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>