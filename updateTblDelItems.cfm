<cfexit>
<cfsetting requesttimeout="300">
<cftransaction>
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfquery name="QDelItems" datasource="#parm.datasource#">
		SELECT diID,diDate
		FROM tblDelItems
		WHERE 1
	</cfquery>
	<cfloop query="QDelItems">
		<cfquery name="QUpdate" datasource="#parm.datasource#">
			UPDATE tblDelItems
			SET diDatestamp='#LSDateFormat(QDelItems.diDate,"yyyy-mm-dd")#'
			WHERE diID=#val(QDelItems.diID)#
		</cfquery>
	</cfloop>
</cftransaction>
