
	<cffunction name="SaveControl" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QControl" datasource="#args.datasource#" result="loc.QControlResult">
				UPDATE tblControl
				SET
					<cfif StructKeyExists(args.form,"advance")>
						ctlNextInvDate = '#toDate#',
					</cfif>
					ctlInvMessage = '#args.form.ctlInvMessage#'
				WHERE
					ctlID = 1
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form = form>
<cfset result = SaveControl(parm)>

