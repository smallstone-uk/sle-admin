<cfcomponent displayname="rounds" extends="core">

	<cffunction name="LoadRoundFiles" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var item={}>
		<cfset var QLoad="">
		
		<cftry>
			<cfquery name="QLoad" datasource="#args.datasource#">
				SELECT dbRef,dbDate
				FROM tblDelBatch
				WHERE 1
				GROUP BY dbRef
				ORDER BY dbRef desc
				LIMIT 7;
			</cfquery>
			<cfloop query="QLoad">
				<cfset item={}>
				<cfset item.Ref=dbRef>
				<cfif len(dbDate)>
					<cfset item.Date=LSDateFormat(dbDate,"DD/MM/YYYY")>
					<cfset item.Time=TimeFormat(dbDate,"HH:mm")>
				<cfelse>
					<cfset item.Date="">
					<cfset item.Time="">
				</cfif>
				<cfset ArrayAppend(result,item)>
			</cfloop>
	
			<cfcatch type="any">
				<cfset ArrayAppend(result,cfcatch)>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadDrop" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDrop="">
		<cfset var QGetStreet="">
		
		<cfquery name="QDrop" datasource="#args.datasource#">
			SELECT *
			FROM tblOrder,tblClients
			WHERE ordID=#args.form.orderID#
			AND ordClientID=cltID
		</cfquery>
		<cfquery name="QGetStreet" datasource="#args.datasource#">
			SELECT *
			<cfif val(QDrop.ordStreetCode) gt 0>
				FROM tblStreets2
				WHERE stID=#QDrop.ordStreetCode#
			<cfelse>
				FROM tblStreets
				WHERE stRef=#QDrop.cltStreetCode#
			</cfif>
		</cfquery>
		<cfset result.ID=QDrop.ordID>
		<cfset result.Client=QDrop.cltID>
		<cfif val(QDrop.ordStreetCode) gt 0>
			<cfset result.name="#QDrop.ordHouseName# #QDrop.ordHouseNumber#">
			<cfset result.Street=QGetStreet.stName>
			<cfset result.Town=QDrop.ordTown>
			<cfset result.Postcode=QDrop.ordPostcode>
		<cfelse>
			<cfset result.name=QDrop.cltDelHouse>
			<cfset result.Street=QGetStreet.stName>
			<cfset result.Town=QDrop.cltDelTown>
			<cfset result.Postcode=QDrop.cltDelPostcode>
		</cfif>

		<cfreturn result>
	</cffunction>
	
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
	
	<cffunction name="LoadRoundInOrder" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var item={}>
		<cfset var QRounds="">
		<cfset var QGetStreet="">
		
		<cftry>
			<cfquery name="QRounds" datasource="#args.datasource#">
				SELECT *
				FROM tblRoundItems,tblClients,tblOrder
				WHERE riRoundID=#args.form.roundID#
				AND riOrderID=ordID
				AND riDay='#args.form.roundDay#'
				AND ordClientID=cltID
				AND cltAccountType<>'N'
				ORDER BY riOrder asc, riID desc
			</cfquery>

			<cfloop query="QRounds">
				<cfquery name="QGetStreet" datasource="#args.datasource#">
					SELECT *
					<cfif val(QRounds.ordStreetCode) gt 0>
						FROM tblStreets2
						WHERE stID=#QRounds.ordStreetCode#
					<cfelse>
						FROM tblStreets
						WHERE stRef=#QRounds.cltStreetCode#
					</cfif>
				</cfquery>
				<cfset item={}>
				<cfset item.ID=riID>
				<cfset item.Ref=cltRef>
				<cfset item.RoundID=riRoundID>
				<cfset item.OrderID=riOrderID>
				<cfset item.Order=riOrder>
				<cfset item.DayName=riDay>
				<cfset item.cltAccountType = cltAccountType>
				<cfif val(QRounds.ordStreetCode) gt 0>
					<cfset item.name="#QRounds.ordHouseName# #QRounds.ordHouseNumber#">
					<cfset item.Street=QGetStreet.stName>
					<cfset item.Town=QRounds.ordTown>
					<cfset item.Postcode=QRounds.ordPostcode>
				<cfelse>
					<cfset item.name=QRounds.cltDelHouse>
					<cfset item.Street=QGetStreet.stName>
					<cfset item.Town=QRounds.cltDelTown>
					<cfset item.Postcode=QRounds.cltDelPostcode>
				</cfif>
				<cfset ArrayAppend(result,item)>
			</cfloop>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="no">
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="SaveRoundOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdate="">
		<cfset var i=0>
		<cfset var order=0>
		
		<cftry>
			<cfif StructKeyExists(args.form,"item")>
				<cfquery name="QUpdate" datasource="#args.datasource#">
					UPDATE tblRoundItems
					SET riOrder = CASE riID <!--- CASE means primary key 'riID'--->
					<cfloop list="#args.form.item#" delimiters="," index="i">
						<cfset order=StructFind(args.form,"order"&i)>
						WHEN #i# THEN #order#
					</cfloop>
					END
					WHERE riID IN (#args.form.item#);	
				</cfquery>
				<cfset result.msg="Done">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
	
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddToRounds" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var i={}>
		<cfset var d=0>
		<cfset var count=0>
		<cfset var itemOrder=0>
		<cfset var item="">
		<cfset var QNew="">
		<cfset var QNewItem="">
		<cfset var QCheck="">
		<cfset var QUpdate="">
		<cfset var QNewOrder="">
		<cfset var ddd="mon">

		<cftry>
			<cfif StructKeyExists(args.form,"AllDays")>
				<cfloop from="1" to="7" index="d">
					<cfif d is 1><cfset ddd="mon"></cfif>
					<cfif d is 2><cfset ddd="tue"></cfif>
					<cfif d is 3><cfset ddd="wed"></cfif>
					<cfif d is 4><cfset ddd="thu"></cfif>
					<cfif d is 5><cfset ddd="fri"></cfif>
					<cfif d is 6><cfset ddd="sat"></cfif>
					<cfif d is 7><cfset ddd="sun"></cfif>
					<cfquery name="QCheck" datasource="#args.datasource#">
						SELECT *
						FROM tblRoundItems
						WHERE riOrderID=#args.form.orderID#
						AND riDay='#ddd#'
						LIMIT 1;
					</cfquery>
					<cfif QCheck.recordcount is 0>
						<cfquery name="QNewItem" datasource="#args.datasource#" result="QNew">
							INSERT INTO tblRoundItems (
								riRoundID,
								riOrderID,
								riOrder,
								riDay
							) Values (
								#args.form.roundID#,
								#args.form.orderID#,
								0,
								'#ddd#'
							)
						</cfquery>
					</cfif>
				</cfloop>
				<cfset result.msg="Done">
			<cfelse>
				<cfquery name="QCheck" datasource="#args.datasource#">
					SELECT *
					FROM tblRoundItems
					WHERE riOrderID=#args.form.orderID#
					AND riDay='#args.form.roundDay#'
					LIMIT 1;
				</cfquery>
				<cfif QCheck.recordcount is 0>
					<cfquery name="QNewItem" datasource="#args.datasource#">
						INSERT INTO tblRoundItems (
							riRoundID,
							riOrderID,
							riOrder,
							riDay
						) Values (
							#args.form.roundID#,
							#args.form.orderID#,
							0,
							'#args.form.roundDay#'
						)
					</cfquery>
					<cfset result.msg="Done">
				<cfelse>
					<cfset result.msg="Already attached to another round on this day">
				</cfif>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.orderID=0>
		<cfset var result.days={}>
		<cfset var result.days.mon={}>
		<cfset var result.days.tue={}>
		<cfset var result.days.wed={}>
		<cfset var result.days.thu={}>
		<cfset var result.days.fri={}>
		<cfset var result.days.sat={}>
		<cfset var result.days.sun={}>
		<cfset var item={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var QRound="">

		<cfquery name="QRound" datasource="#args.datasource#">
			SELECT *
			FROM tblRoundItems,tblRounds
			WHERE riOrderID=#val(args.form.orderID)#
			AND riRoundID=rndID
		</cfquery>
		<cfset result.orderID=val(args.form.orderID)>
		<cfloop query="QRound">
			<cfset item={}>
			<cfset item.ID=riID>
			<cfset item.OrderID=riOrderID>
			<cfset item.RoundID=riRoundID>
			<cfset item.RoundTitle=rndTitle>
			<cfset item.RoundDay=riDay>
			<cfset ArrayAppend(result.list,item)>
			
			<cfif StructKeyExists(result.days,riDay)>
				<cfset StructUpdate(result.days,riDay,item)>
			</cfif>
		</cfloop>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="CheckRound" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRound="">

		<cfquery name="QRound" datasource="#args.datasource#">
			SELECT riID,riRoundID
			FROM tblRoundItems
			WHERE riOrderID=#val(args.form.orderID)#
			AND riRoundID=#val(args.form.roundID)#
			AND riDay='#args.form.roundDay#'
			LIMIT 1;
		</cfquery>
		<cfif QRound.recordcount neq 0>
			<cfset result.ID=QRound.riID>
			<cfset result.roundID=QRound.riRoundID>
		<cfelse>
			<cfset result.ID=0>
			<cfset result.roundID=0>
		</cfif>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="RemoveItemFromRound" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRound="">

		<cftry>
			<cfquery name="QRound" datasource="#args.datasource#">
				DELETE FROM tblRoundItems
				WHERE riID=#val(args.ID)#
			</cfquery>
		
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="RemoveOrderFromRound" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRound="">

		<cfquery name="QRound" datasource="#args.datasource#">
			DELETE FROM tblRoundItems
			WHERE riOrderID=#val(args.form.orderID)#
			AND riRoundID=#val(args.form.roundID)#
		</cfquery>
		<cfset result.msg="Done">

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadRoundDrops" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.rounds=ArrayNew(1)>
		<cfset var street={}>
		<cfset var house={}>
		<cfset var i={}>
		<cfset var ptq={}>
		<cfset var QRound="">
		<cfset var QRoundItems="">
		<cfset var QOrderItems="">
		<cfset var QHolItems="">
		<cfset var QGetStreet="">
		<cfset var QStockCheck="">
		<cfset var QDelCheck="">
		<cfset var dayName="">
		<cfset var streetcode=-1>
		<cfset var roundTotal=0>
		<cfset var roundLine=0>
		<cfset var pubSum=0>
		<cfset var pubLine=0>
		<cfset var pubTotal=0>
		<cfset var AddToRound=true>
		<cfset var hols="">
		<cfset var itemCharges=0>
		<cfset var itemPrice=0>
		<cfset var price=0>
		<cfset var VateRate=0>
		<cfset var Title="">
		<cfset var sortGroup="">
		
		<cftry>
			<cfset dayName=DateFormat(args.form.roundDate,"DDD")>
			<cfset dayDate=DateFormat(args.form.roundDate,"yyyy-mm-dd")>
			<cfset dayYest=DateFormat(DateAdd("d",-1,args.form.roundDate),"yyyy-mm-dd")>
			<cfquery name="QRound" datasource="#args.datasource#">
				SELECT *
				FROM tblRounds
				WHERE rndID IN (#args.roundID#)
				ORDER BY rndRef asc
			</cfquery>
			<cfloop query="QRound">
				<cfset streetcode=-1>
				<cfset roundTotal=0>
				<cfset roundLine=0>
				<cfset pubSum=0>
				<cfset pubLine=0>
				<cfset pubTotal=0>
				
				<cfset r={}>
				<cfset r.roundID=QRound.rndID>
				<cfset r.roundTitle=QRound.rndTitle>
				<cfset r.roundView=QRound.rndView>
				<cfset r.list=[]>
				<cfset r.pubTotalQty={}>
				
				<cfquery name="QRoundItems" datasource="#args.datasource#">
					SELECT *
					FROM tblRoundItems,tblClients,tblOrder
					WHERE riRoundID=#r.roundID#
					AND riOrderID=ordID
					AND riDay='#dayName#'
					AND ordClientID=cltID
					AND (cltAccountType='M' OR cltAccountType='W' OR cltAccountType='C')
					AND ordActive=1
					<cfif StructKeyExists(args,"showRoundOrder")>
						<cfif QRound.rndView is "name">ORDER BY cltName asc, cltCompanyName asc<cfelse>ORDER BY riOrder</cfif>
					<cfelse>
						ORDER BY ordPriority asc
					</cfif>
				</cfquery>
				<cfloop query="QRoundItems">
					<cfquery name="QOrderItems" datasource="#args.datasource#">
						SELECT *
						FROM tblOrderItem,tblPublication
						WHERE oiOrderID=#ordID#
						<cfif StructKeyExists(args.form,"PubSelect")>AND oiPubID IN (#args.form.PubSelect#)</cfif>
						AND oiPubID=pubID
						AND oiStatus='active'
					</cfquery>
					<cfset show=false>
					<cfloop query="QOrderItems">
						<cfif QRoundItems.cltAccountType is "C">
							<cfif QOrderItems.pubGroup is "News">
								<cfset show=true>
							</cfif>
						<cfelse>
							<cfset show=true>
						</cfif>
					</cfloop>
					
					<cfset house={}>
					<cfset house.ID=riID>
					<cfset house.SortOrder=riOrder>
					<cfset house.OpenDay=Evaluate("ord"&dayName)>
					<cfset house.ClientID=ordClientID>
					<cfset house.ClientRef=cltRef>
					<cfif LSDateFormat(cltEntered,"yyyy-mm-dd") gte DateAdd("d",-3,dayDate)>
						<cfset house.new=true>
					<cfelse>
						<cfset house.new=false>
					</cfif>
					<cfset house.OrderID=ordID>
					<cfset house.OrderType=ordType>
					<cfif QRoundItems.cltAccountType is "C">
						<cfset house.pay="Pay on Collect">
					<cfelse>
						<cfset house.pay="">
					</cfif>
					<cfif QRound.rndView is "name">
						<cfset house.number="">
						<cfif len(QRoundItems.cltName) AND len(QRoundItems.cltCompanyName)>
							<cfset house.name="#QRoundItems.cltName#, #QRoundItems.cltCompanyName#">
						<cfelse>
							<cfset house.name="#QRoundItems.cltName##QRoundItems.cltCompanyName#">
						</cfif>
						<cfset house.Town="">
						<cfset house.Postcode="">
					<cfelse>
						<cfif val(QRoundItems.ordStreetCode) gt 0>
							<cfset house.number=QRoundItems.ordHouseNumber>
							<cfset house.name=QRoundItems.ordHouseName>
							<cfset house.Town=QRoundItems.ordTown>
							<cfset house.Postcode=QRoundItems.ordPostcode>
						<cfelse>
							<cfset house.number="">
							<cfset house.name=QRoundItems.cltDelHouse>
							<cfset house.Town=QRoundItems.cltDelTown>
							<cfset house.Postcode=QRoundItems.cltDelPostcode>
						</cfif>
					</cfif>
					<cfset house.items=ArrayNew(1)>
					
					<cfloop query="QOrderItems">
						<cfquery name="QHolItems" datasource="#args.datasource#">
							SELECT *
							FROM tblHolidayOrder,tblHolidayItem
							WHERE hoOrderID=#QOrderItems.oiOrderID#
							AND hiHolidayID=hoID
							AND hiOrderItemID=#QOrderItems.oiID#
							AND hoStop <= '#dayDate#'
							AND (hoStart > '#dayDate#' OR hoStart IS NULL)
							LIMIT 1;
						</cfquery>
						<cfquery name="QHolHoldCheck" datasource="#args.datasource#">
							SELECT *
							FROM tblHolidayOrder,tblHolidayItem
							WHERE hoOrderID=#QOrderItems.oiOrderID#
							AND hiHolidayID=hoID
							AND hiOrderItemID=#QOrderItems.oiID#
							AND hoStart='#dayDate#'
							AND hiAction='hold'
						</cfquery>
						<cfset i={}>
						<cfset i.Issue="">
						<cfset i.ID=oiID>
						<cfset i.pubID=pubID>
						<cfset i.pubGroup=pubGroup>
						<cfif len(pubRoundTitle)>
							<cfset Title=pubRoundTitle>
						<cfelse>
							<cfif len(pubShortTitle)>
								<cfset Title=pubShortTitle>
							<cfelse>
								<cfset Title=pubTitle>
							</cfif>
						</cfif>
						<cfif house.OpenDay is 1>
							<cfif pubGroup is "Magazine">
								<cfquery name="QStockCheck" datasource="#args.datasource#">
									SELECT *
									FROM tblPubStock
									WHERE psPubID=#oiPubID#
									AND psType='received'
									AND psDate >= '#LSDateFormat(DateAdd("d",-4,dayDate),"yyyy-mm-dd")#'
									AND psDate <= '#LSDateFormat(dayDate,"yyyy-mm-dd")#'
									LIMIT 1;
								</cfquery>
								<cfif QStockCheck.recordcount is 1>
									<cfquery name="QDelCheck" datasource="#args.datasource#">
										SELECT *
										FROM tblDelItems
										WHERE diOrderID=#oiOrderID#
										AND diPubID=#oiPubID#
										AND diDate >= '#LSDateFormat(DateAdd("d",-5,dayDate),"yyyy-mm-dd")#'
										LIMIT 1;
									</cfquery>
									<cfif QDelCheck.recordcount is 0>
										<cfset AddToRound=true>
										<cfset i.Issue=QStockCheck.psIssue>
									<cfelse>
										<cfif Year(dayDate) is Year(QDelCheck.diDate)>
											<cfif DateFormat(dayDate,"MMM") is "DEC" AND DateFormat(QDelCheck.diDate,"MMM") neq "DEC">
												<cfset AddToRound=true>
												<cfset i.Issue=QStockCheck.psIssue>
											<cfelse>
												<cfif dayDate is QDelCheck.diDate>
													<cfset AddToRound=true>
													<cfset i.Issue=QStockCheck.psIssue>
												<cfelse>
													<cfset AddToRound=false>
												</cfif>
											</cfif>
										<cfelse>
											<cfset AddToRound=true>
											<cfset i.Issue=QStockCheck.psIssue>
										</cfif>
									</cfif>
								<cfelse>
									<cfset AddToRound=false>
								</cfif>
							<cfelse>
								<cfquery name="QStockCheck" datasource="#args.datasource#">
									SELECT *
									FROM tblPubStock
									WHERE psPubID=#oiPubID#
									AND psType='received'
									AND psDate='#dayDate#'
									LIMIT 1;
								</cfquery>
								<cfset AddToRound=true>
							</cfif>
						<cfelse>
							<cfif pubGroup is "News">
								<cfif dayName is "mon">
									<cfif 1 is 2>
									<cfelseif QRoundItems.ordTue is 1>
										<cfset holdBackStart="Tuesday">
									<cfelseif QRoundItems.ordWed is 1>
										<cfset holdBackStart="Wednesday">
									<cfelseif QRoundItems.ordThu is 1>
										<cfset holdBackStart="Thursday">
									<cfelseif QRoundItems.ordFri is 1>
										<cfset holdBackStart="Friday">
									<cfelseif QRoundItems.ordSat is 1>
										<cfset holdBackStart="Saturday">
									<cfelseif QRoundItems.ordSun is 1>
										<cfset holdBackStart="Sunday">
									<cfelseif QRoundItems.ordMon is 1>
										<cfset holdBackStart="Monday">
									</cfif>
								<cfelseif dayName is "tue">
									<cfif 1 is 2>
									<cfelseif QRoundItems.ordWed is 1>
										<cfset holdBackStart="Wednesday">
									<cfelseif QRoundItems.ordThu is 1>
										<cfset holdBackStart="Thursday">
									<cfelseif QRoundItems.ordFri is 1>
										<cfset holdBackStart="Friday">
									<cfelseif QRoundItems.ordSat is 1>
										<cfset holdBackStart="Saturday">
									<cfelseif QRoundItems.ordSun is 1>
										<cfset holdBackStart="Sunday">
									<cfelseif QRoundItems.ordMon is 1>
										<cfset holdBackStart="Monday">
									<cfelseif QRoundItems.ordTue is 1>
										<cfset holdBackStart="Tuesday">
									</cfif>
								<cfelseif dayName is "wed">
									<cfif 1 is 2>
									<cfelseif QRoundItems.ordThu is 1>
										<cfset holdBackStart="Thursday">
									<cfelseif QRoundItems.ordFri is 1>
										<cfset holdBackStart="Friday">
									<cfelseif QRoundItems.ordSat is 1>
										<cfset holdBackStart="Saturday">
									<cfelseif QRoundItems.ordSun is 1>
										<cfset holdBackStart="Sunday">
									<cfelseif QRoundItems.ordMon is 1>
										<cfset holdBackStart="Monday">
									<cfelseif QRoundItems.ordTue is 1>
										<cfset holdBackStart="Tuesday">
									<cfelseif QRoundItems.ordWed is 1>
										<cfset holdBackStart="Wednesday">
									</cfif>
								<cfelseif dayName is "thu">
									<cfif 1 is 2>
									<cfelseif QRoundItems.ordFri is 1>
										<cfset holdBackStart="Friday">
									<cfelseif QRoundItems.ordSat is 1>
										<cfset holdBackStart="Saturday">
									<cfelseif QRoundItems.ordSun is 1>
										<cfset holdBackStart="Sunday">
									<cfelseif QRoundItems.ordMon is 1>
										<cfset holdBackStart="Monday">
									<cfelseif QRoundItems.ordTue is 1>
										<cfset holdBackStart="Tuesday">
									<cfelseif QRoundItems.ordWed is 1>
										<cfset holdBackStart="Wednesday">
									<cfelseif QRoundItems.ordThu is 1>
										<cfset holdBackStart="Thursday">
									</cfif>
								<cfelseif dayName is "fri">
									<cfif 1 is 2>
									<cfelseif QRoundItems.ordSat is 1>
										<cfset holdBackStart="Saturday">
									<cfelseif QRoundItems.ordSun is 1>
										<cfset holdBackStart="Sunday">
									<cfelseif QRoundItems.ordMon is 1>
										<cfset holdBackStart="Monday">
									<cfelseif QRoundItems.ordTue is 1>
										<cfset holdBackStart="Tuesday">
									<cfelseif QRoundItems.ordWed is 1>
										<cfset holdBackStart="Wednesday">
									<cfelseif QRoundItems.ordThu is 1>
										<cfset holdBackStart="Thursday">
									<cfelseif QRoundItems.ordFri is 1>
										<cfset holdBackStart="Friday">
									</cfif>
								<cfelseif dayName is "sat">
									<cfif 1 is 2>
									<cfelseif QRoundItems.ordSun is 1>
										<cfset holdBackStart="Sunday">
									<cfelseif QRoundItems.ordMon is 1>
										<cfset holdBackStart="Monday">
									<cfelseif QRoundItems.ordTue is 1>
										<cfset holdBackStart="Tuesday">
									<cfelseif QRoundItems.ordWed is 1>
										<cfset holdBackStart="Wednesday">
									<cfelseif QRoundItems.ordThu is 1>
										<cfset holdBackStart="Thursday">
									<cfelseif QRoundItems.ordFri is 1>
										<cfset holdBackStart="Friday">
									<cfelseif QRoundItems.ordSat is 1>
										<cfset holdBackStart="Saturday">
									</cfif>
								<cfelseif dayName is "sun">
									<cfif 1 is 2>
									<cfelseif QRoundItems.ordMon is 1>
										<cfset holdBackStart="Monday">
									<cfelseif QRoundItems.ordTue is 1>
										<cfset holdBackStart="Tuesday">
									<cfelseif QRoundItems.ordWed is 1>
										<cfset holdBackStart="Wednesday">
									<cfelseif QRoundItems.ordThu is 1>
										<cfset holdBackStart="Thursday">
									<cfelseif QRoundItems.ordFri is 1>
										<cfset holdBackStart="Friday">
									<cfelseif QRoundItems.ordSat is 1>
										<cfset holdBackStart="Saturday">
									<cfelseif QRoundItems.ordSun is 1>
										<cfset holdBackStart="Sunday">
									</cfif>
								</cfif>
								<cfset AddToRound=true>
								<cfset i.holiday=true>
								<cfset i.holidayStart=holdBackStart>
								<cfset i.holidayAction="Hold">
								<cfset i.Price=price>
								<cfset i.Charge=1>
							<cfelse>
								<cfset AddToRound=false>
							</cfif>
						</cfif>
						
						<cfif pubGroup is "Magazine">
							<cfset i.Title="#Title# '#QStockCheck.psIssue#'">
						<cfelse>
							<cfset i.Title=Title>
						</cfif>
						
						<cfif QStockCheck.recordcount is 1>
							<cfset price=QStockCheck.psRetail+QStockCheck.psPWRetail>
						<cfelse>
							<cfset price=pubPrice+pubPWPrice>
						</cfif>
						
						<cfif NOT StructKeyExists(i,"holiday")>
							<cfif QHolItems.recordcount is 1>
								<cfset i.holiday=true>
								<cfset i.holidayStop=DateFormat(QHolItems.hoStop,"DD MMM YY")>
								<cfset i.holidayStart=DateFormat(QHolItems.hoStart,"DD MMM YY")>
								<cfset i.holidayAction=QHolItems.hiAction>
								<cfif i.holidayAction is "Cancel">
									<cfset i.Price=price>
									<cfset i.Charge=1>
								<cfelseif i.holidayAction is "Stop">
									<cfset i.Price=0>
									<cfset i.Charge=0>
									<cfif LSDateFormat(dayDate,"yyyy-mm-dd") gte LSDateFormat(i.holidayStop,"yyyy-mm-dd") AND NOT LSDateFormat(dayDate,"yyyy-mm-dd") gt LSDateFormat(DateAdd("d",2,i.holidayStop),"yyyy-mm-dd")>
									<cfelse>
										<cfset AddToRound=false>
									</cfif>
								<cfelse>
									<cfset i.Price=price>
									<cfset i.Charge=1>
								</cfif>
							<cfelse>
								<cfset i.holiday=false>
								<cfset i.holidayStop=DateFormat(QHolHoldCheck.hoStop,"DD MMM YY")>
								<cfset i.holidayStart=DateFormat(QHolHoldCheck.hoStart,"DD MMM YY")>
								<cfset i.holidayAction=QHolHoldCheck.hiAction>
								<cfset i.Price=price>
								<cfset i.Charge=1>
							</cfif>
						</cfif>
						
						<!--------------------- PUB VAT ----------------------->
						<cfset VateRate=StructFind(application.site.Vat,val(pubVATCode))>
						<cfset i.VAT=VateRate>
	
						<cfif pubGroup neq "Magazine">
							<cfswitch expression="#dayName#">
								<cfcase value="sun"><cfif oiSun gte 1 AND AddToRound><cfset i.Qty=oiSun><cfset ArrayAppend(house.items,i)><cfelse><cfset i.Qty=0></cfif></cfcase>
								<cfcase value="mon"><cfif oiMon gte 1 AND AddToRound><cfset i.Qty=oiMon><cfset ArrayAppend(house.items,i)><cfelse><cfset i.Qty=0></cfif></cfcase>
								<cfcase value="tue"><cfif oiTue gte 1 AND AddToRound><cfset i.Qty=oiTue><cfset ArrayAppend(house.items,i)><cfelse><cfset i.Qty=0></cfif></cfcase>
								<cfcase value="wed"><cfif oiWed gte 1 AND AddToRound><cfset i.Qty=oiWed><cfset ArrayAppend(house.items,i)><cfelse><cfset i.Qty=0></cfif></cfcase>
								<cfcase value="thu"><cfif oiThu gte 1 AND AddToRound><cfset i.Qty=oiThu><cfset ArrayAppend(house.items,i)><cfelse><cfset i.Qty=0></cfif></cfcase>
								<cfcase value="fri"><cfif oiFri gte 1 AND AddToRound><cfset i.Qty=oiFri><cfset ArrayAppend(house.items,i)><cfelse><cfset i.Qty=0></cfif></cfcase>
								<cfcase value="sat"><cfif oiSat gte 1 AND AddToRound><cfset i.Qty=oiSat><cfset ArrayAppend(house.items,i)><cfelse><cfset i.Qty=0></cfif></cfcase>
								<cfdefaultcase><cfset i.Qty=0></cfdefaultcase>
							</cfswitch>
						<cfelse>
							<cfset sumQty=oiSun+oiMon+oiTue+oiWed+oiThu+oiFri+oiSat>
							<cfif sumQty gte 1 AND AddToRound>
								<cfset i.Qty=sumQty>
								<cfset ArrayAppend(house.items,i)>
							<cfelse>
								<cfset i.Qty=0>
							</cfif>
						</cfif>
						
						<cfif i.pubGroup is "Magazine">
							<cfset sortGroup="x#i.pubGroup#">
						<cfelse>
							<cfset sortGroup=i.pubGroup>
						</cfif>
											
						<cfif i.Qty neq 0>
							<cfif i.holiday is false>
								<cfif StructKeyExists(r.pubTotalQty,pubID)>
									<cfset ptq=StructFind(r.pubTotalQty,pubID)>
									<cfset ptq.Qty=ptq.Qty+i.Qty>
									<cfset StructUpdate(r.pubTotalQty, pubID, ptq)>
								<cfelse>
									<cfset ptq={}>
									<cfset ptq.ID=pubID>
									<cfset ptq.Sort="#sortGroup##i.Title#">
									<cfset ptq.Title=i.Title>
									<cfset ptq.Qty=i.Qty>
									<cfset StructInsert(r.pubTotalQty,pubID,ptq)>
								</cfif>
							</cfif>
						</cfif>
						
						<cfset pubSum=i.Price*i.Qty>
						<cfset pubLine=pubLine+pubSum>
					</cfloop>
					
					<cfif ArrayLen(house.items)>
						<cfset itemCharges=0>
						<cfset itemPrice=0>
						<cfloop array="#house.items#" index="hols">
							<cfset itemCharges=itemCharges+hols.Charge>
							<cfset itemPrice=itemPrice+hols.Price>
						</cfloop>
						<cfif itemCharges neq 0>
							<cfquery name="QGetCharges" datasource="#args.datasource#">
								SELECT *
								FROM tblDelCharges
								<cfif val(QRoundItems.ordDeliveryCode) gt 0>
									WHERE delCode=#val(QRoundItems.ordDeliveryCode)#
								<cfelse>
									WHERE delCode=#val(QRoundItems.cltDelCode)#
								</cfif>
							</cfquery>
							<cfif QGetCharges.delPrice2 neq 0>
								<cfswitch expression="#dayName#">
									<cfcase value="sat"><cfset house.Charge=QGetCharges.delPrice2></cfcase>
									<cfcase value="sun"><cfset house.Charge=QGetCharges.delPrice3></cfcase>
									<cfdefaultcase><cfset house.Charge=QGetCharges.delPrice1></cfdefaultcase>
								</cfswitch>
							<cfelseif QGetCharges.delType is "Per Day">
								<cfset house.Charge=QGetCharges.delPrice1>
							<cfelseif QGetCharges.delType is "Per Week">
								<cfset house.Charge=QGetCharges.delPrice1/7>
							<cfelse>
								<cfset house.Charge=QGetCharges.delPrice1>
							</cfif>
						<cfelse>
							<cfset house.Charge=0.00>
						</cfif>
						<cfset house.Price=itemPrice>
					<cfelse>
						<cfset house.Charge=0.00>
						<cfset house.Price=0.00>
					</cfif>
					
					<cfif ArrayLen(house.items) OR house.OrderType is "Custom">
						<cfif ArrayLen(house.items) OR args.showRoundOrder>
							<cfquery name="QGetStreet" datasource="#args.datasource#">
								SELECT *
								<cfif val(QRoundItems.ordStreetCode) gt 0>
									FROM tblStreets2
									WHERE stID=#QRoundItems.ordStreetCode#
								<cfelse>
									FROM tblStreets
									WHERE stRef=#QRoundItems.cltStreetCode#
								</cfif>
							</cfquery>
							<cfif val(QRoundItems.ordStreetCode) gt 0>
								<cfif QRoundItems.ordStreetCode neq streetcode>
									<cfset street={}>
									<cfset street.StreetCode=QRoundItems.ordStreetCode>
									<cfset street.StreetName=QGetStreet.stName>
									<cfset streetCode=QRoundItems.ordStreetCode>
									<cfset street.houses=ArrayNew(1)>
									<cfset ArrayAppend(r.list,street)>
								</cfif>
							<cfelse>
								<cfif QRoundItems.cltStreetCode neq streetcode>
									<cfset street={}>
									<cfset street.StreetCode=QRoundItems.cltStreetCode>
									<cfset street.StreetName=QGetStreet.stName>
									<cfset streetCode=QRoundItems.cltStreetCode>
									<cfset street.houses=ArrayNew(1)>
									<cfset ArrayAppend(r.list,street)>
								</cfif>
							</cfif>
						
							<cfset roundLine=roundLine+house.Charge>
							<cfset house.itemCount=ArrayLen(house.items)>
							<cfif show><!--- only show magazines if cltAccountType is C and order has newspapers --->
								<cfset ArrayAppend(street.houses,house)>
							</cfif>
						</cfif>
					</cfif>
					
					<cfset r.pubTotal=DecimalFormat(pubLine)>
					<cfset r.roundTotal=DecimalFormat(roundLine)>
				</cfloop>
				
				<cfset ArrayAppend(result.rounds,r)>
			</cfloop>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="ProcessRounds" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.roundstats=ArrayNew(1)>
		<cfset var result.roundCount={}>
		<cfset var item={}>
		<cfset var rnd={}>
		<cfset var QCheckBatch="">
		<cfset var QCreateBatch="">
		<cfset var QNewBatch="">
		<cfset var QCheckDelItem="">
		<cfset var QCheckCharge="">
		<cfset var QCheckVouchers="">
		<cfset var QAddCharge="">
		<cfset var QUpdateCharge="">
		<cfset var QUpdateBatch="">
		<cfset var QBatchTotal="">
		<cfset var QAdd="">
		<cfset var QCheckCredit="">
		<cfset var QAddCredit="">
		<cfset var BatchRoundID=0>
		<cfset var BatchID=0>
		<cfset var currOrder=0>
		<cfset var chargeLine=0>
		<cfset var chargeAmount=0>
		<cfset var totalprice=0>
		<cfset var totalcharge=0>
		<cfset var chargeAmount=0>
		<cfset var charged=0>
		<cfset var updated=0>
		<cfset var skipped=0>
		<cfset var currOrderNEQ=false>
		
		<cftry>
			<cfif StructKeyExists(args,"list") AND ArrayLen(args.list)>
				<cfloop array="#args.list#" index="item">
					<cfif item.orderID neq 0>
						<cfif BatchRoundID neq item.roundID>
							<cfquery name="QCheckBatch" datasource="#args.datasource#">
								SELECT dbID
								FROM tblDelBatch
								WHERE dbRef='#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#'
								AND dbRound=#val(item.roundID)#
								LIMIT 1;
							</cfquery>
							<cfif QCheckBatch.recordcount is 0>
								<cfquery name="QCreateBatch" datasource="#args.datasource#" result="QNewBatch">
									INSERT INTO tblDelBatch (dbRef,dbRound) VALUES ('#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#',#item.roundID#)
								</cfquery>
								<cfset BatchID=QNewBatch.generatedKey>
								<cfset BatchRoundID=item.roundID>
								<cfset totalprice=0>
								<cfset totalcharge=0>
								<cfset chargeAmount=0>
								<cfset charged=0>
								<cfset updated=0>
								<cfset skipped=0>
							<cfelse>
								<cfset BatchID=QCheckBatch.dbID>
								<cfset BatchRoundID=item.roundID>
								<cfset totalprice=0>
								<cfset totalcharge=0>
								<cfset chargeAmount=0>
								<cfset charged=0>
								<cfset updated=0>
								<cfset skipped=0>
							</cfif>
						</cfif>
						<cfquery name="QCheckDelItem" datasource="#args.datasource#">
							SELECT *
							FROM tblDelItems
							WHERE diOrderID=#item.orderID#
							AND diDate='#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#'
							AND diPubID=#item.pub#
							AND diType='#item.type#'
							LIMIT 1;
						</cfquery>
						<cfif currOrder neq item.orderID>
							<cfquery name="QCheckCharge" datasource="#args.datasource#">
								SELECT *
								FROM tblDelItems
								WHERE diOrderID=#item.orderID#
								AND diDate='#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#'
								AND diType='#item.type#'
								AND diCharge > 0
								LIMIT 1;
							</cfquery>
							<cfif QCheckCharge.recordcount is 0>
								<cfset chargeLine=item.charge>
								<cfset chargeAmount=item.charge>
							<cfelse>
								<cfif QCheckDelItem.diID is QCheckCharge.diID>
									<cfif item.charge is 0>
										<cfset chargeLine=0>
										<cfset chargeAmount=0>
									<cfelse>
										<cfset chargeLine=QCheckCharge.diCharge>
										<cfset chargeAmount=QCheckCharge.diCharge>
									</cfif>
								<cfelse>
									<cfset chargeLine=0>
									<cfset chargeAmount=QCheckCharge.diCharge>
								</cfif>
							</cfif>
							<cfset currOrder=item.orderID>
							<cfif item.price neq 0><cfset currOrderNEQ=true></cfif>
						<cfelse>
							<cfset chargeLine=0>
							<cfset chargeAmount=0>
							<cfset currOrderNEQ=false>
						</cfif>
						<cfquery name="QCheckVouchers" datasource="#args.datasource#">
							SELECT vchID
							FROM tblVoucher
							WHERE vchOrderID=#item.orderID#
							AND vchPubID=#item.pub#
							AND vchStart <= '#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#'
							AND vchStop >= '#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#'
							LIMIT 1;
						</cfquery>
						<cfif QCheckDelItem.recordcount is 0>
							<cfquery name="QAddCharge" datasource="#args.datasource#" result="QAdd">
								INSERT INTO tblDelItems (
									diClientID,diOrderID,diBatchID,diPubID,diIssue,diType,diDatestamp,diDate,diQty,diPrice,diCharge,diVATAmount,diTest,diVoucher
								) VALUES (
									#item.clientID#,#item.orderID#,#BatchID#,#item.pub#,'#item.issue#',
									'#item.type#','#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#','#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#',#item.qty#,#DecimalFormat(item.price)#,#DecimalFormat(chargeLine)#,#item.vat#,#item.test#,#val(QCheckVouchers.vchID)#
								)
							</cfquery>
							<cfif item.holiday>
								<cfquery name="QCheckCredit" datasource="#args.datasource#">
									SELECT *
									FROM tblDelItems
									WHERE diID=#QAdd.generatedKey#
									LIMIT 1;
								</cfquery>
								<cfquery name="QAddCredit" datasource="#args.datasource#">
									INSERT INTO tblDelItems (
										diClientID,diOrderID,diBatchID,diPubID,diIssue,diType,diDatestamp,diDate,diQty,diPrice,diCharge,diVATAmount,diTest,diVoucher,diReason
									) VALUES (
										#QCheckCredit.diClientID#,
										#QCheckCredit.diOrderID#,
										#QCheckCredit.diBatchID#,
										#QCheckCredit.diPubID#,
										'#QCheckCredit.diIssue#',
										'credit',
										'#LSDateFormat(QCheckCredit.diDate,'yyyy-mm-dd')#',
										'#LSDateFormat(QCheckCredit.diDate,'yyyy-mm-dd')#',
										#QCheckCredit.diQty#,
										#DecimalFormat(0-QCheckCredit.diPrice)#,
										#DecimalFormat(0-QCheckCredit.diCharge)#,
										#QCheckCredit.diVATAmount#,
										#QCheckCredit.diTest#,
										#QCheckCredit.diVoucher#,
										'#item.reason#'
									)
								</cfquery>
								<cfset totalprice=totalprice-(QCheckCredit.diPrice*QCheckCredit.diQty)>
								<cfset totalcharge=totalcharge-QCheckCredit.diCharge>
							</cfif>
							<cfset charged=1>
						<cfelse>
							<cfquery name="QUpdateCharge" datasource="#args.datasource#">
								UPDATE tblDelItems
								SET diClientID=#item.clientID#,
									diOrderID=#item.orderID#,
									diBatchID=#BatchID#,
									diPubID=#item.pub#,
									diIssue='#item.issue#',
									diType='#item.type#',
									diDate='#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#',
									diQty=#item.qty#,
									diPrice=#DecimalFormat(item.price)#,
									diCharge=#DecimalFormat(chargeLine)#,
									diVATAmount=#item.vat#,
									diTest=#item.test#,
									diVoucher=#val(QCheckVouchers.vchID)#
								WHERE diID=#QCheckDelItem.diID#
							</cfquery>
							<cfset updated=1>
						</cfif>
						<cfset totalprice=totalprice+(item.price*item.qty)>
						<cfset totalcharge=totalcharge+chargeAmount>
					<cfelse>
						<cfset skipped=1>
					</cfif>
					<cfif currOrderNEQ>
						<cfif StructKeyExists(result.roundCount,item.roundID)>
							<cfset count=StructFind(result.roundCount,item.roundID)>
							<cfset set={}>
							<cfset set.BatchID=BatchID>
							<cfset set.totalprice=totalprice>
							<cfset set.totalcharge=totalcharge>
							<cfset set.charged=count.charged+charged>
							<cfset set.updated=count.updated+updated>
							<cfset set.skipped=count.skipped+skipped>
							<cfset StructUpdate(result.roundCount,item.roundID,set)>
						<cfelse>
							<cfset set={}>
							<cfset set.BatchID=BatchID>
							<cfset set.totalprice=totalprice>
							<cfset set.totalcharge=totalcharge>
							<cfset set.charged=charged>
							<cfset set.updated=updated>
							<cfset set.skipped=skipped>
							<cfset StructInsert(result.roundCount,item.roundID,set)>
						</cfif>
						<cfset currOrderNEQ=false>
					</cfif>
				</cfloop>
				<cfloop collection="#result.roundCount#" item="i">
					<cfset item=StructFind(result.roundCount,i)>
					<cfquery name="QUpdateBatch" datasource="#args.datasource#">
						UPDATE tblDelBatch
						SET dbPubTotal=#item.totalprice#,
							dbDelTotal=#item.totalcharge#,
							dbDate=#Now()#
						WHERE dbID=#item.BatchID#
					</cfquery>
				</cfloop>
				<cfquery name="QBatchTotal" datasource="#args.datasource#">
					SELECT *
					FROM tblDelBatch,tblRounds
					WHERE dbRef='#LSDateFormat(args.form.roundDate,'yyyy-mm-dd')#'
					AND dbRound=rndID
					ORDER BY rndTitle asc
				</cfquery>
				<cfloop query="QBatchTotal">
					<cfset rndCount=StructFind(result.roundCount,rndID)>
					<cfset rnd={}>
					<cfset rnd.Batch=dbID>
					<cfset rnd.RoundID=rndTitle>
					<cfset rnd.PubTotal=dbPubTotal>
					<cfset rnd.DelTotal=dbDelTotal>
					<cfset rnd.charged=rndCount.charged>
					<cfset rnd.updated=rndCount.updated>
					<cfset rnd.skipped=rndCount.skipped>
					<cfset ArrayAppend(result.roundstats,rnd)>
				</cfloop>
			<cfelse>
				<cfset result.msg="Charge array is undefined or is empty">
			</cfif>
							
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadDispatchNote" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.group={}>
		<cfset var item={}>
		<cfset var mag={}>
		<cfset var QOrder="">
		<cfset var QDailys="">
		<cfset var QMags="">
		<cfset var QHolItems="">
		<cfset var QStockCheck="">
		<cfset var QDelCheck="">
		<cfset var pub=0>
		<cfset var tomorrow=LSDateFormat(args.Date,"ddd")>
		<cfset var today=LSDateFormat(args.Date,"yyyy-mm-dd")>
		<cfset var yesterday=LSDateFormat(DateAdd("d",-1,args.Date),"yyyy-mm-dd")>

		<cftry>
			<cfquery name="QOrder" datasource="#args.datasource#">
				SELECT *
				FROM tblOrder,tblClients
				WHERE ordClientID=#val(args.clientID)#
				AND ordActive=1
				AND cltID=#val(args.clientID)#
				LIMIT 1;
			</cfquery>
			<cfif NOT len(QOrder.cltName)>
				<cfset result.ClientName=QOrder.cltCompanyName>
			<cfelse>
				<cfset result.ClientName=QOrder.cltName>
			</cfif>
			<cfset result.list=ArrayNew(1)>
			
			<cfquery name="QDailys" datasource="#args.datasource#">
				SELECT *
				FROM tblOrderItem,tblPublication
				WHERE oiOrderID=#QOrder.ordID#
				AND oiStatus='active'
				AND oi#tomorrow# > 0
				AND oiPubID=pubID
				AND pubGroup='News'
			</cfquery>
			<cfloop query="QDailys">
				<cfquery name="QHolItems" datasource="#args.datasource#">
					SELECT *
					FROM tblHolidayOrder,tblHolidayItem
					WHERE hoOrderID=#QDailys.oiOrderID#
					AND hiHolidayID=hoID
					AND hiOrderItemID=#QDailys.oiID#
					AND hoStop <= '#LSDateFormat(DateAdd("d",1,today),"yyyy-mm-dd")#'
					AND (hoStart > '#LSDateFormat(DateAdd("d",1,today),"yyyy-mm-dd")#' OR hoStart IS NULL)
					LIMIT 1;
				</cfquery>
				<cfif QHolItems.recordcount is 0>
					<cfset item={}>
					<cfset item.sort="#pubGroup##pubType##Left(pubTitle,10)#">
					<cfset item.PubID=pubID>
					<cfset item.group=pubGroup>
					<cfset item.type=pubType>
					<cfset item.title=pubTitle>
					<cfset item.price=pubPrice>
					<cfif StructKeyExists(result.group,item.PubID)>
						<cfset pub=StructFind(result.group,item.PubID)>
						<cfset item.qty=pub.qty+Evaluate("oi#tomorrow#")>
						<cfset StructUpdate(result.group,item.PubID,item)>
					<cfelse>
						<cfset item.qty=Evaluate("oi#tomorrow#")>
						<cfset StructInsert(result.group,item.PubID,item)>
					</cfif>
				</cfif>
			</cfloop>
			<cfquery name="QMags" datasource="#args.datasource#">
				SELECT *
				FROM tblDelItems,tblPublication
				WHERE diClientID=#val(args.clientID)#
				AND diDate='#LSDateFormat(yesterday,"yyyy-mm-dd")#'
				AND diType='debit'
				AND diPubID=pubID
				AND pubGroup='magazine'
			</cfquery>
			<cfloop query="QMags">
				<cfif diClientID neq 6391>
					<cfquery name="QStockCheck" datasource="#args.datasource#">
						SELECT *
						FROM tblPubStock
						WHERE psPubID=#pubID#
						AND psType='received'
						AND psDate >= '#LSDateFormat(DateAdd("d",-4,today),"yyyy-mm-dd")#'
						AND psDate <= '#LSDateFormat(dayDate,"yyyy-mm-dd")#'
						LIMIT 1;
					</cfquery>
					<cfif QStockCheck.recordcount is 1>
						<cfquery name="QDelCheck" datasource="#args.datasource#">
							SELECT *
							FROM tblDelItems
							WHERE diOrderID=#diOrderID#
							AND diPubID=#pubID#
							AND diDate >= '#LSDateFormat(DateAdd("d",-5,today),"yyyy-mm-dd")#'
							LIMIT 1;
						</cfquery>
						<cfif QDelCheck.recordcount is 0>
							<cfset mag={}>
							<cfset mag.sort="x"&"#pubGroup##pubType##Left(pubTitle,10)#">
							<cfset mag.PubID=pubID>
							<cfset mag.group=pubGroup>
							<cfset mag.type=pubType>
							<cfset mag.title=pubTitle>
							<cfset mag.price=diPrice>
							<cfif StructKeyExists(result.group,mag.PubID)>
								<cfset pub=StructFind(result.group,mag.PubID)>
								<cfset mag.qty=pub.qty+diQty>
								<cfset StructUpdate(result.group,mag.PubID,mag)>
							<cfelse>
								<cfset mag.qty=diQty>
								<cfset StructInsert(result.group,mag.PubID,mag)>
							</cfif>
						</cfif>
					</cfif>
				<cfelse>
					<cfset mag={}>
					<cfset mag.sort="x"&"#pubGroup##pubType##Left(pubTitle,10)#">
					<cfset mag.PubID=pubID>
					<cfset mag.group=pubGroup>
					<cfset mag.type=pubType>
					<cfset mag.title=pubTitle>
					<cfset mag.price=diPrice>
					<cfif StructKeyExists(result.group,mag.PubID)>
						<cfset pub=StructFind(result.group,mag.PubID)>
						<cfset mag.qty=pub.qty+diQty>
						<cfset StructUpdate(result.group,mag.PubID,mag)>
					<cfelse>
						<cfset mag.qty=diQty>
						<cfset StructInsert(result.group,mag.PubID,mag)>
					</cfif>
				</cfif>
			</cfloop>
			
			<cfset result.list=StructSort(result.group,"textnocase", "asc","sort")>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
</cfcomponent>

















