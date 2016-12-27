<cftry>

<cfif thisTag.executionMode is "start">
	<cfdump var="#attributes.var#" expand="no">
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>
