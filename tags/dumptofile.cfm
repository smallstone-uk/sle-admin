<cftry>

<cfif thisTag.executionMode is "start">
	<cfdump var="#attributes.var#" output="#application.site.dir_logs#\E#DateFormat(Now(), 'yyyymmdd')##TimeFormat(Now(), 'HHmmss')#.html" format="html">
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>
