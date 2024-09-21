<!--- revision 1.01	16/08/2024 --->
<!--- added running total to publication totals --->

<cftry>
	<cfsetting requesttimeout="300">
	<cfparam name="driverRate" default="0.65">
	<cfparam name="fuelRate" default="0.30">

	<cffunction name="loadRoundData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.parms = args>
		<cfset loc.result.rounds = {}>
		
		<cftry>
			<cfquery name="loc.result.QDrivers" datasource="#args.datasource1#">
				SELECT rndID,rndRef,rndTitle, drName,drDay
				FROM tbldriver
				INNER JOIN tblRounds ON rndID = drRoundID
				WHERE rndActive = 1
			</cfquery>
			<cfquery name="loc.QData" datasource="#args.datasource1#">
				SELECT riRoundID,riDayEnum,riOrder,riOrderID,
					rndID,rndRef,rndTitle,rndMileage,rndStyle,
					cltID,cltRef,cltName,cltCompanyName,cltAccountType, 
					ordID,ordHouseName,ordHouseNumber,
					oiSun,oiMon,oiTue,oiWed,oiThu,oiFri,oiSat,
					ordSun,ordMon,ordTue,ordWed,ordThu,ordFri,ordSat,
					delCode,delPrice1,
					stName,
					pubID,pubTitle,pubPrice,pubTradePrice
				FROM tblRoundItems
				INNER JOIN tblOrderItem ON oiOrderID = riOrderID
				INNER JOIN tblOrder ON ordID = riOrderID
				INNER JOIN tblClients ON cltID = ordClientID
				INNER JOIN tblPublication ON pubID = oiPubID
				INNER JOIN tblRounds ON rndID = riRoundID
				INNER JOIN tblStreets2 ON ordStreetCode = stID
				<cfif StructKeyExists(args.form,"useNewCode")>
					INNER JOIN tblDelCharges ON ordDelCodeNew = delCode
					<cfif len(args.form.DeliveryCode)>AND ordDelCodeNew = '#args.form.DeliveryCode#'</cfif>
				<cfelse>
					INNER JOIN tblDelCharges ON ordDeliveryCode = delCode
					<cfif len(args.form.DeliveryCode)>AND ordDeliveryCode = '#args.form.DeliveryCode#'</cfif>
				</cfif>
				WHERE 1
				AND ordActive
				AND pubActive
				AND oiStatus='active'
				AND cltAccountType NOT IN ('N','H')
				<cfif StructKeyExists(args.form,"roundsTicked")>
					AND riRoundID IN (#args.form.roundsTicked#)
				</cfif>
				AND (
					oiMon != 0 AND riDayEnum = 'mon'
					OR oiTue != 0 AND riDayEnum = 'tue'
					OR oiWed != 0 AND riDayEnum = 'wed'
					OR oiThu != 0 AND riDayEnum = 'thu'
					OR oiFri != 0 AND riDayEnum = 'fri'
					OR oiSat != 0 AND riDayEnum = 'sat'
					OR oiSun != 0 AND riDayEnum = 'sun'
				)
				<cfif StructKeyExists(args.form,"useSamples")>AND riOrderID IN (221,6131,951,6311,6371,7031,7121,8942,10662,12122)</cfif>
				ORDER BY rndRef,riOrder,riDayEnum   
			</cfquery>
			<!---<cfif StructKeyExists(args.form,"showDumps")><cfdump var="#loc.QData#" label="loc.QData" expand="false"></cfif>--->
			<cfloop query="loc.QData">
				<!--- create round structure --->
				<cfif !StructKeyExists(loc.result.rounds,rndRef)>
					<cfset StructInsert(loc.result.rounds,rndRef, {
						"RoundTitle" = rndTitle, 
						"Mileage" = rndMileage, 
						"ID" = rndID,
						"Ref" = rndRef,
						"Style" = rndStyle,
						"Totals" = {
							"pubRetail" = 0, 
							"pubTrade" = 0, 
							"pubProfit" = 0,
							"grossIncome" = 0,
							"grossProfit" = 0,
							"POR" = 0,
							"dropCount" = 0,
							"pubCount" = 0,
							"charges" = 0,
							"driverShare" = 0,
							"driverPay" = 0,
							"fuel" = 0,
							"netProfit" = 0
						},
						"activeDays" = {
							sun = {},
							mon = {},
							tue = {},
							wed = {},
							thu = {},
							fri = {},
							sat = {}
						},
						"Customers" = {}
					})>
				</cfif>
				<cfset loc.roundData = StructFind(loc.result.rounds,rndRef)>
				<!--- create customer structure --->
				<cfset loc.compKey = "#NumberFormat(riOrder,'000')#-#NumberFormat(ordID,'00000')#">
				<cfif !StructKeyExists(loc.roundData.customers,loc.compKey)>
					<cfset StructInsert(loc.roundData.customers,loc.compKey, {
						cltID = cltID,
						cltRef = cltRef,
						cltName = cltName,
						cltCompanyName = cltCompanyName,
						address = "#ordHouseNumber# #ordHouseName# #stName#",
						cltAccountType = cltAccountType,
						ordID = ordID,
						ordSun = ordSun,
						ordMon = ordMon,
						ordTue = ordTue,
						ordWed = ordWed,
						ordThu = ordThu,
						ordFri = ordFri,
						ordSat = ordSat,
						delPrice1 = delPrice1,
						delCode = delCode,
						pubs = {},
						activeDays = {
							sun = 0,
							mon = 0,
							tue = 0,
							wed = 0,
							thu = 0,
							fri = 0,
							sat = 0
						},
						dayCharges = {
							sun = 0,
							mon = 0,
							tue = 0,
							wed = 0,
							thu = 0,
							fri = 0,
							sat = 0
						},
						dayTotals = {
							sun = 0,
							mon = 0,
							tue = 0,
							wed = 0,
							thu = 0,
							fri = 0,
							sat = 0
						}			
					})>
				</cfif>
				<cfset loc.customer = StructFind(loc.roundData.customers,loc.compKey)>
				<!--- create publication structure --->
				<cfif !StructKeyExists(loc.customer.pubs,pubID)>
					<cfset StructInsert(loc.customer.pubs,pubID, {
						pubID = pubID,
						pubTitle = pubTitle,
						pubPrice = pubPrice,
						pubTradePrice = pubTradePrice,
						pubProfit = pubPrice - pubTradePrice,
						days = {}
					})>
				</cfif>
				<cfset loc.publication = StructFind(loc.customer.pubs,pubID)>
				<cfif !StructKeyExists(loc.publication.days,riDayEnum)>
					<cfset StructInsert(loc.publication.days, riDayEnum, Evaluate("oi#riDayEnum#"))>
					<cfset loc.customer.activeDays[riDayEnum] = Evaluate("oi#riDayEnum#") AND Evaluate("ord#riDayEnum#")>
					<cfif loc.customer.activeDays[riDayEnum] gt 0>
						<cfset loc.customer.dayCharges[riDayEnum] = delPrice1>
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

	<cffunction name="processRoundData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = args>
		
		<cftry>
			<cfset loc.roundKeys = ListSort(StructKeyList(args.rounds,","),"text","asc")>
			<!--- loop rounds --->
			<cfloop list="#loc.roundKeys#" index="loc.roundKey" delimiters=",">
				<cfset loc.roundData = StructFind(args.rounds,loc.roundKey)>
				<cfset loc.roundData.totals.dropCount = 0>
				<cfset loc.roundData.totals.pubCount = 0>
				<cfset loc.customerKeys = ListSort(StructKeyList(loc.roundData.customers,","),"text","asc")>
				<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
					<cfset loc.roundData.activeDays[loc.dayName] = {
						"pubQty" = 0,
						"pubProfit" = 0,
						"pubRetail" = 0,
						"charge" = 0,
						"grossProfit" = 0,
						"driverShare" = 0,
						"fuel" = 0,
						"total" = 0,
						"dropCount" = 0
					}>
				</cfloop>
				<!--- loop customers --->
				<cfloop list="#loc.customerKeys#" index="loc.customerKey" delimiters=",">
					<cfset loc.roundData.totals.dropCount++>
					<cfset loc.drop = StructFind(loc.roundData.customers,loc.customerKey)>
					<cfset loc.drop.totRetail = 0>
					<cfset loc.drop.totTrade = 0>
					<cfset loc.drop.totProfit = 0>
					<cfset loc.pubKeys = ListSort(StructKeyList(loc.drop.pubs,","),"numeric","asc")>
					<!--- loop publications --->
					<cfloop list="#loc.pubKeys#" index="loc.pubKey" delimiters=",">
						<cfset loc.pub = StructFind(loc.drop.pubs,loc.pubKey)>
						<cfset loc.pub.qtyWeekly = 0>
						<!---<cfset loc.roundData.totals.pubCount++>--->
						<!--- calculate publication totals --->
						<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
							<cfset loc.dayQty = StructFind(loc.drop.activeDays,loc.dayName)>
							<cfif StructKeyExists(loc.pub.days,loc.dayName)>
								<cfset loc.qty = StructFind(loc.pub.days,loc.dayName)>
								<cfset loc.drop.dayTotals[loc.dayName] += loc.qty>
								<cfset StructUpdate(loc.drop.activeDays, loc.dayName, loc.dayQty AND loc.qty)>
								<cfset loc.pub.qtyWeekly += loc.qty>
								<cfset loc.roundData.activeDays[loc.dayName].pubQty += loc.qty>
								<cfset loc.pub.wkRetail = loc.pub.qtyWeekly * loc.pub.pubPrice>
								<cfset loc.pub.wkTrade = loc.pub.qtyWeekly * loc.pub.pubTradePrice>
								<cfset loc.pub.wkProfit = loc.pub.qtyWeekly * loc.pub.pubProfit>
								<cfset loc.roundData.activeDays[loc.dayName].pubRetail += (loc.pub.pubPrice * loc.qty)>
								<cfset loc.roundData.activeDays[loc.dayName].pubProfit += (loc.pub.pubProfit * loc.qty)>
							</cfif>
						</cfloop>
						<cfset loc.drop.totRetail += loc.pub.wkRetail>
						<cfset loc.drop.totTrade += loc.pub.wkTrade>
						<cfset loc.drop.totProfit += loc.pub.wkProfit>
						<cfset loc.roundData.totals.pubRetail += loc.pub.wkRetail>
						<cfset loc.roundData.totals.pubTrade += loc.pub.wkTrade>
						<cfset loc.roundData.totals.pubProfit += loc.pub.wkProfit>
					</cfloop>	<!--- end publication --->
					<!--- calculate charge totals --->
					<cfset loc.drop.totalCharges = 0>
					<cfset loc.drop.totalPubs = 0>
					<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
						<cfset loc.drop.totalCharges += loc.drop.dayCharges[loc.dayName]>
						<cfset loc.drop.totalPubs += loc.drop.dayTotals[loc.dayName]>
						<cfset loc.roundData.activeDays[loc.dayName].dropCount += loc.drop.activeDays[loc.dayName]>
					</cfloop>
					<cfset loc.roundData.totals.charges += loc.drop.totalCharges>
					<cfset loc.roundData.totals.pubCount += loc.drop.totalPubs>
					<!--- calculate day totals --->
					<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
						<cfif loc.roundData.activeDays[loc.dayName].pubProfit neq 0>
							<cfset loc.roundData.activeDays[loc.dayName].charge += loc.drop.dayCharges[loc.dayName]>
							<cfset loc.roundData.activeDays[loc.dayName].grossProfit = loc.roundData.activeDays[loc.dayName].pubProfit + loc.roundData.activeDays[loc.dayName].charge>
							<cfset loc.roundData.activeDays[loc.dayName].driverShare = loc.roundData.activeDays[loc.dayName].grossProfit * driverRate * int(loc.roundData.mileage gt 0)>
							<cfset loc.roundData.activeDays[loc.dayName].fuel = loc.roundData.mileage * fuelRate>
							<cfset loc.roundData.activeDays[loc.dayName].total = loc.roundData.activeDays[loc.dayName].driverShare + loc.roundData.activeDays[loc.dayName].fuel>
						</cfif>
					</cfloop>
				</cfloop>	<!--- end customer --->
				<!--- calculate fuel --->
				<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
					<cfset loc.roundData.totals.fuel += loc.roundData.activeDays[loc.dayName].fuel>
				</cfloop>
				<!--- calculate final totals --->
				<cfset loc.roundData.totals.grossIncome = loc.roundData.totals.pubRetail + loc.roundData.totals.charges>
				<cfset loc.roundData.totals.grossProfit = loc.roundData.totals.grossIncome - loc.roundData.totals.pubTrade>
				<cfset loc.roundData.totals.POR += int(loc.roundData.totals.grossProfit / loc.roundData.totals.grossIncome * 100)>
				<cfset loc.roundData.totals.driverShare = loc.roundData.totals.grossProfit * driverRate * int(loc.roundData.mileage gt 0)>
				<cfset loc.roundData.totals.driverPay = loc.roundData.totals.driverShare + loc.roundData.totals.fuel>
				<cfset loc.roundData.totals.netProfit = loc.roundData.totals.grossProfit - loc.roundData.totals.driverPay>
			</cfloop>	<!--- end round --->
			
			<!--- build driver struct rndID,rndRef,rndTitle, drName,drDay --->
			<cfset loc.result.drivers = {}>
			<cfloop query="args.QDrivers">
				<cfif ListFind(args.parms.form.roundsTicked,rndID)>
					<cfif !StructKeyExists(loc.result.drivers,rndRef)>
						<cfset StructInsert(loc.result.drivers,rndRef, {"Round" = rndTitle, roundTotal = 0,
								sun = {},
								mon = {},
								tue = {},
								wed = {},
								thu = {},
								fri = {},
								sat = {}					
						})>
					</cfif>
					<cfset loc.rota = StructFind(loc.result.drivers,rndRef)>
					<cfif StructKeyExists(args.rounds,rndRef)>
						<cfset loc.rnd = StructFind(args.rounds,rndRef)>
						<cfset loc.rota.roundTotal += loc.rnd.activeDays[drDay].total>
						<cfset StructUpdate(loc.rota,drDay, {
							"Driver" = drName, 
							"driverPay" = loc.rnd.activeDays[drDay].total,
							"dropCount" = loc.rnd.activeDays[drDay].dropCount
						})>
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

	<cffunction name="showRoundData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfset loc.roundKeys = ListSort(StructKeyList(args.rounds,","),"text","asc")>
			<cfoutput>
				<!--- loop rounds --->
				<cfloop list="#loc.roundKeys#" index="loc.roundKey" delimiters=",">
					<cfset loc.roundData = StructFind(args.rounds,loc.roundKey)>
					<table class="roundList" border="1" style="margin:10px">
						<cfif StructKeyExists(args.parms.form,"showHeader")>
							<tr>
								<th class="rndheader">#loc.roundKey#</th>
								<th colspan="16" class="rndheader">#loc.roundData.roundTitle#</th>
							</tr>
							<tr>
								<th width="10"></th>
								<th>Publication</th>
								<th align="right">Retail Price</th>
								<th align="right">Trade Price</th>
								<th width="30" align="center">Sun</th>
								<th width="30" align="center">Mon</th>
								<th width="30" align="center">Tue</th>
								<th width="30" align="center">Wed</th>
								<th width="30" align="center">Thu</th>
								<th width="30" align="center">Fri</th>
								<th width="30" align="center">Sat</th>
								<th width="20" align="center">Weekly Total</th>
								<th width="40" align="right">Retail Value</th>
								<th width="40" align="right">Trade Total</th>
								<th width="40" align="right">Profit</th>
							</tr>
						</cfif>
						<!--- loop customers --->
						<cfset loc.cumRetail = 0>
						<cfset loc.customerKeys = ListSort(StructKeyList(loc.roundData.customers,","),"text","asc")>
						<cfloop list="#loc.customerKeys#" index="loc.customerKey" delimiters=",">
							<cfset loc.drop = StructFind(loc.roundData.customers,loc.customerKey)>
							<cfif !StructKeyExists(args.parms.form,"showDetail")>
								<cfset loc.header = "header2">
							<cfelse>
								<cfset loc.header = "header">
							</cfif>
							<cfif StructKeyExists(args.parms.form,"showHeader")>
								<tr class="#loc.header#">
									<td><a href="clientDetails.cfm?row=0&ref=#loc.drop.cltRef#" target="_new">#loc.drop.cltRef#</a></td>
									<td>#loc.drop.cltName#</td>
									<td colspan="6">#loc.drop.address#</td>
									<td align="center">#loc.drop.cltAccountType#</td>
									<td>#loc.drop.delCode#</td>
									<td>#loc.drop.delPrice1#</td>
									<td>#loc.drop.ordID#</td>
									<td colspan="3"><input name="dummy" type="checkbox" value="1" /></td>
								</tr>
							</cfif>
							<cfif StructKeyExists(args.parms.form,"showDetail")>
								<!--- loop publications --->
								<cfset loc.pubKeys = ListSort(StructKeyList(loc.drop.pubs,","),"numeric","asc")>							
								<cfloop list="#loc.pubKeys#" index="loc.pubKey" delimiters=",">
									<cfset loc.pub = StructFind(loc.drop.pubs,loc.pubKey)>
									<tr>
										<td></td>
										<td width="200">#loc.pub.pubTitle#</td>
										<td align="right">#loc.pub.pubPrice#</td>
										<td align="right">#loc.pub.pubTradePrice#</td>
										<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
											<td align="center">
												<cfif StructKeyExists(loc.pub.days,loc.dayName)>
													#StructFind(loc.pub.days,loc.dayName)#
												</cfif>
											</td>
										</cfloop>
										<cfset loc.cumRetail += loc.pub.wkRetail>
										<td align="center">#loc.pub.qtyWeekly#</td>
										<td align="right">#DecimalFormat(loc.pub.wkRetail)#</td>
										<td align="right">#DecimalFormat(loc.pub.wkTrade)#</td>
										<td align="right">#DecimalFormat(loc.pub.wkProfit)#</td>
									</tr>
								</cfloop>						
								<tr class="info">
									<td></td>
									<td></td>
									<td colspan="2">Delivery Days</td>
									<td align="center">#loc.drop.ordSun#</td>
									<td align="center">#loc.drop.ordMon#</td>
									<td align="center">#loc.drop.ordTue#</td>
									<td align="center">#loc.drop.ordWed#</td>
									<td align="center">#loc.drop.ordThu#</td>
									<td align="center">#loc.drop.ordFri#</td>
									<td align="center">#loc.drop.ordSat#</td>
									<td colspan="4"></td>
								</tr>
								<tr class="info">
									<td></td>
									<td></td>
									<td colspan="2">Active Days</td>
									<td align="center">#StructFind(loc.drop.activeDays,"sun")#</td>
									<td align="center">#StructFind(loc.drop.activeDays,"mon")#</td>
									<td align="center">#StructFind(loc.drop.activeDays,"tue")#</td>
									<td align="center">#StructFind(loc.drop.activeDays,"wed")#</td>
									<td align="center">#StructFind(loc.drop.activeDays,"thu")#</td>
									<td align="center">#StructFind(loc.drop.activeDays,"fri")#</td>
									<td align="center">#StructFind(loc.drop.activeDays,"sat")#</td>
									<td colspan="6"></td>
								</tr>
								<tr>
									<td></td>
									<td></td>
									<td colspan="2">Delivery Charges</td>
									<td align="center">#StructFind(loc.drop.dayCharges,"sun")#</td>
									<td align="center">#StructFind(loc.drop.dayCharges,"mon")#</td>
									<td align="center">#StructFind(loc.drop.dayCharges,"tue")#</td>
									<td align="center">#StructFind(loc.drop.dayCharges,"wed")#</td>
									<td align="center">#StructFind(loc.drop.dayCharges,"thu")#</td>
									<td align="center">#StructFind(loc.drop.dayCharges,"fri")#</td>
									<td align="center">#StructFind(loc.drop.dayCharges,"sat")#</td>
									<td align="center">#DecimalFormat(loc.drop.totalCharges)#</td>
								</tr>
								<tr class="footer">
									<td></td>
									<td></td>
									<td colspan="2">Publication Totals</td>
									<td align="center">#StructFind(loc.drop.dayTotals,"sun")#</td>
									<td align="center">#StructFind(loc.drop.dayTotals,"mon")#</td>
									<td align="center">#StructFind(loc.drop.dayTotals,"tue")#</td>
									<td align="center">#StructFind(loc.drop.dayTotals,"wed")#</td>
									<td align="center">#StructFind(loc.drop.dayTotals,"thu")#</td>
									<td align="center">#StructFind(loc.drop.dayTotals,"fri")#</td>
									<td align="center">#StructFind(loc.drop.dayTotals,"sat")#</td>
									<td align="center">#loc.drop.totalPubs#</td>
									<td align="right" width="50">#DecimalFormat(loc.drop.totRetail)#</td>
									<td align="right" width="50">#DecimalFormat(loc.drop.totTrade)#</td>
									<td align="right" width="50">#DecimalFormat(loc.drop.totProfit)#</td>
									<td align="right">#DecimalFormat(loc.cumRetail)#</td>
								</tr>
							</cfif>
						</cfloop>
						
						<cfif StructKeyExists(args.parms.form,"showHeader")>
							<tr class="rndfooter">
								<td align="center">#ListLen(loc.customerKeys)#</td>
								<td>drops</td>
								<td align="right" colspan="10">#loc.roundData.roundTitle# Totals</td>
								<td align="right">#DecimalFormat(loc.roundData.Totals.pubRetail)#</td>
								<td align="right">#DecimalFormat(loc.roundData.Totals.pubTrade)#</td>
								<td align="right">#DecimalFormat(loc.roundData.Totals.pubProfit)#</td>
							</tr>
						</cfif>
					</table>
					<div class="summary" style="page-break-before:always;"></div>
				</cfloop>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ShowRoundSummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfset loc.roundKeys = ListSort(StructKeyList(args.rounds,","),"text","asc")>
			<cfoutput>
				<!--- loop rounds --->
				<table class="roundList" border="1" style="margin:10px">
					<tr>
						<th colspan="16" class="rndheader">Round Summary</th>
					</tr>
					<tr>
						<th width="10">Reference</th>
						<th align="left">Round</th>
						<th align="center">Mileage</th>
						<th align="center">Drops</th>
						<th width="20" align="center">Publications</th>
						<th width="40" align="right">Retail</th>
						<th width="40" align="right">Trade</th>
						<th width="40" align="right">Profit</th>
						<th width="40" align="right">Charges</th>
						<th width="40" align="right">Gross Income</th>
						<th width="40" align="right">Gross Profit</th>
						<th width="40" align="right">POR</th>
						<th width="40" align="right">Driver Share</th>
						<th width="40" align="right">Fuel</th>
						<th width="40" align="right">Driver Pay</th>
						<th width="40" align="right">Net Profit</th>
					</tr>
					<cfset loc.grand = {
						mileage = 0,
						dropCount = 0,
						pubCount = 0,
						pubRetail = 0,
						pubTrade = 0,
						pubProfit = 0,
						charges = 0,
						grossIncome = 0,
						grossProfit = 0,
						driverShare = 0,
						fuel = 0,
						driverPay = 0,
						netProfit = 0
					}>
					<cfloop list="#loc.roundKeys#" index="loc.roundKey" delimiters=",">
						<cfset loc.roundData = StructFind(args.rounds,loc.roundKey)>
						<cfset loc.grand.mileage += loc.roundData.mileage>
						<cfset loc.grand.dropCount += loc.roundData.totals.dropCount>
						<cfset loc.grand.pubCount += loc.roundData.totals.pubCount>
						<cfset loc.grand.pubRetail += loc.roundData.totals.pubRetail>
						<cfset loc.grand.pubTrade += loc.roundData.totals.pubTrade>
						<cfset loc.grand.pubProfit += loc.roundData.totals.pubProfit>
						<cfset loc.grand.charges += loc.roundData.totals.charges>
						<cfset loc.grand.grossIncome += loc.roundData.totals.grossIncome>
						<cfset loc.grand.grossProfit += loc.roundData.totals.grossProfit>
						<cfset loc.grand.driverShare += loc.roundData.totals.driverShare>
						<cfset loc.grand.fuel += loc.roundData.totals.fuel>
						<cfset loc.grand.driverPay += loc.roundData.totals.driverPay>
						<cfset loc.grand.netProfit += loc.roundData.totals.netProfit>
						<tr>
							<td>#loc.roundData.ref#</td>
							<td>#loc.roundData.roundTitle#</td>
							<td align="center">#loc.roundData.mileage#</td>
							<td align="center">#loc.roundData.totals.dropCount#</td>
							<td align="center">#loc.roundData.totals.pubCount#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.pubRetail)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.pubTrade)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.pubProfit)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.charges)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.grossIncome)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.grossProfit)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.POR)#%</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.driverShare)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.fuel)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.driverPay)#</td>
							<td align="right">#DecimalFormat(loc.roundData.totals.netProfit)#</td>
						</tr>
					</cfloop>
					<tr>
						<th></th>
						<th>Totals</th>
						<th>#loc.grand.mileage#</th>
						<th>#loc.grand.dropCount#</th>
						<th>#loc.grand.pubCount#</th>
						<th align="right">#DecimalFormat(loc.grand.pubRetail)#</th>
						<th align="right">#DecimalFormat(loc.grand.pubTrade)#</th>
						<th align="right">#DecimalFormat(loc.grand.pubProfit)#</th>
						<th align="right">#DecimalFormat(loc.grand.charges)#</th>
						<th align="right">#DecimalFormat(loc.grand.grossIncome)#</th>
						<th align="right">#DecimalFormat(loc.grand.grossProfit)#</th>
						<th align="right"></th>
						<th align="right">#DecimalFormat(loc.grand.driverShare)#</th>
						<th align="right">#DecimalFormat(loc.grand.fuel)#</th>
						<th align="right">#DecimalFormat(loc.grand.driverPay)#</th>
						<th align="right">#DecimalFormat(loc.grand.netProfit)#</th>
					</tr>
				</table>
				<!---<div class="summary" style="page-break-before:always;"></div>--->
			</cfoutput>
	
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ShowDriverSummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.driverTotals = {}>
		<cfset loc.dayTotals = {}>

		<cftry>
			<cfset loc.roundKeys = ListSort(StructKeyList(args.drivers,","),"text","asc")>
			<cfoutput>
				<table class="summaryList" style="margin:10px">
					<tr>
						<th colspan="4" class="rndheader">Driver Summary</th>
						<th colspan="5" class="rndheader">as at #DateFormat(Now(),'dd-mmm-yy')#</th>
					</tr>
					<tr>
						<th width="80"></th>
						<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
							<th width="60" align="right">#loc.dayName#</th>
						</cfloop>
						<th width="60" align="right">Totals</th>
					</tr>
					<cfloop list="#loc.roundKeys#" index="loc.roundKey" delimiters=",">
						<cfset loc.rnd = StructFind(args.drivers,loc.roundKey)>
						<tr>
							<td>#loc.rnd.round#</td>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<cfset loc.dayData = StructFind(loc.rnd,loc.dayName)>
								<cfif !StructIsEmpty(loc.dayData)>
									<cfif !StructKeyExists(loc.driverTotals,loc.dayData.driver)>
										<cfset StructInsert(loc.driverTotals,loc.dayData.driver,0)>
									</cfif>
									<cfif !StructKeyExists(loc.dayTotals,loc.dayName)>
										<cfset StructInsert(loc.dayTotals,loc.dayName,0)>
									</cfif>
									<cfset loc.balance = StructFind(loc.driverTotals,loc.dayData.driver)>
									<cfset StructUpdate(loc.driverTotals,loc.dayData.driver,loc.balance + loc.dayData.driverPay)>
									<cfset loc.dayTotal = StructFind(loc.dayTotals,loc.dayName)>
									<cfset StructUpdate(loc.dayTotals,loc.dayName,loc.dayTotal + loc.dayData.driverPay)>
									<td align="right">
										#loc.dayData.driver#<br />#showField(loc.dayData.driverPay)#<br />#showField(loc.dayData.dropCount,0)#
									</td>
								<cfelse>
									<td align="right"></td>
								</cfif>
							</cfloop>
							<td align="right">#DecimalFormat(loc.rnd.roundTotal)#</td>
						</tr>
					</cfloop>
					<cfset loc.dayGrandTotal = 0>
					<tr class="rndfooter">
						<td></td>
						<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
							<cfset loc.dayTotal = StructFind(loc.dayTotals,loc.dayName)>
							<cfset loc.dayGrandTotal += loc.dayTotal>
							<td align="right">#DecimalFormat(loc.dayTotal)#</td>
						</cfloop>
						<td align="right">#DecimalFormat(loc.dayGrandTotal)#</td>
					</tr>
				</table>
				<!--- output driver totals --->
				<cfset loc.driverKeys = ListSort(StructKeyList(loc.driverTotals,","),"text","asc")>
				<table class="summaryList" style="margin:10px">
					<cfset loc.driverTotal = 0>
					<cfloop list="#loc.driverKeys#" index="loc.driver" delimiters=",">
						<cfset loc.driverPay = StructFind(loc.driverTotals,loc.driver)>
						<cfset loc.driverTotal += loc.driverPay>
						<tr>
							<td width="80">#loc.driver#</td>
							<td width="80" align="right">#DecimalFormat(showField(loc.driverPay,2))#</td>
						</tr>
					</cfloop>
					<tr class="rndfooter">
						<td>Total</td>
						<td align="right">#DecimalFormat(showField(loc.driverTotal,2))#</td>
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

	<cffunction name="showField" access="private" returntype="string">
		<cfargument name="field" type="numeric" required="no" default="0">
		<cfargument name="places" type="numeric" required="no" default="2">
		<cfif field neq 0>
			<cfif places eq 2>
				<cfreturn DecimalFormat(field)>
			<cfelse>
				<cfreturn NumberFormat(field,"_____")>
			</cfif>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="ShowDaySummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfoutput>
				<cfset loc.roundKeys = ListSort(StructKeyList(args.rounds,","),"text","asc")>
				<!--- loop rounds --->
				<table class="summaryList" style="margin:10px">
					<cfloop list="#loc.roundKeys#" index="loc.roundKey" delimiters=",">
						<cfset loc.roundData = StructFind(args.rounds,loc.roundKey)>
						<tr>
							<th colspan="4" class="rndheader">Day Summary: #loc.roundData.roundTitle#</th>
							<th colspan="5" class="rndheader">as at #DateFormat(Now(),'dd-mmm-yy')#</th>
						</tr>
						<tr>
							<th></th>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<th align="right">#loc.dayName#</th>
							</cfloop>
							<th align="right">Totals</th>
						</tr>
						<tr>
							<td>Media Retail</td>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<cfset loc.dayData = StructFind(loc.roundData.activeDays,loc.dayName)>
								<td width="60" align="right">#showField(loc.dayData.pubRetail)#</td>
							</cfloop>
							<td width="60" align="right">#showField(loc.roundData.totals.pubRetail)#</td>
						</tr>
						<tr>
							<td>Media Profit</td>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<cfset loc.dayData = StructFind(loc.roundData.activeDays,loc.dayName)>
								<td width="60" align="right">#showField(loc.dayData.pubProfit)#</td>
							</cfloop>
							<td width="60" align="right">#showField(loc.roundData.totals.pubProfit)#</td>
						</tr>
						<tr>
							<td>Charges</td>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<cfset loc.dayData = StructFind(loc.roundData.activeDays,loc.dayName)>
								<td width="60" align="right">#showField(loc.dayData.charge)#</td>
							</cfloop>
							<td width="60" align="right">#showField(loc.roundData.totals.charges)#</td>
						</tr>
						<tr>
							<td>Gross Profit</td>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<cfset loc.dayData = StructFind(loc.roundData.activeDays,loc.dayName)>
								<td width="60" align="right">#showField(loc.dayData.grossProfit)#</td>
							</cfloop>
							<td width="60" align="right">#showField(loc.roundData.totals.grossProfit)#</td>
						</tr>
						<tr>
							<td>Driver</td>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<cfset loc.dayData = StructFind(loc.roundData.activeDays,loc.dayName)>
								<td width="60" align="right">#showField(loc.dayData.driverShare)#</td>
							</cfloop>
							<td width="60" align="right">#showField(loc.roundData.totals.driverShare)#</td>
						</tr>
						<tr>
							<td>Fuel</td>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<cfset loc.dayData = StructFind(loc.roundData.activeDays,loc.dayName)>
								<td width="60" align="right">#showField(loc.dayData.fuel)#</td>
							</cfloop>
							<td width="60" align="right">#showField(loc.roundData.totals.fuel)#</td>
						</tr>
						<tr>
							<td>Total</td>
							<cfloop list="sun,mon,tue,wed,thu,fri,sat" index="loc.dayName">
								<cfset loc.dayData = StructFind(loc.roundData.activeDays,loc.dayName)>
								<td width="60" align="right">#showField(loc.dayData.total)#</td>
							</cfloop>
							<td width="60" align="right">#showField(loc.roundData.totals.driverPay)#</td>
						</tr>
					</cfloop>
				</table>
				<div class="summary" style="page-break-before:always;"></div>
			</cfoutput>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cfquery name="QDelRates" datasource="#application.site.datasource1#">
		SELECT * FROM tbldelcharges
		ORDER BY delCode
	</cfquery>	

	<cfquery name="QOrigCodeDelCounts" datasource="#application.site.datasource1#">
		SELECT ordDeliveryCode, delPrice1, COUNT(*) AS delCount
		FROM tblorder
		INNER JOIN tblClients ON cltID=ordClientID
		INNER JOIN tbldelcharges ON delCode=ordDeliveryCode
		WHERE ordActive = 1 
		AND cltAccountType NOT IN ('N','H')
		GROUP BY ordDeliveryCode
	</cfquery>

	<cfquery name="QNewCodeDelCounts" datasource="#application.site.datasource1#">
		SELECT ordDelCodeNew, delPrice1, COUNT(*) AS delCount
		FROM tblorder
		INNER JOIN tblClients ON cltID=ordClientID
		INNER JOIN tbldelcharges ON delCode=ordDelCodeNew
		WHERE ordActive = 1 
		AND cltAccountType NOT IN ('N','H')
		GROUP BY ordDelCodeNew
	</cfquery>
	
	<cfset parms = {}>
	<cfset parms.form = form>
	<cfset parms.datasource1 = application.site.datasource1>
	<cfset parms.driverRate = driverRate>
	<cfset parms.fuelRate = fuelRate>
	
	<!--- load data --->
	<cfset data = loadRoundData(parms)>
	<!---<cfif StructKeyExists(form,"showDumps")><cfdump var="#data#" label="1st Pass" expand="false"></cfif>--->
	<!--- process data --->
	<cfset data = processRoundData(data)>
	<cfif StructKeyExists(form,"showDumps")><cfdump var="#data#" label="2nd Pass" expand="true"></cfif>

	<!--- output data --->
	<cfset view = showRoundData(data)>
	<cfset view = showRoundSummary(data)>
	<cfset view = ShowDaySummary(data)>
	<cfset view = ShowDriverSummary(data)>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

