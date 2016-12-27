<cfcomponent displayname="rounds" extends="core">

	<cffunction name="LoadRoundList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.rounds=ArrayNew(1)>
		<cfset var item={}>
		<cfset var QRounds="">
		
		<cfquery name="QRounds" datasource="#args.datasource#">
			SELECT *
			FROM tblRounds
			WHERE rndActive
			ORDER BY rndRef asc
		</cfquery>
		<cfloop query="QRounds">
			<cfset item={}>
			<cfset item.ID=rndID>
			<cfset item.Ref=rndRef>
			<cfset item.Title=rndTitle>
			<cfset ArrayAppend(result.rounds,item)>
		</cfloop>

		<cfreturn result>
	</cffunction>

</cfcomponent>