<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.tranID = 2052>
<cfset tran = epos.LoadTransaction(parm)>
<cfdump var="#tran#" label="tran" expand="yes">

<cfoutput>
	<cfloop array="#tran.items#" index="item">
		<cfif item.etiItemID gt 0>
			<cfset item.product = epos.LoadProductByID(item.etiItemID)>
			<cfdump var="#item#" label="item" expand="yes">
		<cfelse>
			<cfdump var="#item#" label="item" expand="yes">
		</cfif>
	</cfloop>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>