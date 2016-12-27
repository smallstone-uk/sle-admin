
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.groupID = form.groupID>
<cfset parm.catID = form.catID>

	<cffunction name="GetCats" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.result.QCategories" datasource="#args.datasource#">
				SELECT pcatID,pcatTitle
				FROM tblProductCats
				WHERE pcatGroup=#val(args.groupID)#
				ORDER BY pcatTitle
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<cfset result = GetCats(parm)>
<cfoutput>
	<select name="prodCatID" class="field">
		<cfloop query="result.QCategories">
			<option value="#pcatID#"<cfif pcatId eq parm.catID> selected</cfif>>#pcatTitle#</option>
		</cfloop>
	</select>
</cfoutput>
