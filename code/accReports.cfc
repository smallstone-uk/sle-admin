
<!--- accounting reports functions --->

<cfcomponent displayname="AccountingFunctions" extends="code/core" hint="Report Functions 2025">

	<cffunction name="initInterface" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.menu = []>
		
		<cftry>
			<cfset loc.option = 1>
			<cfset ArrayAppend(loc.result.menu, {
				Value = 1,
				Title = "Nominal Group Headings",
				ID = "ID#loc.option#"
			})>
			<cfset loc.option++>
			<cfset ArrayAppend(loc.result.menu, {
				Value = 2,
				Title = "Monthly Stock Valuation",
				ID = "ID#loc.option#"
			})>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QReport" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT ngTitle,nomID,nomCode,nomGroup,nomType,nomClass,nomTitle,
					(SELECT count(*) FROM tblnomitems WHERE niNomID=nomID) AS ItemCount
				FROM tblNominal
				LEFT JOIN tblNomGroups ON ngCode = nomGroup
				GROUP BY nomID
				ORDER BY nomGroup, nomCode;
			</cfquery>
			<cfset loc.result.QReport = loc.QReport>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ViewReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfoutput>
				<table class="tableList" border="1">
					<tr>
						<th>ID</th>
						<th>Code</th>
						<th>Type</th>
						<th>Class</th>
						<th>Title</th>
						<th>Items</th>
						<th>Details</th>
					</tr>
					<cfset group = "">
					<cfloop query="args.QReport">
						<cfif group neq nomGroup>
							<tr>
								<th colspan="7">#nomGroup# - #ngTitle#</th>
							</tr>
						</cfif>
						<cfset group = nomGroup>
						<tr>
							<td align="right">#nomID#</td>
							<td>#nomCode#</td>
							<td>#nomType#</td>
							<td>#nomClass#</td>
							<td>#nomTitle#</td>
							<td align="right">#NumberFormat(itemCount,',')#</td>
							<td><button class="openModal" data-group="#nomGroup#" data-ref="#nomID#" data-mode="editGroup">Amend</button></td>
						</tr>
					</cfloop>
				</table>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadStockValue" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.stockArray = []>
		<cftry>
			<cfset loc.srchDateFrom = args.form.srchDateFrom>	<!--- e.g. 03/03/2025 --->
			<cfset loc.srchDateTo = args.form.srchDateTo>		<!--- e.g. 29/07/2025 --->
			<cfset loc.dateEnd = CreateDate(year(loc.srchDateFrom),Month(loc.srchDateFrom),1)>	<!--- create a day being 1st of start month and year e.g. 01/03/2025 --->
			<cfset loc.dateEnd = DateAdd("m",1,loc.dateEnd)>		<!--- hop to the 1st of next month e.g. 01/04/2025 --->
			<cfset loc.dateEnd = FormatDate(DateAdd("d",-1,loc.dateEnd),'yyyy-mm-dd')>		<!--- go back 1 day to end of chosen month e.g. 31/03/2025 --->
			<cfset loc.dateStart = FormatDate(DateAdd("d",-14,loc.dateEnd),'yyyy-mm-dd')>	<!--- step back 14 days to give required date span e.g. 17/03/2025 --->	
			<cfset loc.num = 0>
			<cfloop condition="loc.srchDateTo gte loc.dateEnd">
				<cfset loc.num++>
				
				<cfquery name="loc.QStockValue" datasource="#args.datasource#">	<!--- Tota stock value for last 14 days of the selected month --->
					SELECT SUM(trnAmnt1) AS Total
					FROM tbltrans
					WHERE trnLedger = 'purch' 
					AND trnType IN ('inv', 'crn') 
					AND trnDate BETWEEN "#DateFormat(loc.dateStart,'yyyy-mm-dd')#" AND "#DateFormat(loc.dateEnd,'yyyy-mm-dd')#"
				</cfquery>
				<cfset ArrayAppend(loc.result.stockArray, { 
					endDate = loc.dateEnd,
					stockValue = loc.QStockValue.Total
				})>
	
				<cfset loc.dateEnd = DateAdd("m",2,loc.dateEnd)>		<!--- hop to the following month e.g. 31/05/2025 --->
				<cfset loc.dateEnd = CreateDate(year(loc.dateEnd),Month(loc.dateEnd),1)>	<!--- create a day being 1st of start month and year e.g. 01/05/2025 --->
				<cfset loc.dateEnd = FormatDate(DateAdd("d",-1,loc.dateEnd),'yyyy-mm-dd')>	<!--- go back 1 day to end of chosen month e.g. 30/04/2025 --->
				<cfset loc.dateStart = FormatDate(DateAdd("d",-14,loc.dateEnd),'yyyy-mm-dd')>	<!--- step back 14 days to give required date span e.g. 16/04/2025 --->
			</cfloop>
	
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="ViewStockValue" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfoutput>
				<table class="tableList" border="1" width="300">
					<tr>
						<th align="right">As at End</th>
						<th align="right">Stock Value</th>
					</tr>
					<cfloop array="#args.stockArray#" index="loc.item">
						<tr>
							<td align="right">#FormatDate(loc.item.endDate,'mmm yyyy')#</td>
							<td align="right">#NumberFormat(loc.item.stockValue,',')#</td>
						</tr>
					</cfloop>
				</table>
			</cfoutput>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="SaveGroup" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QUpdateNom" datasource="#args.datasource#" result="loc.QNomUpdate">
				UPDATE tblNominal
				SET nomCode = '#args.form.nomCode#',
					nomType = '#args.form.nomType#',
					nomKey = '#args.form.nomKey#',
					nomClass = '#args.form.nomClass#',
					nomTitle = '#args.form.nomTitle#',
					nomGroup = '#args.form.nomGroup#'
				WHERE nomID = #args.form.nomID#
			</cfquery>
			<cfset loc.result.QNomUpdate = loc.QNomUpdate>
			<cfset loc.result.msg = "Record updated">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>
