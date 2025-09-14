<cfcomponent displayname="EMail Maintenance">

	<cffunction name="ReadMail" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.path="#application.site.dir_data#attachments\">
		<cftry>
        	<cfpop
            	action="getall"
                server="mail.shortlanesendstore.co.uk"
                username="#application.company.email_news#"
                password="sle5946" attachmentpath="#loc.path#"
                name="loc.QMsgs">
        	<cfset loc.result.msgs=loc.QMsgs>
			<!---<cfloop query="QMsgs">
            </cfloop>--->
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>