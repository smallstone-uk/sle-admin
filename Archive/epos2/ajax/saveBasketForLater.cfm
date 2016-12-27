<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.timestamp = "#LSDateFormat(Now(), 'dd/mm/yyyy')# #LSTimeFormat(Now(), 'HH:mm')#">
<cfset parm.frame = StructCopy(session.epos_frame)>

<cfif StructKeyExists(session, "epos_archive")>
	<cfif StructCount(session.epos_archive) is 0>
		<cfset StructInsert(session.epos_archive, parm.timestamp, parm.frame)>
	</cfif>
<cfelse>
	<cfset session.epos_archive = {}>
	<cfset StructInsert(session.epos_archive, parm.timestamp, parm.frame)>
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>