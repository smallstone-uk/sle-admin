<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.mode = mode>
<cfset basketCount = epos.BasketItemCount()>

<cfif basketCount is 0>
	<cfset session.epos_frame.mode = mode>
	true
<cfelseif parm.mode eq "office">
	<cfset session.epos_frame.mode = mode>
	true
<cfelseif session.epos_frame.mode eq "office">
	<cfset session.epos_frame.mode = mode>
	true
<cfelse>
	false
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>