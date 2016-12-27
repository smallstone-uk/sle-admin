<cfcomponent extends="core">

	<cffunction name="FixPubPrices" access="public" returntype="numeric" hint="not used as function but query worked in phpmyadmin">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=0>
		<cfset var thePrice=0>
		<cfset var QPub="">
		
		<cfquery name="QPub" datasource="#args.datasource#"> <!--- set new field to one or other existing field --->
			UPDATE tblPublication
			SET pubPrice = IF(pubType='morning',pubPrice1,pubPrice7)
			WHERE 1;
		</cfquery>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadOrders" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var QOrders="">
		<cfset var item={}>
		
		<cfdump var="#args#" label="LoadOrders" expand="no">
		<cfquery name="QOrders" datasource="#args.datasource#">
			SELECT *
			FROM tblOrder, tblOrderItem, tblPublication
			WHERE ordClientID=#val(args.clientID)#
			AND oiOrderID=ordID
			AND oiPubID=pubID
			ORDER BY pubTitle
		</cfquery>
		<cfloop query="QOrders">
			<cfset item={}>
			<cfset item.ID=pubID>
			<cfset item.ref=pubRef>
			<cfset item.title=pubTitle>
			<cfset item.delcode=args.delCode>
			<cfset item.nextIssue=pubNextIssue>
			<cfset item.type=pubType>
			<cfset item.discount=pubDiscount>
			<cfset item.discType=pubDiscType>
			<cfset item.price=pubPrice>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="xxxxLoadDrops" access="private" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var QOrders="">
		<cfset var QHolidayOrder="">
		<cfset var item={}>
		<cfset var pub=0>
		<cfset var itemsAdded=0>
		<cfset var holidays={}>
		
		<cfquery name="QOrders" datasource="#args.datasource#">
			SELECT *
			FROM tblOrder, tblOrderItem, tblPublication
			WHERE ordClientID=#val(args.clientID)#
			AND oiOrderID=ordID
			AND oiPubID=pubID
			ORDER BY pubTitle
		</cfquery>
		<cfif StructKeyExists(args,"roundDate")>
			<cfquery name="QHolidayOrder" datasource="#args.datasource#">
				SELECT *
				FROM tblHolidayOrder,tblHolidayItem
				WHERE hoOrderID=#val(QOrders.ordID)#
				AND hiHolidayID=hoID
				AND hoStop<='#args.roundDate#'
				AND hoStart>='#args.roundDate#'
			</cfquery>
			<cfif QHolidayOrder.recordcount gt 0>
				<cfloop query="QHolidayOrder">
					<cfset StructInsert(holidays,hiOrderItemID,hiAction)>
				</cfloop>
			</cfif>
		</cfif>
		<cfif args.dayNo gt 0>
			<cfloop query="QOrders">
				<cfset item={}>
				<cfset item.ID=pubID>
				<cfset item.ref=pubRef>
				<cfset item.title=pubTitle>
				<cfset item.delcode=args.delCode>
				<cfset item.qty=0>
				<cfset item.price=0>
				<cfset item.delchg=0>
				<cfif StructKeyExists(holidays,oiID)>
					<cfset item.action=StructFind(holidays,oiID)>
				<cfelse><cfset item.action='deliver'></cfif>
				<cfif item.action NEQ 'cancel'>
					<cfswitch expression="#args.dayNo#">
						<cfcase value="1">	<!--- monday --->
							<cfif oiMon neq 0>
								<cfset item.qty=oiMon>
								<cfset item.price=pubPrice1>
							</cfif>
						</cfcase>
						<cfcase value="2">
							<cfif oiTue neq 0>
								<cfset item.qty=oiTue>
								<cfset item.price=pubPrice2>
							</cfif>
						</cfcase>
						<cfcase value="3">
							<cfif oiWed neq 0>
								<cfset item.qty=oiWed>
								<cfset item.price=pubPrice3>
							</cfif>
						</cfcase>
						<cfcase value="4">
							<cfif oiThu neq 0>
								<cfset item.qty=oiThu>
								<cfset item.price=pubPrice4>
							</cfif>
						</cfcase>
						<cfcase value="5">
							<cfif oiFri neq 0>
								<cfset item.qty=oiFri>
								<cfset item.price=pubPrice5>
							</cfif>
						</cfcase>
						<cfcase value="6">
							<cfif oiSat neq 0>
								<cfset item.qty=oiSat>
								<cfset item.price=pubPrice6>
							</cfif>
						</cfcase>
						<cfcase value="7">	<!--- sunday --->
							<cfif oiSun neq 0>
								<cfset item.qty=oiSun>
								<cfset item.price=pubPrice7>
							</cfif>
						</cfcase>
					</cfswitch>
				</cfif>
				<!---<cfif item.qty neq 0>--->
					<cfset itemsAdded++>
					<cfset item.value=item.qty*item.price>
					<cfset item.trade=item.value*(1-pubDiscount)>
					<cfif NOT StructKeyExists(this.roundPubs,pubTitle)>
						<cfset StructInsert(this.roundPubs,pubTitle,{"qty"=item.qty,"retail"=item.price,"value"=item.value,"trade"=item.trade})>
					<cfelse>
						<cfset pub=StructFind(this.roundPubs,pubTitle)>
						<cfset pub.qty=pub.qty+item.qty>
						<cfset pub.value=pub.value+item.value>
						<cfset pub.trade=pub.trade+item.trade>
						<cfset StructUpdate(this.roundPubs,pubTitle,pub)>
					</cfif>
					<cfset this.roundTitleCount=this.roundTitleCount+item.qty>
					<cfif itemsAdded is 1>
						<cfset item.delchg=GetCharge(args.delCode,args.dayNo)>
						<cfif NOT StructKeyExists(this.charges,args.delCode)>
							<cfset StructInsert(this.charges,args.delCode,{"code"=args.delCode,"rate"=item.delchg,"count"=1,"charge"=item.delchg})>
							<cfset pub=StructFind(this.charges,args.delCode)>
						<cfelse>
							<cfset pub=StructFind(this.charges,args.delCode)>
							<cfset pub.count++>
							<cfset pub.charge=pub.charge+item.delchg>
							<cfset StructUpdate(this.charges,args.delCode,pub)>
						</cfif>
					</cfif>
					<cfset ArrayAppend(result,item)>
				<!---</cfif>--->
			</cfloop>
			<cfif args.chargeAccts>
				<cfset ChargeAccount(args,result)>
			</cfif>
		</cfif>
		<cfreturn result>
	</cffunction>
</cfcomponent>