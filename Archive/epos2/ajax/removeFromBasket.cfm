<cftry>
<cfset parm = {}>
<cfset parm.type = type>
<cfset parm.index = index>

<cfif StructKeyExists(session.epos_frame.basket, parm.type)>
	<cfset category = StructFind(session.epos_frame.basket, parm.type)>
	<cfif StructKeyExists(category, parm.index)>
		<cfset StructDelete(category, parm.index)>
	</cfif>
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>