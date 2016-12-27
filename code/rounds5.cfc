<cfcomponent displayname="rounds" extends="core">

	<cffunction name="LoadRoundList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QRounds="">
		<cfset result.rounds=[]>
		
		<cfquery name="QRounds" datasource="#args.datasource#">
			SELECT *
			FROM tblRounds
			WHERE rndActive
			<cfif StructKeyExists(args,"streetOnly")>AND rndView='street'</cfif>
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

	<cffunction name="LoadRoundDrops" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var r={}>
		<cfset var street={}>
		<cfset var house={}>
		<cfset var i={}>
		<cfset var c={}>
		<cfset var cc={}>
		<cfset var set={}>
		<cfset var dis={}>
		<cfset var disItem={}>
		<cfset var QRounds="">
		<cfset var QRoundItems="">
		<cfset var QOrderItems="">
		<cfset var QHolItems="">
		<cfset var QHolHoldCheck="">
		<cfset var QStockCheck="">
		<cfset var QGetStreet="">
		<cfset var QGetCharges="">
		<cfset var QCheckCharges="">
		<cfset var QCheckDelItems="">
		<cfset var QCheckDelCreditItems="">
		<cfset var QDispatch="">
		<cfset var QDisHolItems="">
		<cfset var QCheckBatch="">
		<cfset var QCreateBatch="">
		<cfset var QNewBatch="">
		<cfset var QCheckVouchers="">
		<cfset var QCheckVouchersReturns="">
		<cfset var grandPubQty=0>
		<cfset var pubQty=0>
		<cfset var key=0>
		<cfset var streetcode=0>
		<cfset var counter=0>
		<cfset var testmode=0>
		<cfset var dayName=DateFormat(args.roundDate,"DDD")>
		<cfset var dayDate=DateFormat(args.roundDate,"yyyy-mm-dd")>
		<cfset var dayYest=DateFormat(DateAdd("d",-1,args.roundDate),"yyyy-mm-dd")>
		<cfset result.GrandTotalQty={}>
		<cfset result.dispatch=[]>
		<cfset result.charge=[]>
		<cfset result.rounds=[]>
		<cfset result.counterID={}>
		<cfset result.batches={}>
		<cfif StructKeyExists(args,"showRoundOrder") AND args.showRoundOrder is "yes">
			<cfset var rerun=false>
		<cfelse>
			<cfset var rerun=true>
		</cfif>
		
		<cftry>
			<cfif StructKeyExists(args,"roundID")>
				<!--- Load Rounds --->

				<cfquery name="QRounds" datasource="#args.datasource#">
					SELECT *
					FROM tblRounds
					WHERE rndID IN (#args.roundID#)
					ORDER BY rndRef asc
					<cfif rerun>LIMIT 1;</cfif>
				</cfquery>
				<cfloop query="QRounds">
					<cfif NOT rerun>
						<cfset r={}>
						<cfset r.roundID=QRounds.rndID>
						<cfset r.roundTitle=QRounds.rndTitle>
						<cfset r.roundView=QRounds.rndView>
						<cfset r.list=[]>
						<cfset r.TotalQty={}>
					<cfelse>
						<cfset r={}>
						<cfset r.roundID=0>
						<cfset r.roundTitle="Rerun">
						<cfset r.roundView="street">
						<cfset r.list=[]>
						<cfset r.TotalQty={}>
					</cfif>
					
					<cfquery name="QRoundItems" datasource="#args.datasource#">
						SELECT *
						FROM tblRoundItems,tblClients,tblOrder
						WHERE 1
						<cfif NOT rerun>AND riRoundID=#r.roundID#<cfelse>AND riRoundID IN (#args.roundID#)</cfif>
						AND riOrderID=ordID
						AND riDay='#dayName#'
						AND ordClientID=cltID
						AND (cltAccountType='M' OR cltAccountType='W' OR cltAccountType='C')
						AND ordActive=1
						<cfif NOT rerun>
							<cfif r.roundView is "name">ORDER BY cltName asc, cltCompanyName asc<cfelse>ORDER BY riOrder</cfif>
						<cfelse>
							ORDER BY ordPriority asc
						</cfif>
					</cfquery>
					<cfloop query="QRoundItems">
						<cfset house={}>
						<cfset house.ID=QRoundItems.riID>
						<cfset house.SortOrder=QRoundItems.riOrder>
						<cfset house.OpenDay=Evaluate("ord"&dayName)>
						<cfset house.ClientID=QRoundItems.ordClientID>
						<cfset house.ClientRef=QRoundItems.cltRef>
						<cfif LSDateFormat(QRoundItems.cltEntered,"yyyy-mm-dd") gte DateAdd("d",-7,dayDate)><cfset house.new=true><cfelse><cfset house.new=false></cfif>
						<cfset house.OrderID=QRoundItems.ordID>
						<cfset house.OrderType=QRoundItems.ordType>
						<cfif QRoundItems.cltAccountType is "C"><cfset house.pay="Pay Collect"><cfelse><cfset house.pay=""></cfif>
						<cfif r.roundView is "name">
							<cfset house.number="">
							<cfif len(QRoundItems.cltName) AND len(QRoundItems.cltCompanyName)>
								<cfset house.name="#QRoundItems.cltName#, #QRoundItems.cltCompanyName#">
							<cfelse>
								<cfset house.name="#QRoundItems.cltName##QRoundItems.cltCompanyName#">
							</cfif>
							<cfset house.Town="">
							<cfset house.Postcode="">
						<cfelse>
							<cfset house.number=QRoundItems.ordHouseNumber>
							<cfset house.name=QRoundItems.ordHouseName>
							<cfset house.Town=QRoundItems.ordTown>
							<cfset house.Postcode=QRoundItems.ordPostcode>
						</cfif>
						<cfset house.delCharge=false>
						<cfset house.delIncrease=QRoundItems.ordDeliveryIncrease>
						<cfset house.Note=QRoundItems.ordNote>
						<cfset house.items=[]>

						<cfquery name="QOrderItems" datasource="#args.datasource#">
							SELECT *
							FROM tblOrderItem,tblPublication
							WHERE oiOrderID=#ordID#
							<cfif StructKeyExists(args,"PubSelect")>AND oiPubID IN (#args.PubSelect#)</cfif>
							AND oiPubID=pubID
							AND pubActive
							AND oiStatus='active'
							ORDER BY pubType asc, pubTitle asc
						</cfquery>
						<cfloop query="QOrderItems">
							<cfset i={}>
							<cfset counter=counter+1>
							<cfset i.counter=counter>
							
							<!--- Switch setup --->
							<cfset i.AddToRound=false>
							<cfset i.ChargeItem=false>
							<cfset i.CreditItem=false>
							<cfset i.ChargeItemDel=false>
							<cfset i.InStock=true>
							<cfset i.CheckPoint1=false>
							<cfset i.CheckPoint2=false>
							
							<!--- Item Setup --->
							<cfset i.ID=oiID>
							<cfset i.pubID=pubID>
							<cfset i.batch=0>
							<cfset i.pubGroup=pubGroup>
							<cfset i.OrderID=oiOrderID>
							<cfset i.reason="">
							<cfset i.heldback=0>
							<cfset i.Price=QOrderItems.pubPrice+QOrderItems.pubPWPrice>
							<cfset i.PriceTrade=val(QOrderItems.pubTradePrice)>
							<cfif len(pubRoundTitle)>
								<cfset i.Title=pubRoundTitle>
							<cfelse>
								<cfif len(pubShortTitle)>
									<cfset i.Title=pubShortTitle>
								<cfelse>
									<cfset i.Title=pubTitle>
								</cfif>
							</cfif>
							<cfif i.pubGroup is "news">
								<cfset i.Issue=LSDateFormat(dayDate,"ddmmm")>
							<cfelse>
								<cfset i.Issue="">
							</cfif>
							<cfif i.pubGroup is "magazine">
								<cfset i.sort="x"&pubGroup&i.Title>
							<cfelse>
								<cfset i.sort=pubGroup&i.Title>
							</cfif>
							
							<!--- Day Setup --->
							<cfif i.pubGroup is "news">
								<cfset i.Qty=val(Evaluate("QOrderItems.oi"&dayName))>
							<cfelse>
								<cfset i.Qty=val(oiMon+oiTue+oiWed+oiThu+oiFri+oiSat+oiSun)>
							</cfif>
							
							<cfif i.Qty neq 0>
								<cfif i.pubGroup is "Magazine">
									<!--- MAGAZINE --->
									<!--- Check magazine stock --->
									<cfquery name="QStockCheck" datasource="#args.datasource#">
										SELECT psIssue,psQty
										FROM tblPubStock
										WHERE psPubID=#i.pubID#
										AND psType='received'
										AND psDate >= '#LSDateFormat(DateAdd("d",-4,dayDate),"yyyy-mm-dd")#'
										AND psDate < '#LSDateFormat(dayDate,"yyyy-mm-dd")#'
										LIMIT 1;
									</cfquery>
									<cfquery name="QStockClaimCheck" datasource="#args.datasource#">
										SELECT psIssue,psQty
										FROM tblPubStock
										WHERE psPubID=#i.pubID#
										AND psType='claim'
										AND psDate >= '#LSDateFormat(DateAdd("d",-4,dayDate),"yyyy-mm-dd")#'
										AND psDate < '#LSDateFormat(dayDate,"yyyy-mm-dd")#'
										LIMIT 1;
									</cfquery>
									<cfset i.totalReceived=val(QStockCheck.psQty)+val(QStockClaimCheck.psQty)>
									<cfif QStockCheck.recordcount is 1>
										<cfset i.Issue=QStockCheck.psIssue>
										<cfset i.CheckPoint1=true>
									</cfif>
								<cfelse>
									<!--- NEWSPAPER --->
									<cfset i.CheckPoint1=true>
								</cfif>
								<cfif i.CheckPoint1>
									<!--- Check if customer already received the publication --->
									<cfquery name="QDelCheck" datasource="#args.datasource#">
										SELECT *
										FROM tblDelItems
										WHERE diOrderID=#i.OrderID#
										AND diPubID=#i.pubID#
										AND diIssue='#i.Issue#'
										AND diDate >= '#LSDateFormat(DateAdd("d",-28,dayYest),"yyyy-mm-dd")#'
										AND diDate <= '#LSDateFormat(dayYest,"yyyy-mm-dd")#'
										LIMIT 1;
									</cfquery>
									<cfif QDelCheck.recordcount is 0>
										<cfset i.CheckPoint2=true>
									</cfif>
										
									<cfif i.CheckPoint2>
										<!--- Check for Holiday --->
										<cfquery name="QHolItems" datasource="#args.datasource#">
											SELECT *
											FROM tblHolidayOrder,tblHolidayItem
											WHERE hoOrderID=#i.OrderID#
											AND hiHolidayID=hoID
											AND hiOrderItemID=#i.ID#
											AND hoStop <= '#dayDate#'
											AND (hoStart > '#dayDate#' OR hoStart IS NULL)
											LIMIT 1;
										</cfquery>
										<cfif QHolItems.recordcount is 1>
											<cfset i.holiday=true>
											<cfset i.holidayStop=DateFormat(QHolItems.hoStop,"DD MMM YY")>
											<cfset i.holidayStart=DateFormat(QHolItems.hoStart,"DD MMM YY")>
											<cfset i.holidayAction=QHolItems.hiAction>
											<cfswitch expression="#i.holidayAction#">
												<cfcase value="cancel">
													<cfset i.AddToRound=true>
													<cfset i.ChargeItem=true>
													<cfset i.ChargeItemDel=false>
													<cfset i.CreditItem=true>
													<cfset i.reason="On Holiday">
												</cfcase>
												<cfcase value="stop">	<!--- 287 was i.holidayStop but broke dateformat --->
													<cfif LSDateFormat(dayDate,"yyyy-mm-dd") gte LSDateFormat(QHolItems.hoStop,"yyyy-mm-dd") 
														AND NOT LSDateFormat(dayDate,"yyyy-mm-dd") gt LSDateFormat(DateAdd("d",2,QHolItems.hoStop),"yyyy-mm-dd")>
														<cfset i.AddToRound=true>
														<cfset i.ChargeItem=false>
														<cfset i.ChargeItemDel=false>
														<cfset i.CreditItem=false>
													</cfif>
												</cfcase>
												<cfcase value="hold">
													<cfset i.AddToRound=true>
													<cfset i.ChargeItem=true>
													<cfset i.ChargeItemDel=false>
													<cfset i.CreditItem=false>
												</cfcase>
												<cfdefaultcase>
													<cfset i.AddToRound=false>
													<cfset i.ChargeItem=false>
													<cfset i.ChargeItemDel=false>
													<cfset i.CreditItem=false>
												</cfdefaultcase>
											</cfswitch>
										<cfelse>
											<!--- Get Hold back date start date, to show date of when to deliver pubs again --->
											<cfquery name="QHolHoldCheck" datasource="#args.datasource#">
												SELECT *
												FROM tblHolidayOrder,tblHolidayItem
												WHERE hoOrderID=#i.OrderID#
												AND hiHolidayID=hoID
												AND hiOrderItemID=#i.ID#
												AND hoStart='#dayDate#'
												AND hiAction='hold'
												LIMIT 1;
											</cfquery>
											<!---  --->
											<cfset i.AddToRound=true>
											<cfset i.ChargeItem=true>
											<cfset i.ChargeItemDel=true>
											<cfset i.CreditItem=false>
											<cfif QHolHoldCheck.recordcount is 1>
												<cfset i.holiday=true>
												<cfset i.holidayStop=DateFormat(QHolHoldCheck.hoStop,"DD MMM YY")>
												<cfset i.holidayStart=DateFormat(QHolHoldCheck.hoStart,"DD MMM YY")>
												<cfset i.holidayAction=QHolHoldCheck.hiAction>
											<cfelse>
												<cfset i.holiday=false>
												<cfset i.holidayStop="">
												<cfset i.holidayStart="">
												<cfset i.holidayAction="">
											</cfif>
											<cfif r.roundView is "street" AND house.OpenDay is 0>
												<cfset i.heldback=1>
												<cfset i.holiday=true>
												<cfset i.holidayAction="hold">
												<cfset i.holidayStart="Monday">
												<cfset i.AddToRound=true>
												<cfset i.ChargeItem=true>
												<cfset i.ChargeItemDel=false>
												<cfset i.CreditItem=false>
											</cfif>
											<cfif r.roundView is "name" AND house.OpenDay is 0>
												<cfset i.AddToRound=false>
												<cfset i.ChargeItem=false>
												<cfset i.ChargeItemDel=false>
												<cfset i.CreditItem=false>
											</cfif>
										</cfif>
										<cfif i.holiday AND rerun>
											<cfset i.AddToRound=false>
											<cfset i.ChargeItem=false>
											<cfset i.ChargeItemDel=false>
											<cfset i.CreditItem=false>
										</cfif>
									</cfif>
								</cfif>
								
								<!--- Show on round sheet --->
								<cfif i.AddToRound>
									<cfset key=r.RoundID&i.pubID>
									
									<!--- Round Total --->
									<cfif i.ChargeItem AND NOT i.CreditItem>
										<cfif StructKeyExists(r,"TotalQty")>
											<cfif StructKeyExists(r.TotalQty,key)>
												<cfset pubQty=StructFind(r.TotalQty,key)>
												<cfset set={}>
												<cfset set.sort=i.sort>
												<cfset set.Title=i.Title>
												<cfset set.Qty=pubQty.qty+i.qty>
												
												<cfif i.pubGroup is "magazine">
													<cfif i.totalReceived gte pubQty.qty>
														<cfset i.InStock=true>
													<cfelse>
														<cfset i.InStock=false>
													</cfif>
												<cfelse>
													<cfset i.InStock=true>
												</cfif>
												
												<cfif i.InStock><cfset StructUpdate(r.TotalQty,key,set)></cfif>
											<cfelse>
												<cfset set={}>
												<cfset set.sort=i.sort>
												<cfset set.Title=i.Title>
												<cfset set.Qty=i.qty>
												
												<cfif i.pubGroup is "magazine">
													<cfif i.totalReceived gte i.qty>
														<cfset i.InStock=true>
													<cfelse>
														<cfset i.InStock=false>
													</cfif>
												<cfelse>
													<cfset i.InStock=true>
												</cfif>
												
												<cfif i.InStock><cfset StructInsert(r.TotalQty,key,set)></cfif>
											</cfif>
										</cfif>
									</cfif>
									
									<!--- Grand Total --->
									<cfif i.InStock AND NOT i.CreditItem AND i.ChargeItem>		<!--- STOP was being included in the total --->
										<cfif StructKeyExists(result.GrandTotalQty,i.pubID)>
											<cfset grandPubQty=StructFind(result.GrandTotalQty,i.pubID)>
											<cfset set={}>
											<cfset set.sort=i.sort>
											<cfset set.Title=i.Title>
											<cfset set.Qty=grandPubQty.qty+i.qty>
											<cfset StructUpdate(result.GrandTotalQty,i.pubID,set)>
										<cfelse>
											<cfset set={}>
											<cfset set.sort=i.sort>
											<cfset set.Title=i.Title>
											<cfset set.Qty=i.qty>
											<cfset StructInsert(result.GrandTotalQty,i.pubID,set)>
										</cfif>
									</cfif>
										
									<cfset ArrayAppend(house.items,i)>
								</cfif>
								
								<cfif i.ChargeItem AND i.InStock AND NOT rerun>
									<!--- Create batch --->
									<cfif StructKeyExists(result.batches,r.roundID)>
										<cfset i.batch=StructFind(result.batches,r.roundID)>
									<cfelse>
										<cfquery name="QCheckBatch" datasource="#args.datasource#">
											SELECT dbID
											FROM tblDelBatch
											WHERE dbRef='#dayDate#'
											AND dbRound=#r.roundID#
											LIMIT 1;
										</cfquery>
										<cfif QCheckBatch.recordcount is 0>
											<cfquery name="QCreateBatch" datasource="#args.datasource#" result="QNewBatch">
												INSERT INTO tblDelBatch (dbRef,dbRound) VALUES ('#dayDate#',#r.roundID#)
											</cfquery>
											<cfset i.batch=QNewBatch.generatedKey>
											<cfset StructInsert(result.batches,r.roundID,i.batch)>
										<cfelse>
											<cfset i.batch=QCheckBatch.dbID>
											<cfset StructInsert(result.batches,r.roundID,i.batch)>
										</cfif>
									</cfif>
									
									<!--- Charge Data --->
									<cfset c={}>
									<cfset c.counter=i.counter>
									<cfset c.roundID=r.roundID>
									<cfset c.clientID=house.clientID>
									<cfset c.orderID=i.orderID>
									<cfset c.batchID=i.batch>
									<cfset c.pubID=i.pubID>
									<cfset c.type="debit">
									<cfset c.date=dayDate>
									<cfset c.datestamp=dayDate>
									<cfset c.issue=i.issue>
									<cfset c.qty=i.qty>
									<cfset c.price=i.price>
									<cfset c.priceTrade=i.PriceTrade>
									<cfset c.charge=0>
									<cfset c.vat=0>
									<cfset c.test=testmode>
									<cfset c.voucher=0>
									<cfset c.invoice=0>
									<cfset c.heldback=i.heldback>
									<cfset c.reason="">
									<cfif i.CreditItem>
										<cfset c.ignore=true>
									<cfelse>
										<cfset c.ignore=false>
									</cfif>
									
									<cfquery name="QCheckVouchers" datasource="#args.datasource#">
										SELECT vchID
										FROM tblVoucher
										WHERE vchOrderID=#i.orderID#
										AND vchPubID=#i.pubID#
										AND vchStart <= '#LSDateFormat(dayDate,'yyyy-mm-dd')#'
										AND vchStop >= '#LSDateFormat(dayDate,'yyyy-mm-dd')#'
										AND vchStatus='in'
										LIMIT 1;
									</cfquery>
									<cfquery name="QCheckVouchersReturns" datasource="#args.datasource#">
										SELECT vchID
										FROM tblVoucher
										WHERE vchOrderID=#i.orderID#
										AND vchPubID=#i.pubID#
										AND vchStart <= '#LSDateFormat(dayDate,'yyyy-mm-dd')#'
										AND vchStop >= '#LSDateFormat(dayDate,'yyyy-mm-dd')#'
										AND vchStatus='out'
										LIMIT 1;
									</cfquery>
									<cfif QCheckVouchersReturns.recordcount is 0>
										<cfset c.voucher=val(QCheckVouchers.vchID)>
									</cfif>
									
									<cfquery name="QCheckDelItems" datasource="#args.datasource#">
										SELECT *
										FROM tblDelItems
										WHERE diOrderID=#i.orderID#
										AND diPubID=#i.pubID#
										AND diDate='#dayDate#'
										AND diType='debit'
										LIMIT 1;
									</cfquery>
									<cfif QCheckDelItems.recordcount is 0>
										<!--- Charge delivery --->
										<cfif i.ChargeItemDel AND NOT house.delCharge>
											<cfquery name="QGetCharges" datasource="#args.datasource#">
												SELECT *
												FROM tblDelCharges
												WHERE delCode=#val(QRoundItems.ordDeliveryCode)#
												LIMIT 1;
											</cfquery>
											<cfif QGetCharges.delPrice2 neq 0>
												<cfswitch expression="#dayName#">
													<cfcase value="sat"><cfset c.charge=QGetCharges.delPrice2></cfcase>
													<cfcase value="sun"><cfset c.charge=QGetCharges.delPrice3></cfcase>
													<cfdefaultcase><cfset c.charge=QGetCharges.delPrice1></cfdefaultcase>
												</cfswitch>
											<cfelseif QGetCharges.delType is "Per Day">
												<cfset c.charge=QGetCharges.delPrice1>
											<cfelseif QGetCharges.delType is "Per Week">
												<cfset c.charge=QGetCharges.delPrice1/7>
											<cfelse>
												<cfset c.charge=QGetCharges.delPrice1>
											</cfif>
											<cfset house.delCharge=true>
										</cfif>
										<cfset c.charge=c.charge+house.delIncrease>
										
										<!--- Add charge to charge array --->
										<cfif NOT StructKeyExists(result.counterID,i.counter)>
											<cfset StructInsert(result.counterID,i.counter,i.counter)>
										</cfif>
										<cfset ArrayAppend(result.charge,c)>
										
										<!--- Add credit to charge array --->
										<cfif i.CreditItem AND NOT rerun>
											<cfquery name="QCheckDelCreditItems" datasource="#args.datasource#">
												SELECT *
												FROM tblDelItems
												WHERE diOrderID=#i.orderID#
												AND diPubID=#i.pubID#
												AND diDate='#dayDate#'
												AND diType='credit'
												LIMIT 1;
											</cfquery>
											<cfif QCheckDelCreditItems.recordcount is 0>
												<cfset cc={}>
												<cfset cc.counter=i.counter>
												<cfset cc.roundID=r.roundID>
												<cfset cc.clientID=house.clientID>
												<cfset cc.orderID=i.orderID>
												<cfset cc.batchID=i.batch>
												<cfset cc.pubID=i.pubID>
												<cfset cc.type="credit">
												<cfset cc.date=dayDate>
												<cfset cc.datestamp=dayDate>
												<cfset cc.issue=i.issue>
												<cfset cc.qty=i.qty>
												<cfset cc.price="-"&val(i.price)>
												<cfset cc.priceTrade="-"&val(i.PriceTrade)>
												<cfset cc.charge=0>
												<cfset cc.vat=0>
												<cfset cc.test=testmode>
												<cfset cc.voucher=c.voucher>
												<cfset cc.invoice=0>
												<cfset cc.heldback=i.heldback>
												<cfset cc.ignore=true>
												<cfset cc.reason=i.reason>
												<cfif i.ChargeItemDel><cfset cc.charge="-"&val(c.charge)></cfif>
												<cfset ArrayAppend(result.charge,cc)>
											</cfif>
										</cfif>
									</cfif>
								</cfif>
								
							</cfif>
							
						</cfloop>
						
						<!--- Assign Street --->
						<cfif ArrayLen(house.items) OR house.OrderType is "Custom">
							<cfquery name="QGetStreet" datasource="#args.datasource#">
								SELECT *
								FROM tblStreets2
								WHERE stID=#val(QRoundItems.ordStreetCode)#
							</cfquery>
							<cfif QRoundItems.ordStreetCode neq streetcode>
								<cfset streetcode=QRoundItems.ordStreetCode>
								<cfset street={}>
								<cfset street.StreetCode=QRoundItems.ordStreetCode>
								<cfset street.StreetName=QGetStreet.stName>
								<cfset streetCode=QRoundItems.ordStreetCode>
								<cfset street.houses=[]>
								<cfset ArrayAppend(r.list,street)>
							</cfif>
							<cfset ArrayAppend(street.houses,house)>
						</cfif>
					</cfloop>
					
					<!--- Append round to result--->
					<cfset ArrayAppend(result.rounds,r)>
				</cfloop>
			</cfif>
				
			<cfcatch type="any">
				<cfdump var="#house#" label="house" expand="no">
				<cfdump var="#QHolItems#" label="QHolItems" expand="no">
				<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="ProcessChargedItems" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var batch={}>
		<cfset var rounds={}>
		<cfset var set={}>
		<cfset var r={}>
		<cfset var QInsert="">
		<cfset var QCheckBatch="">
		<cfset var QUpdateBatch="">
		<cfset var row=0>
		<cfset var array=0>
		<cfset var drops=0>
		
		<cfif StructKeyExists(args,"charges")>
			<cfset array=ArrayLen(args.charges)>
			<cfif array neq 0>
				<cfquery name="QInsert" datasource="#args.datasource#">
					INSERT INTO tblDelItems (diClientID,diOrderID,diBatchID,diRoundID,diPubID,diType,diDatestamp,diDate,diIssue,diQty,diPrice,diPriceTrade,diCharge,diVATAmount,diTest,diVoucher,diInvoiceID,diHeldBack,diReason) VALUES 
					<cfloop array="#args.charges#" index="i">
						<cfset row=row+1>
						<cfset drops=0>
						(#i.ClientID#,#i.OrderID#,#i.BatchID#,#i.RoundID#,#i.PubID#,'#i.Type#','#i.Datestamp#','#i.Date#','#i.Issue#',#i.Qty#,#i.Price#,#i.PriceTrade#,#i.charge#,#i.vat#,#i.test#,#i.voucher#,#i.invoice#,#i.heldback#,'#i.reason#')
						<cfif row neq array>,</cfif>
						<cfif NOT i.ignore>
							<cfif StructKeyExists(rounds,i.RoundID)>
								<cfset r=StructFind(rounds,i.RoundID)>
								<cfif NOT StructKeyExists(r.drops,i.OrderID)>
									<cfset StructInsert(r.drops,i.OrderID,1)>
									<cfset drops=1>
								</cfif>
							<cfelse>
								<cfset r={}>
								<cfset r.drops={}>
								<cfset StructInsert(r.drops,i.OrderID,1)>
								<cfset StructInsert(rounds,i.RoundID,r)>
								<cfset drops=1>
							</cfif>
							<cfif StructKeyExists(batch,i.BatchID)>
								<cfset b=StructFind(batch,i.BatchID)>
								<cfset set={}>
								<cfset set.ID=i.BatchID>
								<cfset set.pubTotal=b.pubTotal+i.Price>
								<cfset set.delTotal=b.delTotal+i.charge>
								<cfset set.pubQty=b.pubQty+i.Qty>
								<cfset set.dropQty=b.dropQty+drops>
								<cfset set.roundExp=b.roundExp+i.PriceTrade>
								<cfset StructUpdate(batch,i.BatchID,set)>
							<cfelse>
								<cfquery name="QCheckBatch" datasource="#args.datasource#">
									SELECT *
									FROM tblDelBatch
									WHERE dbID=#i.BatchID#
								</cfquery>
								<cfset set={}>
								<cfset set.ID=i.BatchID>
								<cfset set.pubTotal=QCheckBatch.dbPubTotal+i.Price>
								<cfset set.delTotal=QCheckBatch.dbDelTotal+i.charge>
								<cfset set.pubQty=QCheckBatch.dbPubQty+i.Qty>
								<cfset set.dropQty=QCheckBatch.dbDropQty+drops>
								<cfset set.roundExp=QCheckBatch.dbRoundExp+i.PriceTrade>
								<cfset StructInsert(batch,i.BatchID,set)>
							</cfif>
						</cfif>
					</cfloop>
				</cfquery>
				<cfloop collection="#batch#" item="item">
					<cfset bi=StructFind(batch,item)>
					<cfquery name="QUpdateBatch" datasource="#args.datasource#">
						UPDATE tblDelBatch
						SET dbDate='#LSDateFormat(Now(),"yyyy-mm-dd")# #TimeFormat(Now(),"HH:mm:ss")#',
							dbPubTotal=#bi.pubTotal#,
							dbDelTotal=#bi.delTotal#,
							dbPubQty=#bi.pubqty#,
							dbDropQty=#bi.dropqty#,
							dbRoundExp=#bi.roundExp#
						WHERE dbID=#bi.ID#
					</cfquery>
				</cfloop>
			</cfif>
		</cfif>

		<cfset result=rounds>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadDispatchNotes" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var dis={}>
		<cfset var item={}>
		<cfset var QDispatch="">
		<cfset var QCreditCheck="">
		<cfset var QPapers="">
		<cfset var QMags="">

<cftry>
		<cfif StructKeyExists(args.form,"dispatchTicked")>
			<cfquery name="QDispatch" datasource="#args.datasource#">
				SELECT cltName,cltCompanyName,cltDelHouseNumber, tblOrder.*
				FROM tblOrder,tblClients
				WHERE ordClientID IN (#args.form.dispatchTicked#)
				AND cltID=ordClientID
				AND ordActive=1
			</cfquery>
			<cfloop query="QDispatch">
				<cfset dis={}>
				<cfif QDispatch.ordClientID is 6391><cfset dis.Type="Detail"><cfelse><cfset dis.Type="Plain"></cfif>
				<cfif NOT len(cltCompanyName)><cfset dis.Name=cltName><cfelse><cfset dis.Name=cltCompanyName></cfif>
				<cfset dis.cltDelHouseNumber=cltDelHouseNumber>
				<cfset dis.ordContact=ordContact>
				<cfset dis.ordSignDesp=ordSignDesp>
				<cfset dis.totalDis=0>
				<cfset dis.totalDisQty=0>
				<cfset dis.list=[]>
				
				<!--- Load Papers --->
				<cfquery name="QPapers" datasource="#args.datasource#">
					SELECT tblDelItems.*,pubTitle,pubGroup,pubType
					FROM tblDelItems,tblPublication
					WHERE diOrderID=#QDispatch.ordID#
					AND diDate='#LSDateFormat(args.form.roundDate,"yyyy-mm-dd")#'
					AND diType='debit'
					AND diPubID=pubID
					AND pubGroup='news'
					AND pubActive
					ORDER BY pubTitle asc
				</cfquery>
				<cfloop query="QPapers">
					<cfquery name="QCreditCheck" datasource="#args.datasource#">
						SELECT *
						FROM tblDelItems
						WHERE diOrderID=#QPapers.diOrderID#
						AND diPubID=#QPapers.diOrderID#
						AND diDate=#LSDateFormat(args.form.roundDate,"yyyy-mm-dd")#
						AND diType='credit'
						LIMIT 1;
					</cfquery>
					<cfif QCreditCheck.recordcount is 0>
						<cfset item={}>
						<cfset item.Title=pubTitle>
						<cfset item.Group=pubGroup>
						<cfset item.Type=pubType>
						<cfset item.Qty=diQty>
						<cfset item.Price=diPrice>
						<cfset ArrayAppend(dis.list,item)>
						<cfset dis.totalDis=dis.totalDis+(item.Price*item.Qty)>
						<cfset dis.totalDisQty=dis.totalDisQty+item.Qty>
					</cfif>
				</cfloop>
				
				<!--- Load Mags --->
				<cfquery name="QMags" datasource="#args.datasource#" result="QMagResult">
					SELECT tblDelItems.*,pubTitle,pubGroup,pubType
					FROM tblDelItems,tblPublication
					WHERE diOrderID=#QDispatch.ordID#
					<!---AND diDate='#LSDateFormat(DateAdd("d",-1,args.form.roundDate),"yyyy-mm-dd")#'--->
					AND diDate='#LSDateFormat(args.form.roundDate,"yyyy-mm-dd")#'
					AND diType='debit'
					AND diPubID=pubID
					AND pubGroup='magazine'
					AND pubActive
					ORDER BY pubTitle asc
				</cfquery>
<!---<cfdump var="#QMagResult#" label="QMagResult" expand="yes" format="html" 
	output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
--->				
				<cfloop query="QMags">
					<cfquery name="QCreditCheck" datasource="#args.datasource#">
						SELECT *
						FROM tblDelItems
						WHERE diOrderID=#QMags.diOrderID#
						AND diPubID=#QMags.diOrderID#
					<!---AND diDate='#LSDateFormat(DateAdd("d",-1,args.form.roundDate),"yyyy-mm-dd")#'--->
					AND diDate='#LSDateFormat(args.form.roundDate,"yyyy-mm-dd")#'
						AND diType='credit'
						LIMIT 1;
					</cfquery>
					<cfif QCreditCheck.recordcount is 0>
						<cfset item={}>
						<cfset item.Title=pubTitle>
						<cfset item.Group=pubGroup>
						<cfset item.Type=pubType>
						<cfset item.Qty=diQty>
						<cfset item.Price=diPrice>
						<cfset ArrayAppend(dis.list,item)>
						<cfset dis.totalDis=dis.totalDis+(item.Price*item.Qty)>
						<cfset dis.totalDisQty=dis.totalDisQty+item.Qty>
					</cfif>
				</cfloop>
				
				<!--- Add to dispatch array --->
				<cfset ArrayAppend(result,dis)>
			</cfloop>
		</cfif>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="CopyRoundOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QSelect="">
		<cfset var QUpdate="">
		<cfset var QClear="">
		<cfset var dayName="">
		<cfset var count=0>

		<cftry>
			<cfquery name="QClear" datasource="#application.site.datasource1#">
				DELETE FROM tblRoundItems
				WHERE riRoundID=#val(args.roundID)#
				AND riDay IN (<cfloop list="#args.days#" delimiters="," index="i"><cfset count=count+1><cfif count neq 1>,</cfif>'#i#'</cfloop>)
			</cfquery>
			<cfset count=0>
			<cfquery name="QSelect" datasource="#application.site.datasource1#">
				SELECT * 
				FROM tblRoundItems
				WHERE riRoundID=#val(args.roundID)#
				AND riDay='#args.roundDay#'
				GROUP BY riOrderID
				ORDER BY riOrder asc
			</cfquery>
			<cfquery name="QUpdate" datasource="#application.site.datasource1#">
				INSERT INTO tblRoundItems (riClientID,riOrderID,riRoundID,riRoundRef,riDay,riDayEnum,riOrder) VALUES 
				<cfloop query="QSelect">
					<cfloop list="#args.days#" delimiters="," index="iDay">
						<cfset count=count+1>
						<cfif count neq 1>,</cfif>(#QSelect.riClientID#,#QSelect.riOrderID#,#QSelect.riRoundID#,#QSelect.riRoundRef#,'#iDay#','#iDay#',#QSelect.riOrder#)
					</cfloop>
				</cfloop>
			</cfquery>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="RoundReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QSelect="">
		<cfset var delWage=0>
		<cfset var daySelection=DateDiff("d",LSDateFormat(args.form.from,"yyyy-mm-dd"),LSDateFormat(args.form.to,"yyyy-mm-dd"))>
		<cfset var roundCount=ListLen(args.form.roundID,",")>
		<cfset var adminfee=((400/28)/args.form.roundTotal)*roundCount>
		<cfset var bankcharges=((150/28)/args.form.roundTotal)*roundCount>
		<cfset result.list=[]>
		<cfset result.pubtotal=0>
		<cfset result.droptotal=0>
		<cfset result.pubcost=0>
		<cfset result.wagecost=0>
		<cfset result.total=0>
		<cfset result.grandtotal=0>
		<cfset result.grossgrandtotal=0>
		<cfset result.adminfee=adminfee*daySelection>
		<cfset result.bankcharges=bankcharges*daySelection>

		<cftry>
			<cfquery name="QSelect" datasource="#args.datasource#">
				SELECT * 
				FROM tblDelBatch,tblRounds
				WHERE dbRoundExp > 0
				AND rndID IN (#args.form.roundID#)
				AND dbRound=rndID
				AND dbRef >= '#LSDateFormat(args.form.from,"yyyy-mm-dd")#'
				AND dbRef <= '#LSDateFormat(args.form.to,"yyyy-mm-dd")#'
				ORDER BY dbRound asc, dbRef asc
			</cfquery>
			<cfloop query="QSelect">
				<cfset item={}>
				<cfset item.ID=dbRound>
				<cfset item.title=rndTitle>
				<cfset item.PubQty=dbPubQty>
				<cfset item.DropQty=dbDropQty>
				<cfset item.DelIncrease=val(args.form.delinc)*item.DropQty>
				<cfset item.PubTotal=dbPubTotal>
				<cfset item.DelTotal=dbDelTotal+val(item.DelIncrease)>
				<cfset item.RoundExp=dbRoundExp>
				<cfset item.GrossTotal=item.PubTotal-item.RoundExp>
				<cfset item.Date=LSDateFormat(dbRef,"ddd")>
				<cfif args.form.wageType is "fixed">
					<cfif item.ID neq 241>
						<cfif item.Date is "sat"><cfset delWage=30><cfelse><cfset delWage=25></cfif>
					</cfif>
					<cfset item.wage=delWage>
				<cfelse>
					<cfset item.wage=item.DelTotal>
				</cfif>
				<cfset item.Profit=(item.GrossTotal+item.DelTotal)-item.wage>
				<cfset result.pubtotal=result.pubtotal+item.PubTotal>
				<cfset result.droptotal=result.droptotal+item.DelTotal>
				<cfset result.pubcost=result.pubcost+item.RoundExp>
				<cfset result.grossgrandtotal=result.grossgrandtotal+item.GrossTotal>
				<cfset result.wagecost=result.wagecost+item.wage>
				<cfset result.total=result.total+item.Profit>
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
			
			<cfset result.grandtotal=result.total-result.adminfee-result.bankcharges>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="RoundWage" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var i={}>
		<cfset var QRounds="">
		<cfset var QBatch="">
		<cfset var delWage=0>
		<cfset result.list=[]>
		<cfset result.delTotal=0>
		<cfset result.bonuses=0>
		<cfset result.total=0>
		<cfset result.grandtotal=0>
		<cfset result.loss=0>

		<cftry>
			<cfset parm={}>
			<cfset parm.datasource=args.datasource>
			<cfset parm.form.roundID=args.form.roundID>
			<cfset parm.form.from=args.form.from>
			<cfset parm.form.to=args.form.to>
			<cfset parm.form.delinc=args.form.delinc>
			<cfset parm.form.roundtotal=args.form.roundtotal>
			<cfset parm.form.wageType="variable">
			<cfset result.profit=RoundReport(parm)>
		
			<cfquery name="QRounds" datasource="#args.datasource#">
				SELECT *
				FROM tblRounds
				WHERE rndID IN (#args.form.roundID#) 
				ORDER BY rndRef asc
			</cfquery>
			<cfloop query="QRounds">
				<cfset item={}>
				<cfset item.ID=rndID>
				<cfset item.title=rndTitle>
				<cfset item.mileage=rndMileage>
				<cfset item.pubqty=0>
				<cfset item.dropqty=0>
				<cfset item.deltotal=0>
				<cfset item.bonus=0>
				<cfset item.total=0>
				<cfset item.pay=0>
				<cfset item.days=[]>
				
				<cfquery name="QBatch" datasource="#args.datasource#">
					SELECT * 
					FROM tblDelBatch
					WHERE dbRoundExp > 0
					AND dbRound=#QRounds.rndID#
					AND dbRef >= '#LSDateFormat(args.form.from,"yyyy-mm-dd")#'
					AND dbRef <= '#LSDateFormat(args.form.to,"yyyy-mm-dd")#'
					ORDER BY dbRound asc, dbRef asc
				</cfquery>
				<cfloop query="QBatch">
					<cfset i={}>
					<cfset i.Date=LSDateFormat(dbRef,"ddd")>
					<cfset i.bonus=0>
					
					<cfset i.PubQty=dbPubQty>
					<cfset i.DropQty=dbDropQty>
					<cfset i.DelIncrease=val(args.form.delinc)*i.DropQty>
					<cfset i.DelTotal=dbDelTotal+val(i.DelIncrease)>
					<cfif i.Date is "sat"><cfset delWage=30><cfelse><cfset delWage=25></cfif>
					<cfset i.wage=i.DelTotal>
					<cfif StructKeyExists(args.form,"pubbonus")><cfset i.bonus=i.bonus+(0.01*i.PubQty)></cfif>
					<cfif StructKeyExists(args.form,"dropbonus")><cfset i.bonus=i.bonus+(0.01*i.DropQty)></cfif>
					<cfif StructKeyExists(args.form,"mileagebonus")><cfset i.bonus=i.bonus+(args.form.mileageallow*item.mileage)></cfif>
					<cfset i.Total=i.DelTotal+i.bonus>
					<cfset i.Pay=i.wage+i.bonus>
					
					<cfset item.pubqty=item.pubqty+i.PubQty>
					<cfset item.dropqty=item.dropqty+i.DropQty>
					<cfset item.deltotal=item.deltotal+i.DelTotal>
					<cfset item.bonus=item.bonus+i.bonus>
					<cfset item.total=item.total+i.Total>
					<cfset item.pay=item.pay+i.Pay>
					
					<cfset ArrayAppend(item.days,i)>
				</cfloop>
				
				<cfif item.Pay lt 180>
					<cfset item.pay=180>
				</cfif>
				
				<cfset result.deltotal=result.deltotal+item.deltotal>
				<cfset result.bonuses=result.bonuses+item.bonus>
				<cfset result.total=result.total+item.total>
				<cfset result.grandtotal=result.grandtotal+item.pay>
				<cfset result.QBatch=QBatch>
				
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
			
			<cfset result.loss=result.deltotal-result.grandtotal>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="PriorityOrdering" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QOrders="">
		<cfset var QGetStreet="">
		<cfset var QGetRound="">
		
		<cftry>
			<cfquery name="QOrders" datasource="#args.datasource#">
				SELECT *
				FROM tblClients,tblOrder
				WHERE ordClientID=cltID
				AND (cltAccountType='M' OR cltAccountType='W')
				AND ordActive=1
				ORDER BY ordPriority asc
			</cfquery>
			<cfloop query="QOrders">
				<cfquery name="QGetStreet" datasource="#args.datasource#">
					SELECT *
					FROM tblStreets2
					WHERE stID=#val(ordStreetCode)#
				</cfquery>
				<cfquery name="QGetRound" datasource="#args.datasource#">
					SELECT *
					FROM tblRoundItems,tblRounds
					WHERE riRoundID IN (301,311,321)
					AND riOrderID=#ordID#
					AND riRoundID=rndID
					AND rndView='street'
					LIMIT 1;
				</cfquery>
				<cfif QGetRound.recordcount is 1>
					<cfset item={}>
					<cfset item.ID=ordID>
					<cfset item.Priority=ordPriority>
					<cfif len(ordHouseNumber) AND len(ordHouseName)>
						<cfset item.Name="#ordHouseNumber# #ordHouseName#">
					<cfelse>
						<cfset item.Name="#ordHouseNumber##ordHouseName#">
					</cfif>
					<cfset item.Street=QGetStreet.stName>
					<cfset ArrayAppend(result,item)>
				</cfif>
			</cfloop>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="SavePriorityOrdering" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QOrders="">
		<cfset result.msg="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"item")>
				<cfquery name="QOrders" datasource="#args.datasource#">
					UPDATE tblOrder
					SET ordPriority = CASE ordID
					<cfloop list="#args.form.item#" delimiters="," index="i">
						<cfset order=StructFind(args.form,"order"&i)>
						WHEN #i# THEN #val(order)#
					</cfloop>
					END
					WHERE ordID IN (#args.form.item#);
				</cfquery>
				<cfset result.msg="Saved">
			</cfif>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

</cfcomponent>