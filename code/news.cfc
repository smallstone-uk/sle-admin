<cfcomponent displayname="news" hint="News Management Functions">

	<cffunction name="myFunction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QQuery" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT *
				FROM table
				WHERE ID=#val(id)#
				LIMIT 1;
			</cfquery>
			<cfset loc.result.QQuery = loc.QQuery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>
