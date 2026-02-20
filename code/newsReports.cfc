
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
				Title = "Book in Stock",
				ID = "ID#loc.option#"
			})>
			<cfset loc.option++>
			<cfset ArrayAppend(loc.result.menu, {
				Value = #loc.option#,
				Title = "Stock Movement",
				ID = "ID#loc.option#"
			})>
			<cfset loc.option++>
			<cfset ArrayAppend(loc.result.menu, {
				Value = #loc.option#,
				Title = "Reconcilliation Report",
				ID = "ID#loc.option#"
			})>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ShopStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.pubs = {}>
		<cfset loc.result.viewOrder = []>
		
		<cftry>
			<cfif !StructKeyExists(args.form,"srchDateFrom") OR len(args.form.srchDateFrom) IS 0>
				<cfset loc.srchDateFrom = FormatDate(Now(),'yyyy-mm-dd')>
			<cfelseif IsDate(args.form.srchDateFrom)>
				<cfset loc.srchDateFrom = FormatDate(args.form.srchDateFrom,'yyyy-mm-dd')>
			<cfelse>
				<cfset loc.srchDateFrom = FormatDate(Now(),'yyyy-mm-dd')>
			</cfif>
			<cfset loc.result.srchDateFrom = loc.srchDateFrom>
			<cfset loc.dayNo = DayOfWeek(loc.srchDateFrom)>
			<cfif loc.dayNo eq 1>
				<cfset loc.dayName = '"Sunday"'>
			<cfelseif loc.dayNo eq 7>
				<cfset loc.dayName = '"Saturday","Weekend"'>
			<cfelse>
				<cfset loc.dayName = '"Morning"'>
			</cfif>
			<cfset loc.dayNo = ((loc.dayNo + (7 - 2)) MOD 7) + 1>	<!--- pubArrival is based on Monday = day 1 --->
			<cfset loc.result.arrival = loc.dayNo>
			<cfset loc.result.query = 1>
			<cfquery name="loc.QPubs" datasource="#args.datasource#" result="loc.result.rpubs">
				SELECT pubID,pubRef,pubTitle,pubType,pubGroup,pubLinkPub,pubSup,pubArrival,pubActive, psIssue,psRetail,psDiscount,psDiscountType,psQty,psVATRate,psVAT
				FROM tblPublication
				INNER JOIN tblPubStock ON psPubID = pubID
				WHERE pubActive = 1
				AND psDate = '#loc.srchDateFrom#'
				AND psType = 'received'
				AND (
					pubType IN (#loc.dayName#)
					OR (pubType IN ('Weekly','Monthly') AND pubArrival = #loc.dayNo#)
				)
				ORDER BY pubGroup ASC, pubType ASC, pubTitle ASC, pubRef
			</cfquery>
			<cfif loc.QPubs.recordCount IS 0>
				<cfset loc.srchDateFrom = FormatDate(DateAdd("d",-7,loc.srchDateFrom),'yyyy-mm-dd')>		<!--- look at previous week --->
				<cfset loc.result.query = 2>
				<cfquery name="loc.QPubs" datasource="#args.datasource#" result="loc.result.rpubs">
					SELECT pubID,pubRef,pubTitle,pubType,pubGroup,pubLinkPub,pubSup,pubArrival, psIssue,psRetail,psDiscount,psDiscountType,0 AS psQty,psVATRate,psVAT
					FROM tblPublication
					INNER JOIN tblPubStock ON psPubID = pubID
					WHERE pubActive = 1
					AND psDate = '#loc.srchDateFrom#'
					AND psType = 'received'
					AND (
						pubType IN (#loc.dayName#)
						OR (pubType IN ('Weekly','Monthly') AND pubArrival = #loc.dayNo#)
					)
					ORDER BY pubGroup ASC, pubType ASC, pubTitle ASC, pubRef
				</cfquery>
				<cfif loc.QPubs.recordCount eq 0>
					<cfset loc.result.query = 3>
					<cfquery name="loc.QPubs" datasource="#args.datasource#" result="loc.result.rpubs">
						SELECT pubID,pubRef,pubTitle,pubType,pubGroup,pubLinkPub,pubSup,pubArrival,pubActive, 
						'' AS psIssue,
						pubPrice AS psRetail,
						pubDiscount AS psDiscount,
						pubDiscType AS psDiscountType,
						0 AS psQty,
						pubVAT AS psVATRate,
						pubVATCode AS psVAT
						FROM tblPublication
						WHERE pubActive = 1
						AND (
							pubType IN (#loc.dayName#)
							OR (pubType IN ('Weekly','Monthly') AND pubArrival = #loc.dayNo#)
						)
						ORDER BY pubGroup ASC, pubType ASC, pubTitle ASC, pubRef
					</cfquery>
				</cfif>
			</cfif>
			<cfloop query="loc.QPubs">
				<cfset ArrayAppend(loc.result.viewOrder,pubID)>
				<cfif pubLinkPub neq 0>
					<cfset ArrayAppend(loc.result.viewOrder,pubLinkPub)>
				</cfif>
				<cfif !StructKeyExists(loc.result.pubs,pubID)>
					<cfset loc.issue = ''>
					<cfswitch expression="#loc.result.query#">
						<cfcase value="1">
							<cfset loc.issue = psIssue>
						</cfcase>
						<cfcase value="2">
							<cfif pubGroup eq "NEWS">
								<cfset loc.issue = LSDateFormat(loc.result.srchDateFrom,"ddmmm")>
							<cfelseif IsNumeric(psIssue)>
								<cfset loc.issue = val(psIssue) + 1>
							</cfif>
						</cfcase>
						<cfcase value="3">
							<cfif pubGroup eq "NEWS">
								<cfset loc.issue = LSDateFormat(loc.result.srchDateFrom,"ddmmm")>
							</cfif>
						</cfcase>
						<cfdefaultcase></cfdefaultcase>
					</cfswitch>
					<cfset StructInsert(loc.result.pubs,pubID,{
						qType = loc.result.query,
						pubRef = pubRef,
						pubTitle = pubTitle,
						pubType = pubType,
						pubGroup = pubGroup,
						pubLinkPub = pubLinkPub,
						pubSup = pubSup,
						pubArrival = pubArrival,
						psIssue = loc.issue,
						psRetail = psRetail,
						psDiscount = psDiscount,
						psDiscountType = psDiscountType,
						psQty = psQty,
						psVATRate = psVATRate,
						psVAT = psVAT
					})>
				</cfif>
			</cfloop>
			<cfset loc.result.QPubs = loc.QPubs>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="ViewShopStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfdump var="#args#" label="ViewShopStock" expand="false">
			<!---,,,,,,,PUBACTIVE,,,PUBID,PUBLINKPUB,PUBREF,PUBSUP,,--->
			<cfoutput>
				<table class="tableList" border="1">
					<tr>
						<th>ID</th>
						<th>Title</th>
						<th>Type</th>
						<th>Group</th>
						<th>Arrival</th>
						<th>VAT</th>
						<th>Rate</th>
						<th>Retail</th>
						<th>Discount</th>
						<th>Disc. Type</th>
						<th width="60">Issue</th>
						<th width="60">Qty</th>
					</tr>
					<!---<cfloop query="args.QPubs">--->
					<form>
					<cfloop array="#args.viewOrder#" index="loc.item">
						<cfif StructKeyExists(args.pubs,loc.item)>
							<cfset loc.data = StructFind(args.pubs,loc.item)>
							<tr>
								<td>#loc.item#</td>
								<td>#loc.data.PUBTITLE#</td>
								<td>#loc.data.PUBTYPE#</td>
								<td>#loc.data.PUBGROUP#</td>
								<td>#loc.data.PUBARRIVAL#</td>
								<td>#loc.data.PSVAT#</td>
								<td>#loc.data.PSVATRATE#%</td>
								<td><input name="PSRETAIL" id="PSRETAIL" class="newsfld" value="#loc.data.PSRETAIL#" /></td>
								<td><input name="PSDISCOUNT" id="PSDISCOUNT" class="newsfld" value="#loc.data.PSDISCOUNT#" /></td>
								<td>#loc.data.PSDISCOUNTTYPE#</td>
								<td><input name="PSISSUE" id="PSISSUE" class="newsfld" value="#loc.data.PSISSUE#" /></td>
								<td><input name="PSQTY" id="PSQTY" class="newsfld" value="#loc.data.PSQTY#" /></td>
							</tr>
						</cfif>
					</cfloop>
					</form>
				</table>			
			</cfoutput>
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
		<cfset loc.result.queries = []>
		<cfset loc.result.diff = 1>
		<cfset loc.result.numWeeks = 1>
		
		<cfset loc.spans = {
			"Fortnightly" = 14,
			"Monthly" = 31,
			"Weekly" = 7,
			"Four-Weekly" = 28,
			"Morning" = 1,
			"Sunday" = 1,
			"Saturday" = 2,
			"Weekend" = 2,
			"One Shots" = 31
		}>
		
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
				<cfset loc.result.diff = DateDiff("d",loc.srchDateFrom,loc.srchDateTo) + 1>
				<cfset loc.result.numWeeks = int((loc.result.diff / 7) * 100) /100>
			</cfif>
			<cfset loc.result.srchDateFrom = loc.srchDateFrom>
			<cfset loc.result.srchDateTo = loc.srchDateTo>
			
			<!--- calculate no. of saturdays --->
			<cfset loc.saturdayCount = 0>
			<cfset loc.currentDate = loc.srchDateFrom>
			<cfloop condition="loc.currentDate LTE loc.srchDateTo">
				<cfif dayOfWeek(loc.currentDate) EQ 7>
					<cfset loc.saturdayCount++>
				</cfif>
				<cfset loc.currentDate = dateAdd("d", 1, loc.currentDate)>
			</cfloop>			
			<cfif loc.saturdayCount gt 1>
				<cfset loc.result.numWeeks = loc.saturdayCount>
			</cfif>
			<cfset loc.result.bblContribution = -val(args.form.bblContribution) * loc.result.numWeeks>
			
			<cfquery name="loc.QPubStockReceived" datasource="#args.datasource#">
				SELECT pubID,pubTitle,pubType,pubGroup, psIssue,psDate,psQty,psType,psRetail,psTradePrice, DATE_FORMAT( psDate, '%Y-%m-%d' ) AS YYMMDD
				FROM tblPubStock
				INNER JOIN tblPublication ON psPubID = pubID
				WHERE psType = 'received'
				AND psRetail > 0
				AND pubCategory != 'TRADE'
				<!---AND pubID IN (26581)--->
				<cfif len(args.form.srchGroup)> AND pubGroup LIKE '#args.form.srchGroup#'</cfif>
				AND psDate BETWEEN '#LSDateFormat(loc.srchDateFrom,"yyyy-mm-dd")#' AND '#LSDateFormat(loc.srchDateTo,"yyyy-mm-dd")#'
				ORDER BY pubID,psType
			</cfquery>
			<cfset loc.result.QPubStockReceived = loc.QPubStockReceived>
			<cfloop query="loc.QPubStockReceived">
				<cfset loc.pubID = val(pubID)>
				<cfset loc.psIssue = psIssue>
				<cfset loc.psDate = psDate>
				<cfif StructKeyExists(loc.spans,pubType)>
					<cfset loc.span = StructFind(loc.spans,pubType) + 3>
					<cfset loc.endDate = LSDateFormat(DateAdd("d",loc.span,psDate),"yyyy-mm-dd")>
				<cfelse>
					<cfset loc.span = 1>
					<cfset loc.endDate = LSDateFormat(DateAdd("d",1,psDate),"yyyy-mm-dd")>
				</cfif>
				<cfset loc.compKey = "#loc.pubID#-#loc.psIssue#">
				<cfif !StructKeyExists(loc.result.Stock,loc.compKey)>
					<cfset StructInsert(loc.result.Stock,loc.compKey,{
						pubID = pubID,
						pubTitle = pubTitle,
						psIssue = psIssue,
						psDate = psDate,
						pubType = pubType,
						pubGroup = pubGroup,
						span = loc.span,
						endDate = loc.endDate,
						yymmdd = YYMMDD,
						Retail = psRetail,
						Trade = psTradePrice,
						"received" = psQty,
						"delivered" = 0,
						"claim" = 0,
						"returned" = 0,
						"credited" = 0,
						"sales" = 0,
						"missing" = 0,
						"error" = 0,
						"tradeValue" = 0,
						"salesValue" = 0,
						"style" = "",
						"msg" = ""
					})>
					<cfset loc.data = StructFind(loc.result.Stock,loc.compKey)>
				<cfelse>
					<cfset loc.data = StructFind(loc.result.Stock,loc.compKey)>
					<cfset loc.data.received += psQty>
				</cfif>
				
				<cfquery name="loc.QPubStockOther" datasource="#args.datasource#">	<!--- get other stock items related to the received stock --->
					SELECT pubID,pubTitle, psIssue,psDate,psQty,psType,psRetail,psTradePrice, DATE_FORMAT( psDate, '%Y-%m-%d' ) AS YYMMDD
					FROM tblPubStock
					INNER JOIN tblPublication ON psPubID = pubID
					WHERE pubID = #loc.pubID#
					AND psType != 'received'
					AND psIssue = '#loc.psIssue#'
					AND psDate >= '#LSDateFormat(loc.srchDateFrom,"yyyy-mm-dd")#'
					ORDER BY pubID,psType
				</cfquery>
				<cfif loc.QPubStockOther.recordcount gt 0>
					<!---<cfset ArrayAppend(loc.result.queries,{"query" = "QPubStockOther", "data" = loc.QPubStockOther})>--->
					<cfloop query="loc.QPubStockOther">
						<cfset loc.dataQty = StructFind(loc.data,psType)>
						<cfset StructUpdate(loc.data,psType,loc.dataQty + psQty)>
					</cfloop>
				</cfif>
				
				<cfquery name="loc.QDelivered" datasource="#args.datasource#">
					SELECT pubID,pubTitle,pubType, diIssue,diType,diDate,SUM(diPrice) AS netTotal, SUM(diPriceTrade) AS tradeTotal, SUM(IF(diType = 'credit',-diQty,diQty)) AS Qty
					FROM tbldelitems 
					INNER JOIN tblPublication ON diPubID = pubID
					WHERE diPubID = #loc.pubID#
					AND diIssue = '#loc.psIssue#'
					AND diDate BETWEEN '#LSDateFormat(loc.psDate,"yyyy-mm-dd")#' AND '#LSDateFormat(loc.endDate,"yyyy-mm-dd")#'
					ORDER BY pubID
				</cfquery>
				<cfif loc.QDelivered.recordcount gt 0>
					<!---<cfset ArrayAppend(loc.result.queries,{"result" = loc.QDelResult, "data" = loc.QDelivered})>--->
					<cfset loc.data = StructFind(loc.result.Stock,loc.compKey)>
					<cfset loc.data.delivered += val(loc.QDelivered.Qty)>
				</cfif>
				
				<cfset loc.data.missing = 0>
				<cfif loc.data.credited gt (loc.data.returned + loc.data.claim)>
					<cfset loc.data.sales = loc.data.received - loc.data.delivered - loc.data.credited>
					<cfset loc.data.msg = "#loc.data.msg#<br>credits exceed returns">
				<cfelse>
					<cfset loc.data.sales = loc.data.received - loc.data.delivered - loc.data.returned - loc.data.claim>
				</cfif>
				<cfif (Now() lt loc.endDate)>	<!--- not due to be returned yet --->
					<cfset loc.data.sales = 0>
					<cfset loc.data.msg = "#loc.data.msg#<br>returns not due yet">
				<cfelse>
					<cfset loc.data.missing = loc.data.returned + loc.data.claim - loc.data.credited>
				</cfif>
				<cfif loc.data.sales gte 0>
					<cfset loc.data.salesValue = loc.data.sales * loc.data.Retail>
					<cfset loc.data.tradeValue = loc.data.sales * loc.data.trade>
				<cfelse>
					<cfset loc.data.error = loc.data.sales>
					<cfset loc.data.sales = 0>
				</cfif>
				<cfif loc.data.returned gt loc.data.received>
					<cfset loc.data.style = "amber">
					<cfset loc.data.msg = "#loc.data.msg#<br>returns exceed received">
				<cfelseif loc.data.missing neq 0>
					<cfset loc.data.style = "error">
					<cfset loc.data.msg = "#loc.data.msg#<br>credits mismatch">
					<cfset loc.data.sales = 0>
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
			"error" = 0,
			"salesValue" = 0,
			"tradeValue" = 0
		}>
		<!---<cfdump var="#args#" label="ViewShopSalesReport" expand="true">--->
		<cftry>
			<cfoutput>
				<div id="nwrapper">
					<table class="tableList" border="1">
						<thead>
						<tr>
							<th>ID</th>
							<th>Title</th>
							<th>Issue</th>
							<th width="110">Type</th>
							<th>Retail</th>
							<th>Trade</th>
							<th width="80">Date</th>
							<th>Received</th>
							<th>Delivered</th>
							<th>Returned</th>
							<th>Claimed</th>
							<th>Credited</th>
							<th>Missing</th>
							<th>Error</th>
							<th>Sales</th>
							<th>Sales Value</th>
							<th>Trade Value</th>
							<th>Message</th>
						</tr>
						</thead>
						<cfset loc.keys = ListSort(StructKeyList(args.stock,","),"text","asc")>
						<cfloop list="#loc.keys#" index="loc.key">
							<cfset loc.data = StructFind(args.stock,loc.key)>
							<cfset loc.totals.received += loc.data.received>
							<cfset loc.totals.delivered += loc.data.delivered>
							<cfset loc.totals.returned += loc.data.returned>
							<cfset loc.totals.credited += loc.data.credited>
							<cfset loc.totals.claim += loc.data.claim>
							<cfset loc.totals.missing += loc.data.missing>
							<cfset loc.totals.error += loc.data.error>
							<cfset loc.totals.sales += loc.data.sales>
							<cfset loc.totals.salesValue += loc.data.salesValue>
							<cfset loc.totals.tradeValue += loc.data.tradeValue>
							<tr class="#loc.data.style#">
								<td>#loc.data.pubID#</td>
								<td>#loc.data.pubTitle#</td>
								<td>#loc.data.psIssue#</td>
								<td>#loc.data.pubType# (#loc.data.span#)</td>
								<td align="right">#loc.data.Retail#</td>
								<td align="right">#loc.data.Trade#</td>
								<td align="right">#loc.data.yymmdd#<br><span class="smallText">#loc.data.endDate#</span></td>
								<td align="center">#loc.data.received#</td>
								<td align="center">#loc.data.delivered#</td>
								<td align="center">#loc.data.returned#</td>
								<td align="center">#loc.data.claim#</td>
								<td align="center">#loc.data.credited#</td>
								<td align="center">#loc.data.missing#</td>
								<td align="center">#loc.data.error#</td>
								<td align="center">#loc.data.sales#</td>
								<td align="right">#FormatNum(loc.data.salesValue)#</td>
								<td align="right">#FormatNum(loc.data.tradeValue)#</td>
								<td align="center">#loc.data.msg#</td>
							</tr>
						</cfloop>
						<tr class="#loc.data.style#">
							<th colspan="7" align="right">Totals</th>
							<th align="center">#loc.totals.received#</th>
							<th align="center">#loc.totals.delivered#</th>
							<th align="center">#loc.totals.returned#</th>
							<th align="center">#loc.totals.claim#</th>
							<th align="center">#loc.totals.credited#</th>
							<th align="center">#loc.totals.missing#</th>
							<th align="center">#loc.totals.error#</th>
							<th align="center">#loc.totals.sales#</th>
							<th align="right">#FormatNum(loc.totals.salesValue)#</th>
							<th align="right">#FormatNum(loc.totals.tradeValue)#</th>
							<th align="right">Profit: #FormatNum(loc.totals.salesValue - loc.totals.tradeValue)#</th>
						</tr>
					</table>
				</div>
				<p></p>
			</cfoutput>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ReconcilliationReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.pubStock = {}>
		<cfset loc.result.pubSort = {}>
		<cfset loc.result.parms = args>
		<cfset loc.bankID = 3392>
		<cfset loc.wageID = 2092>
		
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
				<cfset loc.result.diff = DateDiff("d",loc.srchDateFrom,loc.srchDateTo) + 1>
				<cfset loc.result.numWeeks = int((loc.result.diff / 7) * 100) /100>
			</cfif>
			<cfset loc.result.srchDateFrom = loc.srchDateFrom>
			<cfset loc.result.srchDateTo = loc.srchDateTo>

			<!--- calculate no. of saturdays --->
			<cfset loc.saturdayCount = 0>
			<cfset loc.currentDate = loc.srchDateFrom>
			<cfloop condition="loc.currentDate LTE loc.srchDateTo">
				<cfif dayOfWeek(loc.currentDate) EQ 7>
					<cfset loc.saturdayCount++>
				</cfif>
				<cfset loc.currentDate = dateAdd("d", 1, loc.currentDate)>
			</cfloop>			
			<cfif loc.saturdayCount gt 1>
				<cfset loc.result.numWeeks = loc.saturdayCount>
			</cfif>
			<cfset loc.result.bblContribution = -val(args.form.bblContribution) * loc.result.numWeeks>
			
			<cfset loc.SalesData = ShopSales(args)>
			<!---<cfdump var="#loc.SalesData#" label="ShopSales" expand="false">--->
			<cfset loc.keys = ListSort(StructKeyList(loc.SalesData.stock,","),"text","asc")>
			<cfloop list="#loc.keys#" index="loc.key">
				<cfset loc.data = StructFind(loc.SalesData.stock,loc.key)>
				<!---<cfdump var="#loc.data#" label="#loc.key#" expand="false">--->
				<!---<cfset loc.compKey = "#loc.data.pubGroup#-#loc.data.pubID#">--->
				<cfif !StructKeyExists(loc.result.pubStock,loc.data.pubID)>
					<cfset StructInsert(loc.result.pubStock,loc.data.pubID,{
						pubID = loc.data.pubID,
						pubTitle = loc.data.pubTitle,
						pubType = loc.data.pubType,
						pubGroup = loc.data.pubGroup,
						Retail = loc.data.Retail,
						Trade = loc.data.Trade,
						"received" = loc.data.received,
						"delivered" = loc.data.delivered,
						"claim" = loc.data.claim,
						"returned" = loc.data.returned,
						"credited" = loc.data.credited,
						"sales" = loc.data.sales,
						"missing" = loc.data.missing,
						"error" = loc.data.error,
						"tradeValue" = loc.data.tradeValue,
						"salesValue" = loc.data.salesValue
					})>
					<cfset loc.group = IIf(loc.data.pubGroup eq "News",DE("A"),DE("B"))>
					<cfset loc.sortKey = "#loc.group#-#loc.data.pubTitle#">
					<cfif !StructKeyExists(loc.result.pubSort,loc.sortKey)>
						<cfset StructInsert(loc.result.pubSort,loc.sortKey,{
							pubID = loc.data.pubID,
							pubType = loc.data.pubType,
							pubGroup = loc.data.pubGroup,
							pubTitle = loc.data.pubTitle
						})>
					</cfif>
				<cfelse>
					<cfset loc.pubData = StructFind(loc.result.pubStock,loc.data.pubID)>
					<cfset loc.pubData.received += loc.data.received>
					<cfset loc.pubData.delivered += loc.data.delivered>
					<cfset loc.pubData.claim += loc.data.claim>
					<cfset loc.pubData.returned += loc.data.returned>
					<cfset loc.pubData.credited += loc.data.credited>
					<cfset loc.pubData.sales += loc.data.sales>
					<cfset loc.pubData.missing += loc.data.missing>
					<cfset loc.pubData.error += loc.data.error>
					<cfset loc.pubData.tradeValue += loc.data.tradeValue>
					<cfset loc.pubData.salesValue += loc.data.salesValue>
				</cfif>
			</cfloop>
			<!---<cfdump var="#loc.result.pubStock#" label="pubData" expand="false">--->

			<!--- news payments taken through till --->
			<cfquery name="loc.result.QPayments" datasource="#args.datasource#">
				SELECT cltRef,cltTitle,cltName,trnID,trnClientRef,trnDate,trnMethod,trnAmnt1
				FROM tbltrans
				INNNER JOIN tblClients ON cltRef = trnClientRef 
				WHERE `trnLedger` = 'sales' 
				AND `trnAccountID` = 4 
				AND `trnType` = 'pay' 
				AND `trnMethod` IN ('cash','card') 
				AND `trnDate` BETWEEN '#LSDateFormat(loc.srchDateFrom,"yyyy-mm-dd")#' AND '#LSDateFormat(loc.srchDateTo,"yyyy-mm-dd")#'
			</cfquery>
			<!--- news payments taken through Lloyds account --->
			<cfquery name="loc.result.QPaymentsLloyds" datasource="#args.datasource#">	
				SELECT cltRef,cltTitle,cltName,trnID,trnClientRef,trnDate,trnMethod,trnAmnt1
				FROM tbltrans
				INNNER JOIN tblClients ON cltRef = trnClientRef 
				INNER JOIN tblNomItems ON niTranID=trnID
				WHERE trnAccountID = 4 <!--- news acc payment --->
				AND niNomID = 41	<!--- lloyds bank --->
				AND `trnDate` BETWEEN '#LSDateFormat(loc.srchDateFrom,"yyyy-mm-dd")#' AND '#LSDateFormat(loc.srchDateTo,"yyyy-mm-dd")#'
			</cfquery>

			<!--- delivery wages due to drivers --->
			<cfquery name="loc.result.QWagesDue" datasource="#args.datasource#">
				SELECT trnID,trnDate,trnRef,trnDesc, nomCode,nomTitle, niAmount
				FROM tblTrans, tblNominal, tblNomItems
				WHERE niTranID = trnID
				AND niNomID = nomID
				AND nomID = #val(loc.wageID)#
				AND `trnDate` BETWEEN '#LSDateFormat(loc.srchDateFrom,"yyyy-mm-dd")#' AND '#LSDateFormat(loc.srchDateTo,"yyyy-mm-dd")#'
			</cfquery>
			<cfset loc.srchDateFrom5 = DateAdd("d",5,loc.srchDateFrom)>
			<cfset loc.srchDateTo5 = DateAdd("d",5,loc.srchDateTo)>
			<!--- delivery wages transferred to shop bank --->
			<cfquery name="loc.result.QWagesPaid" datasource="#args.datasource#">
				SELECT trnID,trnDate,trnRef,trnDesc, nomCode,nomTitle, niAmount
				FROM tblTrans, tblNominal, tblNomItems
				WHERE niTranID = trnID
				AND niNomID = nomID
				AND nomID = #val(loc.bankID)#
				AND trnDesc LIKE '%wages%'
				AND `trnDate` BETWEEN '#LSDateFormat(loc.srchDateFrom5,"yyyy-mm-dd")#' AND '#LSDateFormat(loc.srchDateTo5,"yyyy-mm-dd")#'
			</cfquery>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ViewReconcilliationReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.cardpay = 0>
		<cfset loc.cashpay = 0>
		<cfset loc.ibpay = 0>
		<cfset loc.value = 0>
		<cfset loc.wageTotal = 0>
		<cfset loc.paidTotal = 0>
		<cfset loc.summary = {}>
		<cfset loc.totals = {
			"received" = 0,
			"delivered" = 0,
			"claim" = 0,
			"returned" = 0,
			"credited" = 0,
			"sales" = 0,
			"missing" = 0,
			"error" = 0,
			"salesValue" = 0,
			"tradeValue" = 0
		}>
		
		<cftry>
			<cfset loc.summary.BBLoan = {
				"title" = "BB Loan Contribution", value = args.bblContribution
			}>
			<cfoutput>
				<!--- output news stock movement --->
				<cfset loc.keys = ListSort(StructKeyList(args.pubSort,","),"text","asc")>
				<table class="tableList" border="1">
					<tr>
						<th colspan="7">Publication Shop Sales</th>
						<th colspan="7">
							From: #LSDateFormat(args.srchDateFrom,'ddd dd-mmm-yy')# To: #LSDateFormat(args.srchDateTo,'ddd dd-mmm-yy')#
							&nbsp; (#args.numWeeks# weeks)
						</th>
					</tr>
					<tr>
						<th>pubID</th>
						<th>pubTitle</th>
						<th>pubType</th>
						<th>retail</th>
						<th>received</th>
						<th>delivered</th>
						<th>claim</th>
						<th>returned</th>
						<th>credited</th>
						<th>missing</th>
						<th>error</th>
						<th>sales</th>
						<th>salesValue</th>
						<th>tradeValue</th>
					</tr>
					<cfloop list="#loc.keys#" index="loc.key">
						<cfset loc.pubSortItem = StructFind(args.pubSort,loc.key)>
						<cfset loc.pubStock = StructFind(args.pubStock,loc.pubSortItem.pubID)>
								<cfset loc.totals.received += loc.pubStock.received>
								<cfset loc.totals.delivered += loc.pubStock.delivered>
								<cfset loc.totals.returned += loc.pubStock.returned>
								<cfset loc.totals.credited += loc.pubStock.credited>
								<cfset loc.totals.claim += loc.pubStock.claim>
								<cfset loc.totals.missing += loc.pubStock.missing>
								<cfset loc.totals.error += loc.pubStock.error>
								<cfset loc.totals.sales += loc.pubStock.sales>
								<cfset loc.totals.salesValue += loc.pubStock.salesValue>
								<cfset loc.totals.tradeValue += loc.pubStock.tradeValue>
						<!---<cfdump var="#loc.pubStock#" label="#loc.key#" expand="false">--->
						<tr>
							<td>#loc.pubStock.pubID#</td>
							<td>#loc.pubStock.pubTitle#</td>
							<td>#loc.pubStock.pubType#</td>
							<td align="right">#loc.pubStock.retail#</td>
							<td align="right" class="ncol1">#loc.pubStock.received#</td>
							<td align="right" class="ncol1">#loc.pubStock.delivered#</td>
							<td align="right" class="ncol1">#loc.pubStock.claim#</td>
							<td align="right" class="ncol1">#loc.pubStock.returned#</td>
							<td align="right" class="ncol1">#loc.pubStock.credited#</td>
							<td align="right" class="ncol1">#loc.pubStock.missing#</td>
							<td align="right" class="ncol1">#loc.pubStock.error#</td>
							<td align="right">#loc.pubStock.sales#</td>
							<td align="right">#FormatNum(loc.pubStock.salesValue)#</td>
							<td align="right">#FormatNum(loc.pubStock.tradeValue)#</td>
						</tr>
					</cfloop>
					<tr>
						<th colspan="4" align="right">Totals</th>
						<th align="center">#loc.totals.received#</th>
						<th align="center">#loc.totals.delivered#</th>
						<th align="center">#loc.totals.claim#</th>
						<th align="center">#loc.totals.returned#</th>
						<th align="center">#loc.totals.credited#</th>
						<th align="center">#loc.totals.missing#</th>
						<th align="center">#loc.totals.error#</th>
						<th align="center">#loc.totals.sales#</th>
						<th align="right">#FormatNum(loc.totals.salesValue)#</th>
						<th align="right">#FormatNum(loc.totals.tradeValue)#</th>
						<!---<th align="right">Profit: #FormatNum(loc.totals.salesValue - loc.totals.tradeValue)#</th>--->
					</tr>
				</table>
				<cfset loc.summary.stock = {
					"title" = "News Stock Trade Value", value = loc.totals.tradeValue
				}>

				<!--- output news payments --->
				<p></p>
				<table class="tableList" border="1">
					<tr>
						<th colspan="7">News Account Payments via Till and Lloyds Bank</th>
					</tr>
					<tr>
						<th>Reference</th>
						<th>Name</th>
						<th>Tran ID</th>
						<th>Date</th>
						<th width="60">Bank</th>
						<th width="60">Card</th>
						<th width="60">Cash</th>
					</tr>
					<cfloop query="args.QPayments">
						<cfset loc.value = -trnAmnt1>
						<tr>
							<td>#cltRef#</td>
							<td>#cltTitle# #cltName#</td>
							<td>#trnID#</td>
							<td>#LSDateFormat(trnDate,'dd-mmm-yy')#</td>
							<cfif trnMethod eq 'cash'>
								<cfset loc.cashpay += loc.value>
								<td></td>
								<td></td>
								<td align="right">#FormatNum(loc.value)#</td>
							<cfelse>
								<cfset loc.cardpay += loc.value>
								<td></td>
								<td align="right">#FormatNum(loc.value)#</td>
								<td></td>
							</cfif>
						</tr>
					</cfloop>
					<tr>
						<th colspan="7"></th>
					</tr>
					<cfloop query="args.QPaymentsLloyds">
						<cfset loc.value = -trnAmnt1>
						<tr>
							<td>#cltRef#</td>
							<td>#cltTitle# #cltName#</td>
							<td>#trnID#</td>
							<td>#LSDateFormat(trnDate,'dd-mmm-yy')#</td>
							<cfset loc.ibpay += loc.value>
							<td align="right">#FormatNum(loc.value)#</td>
							<td></td>
							<td></td>
						</tr>
					</cfloop>
					<tr>
						<th colspan="4">Totals</th>
						<th align="right">#FormatNum(loc.ibpay)#</th>
						<th align="right">#FormatNum(loc.cardpay)#</th>
						<th align="right">#FormatNum(loc.cashpay)#</th>
					</tr>
					<cfset loc.payTotal = loc.cashpay + loc.cardpay + loc.ibpay>
					<tr>
						<th colspan="6">Total News Payments</th>
						<th align="right">#FormatNum(loc.payTotal)#</th>
					</tr>
				</table>
				<cfset loc.summary.accounts = {
					"title" = "News Accounts Payments Collected", value = loc.payTotal
				}>
				
				<!--- output wages due --->
				<p></p>
				<table class="tableList" border="1">
					<tr>
						<th colspan="7">Delivery Wages Due</th>
					</tr>
					<tr>
						<th>Tran ID</th>
						<th>Date</th>
						<th>Reference</th>
						<th>Description</th>
						<th>Nom Code</th>
						<th>Title</th>
						<th width="60">Value</th>
					</tr>
					<cfloop query="args.QWagesDue">
						<cfset loc.value = -niAmount>
						<cfset loc.wageTotal += loc.value>
						<tr>
							<td>#trnID#</td>
							<td>#LSDateFormat(trnDate,'dd-mmm-yy')#</td>
							<td>#trnRef#</td>
							<td>#trnDesc#</td>
							<td>#nomCode#</td>
							<td>#nomTitle#</td>
							<td align="right">#FormatNum(loc.value)#</td>
						</tr>
					</cfloop>
					<tr>
						<th colspan="6">Total</th>
						<th align="right">#FormatNum(loc.wageTotal)#</th>
					</tr>
				</table>
				<cfset loc.summary.wagesDue = {
					"title" = "Delivery Wages Due", value = loc.wageTotal
				}>
				
				<!--- output wage payments --->
				<p></p>
				<table class="tableList" border="1">
					<tr>
						<th colspan="7">Delivery Wages Paid</th>
					</tr>
					<tr>
						<th>Tran ID</th>
						<th>Date</th>
						<th>Reference</th>
						<th>Description</th>
						<th>Nom Code</th>
						<th>Title</th>
						<th width="60">Value</th>
					</tr>
					<cfloop query="args.QWagesPaid">
						<cfset loc.value = -niAmount>
						<cfset loc.paidTotal += loc.value>
						<tr>
							<td>#trnID#</td>
							<td>#LSDateFormat(trnDate,'dd-mmm-yy')#</td>
							<td>#trnRef#</td>
							<td>#trnDesc#</td>
							<td>#nomCode#</td>
							<td>#nomTitle#</td>
							<td align="right">#FormatNum(loc.value)#</td>
						</tr>
					</cfloop>
					<tr>
						<th colspan="6">Total</th>
						<th align="right">#FormatNum(loc.paidTotal)#</th>
					</tr>
				</table>
				<cfset loc.summary.wagesPaid = {
					"title" = "Delivery Wages Sent", value = loc.paidTotal
				}>
				
				<!--- output summary totals --->
				<p></p>
				<table class="tableList">
					<tr>
						<th>Summary</th>
						<th align="right">DR</th>
						<th align="right">CR</th>
					</tr>
					<cfset loc.drTotal = 0>
					<cfset loc.crTotal = 0>
					<cfset loc.keys = ListSort(StructKeyList(loc.summary,","),"text","asc")>
					<cfloop list="#loc.keys#" index="loc.key">
						<cfset loc.item = StructFind(loc.summary,loc.key)>
						<tr>
							<td>#loc.item.title#</td>
							<cfif loc.item.value gt 0>
								<cfset loc.drTotal += loc.item.value>
								<td></td>
								<td align="right">#FormatNum(loc.item.value)#</td>
							<cfelse>
								<cfset loc.crTotal += loc.item.value>
								<td align="right">#FormatNum(loc.item.value)#</td>
								<td></td>
							</cfif>
						</tr>
					</cfloop>
					<cfset loc.balance = loc.drTotal + loc.crTotal>
					<tr>
						<th>Totals</th>
						<th align="right">#FormatNum(loc.crTotal)#</th>
						<th align="right">#FormatNum(loc.drTotal)#</th>
					</tr>
					<cfif loc.balance gt 0><cfset loc.legend = "from"><cfelse><cfset loc.legend = "to"></cfif>
					<tr>
						<th>Balance due #loc.legend# shop</th>
						<cfif loc.balance gt 0>
							<th></th><th>#FormatNum(loc.balance)#</th>
						<cfelse>
							<th>#FormatNum(loc.balance)#</th><th></th>
						</cfif>
					</tr>
				</table>
			</cfoutput>
			<!---<cfdump var="#loc.summary#" label="summary" expand="true">--->
			<p></p>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>
