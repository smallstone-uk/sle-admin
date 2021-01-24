
<!--- load delivery items --->

<cftry>
	<cfobject component="code/functions" name="cust">
	<cfif StructKeyExists(session,"clientSearch")>
		<cfset search=Duplicate(session.clientSearch)>
	<cfelse><cfset search = {}></cfif>
	<cfset search.srchDelDate=form.srchDelDate>
	<cfset search.datasource = application.site.datasource1>
	<cfset customer=cust.LoadClient(search)>
	<cfset custDelItems=cust.LoadClientDelItems(customer)>
	<cfinclude template="clientDelItems.cfm">
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

