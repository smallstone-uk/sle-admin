<cfset ddd="mon">
<cfset args.datasource=application.site.datasource1>
<cfsetting requesttimeout="3000">
<cfquery name="QSelect" datasource="#args.datasource#">
	SELECT *
	FROM tblOrder,tblClients
	WHERE ordActive=1
	AND cltAccountType<>'N'
	AND ordClientID=cltID
</cfquery>

<cfset ord=0>
<cfset found=0>
<cfset missingTotal=0>
<cfoutput>
<table border="1">
	<tr>
		<th width="10">##</th>
		<th width="60">Client</th>
		<th width="40">Mon</th>
		<th width="40">Tue</th>
		<th width="40">Wed</th>
		<th width="40">Thu</th>
		<th width="40">Fri</th>
		<th width="40">Sat</th>
		<th width="40">Sun</th>
	</tr>
	<cfloop query="QSelect">
		<cfset found=0>
		<cfquery name="QItems" datasource="#args.datasource#">
			SELECT *
			FROM tblRoundItems,tblRounds
			WHERE riOrderID=#ordID#
			AND riRoundID=rndID
		</cfquery>
		<cfset days={}>
		<cfset days.mon="">
		<cfset days.tue="">
		<cfset days.wed="">
		<cfset days.thu="">
		<cfset days.fri="">
		<cfset days.sat="">
		<cfset days.sun="">
		<cfloop query="QItems">
			<cfset found=found+1>
			<cfset StructUpdate(days,riDay,rndTitle)>
		</cfloop>
		<cfif found neq 7>
			<cfset missingTotal=missingTotal+1>
			<tr>
				<td>#missingTotal#</td>
				<td><a href="clientDetails.cfm?row=0&ref=#QSelect.cltRef#" target="_blank">#QSelect.cltName# #QSelect.cltCompanyName#</a></td>
				<th width="40">#days.mon#</th>
				<th width="40">#days.tue#</th>
				<th width="40">#days.wed#</th>
				<th width="40">#days.thu#</th>
				<th width="40">#days.fri#</th>
				<th width="40">#days.sat#</th>
				<th width="40">#days.sun#</th>
			</tr>
		</cfif>
		<cfif 1 is 2>
			<cfloop from="1" to="7" index="i">
				<cfif i is 1><cfset ddd="mon"></cfif>
				<cfif i is 2><cfset ddd="tue"></cfif>
				<cfif i is 3><cfset ddd="wed"></cfif>
				<cfif i is 4><cfset ddd="thu"></cfif>
				<cfif i is 5><cfset ddd="fri"></cfif>
				<cfif i is 6><cfset ddd="sat"></cfif>
				<cfif i is 7><cfset ddd="sun"></cfif>
				<cfquery name="QCheck" datasource="#args.datasource#">
					SELECT *
					FROM tblRoundItems
					WHERE riOrderID=#riOrderID#
					AND riRoundID=#riRoundID#
					AND riDay='#ddd#'
				</cfquery>
				<cfif QCheck.recordcount is 0>
					<cfif i is 1>
						<cfquery name="QUpdate" datasource="#args.datasource#">
							UPDATE tblRoundItems
							SET riDay='mon'
							WHERE riID=#riID#
						</cfquery>
					<cfelse>
						<cfquery name="QInsert" datasource="#args.datasource#">
							INSERT INTO tblRoundItems (
								riClientID,
								riOrderID,
								riRoundID,
								riDay,
								riOrder
							) VALUES (
								#val(riClientID)#,
								#val(riOrderID)#,
								#val(riRoundID)#,
								'#ddd#',
								#val(riOrder)#
							)
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>
</table>
</cfoutput>

