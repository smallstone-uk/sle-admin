
<!--- accounting reports functions --->

<cfcomponent displayname="NewsFunctions" extends="code/core" hint="Report Functions 2025">

	<cffunction name="initInterface" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.menu = []>
		
		<cftry>
			<cfset loc.option = 1>
			<cfset ArrayAppend(loc.result.menu, {
				Value = #loc.option#,
				Title = "Stock Movement",
				ID = "ID#loc.option#"
			})>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="ShopSales" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.Stock = {}>
		
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
			<cfif IsDate(loc.srchDateFrom) AND IsDate(loc.srchDateTo)>
				<cfset loc.result.diff = DateDiff("d",loc.srchDateFrom,loc.srchDateTo)>
			</cfif>

			<cfquery name="loc.QPubStockReceived" datasource="#args.datasource#">
				SELECT pubID,pubTitle,pubType, psIssue,psDate,psQty,psType,psRetail,psTradePrice, DATE_FORMAT( psDate, '%Y-%m-%d' ) AS YYMMDD
				FROM tblPubStock
				INNER JOIN tblPublication ON psPubID = pubID
				WHERE psType = 'received'
				AND psRetail > 0
				<!---AND pubID IN (28861,31401,17021)--->
				<cfif len(args.form.srchGroup)> AND pubGroup LIKE '#args.form.srchGroup#'</cfif>
				AND psDate BETWEEN '#LSDateFormat(loc.srchDateFrom,"yyyy-mm-dd")#' AND '#LSDateFormat(loc.srchDateTo,"yyyy-mm-dd")#'
				ORDER BY pubID,psType
			</cfquery>
			<cfset loc.result.QPubStockReceived = loc.QPubStockReceived>
			<cfloop query="loc.QPubStockReceived">
				<cfset loc.pubID = val(pubID)>
				<cfset loc.psIssue = psIssue>
				<cfset loc.psDate = psDate>
				<cfset loc.compKey = "#loc.pubID#-#loc.psIssue#">
				<cfif !StructKeyExists(loc.result.Stock,loc.compKey)>
					<cfset StructInsert(loc.result.Stock,loc.compKey,{
						pubTitle = pubTitle,
						psIssue = psIssue,
						psDate = psDate,
						pubType = pubType,
						yymmdd = YYMMDD,
						Retail = psRetail,
						Trade = psTradePrice,
						"received" = 0,
						"claim" = 0,
						"returned" = 0,
						"credited" = 0,
						"sales" = 0,
						"missing" = 0,
						"tradeValue" = 0,
						"salesValue" = 0,
						"style" = ""
					})>
				</cfif>
				<cfset loc.data = StructFind(loc.result.Stock,loc.compKey)>
				
				<cfquery name="loc.QPubStockOther" datasource="#args.datasource#">	<!--- get other stock items related to the received stock --->
					SELECT pubID,pubTitle, psIssue,psDate,psQty,psType,psRetail,psTradePrice, DATE_FORMAT( psDate, '%Y-%m-%d' ) AS YYMMDD
					FROM tblPubStock
					INNER JOIN tblPublication ON psPubID = pubID
					WHERE pubID = #loc.pubID#
					AND psIssue = '#loc.psIssue#'
					AND psDate >= '#LSDateFormat(loc.srchDateFrom,"yyyy-mm-dd")#'
					ORDER BY pubID,psType
				</cfquery>
				<cfif loc.QPubStockOther.recordcount gt 0>
					<cfloop query="loc.QPubStockOther">
						<cfif !StructKeyExists(loc.data,psType)>
							<cfset StructInsert(loc.data,psType, psQty)>
						<cfelse>
							<cfset loc.dataQty = StructFind(loc.data,psType)>
							<cfset StructUpdate(loc.data,psType,loc.dataQty + psQty)>
						</cfif>
					</cfloop>
				</cfif>
				
				<cfquery name="loc.QDelivered" datasource="#args.datasource#">
					SELECT pubID,pubTitle, diType,diDate,SUM(diPrice) AS netTotal, SUM(diPriceTrade) AS tradeTotal, SUM(IF(diType = 'credit',-diQty,diQty)) AS Qty
					FROM tbldelitems 
					INNER JOIN tblPublication ON diPubID = pubID
					WHERE diPubID = #loc.pubID#
					AND diIssue = '#loc.psIssue#'
					AND diDate = '#LSDateFormat(loc.psDate,"yyyy-mm-dd")#'
					ORDER BY pubID
				</cfquery>
				<cfif loc.QDelivered.recordcount gt 0>
					<cfset loc.data = StructFind(loc.result.Stock,loc.compKey)>
					<cfif !StructKeyExists(loc.data,"delivered")>
						<cfset StructInsert(loc.data,"delivered", val(loc.QDelivered.Qty))>
					</cfif>
					<cfif loc.data.credited gt loc.data.returned>
						<cfset loc.data.sales = loc.data.received - loc.data.delivered - loc.data.credited>
					<cfelse>
						<cfset loc.data.sales = loc.data.received - loc.data.delivered - loc.data.returned - loc.data.claim>
					</cfif>
					<cfif loc.data.sales gt 0>
						<cfset loc.data.salesValue = loc.data.sales * loc.data.Retail>
						<cfset loc.data.tradeValue = loc.data.sales * loc.data.trade>
					</cfif>
					<cfset loc.data.missing = loc.data.returned + loc.data.claim - loc.data.credited>
					<cfif loc.data.returned neq loc.data.credited>
						<cfset loc.data.style = "amber">
					<cfelseif loc.data.missing neq 0>
						<cfset loc.data.style = "error">
					</cfif> 
				</cfif>
			</cfloop>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="ViewShopSalesReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.totals = {
			"received" = 0,
			"delivered" = 0,
			"claim" = 0,
			"returned" = 0,
			"credited" = 0,
			"sales" = 0,
			"missing" = 0,
			"salesValue" = 0,
			"tradeValue" = 0
		}>
		<!---<cfdump var="#args#" label="ViewShopSalesReport" expand="true">--->
		
		<cftry>
			<cfoutput>
				<table class="tableList" border="1">
					<tr>
						<th>Title</th>
						<th>Issue</th>
						<th>Type</th>
						<th>Retail</th>
						<th>Trade</th>
						<th>Date</th>
						<th>Received</th>
						<th>Delivered</th>
						<th>Returned</th>
						<th>Claimed</th>
						<th>Credited</th>
						<th>Missing</th>
						<th>Sales</th>
						<th>Sales Value</th>
						<th>Trade Value</th>
					</tr>
					<cfset loc.keys = ListSort(StructKeyList(args.stock,","),"text","asc")>
					<cfloop list="#loc.keys#" index="loc.key">
						<cfset loc.data = StructFind(args.stock,loc.key)>
						<cfset loc.totals.received += loc.data.received>
						<cfset loc.totals.delivered += loc.data.delivered>
						<cfset loc.totals.returned += loc.data.returned>
						<cfset loc.totals.credited += loc.data.credited>
						<cfset loc.totals.claim += loc.data.claim>
						<cfset loc.totals.missing += loc.data.missing>
						<cfset loc.totals.sales += loc.data.sales>
						<cfset loc.totals.salesValue += loc.data.salesValue>
						<cfset loc.totals.tradeValue += loc.data.tradeValue>
						<tr class="#loc.data.style#">
							<td>#loc.data.pubTitle#</td>
							<td>#loc.data.psIssue#</td>
							<td>#loc.data.pubType#</td>
							<td align="right">#loc.data.Retail#</td>
							<td align="right">#loc.data.Trade#</td>
							<td align="right">#loc.data.yymmdd#</td>
							<td align="center">#loc.data.received#</td>
							<td align="center">#loc.data.delivered#</td>
							<td align="center">#loc.data.returned#</td>
							<td align="center">#loc.data.claim#</td>
							<td align="center">#loc.data.credited#</td>
							<td align="center">#loc.data.missing#</td>
							<td align="center">#loc.data.sales#</td>
							<td align="right">#FormatNum(loc.data.salesValue)#</td>
							<td align="right">#FormatNum(loc.data.tradeValue)#</td>
						</tr>
					</cfloop>
					<tr class="#loc.data.style#">
						<th colspan="6" align="right">Totals</th>
						<th align="center">#loc.totals.received#</th>
						<th align="center">#loc.totals.delivered#</th>
						<th align="center">#loc.totals.returned#</th>
						<th align="center">#loc.totals.claim#</th>
						<th align="center">#loc.totals.credited#</th>
						<th align="center">#loc.totals.missing#</th>
						<th align="center">#loc.totals.sales#</th>
						<th align="right">#FormatNum(loc.totals.salesValue)#</th>
						<th align="right">#FormatNum(loc.totals.tradeValue)#</th>
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

</cfcomponent>
