
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
				Value = #loc.option#,
				Title = "Nominal Group Headings",
				ID = "ID#loc.option#"
			})>
			<cfset loc.option++>
			<cfset ArrayAppend(loc.result.menu, {
				Value = #loc.option#,
				Title = "Monthly Stock Valuation",
				ID = "ID#loc.option#"
			})>
			<cfset loc.option++>
			<cfset ArrayAppend(loc.result.menu, {
				Value = #loc.option#,
				Title = "Aged Account Report",
				ID = "ID#loc.option#"
			})>
			<cfset loc.option++>
			<cfset ArrayAppend(loc.result.menu, {
				Value = #loc.option#,
				Title = "Sales Data Corrections",
				ID = "ID#loc.option#"
			})>
			<cfset loc.option++>
			<cfset ArrayAppend(loc.result.menu, {
				Value = #loc.option#,
				Title = "Balance Sheet",
				ID = "ID#loc.option#"
			})>
			<cfset loc.option++>
			<cfset ArrayAppend(loc.result.menu, {
				Value = #loc.option#,
				Title = "Suppliers Report",
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
						<th>Trans</th>
					</tr>
					<cfset group = "">
					<cfloop query="args.QReport">
						<cfif group neq nomGroup>
							<tr>
								<th colspan="8">#nomGroup# - #ngTitle#</th>
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
							<td><button class="openModal" data-group="#nomGroup#" data-ref="#nomID#" data-title="#nomTitle#" data-mode="editGroup">Amend</button></td>
							<td><button class="openTrans" data-group="#nomGroup#" data-ref="#nomID#" data-title="#nomTitle#" data-mode="viewTrans">Trans</button></td>
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
				
				<cfquery name="loc.QStockValue" datasource="#args.datasource#">	<!--- Total stock value for last 14 days of the selected month --->
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

	<cffunction name="AgedAccount" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.data = {}>
		
		<cftry>
			<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
				<cfset loc.srchDateFrom = FormatDate("2013-01-01",'yyyy-mm-dd')>
			<cfelseif IsDate(args.form.srchDateFrom)>
				<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateFrom = "">
			</cfif>
			<cfif !StructKeyExists(args.form,"srchDateTo") OR len(args.form.srchDateTo) IS 0>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			<cfelseif IsDate(args.form.srchDateTo)>
				<!---<cfset loc.srchDateTo = DateAdd("d",1,args.form.srchDateTo)> for timed dates only --->
				<cfset loc.srchDateTo = FormatDate(args.form.srchDateTo,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			</cfif>

			<cfquery name="loc.QMonthTotals" datasource="#args.datasource#">
				SELECT trnID,trnRef,trnDate,trnType,trnDesc, nomCode,nomTitle,nomGroup, 
					SUM(niAmount) AS value, SUM(niVATAmount) AS VAT, DATE_FORMAT( trnDate, '%Y-%m' ) AS YYMM 
				FROM tblnomitems 
				INNER JOIN tblTrans ON trnID = niTranID 
				INNER JOIN tblNominal ON nomID = niNomID 
				WHERE niNomID = #args.nomAccount# 
				AND trnDate BETWEEN '#loc.srchDateFrom#' AND '#loc.srchDateTo#' 
				GROUP BY nomGroup, YYMM;
			</cfquery>
			<cfif loc.QMonthTotals.recordcount gt 0>
				<cfquery name="loc.QBfwd" datasource="#args.datasource#">
					SELECT SUM(niAmount) AS Total
					FROM tblNomItems
					INNER JOIN tblTrans ON trnID = niTranID 
					WHERE niNomID = #args.nomAccount#
					AND trnDate < '#loc.srchDateFrom#'
					GROUP BY niNomID
				</cfquery>
				<cfset loc.runTotal = val(loc.QBfwd.Total)>
				<cfset loc.data = 
					{" BFWD" = {"value" = val(loc.QBfwd.Total), "VAT" = 0, "balance" = val(loc.QBfwd.Total)},
					 "Total" = {"value" = 0, "VAT" = 0, "balance" = val(loc.QBfwd.Total)}
				}>
					
				<cfset loc.lastDate = DateFormat(loc.srchDateTo,'yyyy-mm')>
				<cfloop from="1" to="12" index="loc.i">
					<cfset StructInsert(loc.data,loc.lastDate,{
						"value" = 0,
						"VAT" = 0,
						"balance" = 0
					})>
					<cfset loc.lastDate = DateFormat(DateAdd("m",-1,loc.lastDate),'yyyy-mm')>
				</cfloop>
				
				<cfloop query="loc.QMonthTotals">
					<cfset loc.runTotal += val(value)>
					<cfif !StructKeyExists(loc.result,"#nomGroup#-#nomCode#")>
						<cfset loc.result.nomCode = nomCode>
						<cfset loc.result.nomTitle = nomTitle>
						<cfset loc.result.nomGroup = nomGroup>
					</cfif>
					<cfif !StructKeyExists(loc.data,YYMM)>
						<cfset loc.prd = StructFind(loc.data," BFWD")>
						<cfset loc.prd.value += value>
						<cfset loc.prd.VAT += VAT>
						<cfset loc.prd.balance = loc.runTotal>
					<cfelse>
						<cfset loc.prd = StructFind(loc.data,YYMM)>
						<cfset loc.prd.value += value>
						<cfset loc.prd.VAT += VAT>
						<cfset loc.prd.balance = loc.runTotal>
					</cfif>
					<cfset loc.prd = StructFind(loc.data,"Total")>
						<cfset loc.prd.value += value>
						<cfset loc.prd.VAT += VAT>
						<cfset loc.prd.balance += value>
				</cfloop>
			</cfif>
			<cfset loc.result.data = loc.data>			

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AgedAccountReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.accounts = []>
		<cfset loc.accList = "">
		
		<cftry>
			<cfquery name="loc.QAccountList" datasource="#args.datasource#">
				SELECT nomID, nomGroup, nomCode
				FROM tblNominal
				WHERE nomGroup IN ('R','R3','R4','RS')
				ORDER BY nomGroup,nomCode
			</cfquery>
			<cfloop query="loc.QAccountList">
				<cfset loc.accList = "#loc.accList#,#nomID#">
			</cfloop>
			
			<cfloop list="#loc.accList#" index="loc.ID">
				<cfset args.nomAccount = loc.ID>
				<cfset loc.account = AgedAccount(args)>
				<cfif  !StructIsEmpty(loc.account.data)>
					<cfset ArrayAppend(loc.result.accounts,loc.account)>
				</cfif>
			</cfloop>
			<cfif ArrayLen(loc.result.accounts) gt 0>
				<cfset loc.header = loc.result.accounts[1]>
				<cfset loc.headerlist = ListSort(StructKeyList(loc.header.data,","),"text","ASC")>
				<cfoutput>
					<table class="tableList" width="100%">
						<tr>
							<th>Group</th>
							<th>Code</th>
							<th>Title</th>
							<cfloop list="#loc.headerlist#" index="loc.key">
								<th align="right">#loc.key#</th>
							</cfloop>
						</tr>
						<cfloop array="#loc.result.accounts#" index="loc.item">
							<cfset loc.datalist = ListSort(StructKeyList(loc.item.data,","),"text","ASC")>
							<tr>
								<td>#loc.item.nomGroup#</td>
								<td>#loc.item.nomCode#</td>
								<td>#loc.item.nomTitle#</td>
								<cfloop list="#loc.datalist#" index="loc.key">
									<cfset loc.prd = StructFind(loc.item.data,loc.key)>
									<td align="right">
										<table class="tableList" width="100%">
											<tr><td align="right">#showField(loc.prd.value,2)#&nbsp;</td></tr>
											<tr><td align="right">#showField(loc.prd.balance,2)#&nbsp;</td></tr>
										</table>
									</td>
								</cfloop>
							</tr>
						</cfloop>
					</table>
				</cfoutput>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ViewTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.trans = []>
		
		<cftry>
			<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
				<cfset loc.srchDateFrom = FormatDate("2013-01-01",'yyyy-mm-dd')>
			<cfelseif IsDate(args.form.srchDateFrom)>
				<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateFrom = "">
			</cfif>
			<cfif !StructKeyExists(args.form,"srchDateTo") OR len(args.form.srchDateTo) IS 0>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			<cfelseif IsDate(args.form.srchDateTo)>
				<cfset loc.srchDateTo = FormatDate(args.form.srchDateTo,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			</cfif>
			<cfquery name="loc.QLimit" datasource="#args.datasource#">
				SELECT count(*) AS maxRecs
				FROM tblNomItems
				INNER JOIN tblTrans ON trnID = niTranID 
				WHERE niNomID = #val(args.form.ref)#
				AND trnDate BETWEEN '#loc.srchDateFrom#' AND '#loc.srchDateTo#' 
			</cfquery>
			<cfif loc.QLimit.maxRecs gt 1000>
				<cfset loc.result.msg = "Your selection will return #NumberFormat(loc.QLimit.maxRecs,',')# records 
					which is too many in one go.<br>The limit is 1,000. Try narrowing your search criteria.">
				<cfreturn loc.result>
			</cfif>
			<cfquery name="loc.QTransIDs" datasource="#args.datasource#">
				SELECT trnID,trnRef,trnDate,trnType,trnDesc
				FROM tblNomItems
				INNER JOIN tblTrans ON trnID = niTranID 
				WHERE niNomID = #val(args.form.ref)#
				AND trnDate BETWEEN '#loc.srchDateFrom#' AND '#loc.srchDateTo#' 
				ORDER BY trnDate
				<!---LIMIT 50; --->
			</cfquery>
			<cfset loc.result.QTransIDs = loc.QTransIDs>
			<cfset loc.result.tranCount = loc.QTransIDs.recordcount>
			
			<cfset loc.TransIDs = {}>
			<cfloop query="loc.QTransIDs">
				<cfif !StructKeyExists(loc.TransIDs,trnID)>
					<cfset StructInsert(loc.TransIDs,trnID,0)>
					<cfset loc.tran = {
						trnID = trnID,
						trnRef = trnRef,
						trnDate = trnDate,
						trnType = trnType,
						trnDesc = trnDesc,
						items = []
					}>
					<cfset loc.tranID = trnID>
					<cfquery name="loc.QTransItems" datasource="#args.datasource#">
						SELECT nomCode,nomTitle,nomGroup, niID,niAmount
						FROM tblNomItems 
						INNER JOIN tblNominal ON nomID = niNomID 
						WHERE niTranID = #loc.tranID#
					</cfquery>
					<cfloop query="loc.QTransItems">
						<cfset ArrayAppend(loc.tran.items,{
							nomCode = nomCode,
							nomTitle = nomTitle,
							nomGroup = nomGroup, 
							niID = niID,
							niAmount = niAmount
						})>
					</cfloop>
					<cfset ArrayAppend(loc.result.trans, loc.tran)>
				</cfif>
			</cfloop>
			<cfset loc.result.tranIDs = loc.TransIDs>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="InvertValue" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QInvert" datasource="#args.datasource#">
				UPDATE tblNomItems
				SET niAmount = -niAmount
				WHERE niID = #val(args.form.recordID)#
				LIMIT 1;
			</cfquery>
			<cfset loc.result.value = -args.form.value>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="SalesDataCorrections" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.trans = []>
		<cfset loc.fixData = StructKeyExists(args.form,"srchFixData")>

		<cftry>
			<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
				<cfset loc.srchDateFrom = FormatDate("2013-01-01",'yyyy-mm-dd')>
			<cfelseif IsDate(args.form.srchDateFrom)>
				<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateFrom = "">
			</cfif>
			<cfif !StructKeyExists(args.form,"srchDateTo") OR len(args.form.srchDateTo) IS 0>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			<cfelseif IsDate(args.form.srchDateTo)>
				<cfset loc.srchDateTo = FormatDate(args.form.srchDateTo,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			</cfif>
			
			<!--- check for cashback items --->
			<cfquery name="loc.QCashbackItems" datasource="#args.datasource#">
				SELECT trnID,trnDate, tblNomItems.*
				FROM tblNomItems
				INNER JOIN tbltrans ON niTranID=trnID
				WHERE trnAccountID=1
				AND trnDate BETWEEN '#loc.srchDateFrom#' AND '#loc.srchDateTo#'
				AND niNomID=1411
				AND niAmount > 0;
			</cfquery>
			<cfset loc.result.QCashbackItems = loc.QCashbackItems>
			<cfif (loc.QCashbackItems.recordcount gt 0) AND loc.fixData>
				<cfquery name="loc.QDeleteCashbackItems" datasource="#args.datasource#">
					DELETE tblNomItems
					FROM tblNomItems
					inner join tbltrans ON niTranID=trnID
					WHERE trnAccountID=1
					AND trnDate BETWEEN '#loc.srchDateFrom#' AND '#loc.srchDateTo#'
					AND niNomID=1411
					AND niAmount > 0;			
				</cfquery>
			</cfif>
			
			<!--- check for error balances --->
			<cfquery name="loc.QTranBalances" datasource="#args.datasource#">
				SELECT trnID,trnRef,trnDate,trnType,trnAmnt1,trnAmnt2, SUM(niAmount) AS Total
				FROM tblNomItems
				INNER JOIN tblTrans ON trnID = niTranID 
				WHERE trnAccountID = 1
				AND trnDate BETWEEN '#loc.srchDateFrom#' AND '#loc.srchDateTo#'
				GROUP BY trnID
				HAVING Total != 0
				ORDER BY trnDate
			</cfquery>
			<cfset loc.result.QTranBalances = loc.QTranBalances>
			<cfloop query="loc.QTranBalances">
				<cfset loc.tranID = trnID>
				<cfset loc.tran = {
					trnID = trnID,
					trnRef = trnRef,
					trnDate = trnDate,
					trnType = trnType,
					trnAmnt1 = trnAmnt1,
					trnAmnt2 = trnAmnt2,
					itemID = 0,
					errorTotal = Total,
					Items = [],
					fixMe = false,
					updated = false
				}>
				<cfquery name="loc.QNomItems" datasource="#args.datasource#">
					SELECT *
					FROM tblNomItems
					WHERE niTranID = #loc.tranID#
					AND niNomID IN (181,491)
				</cfquery>
				<cfif loc.QNomItems.recordcount gt 0>
					<cfset loc.cash = 0>
					<cfset loc.supplier = 0>
					<cfloop query="loc.QNomItems">
						<cfset ArrayAppend(loc.tran.items,{
							niID = niID,
							niNomID = niNomID,
							niAmount = niAmount
						})>
						<cfif niNomID eq 491 AND niAmount neq 0>
							<cfset loc.supplier = niAmount>
						</cfif>
						<cfif niNomID eq 181 AND niAmount neq 0>
							<cfset loc.cash = niAmount>
							<cfset loc.tran.itemID = niID>
						</cfif>
					</cfloop>
					<cfset loc.tran.itemValue = loc.cash - loc.supplier>
					<cfif loc.tran.itemValue neq 0><cfset loc.tran.fixMe = true></cfif>
					<cfset ArrayAppend(loc.result.trans,loc.tran)>
				</cfif>
				<cfif loc.fixData AND loc.tran.fixMe>
					<cfquery name="loc.QUpdateItems" datasource="#args.datasource#">
						UPDATE tblNomItems
						SET niAmount = #loc.tran.itemValue#
						WHERE niID = #loc.tran.itemID#
					</cfquery>
					<cfset loc.tran.updated = true>
				</cfif>
			</cfloop>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ViewCorrections" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfoutput>
				<table class="tableList" border="1" width="700">
					<tr>
						<th>Tran ID</th>
						<th>Type</th>
						<th>Date</th>
						<th>Inv Total</th>
						<th>Balance Error</th>
						<th>Item ID</th>
						<th>New Value</th>
						<th>Updated</th>
					</tr>
					<cfset loc.grandError = 0>
					<cfloop array="#args.trans#" index="loc.item">
						<cfset loc.grandError += loc.item.errorTotal>
						<tr>
							<td align="right"><a href="#application.site.normal#salesMain3.cfm?acc=1&tran=#loc.item.trnID#" target="#loc.item.trnID#">#loc.item.trnID#</a></td>
							<td>#loc.item.trnType#</td>
							<td align="right">#LSDateFormat(loc.item.trnDate,'ddd dd-mmm-yy')#</td>
							<td align="right">#DecimalFormat(loc.item.trnAmnt1)#</td>
							<td align="right">#DecimalFormat(loc.item.errorTotal)#</td>
							<td align="right">#loc.item.itemID#</td>
							<td align="right">#DecimalFormat(loc.item.itemValue)#</td>
							<td align="right">#loc.item.updated#</td>
						</tr>
					</cfloop>
					<tr>
						<th colspan="4">Totals</th>
						<th align="right">#DecimalFormat(loc.grandError)#</th>
						<th colspan="3"></th>
					</tr>
				</table>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadBalanceSheet" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.accounts = {}>
		
		<cftry>
			<cfquery name="loc.QNominals" datasource="#args.datasource#">
				SELECT ngType,ngCode,ngTitle, nomID,nomCode,nomGroup,nomType,nomClass,nomTitle,
					(SELECT count(*) FROM tblNomItems WHERE niNomID = nomID) AS ItemCount,
					SUM(niAmount) AS total
				FROM tblNominal 
				LEFT JOIN tblNomGroups ON ngCode = nomGroup 
				INNER JOIN tblNomItems ON niNomID = nomID
				WHERE ngType = 'bs'
				GROUP BY ngType, ngCode, nomCode
				ORDER BY ngType, ngCode, nomCode;
			</cfquery>
			<cfset loc.result.QNominals = loc.QNominals>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ViewBalanceSheet" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfoutput>
				<table class="tableList" border="1">
					<tr>
						<th>Group Type</th>
						<th>Group Code</th>
						<th>Group Title</th>
						<th>ID</th>
						<th>Nom Code</th>
						<th>Nom Type</th>
						<th>Class</th>
						<th>Nom Title</th>
						<th>Count</th>
						<th>DR</th>
						<th>CR</th>
					</tr>
					<cfloop query="args.QNominals">
						<tr>
							<td align="right">#ngType#</td>
							<td>#ngCode#</td>
							<td>#ngTitle#</td>
							<td>#nomID#</td>
							<td>#nomCode#</td>
							<td>#nomType#</td>
							<td>#nomClass#</td>
							<td>#nomTitle#</td>
							<td align="right">#NumberFormat(ItemCount,',')#</td>
							<cfif total lt 0>
								<td></td>
								<td align="right">#DecimalFormat(total)#</td>
							<cfelse>
								<td align="right">#DecimalFormat(total)#</td>
								<td></td>							
							</cfif>
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

	
	<cffunction name="LoadSuppliersReportOrig" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.parms = args>
		<cfset loc.suppliers = {}>
		<cfset loc.data = {}>
		
		<cftry>
			<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
				<cfset loc.srchDateFrom = FormatDate("2013-01-01",'yyyy-mm-dd')>
			<cfelseif IsDate(args.form.srchDateFrom)>
				<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateFrom = "">
			</cfif>
			<cfif !StructKeyExists(args.form,"srchDateTo") OR len(args.form.srchDateTo) IS 0>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			<cfelseif IsDate(args.form.srchDateTo)>
				<cfset loc.srchDateTo = FormatDate(args.form.srchDateTo,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateTo = LSDateFormat(Now(),"yyyy-mm-dd")>
			</cfif>
			<cfset loc.data = 
				{" BFWD" = {"net" = 0, "VAT" = 0, "bal" = 0},
				 "Total" = {"net" = 0, "VAT" = 0, "bal" = 0}
			}>
			<cfset loc.lastDate = DateFormat(loc.srchDateTo,'yyyy-mm')>
			<cfloop from="1" to="12" index="loc.i">
				<cfset StructInsert(loc.data,loc.lastDate,{
					"net" = 0,
					"VAT" = 0,
					"bal" = 0
				})>
				<cfset loc.lastDate = DateFormat(DateAdd("m",loc.i,loc.srchDateTo),'yyyy-mm')>
			</cfloop>
			<cfset loc.result.header = Duplicate(loc.data)>
			<cfquery name="loc.QAccounts" datasource="#args.datasource#">
				SELECT * 
				FROM tblaccount
				WHERE accType = 'purch' 
				AND accStatus = 'active'
				AND accCode IN ('BOOK','BOOKBUN','ALLWYN','EBUYER','REDBULL','STORM','WHS')
				ORDER BY accName
			</cfquery>
			<cfloop query="loc.QAccounts">
				<cfset loc.accountID = val(accID)>
				<cfset loc.accountName = accName>
				<cfset StructInsert(loc.suppliers,accCode,{
					"ID" = loc.accountID,
					"Code" = accCode,
					"Account" = accName,
					"Values" = Duplicate(loc.data)
				})>
				<cfset loc.supp = StructFind(loc.suppliers,accCode)>
				<cfquery name="loc.QBFwd" datasource="#args.datasource#">
					SELECT SUM(trnAmnt1) AS net, SUM(trnAmnt2) AS VAT, SUM(trnAmnt1 + trnAmnt2) AS gross
					FROM tblTrans
					WHERE trnAccountID = #loc.accountID#
					AND trnDate < '#loc.srchDateFrom#'
					GROUP BY trnAccountID
				</cfquery>
				<cfset loc.bfwd = StructFind(loc.supp.values," BFWD")>
				<cfset loc.bfwd.net = val(loc.QBFwd.net)>
				<cfset loc.bfwd.VAT = val(loc.QBFwd.VAT)>
				<cfset loc.bfwd.bal = val(loc.QBFwd.gross)>
				<cfset loc.total = StructFind(loc.supp.values,"Total")>
				<cfset loc.total.net = loc.bfwd.net>
				<cfset loc.total.VAT = loc.bfwd.VAT>
				<cfset loc.total.bal = loc.bfwd.bal>
				
				<cfset loc.header = StructFind(loc.result.header," BFWD")>
				<cfset loc.header.net = loc.bfwd.net>
				<cfset loc.header.VAT = loc.bfwd.VAT>
				<cfset loc.header.bal = loc.bfwd.bal>
				<cfset loc.header = StructFind(loc.result.header,"Total")>
				<cfset loc.header.net = loc.bfwd.net>
				<cfset loc.header.VAT = loc.bfwd.VAT>
				<cfset loc.header.bal = loc.bfwd.bal>
				<cfquery name="loc.QTrans" datasource="#args.datasource#">
					SELECT trnAccountID,trnType,trnDate,trnAmnt1,trnAmnt2, SUM(trnAmnt1 + trnAmnt2) AS gross
					FROM tblTrans
					WHERE trnAccountID = #loc.accountID#
					AND trnDate BETWEEN '#loc.srchDateFrom#' AND '#loc.srchDateTo#'
				</cfquery>
				<cfif loc.QTrans.recordcount gt 0>
					<!---<cfif accCode eq 'ALLWYN'>
						<cfdump var="#loc.QTrans#" label="QTrans" expand="false">
					</cfif>--->
					<cfloop query="loc.QTrans">
						<cfset loc.thisDate = DateFormat(trnDate,'yyyy-mm')>
						<cfset loc.gross = INT((val(trnAmnt1) + val(trnAmnt2)) * 100) / 100>
						<cfif StructKeyExists(loc.supp.values,loc.thisDate)>
							<cfset loc.values = StructFind(loc.supp.values,loc.thisDate)>
							<cfset loc.values.net += val(trnAmnt1)>
							<cfset loc.values.VAT += val(trnAmnt2)>
							<cfset loc.values.bal += val(loc.gross)>
							<cfset loc.header = StructFind(loc.result.header,loc.thisDate)>
							<cfset loc.header.net += val(trnAmnt1)>
							<cfset loc.header.VAT += val(trnAmnt2)>
							<cfset loc.header.bal += val(loc.gross)>
						<cfelse>
							<cfset loc.bfwd.net += val(trnAmnt1)>
							<cfset loc.bfwd.VAT += val(trnAmnt2)>
							<cfset loc.bfwd.bal += val(loc.gross)>
							<cfset loc.header = StructFind(loc.result.header," BFWD")>
							<cfset loc.header.net += val(trnAmnt1)>
							<cfset loc.header.VAT += val(trnAmnt2)>
							<cfset loc.header.bal += val(loc.gross)>
						</cfif>
						
						<cfset loc.total.net += val(trnAmnt1)>
						<cfset loc.total.VAT += val(trnAmnt2)>
						<cfset loc.total.bal += val(loc.gross)>
					</cfloop>
				</cfif>
			</cfloop>
			<cfset loc.result.suppliers = loc.suppliers>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<cffunction name="LoadSuppliersReport" access="public" returntype="struct">
    <cfargument name="args" type="struct" required="yes">

    <cfset var loc = {} />
    <cfset var i = 0 />
    <cfset var monthDate = "" />

    <cfset loc.result = {} />
    <cfset loc.result.parms = arguments.args />
    <cfset loc.suppliers = {} />
    <cfset loc.data = {} />

    <cftry>

        <!--- Validate date inputs --->
        <cfif StructKeyExists(args.form, "srchDateFrom") 
                AND len(trim(args.form.srchDateFrom)) 
                AND IsDate(args.form.srchDateFrom)>
            <cfset loc.srchDateFromDate = ParseDateTime(args.form.srchDateFrom) />
        <cfelse>
            <cfset loc.srchDateFromDate = CreateDate(2013, 1, 1) />
        </cfif>

        <cfif StructKeyExists(args.form, "srchDateTo") 
                AND len(trim(args.form.srchDateTo)) 
                AND IsDate(args.form.srchDateTo)>
            <cfset loc.srchDateToDate = ParseDateTime(args.form.srchDateTo) />
        <cfelse>
            <cfset loc.srchDateToDate = Now() />
        </cfif>

        <!--- Swap if needed --->
        <cfif loc.srchDateFromDate GT loc.srchDateToDate>
            <cfset temp = loc.srchDateFromDate />
            <cfset loc.srchDateFromDate = loc.srchDateToDate />
            <cfset loc.srchDateToDate = temp />
        </cfif>

        <!--- Template struct for BFWD, Total, 12 months --->
        <cfset loc.data = {
            " BFWD" = {"net"=0, "VAT"=0, "bal"=0},
            "Total" = {"net"=0, "VAT"=0, "bal"=0}
        } />

        <!--- Add 12 months (yyyy-mm) ending at srchDateToDate --->
        <cfloop from="0" to="11" index="i">
            <cfset monthDate = DateAdd("m", -i, loc.srchDateToDate) />
            <cfset loc.data[ DateFormat(monthDate, "yyyy-mm") ] = {"net"=0,"VAT"=0,"bal"=0} />
        </cfloop>

        <cfset loc.result.header = Duplicate(loc.data) />

        <!--- Get supplier accounts --->
        <cfquery name="loc.QAccounts" datasource="#args.datasource#">
            SELECT accID, accName, accCode
            FROM tblaccount
            WHERE accType='purch'
              AND accStatus='active'
              <!---AND accCode IN ('BOOK','BOOKBUN','ALLWYN','EBUYER','REDBULL','STORM','WHS')--->
            ORDER BY accName
        </cfquery>

        <!--- Loop suppliers --->
        <cfloop query="loc.QAccounts">
            <cfset var accountID = val(accID) />
            <cfset var accountCode = accCode />
            <cfset var accountName = accName />

            <cfset loc.suppliers[accountCode] = {
                "ID" = accountID,
                "Code" = accountCode,
                "Account" = accountName,
                "Values" = Duplicate(loc.data)
            } />

            <cfset var supp = loc.suppliers[accountCode] />
            <cfset var suppVals = supp.Values />
            <cfset var bfwdKey = " BFWD" />
            <cfset var totalVals = suppVals["Total"] />

            <!--- Brought Forward --->
            <cfquery name="loc.QBFwd" datasource="#args.datasource#">
                SELECT SUM(trnAmnt1) AS net,
                       SUM(trnAmnt2) AS VAT,
                       SUM(trnAmnt1 + trnAmnt2) AS gross
                FROM tblTrans
                WHERE trnAccountID = <cfqueryparam value="#accountID#" cfsqltype="cf_sql_integer">
                  AND trnDate < <cfqueryparam value="#DateFormat(loc.srchDateFromDate,'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
                GROUP BY trnAccountID
            </cfquery>

            <cfif loc.QBFwd.recordcount>
                <cfset suppVals[bfwdKey].net  = Round(Val(loc.QBFwd.net) * 100) / 100 />
                <cfset suppVals[bfwdKey].VAT  = Round(Val(loc.QBFwd.VAT) * 100) / 100 />
                <cfset suppVals[bfwdKey].bal  = Round(Val(loc.QBFwd.gross) * 100) / 100 />
            </cfif>

            <!--- Supplier Total starts as BFWD --->
            <cfset totalVals.net = suppVals[bfwdKey].net />
            <cfset totalVals.VAT = suppVals[bfwdKey].VAT />
            <cfset totalVals.bal = suppVals[bfwdKey].bal />

            <!--- Add BFWD to header --->
            <cfset loc.result.header[bfwdKey].net = Round((loc.result.header[bfwdKey].net + suppVals[bfwdKey].net)*100)/100 />
            <cfset loc.result.header[bfwdKey].VAT = Round((loc.result.header[bfwdKey].VAT + suppVals[bfwdKey].VAT)*100)/100 />
            <cfset loc.result.header[bfwdKey].bal = Round((loc.result.header[bfwdKey].bal + suppVals[bfwdKey].bal)*100)/100 />

            <!--- Transactions within range --->
            <cfquery name="loc.QTrans" datasource="#args.datasource#">
                SELECT trnDate, trnAmnt1, trnAmnt2,
                       (trnAmnt1 + trnAmnt2) AS gross
                FROM tblTrans
                WHERE trnAccountID = <cfqueryparam value="#accountID#" cfsqltype="cf_sql_integer">
                  AND trnDate BETWEEN
                        <cfqueryparam value="#DateFormat(loc.srchDateFromDate,'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
                  AND <cfqueryparam value="#DateFormat(loc.srchDateToDate,'yyyy-mm-dd')#" cfsqltype="cf_sql_date">
                ORDER BY trnDate
            </cfquery>

            <!--- Process transactions --->
            <cfloop query="loc.QTrans">
                <cfset var txNet   = Round(val(trnAmnt1) * 100) / 100 />
                <cfset var txVAT   = Round(val(trnAmnt2) * 100) / 100 />
                <cfset var txGross = Round(val(gross) * 100) / 100 />

                <cfset var txMonthKey = DateFormat(trnDate, "yyyy-mm") />

                <cfif StructKeyExists(suppVals, txMonthKey)>
                    <cfset suppVals[txMonthKey].net   = Round((suppVals[txMonthKey].net   + txNet) * 100)/100 />
                    <cfset suppVals[txMonthKey].VAT   = Round((suppVals[txMonthKey].VAT   + txVAT) * 100)/100 />
                    <cfset suppVals[txMonthKey].bal   = Round((suppVals[txMonthKey].bal   + txGross) * 100)/100 />

                    <cfset loc.result.header[txMonthKey].net = Round((loc.result.header[txMonthKey].net + txNet) * 100)/100 />
                    <cfset loc.result.header[txMonthKey].VAT = Round((loc.result.header[txMonthKey].VAT + txVAT) * 100)/100 />
                    <cfset loc.result.header[txMonthKey].bal = Round((loc.result.header[txMonthKey].bal + txGross) * 100)/100 />
                <cfelse>
                    <cfset suppVals[bfwdKey].net = Round((suppVals[bfwdKey].net + txNet) * 100)/100 />
                    <cfset suppVals[bfwdKey].VAT = Round((suppVals[bfwdKey].VAT + txVAT) * 100)/100 />
                    <cfset suppVals[bfwdKey].bal = Round((suppVals[bfwdKey].bal + txGross) * 100)/100 />

                    <cfset loc.result.header[bfwdKey].net = Round((loc.result.header[bfwdKey].net + txNet) * 100)/100 />
                    <cfset loc.result.header[bfwdKey].VAT = Round((loc.result.header[bfwdKey].VAT + txVAT) * 100)/100 />
                    <cfset loc.result.header[bfwdKey].bal = Round((loc.result.header[bfwdKey].bal + txGross) * 100)/100 />
                </cfif>

                <!-- Always add to supplier Total -->
                <cfset totalVals.net = Round((totalVals.net + txNet) * 100)/100 />
                <cfset totalVals.VAT = Round((totalVals.VAT + txVAT) * 100)/100 />
                <cfset totalVals.bal = Round((totalVals.bal + txGross) * 100)/100 />
            </cfloop>

            <!-- Add supplier totals to header Total -->
            <cfset loc.result.header["Total"].net = Round((loc.result.header["Total"].net + totalVals.net) * 100)/100 />
            <cfset loc.result.header["Total"].VAT = Round((loc.result.header["Total"].VAT + totalVals.VAT) * 100)/100 />
            <cfset loc.result.header["Total"].bal = Round((loc.result.header["Total"].bal + totalVals.bal) * 100)/100 />
        </cfloop>

        <cfset loc.result.suppliers = loc.suppliers />

    <cfcatch type="any">
        <cfdump var="#cfcatch#" expand="yes" format="html"
            output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
        <cfset loc.result.error = cfcatch />
    </cfcatch>
    </cftry>

    <cfreturn loc.result />
</cffunction>

	<cffunction name="ViewSuppliersReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.args = args>
		
		<cftry>
			<!---<cfdump var="#args#" label="ViewSuppliersReport" expand="false">--->
			<cfoutput>
				<cfset loc.keys = ListSort(StructKeyList(args.suppliers,','),"text","asc",",")>
				<table class="tableList" border="1">
					<!--- header --->
					<tr>
						<th>Supplier</th>
						<th>Code</th>
						<cfset loc.titles = ListSort(StructKeyList(args.header,','),"text","asc",",")>
						<cfloop list="#loc.titles#" index="loc.head" delimiters=",">
							<th>#loc.head#</th>
						</cfloop>
					</tr>
					<!--- data --->
					<cfset loc.linecount = 0>
					<cfloop list="#loc.keys#" index="loc.item">
						<cfset loc.supp = StructFind(args.suppliers,loc.item)>
						<cfset loc.zero = StructFind(loc.supp.values,"Total")>
						<cfif loc.zero.bal neq 0>
							<cfset loc.linecount++>
							<tr>
								<td>#loc.supp.Account#</td>
								<td><a href="tranMain2.cfm?acc=#loc.supp.ID#" target="#loc.supp.Code#">#loc.supp.Code#</td>
								<cfloop list="#loc.titles#" index="loc.key" delimiters=",">
									<cfset loc.values = StructFind(loc.supp.values,loc.key)>
									<td align="right"><cfif loc.values.bal neq 0>#formatNum(loc.values.bal)#</cfif></td>
								</cfloop>
							</tr>
						</cfif>
					</cfloop>
					<!--- totals --->
					<tr>
						<th>Totals</th>
						<th>#loc.linecount# records</th>
						<cfset loc.titles = ListSort(StructKeyList(args.header,','),"text","asc",",")>
						<cfloop list="#loc.titles#" index="loc.head" delimiters=",">
							<cfset loc.total = StructFind(args.header,loc.head)>
							<th>#formatNum(loc.total.bal)#</th>
						</cfloop>
					</tr>
				</table>
				<p>&nbsp;</p>
			</cfoutput>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>
