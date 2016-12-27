<cfcomponent displayname="functions" extends="CMSCode/CoreFunctions">

	<cfset this.roundPubs={}>
	<cfset this.charges={}>
	<cfset this.roundTitleCount=0>

	<cffunction name="LoadDelCharges" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var QDelivery=0>
		<cfset var rec={}>
		<cfset var fld=0>
		
		<cfquery name="QDelivery" datasource="#args.datasource#">
			SELECT *
			FROM tblDelCharges
		</cfquery>
		<cfset application.site.delcharges={}>
		<cfloop query="QDelivery">
			<cfset rec={}>
			<cfloop list="#QDelivery.columnlist#" index="fld">
				<cfset "rec.#fld#"=QDelivery[fld][currentrow]>
			</cfloop>
			<cfif NOT StructKeyExists(application.site.delcharges,delCode)>
				<cfset StructInsert(application.site.delcharges,delCode,rec)>
			</cfif>
		</cfloop>
	</cffunction>
	
	<cffunction name="LoadDeliveryCharges" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var QDelivery="">
		
		<cfquery name="QDelivery" datasource="#args.datasource#">
			SELECT *
			FROM tblDelCharges
		</cfquery>
		<cfloop query="QDelivery">
			<cfset item={}>
			<cfset item.ID=delID>
			<cfset item.Code=delCode>
			<cfset item.Price1=delPrice1>
			<cfset item.Price2=delPrice2>
			<cfset item.Price3=delPrice3>
			<cfset item.Type=delType>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="ClientSearch" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var parms={}>
		<cfset var QCustomers="">
		
		<cfset parms.srchRefFrom=0>
		<cfset parms.srchRefTo=0>
		<cfset parms.name="">
		<cfset parms.addr="">
		<cfset parms.type="">
		<cfset parms.srchLastDel="">
		<cfset result.records=0>
		<cfif StructKeyExists(args.search,"srchRefFrom") AND args.search.srchRefFrom gt 0>
			<cfset parms.srchRefFrom=args.search.srchRefFrom>
		</cfif>
		<cfif StructKeyExists(args.search,"srchRefTo") AND args.search.srchRefTo gt 0>
			<cfset parms.srchRefTo=args.search.srchRefTo>
		</cfif>
		<cfif StructKeyExists(args.search,"srchName") AND len(args.search.srchName)>
			<cfset parms.name=args.search.srchName>
		</cfif>
		<cfif StructKeyExists(args.search,"srchAddr") AND len(args.search.srchAddr)>
			<cfset parms.addr=args.search.srchAddr>
		</cfif>
		<cfif StructKeyExists(args.search,"srchType") AND len(args.search.srchType)>
			<cfset parms.type=args.search.srchType>
		</cfif>
		<cfif StructKeyExists(args.search,"srchLastDel") AND len(args.search.srchLastDel)>
			<cfset parms.srchLastDel=args.search.srchLastDel>
		</cfif>
		<cfset parms.sql="SELECT * FROM tblClients WHERE 1=1 ">
		<cfif parms.srchRefFrom gt 0><cfset parms.sql="#parms.sql#AND cltRef>=#parms.srchRefFrom# "></cfif>
		<cfif parms.srchRefTo gt 0><cfset parms.sql="#parms.sql#AND cltRef<=#parms.srchRefTo# "></cfif>
		<cfif parms.name gt 0><cfset parms.sql="#parms.sql#AND cltName LIKE '%#parms.name#%' "></cfif>
		<cfif parms.addr gt 0><cfset parms.sql="#parms.sql#AND (cltDelHouse LIKE '%#parms.addr#%' OR cltDelAddr LIKE '%#parms.addr#%') "></cfif>
		<cfif parms.type gt 0><cfset parms.sql="#parms.sql#AND cltAccountType='#parms.type#' "></cfif>
		<cfif parms.srchLastDel gt 0><cfset parms.sql="#parms.sql#AND cltLastDel>='#parms.srchLastDel#' "></cfif>
		<cfset parms.sql="#parms.sql# ORDER BY #args.search.srchSort#">
		<cfif val(args.search.limitRecs) gt 0><cfset parms.sql="#parms.sql# LIMIT 0,#args.search.limitRecs#; "></cfif>
		<cftry>
			<cfquery name="QCustomers" datasource="#args.datasource#">
				#PreserveSingleQuotes(parms.sql)#
			</cfquery>
			<cfset result.sql=parms.sql>
			<cfset result.rowMax=QCustomers.recordcount>
			<cfset result.records=QCustomers>
		<cfcatch type="any">
			<cfset result.err=cfcatch>
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClient" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=args>
		<cfset var QClient="">

		<cfif StructKeyExists(args,"direction")>
			<cfif args.direction eq "next">
				<cfif result.row lt args.rowMax-1><cfset result.row++></cfif>
			<cfelseif args.direction eq "prev">
				<cfif result.row gt 0><cfset result.row--></cfif>
			<cfelseif args.direction eq "first">
				<cfset result.row=0>
			<cfelseif args.direction eq "last">
				<cfset result.row=args.rowMax-1>
			</cfif>
		</cfif>
		<cfquery name="QClient" datasource="#args.datasource#">
			#PreserveSingleQuotes(args.sql)#
			LIMIT #result.row#,1;
		</cfquery>
		<cfloop list="#QClient.columnlist#" index="fld">
			<cfset "result.rec.#fld#"=QClient[fld]>
		</cfloop>
		<cfset result.row=args.row>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientByID" access="public" returntype="any">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClient="">

		<cfquery name="QClient" datasource="#args.datasource#">
			SELECT *
			FROM tblClients
			WHERE cltID=#args.clientID#
		</cfquery>
		<cfset result=QueryToArrayOfStruct(QClient)>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateClient" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdate="">
		
		<cftry>
			<cfquery name="QUpdate" datasource="#args.datasource#">
				UPDATE tblClients
				SET <cfif len(cltStreetCode)>cltStreetCode=#args.form.cltStreetCode#,<cfelse>cltStreetCode=0,</cfif>
					cltName='#args.form.cltName#',
					cltCompanyName='#args.form.cltCompanyName#',
					cltDelHouse='#args.form.cltDelHouse#',
					cltDelHouseName='#args.form.cltDelHouseName#',
					cltDelHouseNumber='#args.form.cltDelHouseNumber#',
					cltDelTown='#args.form.cltDelTown#',
					cltDelCity='#args.form.cltDelCity#',
					cltDelPostcode='#args.form.cltDelPostcode#',
					cltDelTel='#args.form.cltDelTel#',
					cltAddr1='#args.form.cltAddr1#',
					cltAddr2='#args.form.cltAddr2#',
					cltTown='#args.form.cltTown#',
					cltCity='#args.form.cltCity#',
					cltCounty='#args.form.cltCounty#',
					cltPostCode='#args.form.cltPostCode#',
					cltAccountType='#args.form.cltAccountType#',
					cltPayMethod='#args.form.cltPayMethod#',
					cltDelCode=#args.form.cltDelCode#
				WHERE cltID=#args.form.cltID#
			</cfquery>
			<cfset result.msg="Customer detail have been updated">
			<cfset result.ref=args.form.cltRef>
			<cfset result.stage=2>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddClient" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QAdd="">
		
		<cftry>
			<cfquery name="QAdd" datasource="#args.datasource#">
				INSERT INTO tblClients (
					cltEntered,
					cltRef,
					cltStreetCode,
					cltName,
					cltCompanyName,
					cltDelHouseName,
					cltDelHouseNumber,
					cltDelTown,
					cltDelCity,
					cltDelPostcode,
					cltDelTel,
					cltAddr1,
					cltAddr2,
					cltTown,
					cltCity,
					cltCounty,
					cltPostCode,
					cltAccountType,
					cltPayMethod,
					cltDelCode
				) VALUES (
					#Now()#,
					#args.form.cltRef#,
					#args.form.cltStreetCode#,
					'#args.form.cltName#',
					'#args.form.cltCompanyName#',
					'#args.form.cltDelHouseName#',
					'#args.form.cltDelHouseNumber#',
					'#args.form.cltDelTown#',
					'#args.form.cltDelCity#',
					'#args.form.cltDelPostcode#',
					'#args.form.cltDelTel#',
					'#args.form.cltAddr1#',
					'#args.form.cltAddr2#',
					'#args.form.cltTown#',
					'#args.form.cltCity#',
					'#args.form.cltCounty#',
					'#args.form.cltPostCode#',
					'#args.form.cltAccountType#',
					'#args.form.cltPayMethod#',
					#args.form.cltDelCode#
				)
			</cfquery>
			<cfset result.msg="Customer has been added">
			<cfset result.ref=args.form.cltRef>
			<cfset result.stage=2>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadStreets" access="public" returntype="any">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var QStreets="">
		<cfset var item={}>
		
		<cfquery name="QStreets" datasource="#args.datasource#">
			SELECT *
			FROM tblStreets2
			<cfif StructKeyExists(args,"streetcode")>WHERE stID=#args.streetcode#</cfif>
		</cfquery>
		<cfif QStreets.recordcount is 1>
			<cfset result=QStreets.stName>
		<cfelse>
			<cfloop query="QStreets">
				<cfset item={}>
				<cfset item.ID=stID>
				<cfset item.Name=stName>
				<cfset ArrayAppend(result,item)>
			</cfloop>
		</cfif>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadLastClientRef" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClientRef="">
		
		<cfquery name="QClientRef" datasource="#args.datasource#">
			SELECT * 
			FROM tblClients 
			WHERE cltRef <> 9000
			ORDER BY cltRef desc
			LIMIT 1;
		</cfquery>
		<cfset result.ref=QClientRef.cltRef>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var tran={}>
		
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnClientRef=#val(args.rec.cltRef)#
			ORDER BY trnDate
		</cfquery>
		<cfset result.trans=[]>
		<cfset result.balance=0>
		<cfloop query="QTrans">
			<cfset tran={}>
			<cfset tran.ID=trnID>
			<cfset tran.ref=trnRef>
			<cfset tran.date=DateFormat(trnDate,"dd-mmm-yyyy")>
			<cfset tran.type=trnType>
			<cfset tran.method=trnMethod>
			<cfset tran.amnt1=trnAmnt1>
			<cfset tran.amnt2=trnAmnt2>
			<cfset tran.alloc=trnAlloc>
			<cfif tran.type eq "pay"><cfset tran.paidin=trnPaidIn><cfelse><cfset tran.paidin=""></cfif>
			<cfset ArrayAppend(result.trans,tran)>
			<cfset result.balance=result.balance+trnAmnt1+trnAmnt2>
		</cfloop>
		<cfset result.QTrans=QTrans>
		<cfreturn result>
	</cffunction>

	<cffunction name="GetRoundData" access="public" returntype="array">
		<cfreturn this.roundPubs>
	</cffunction>

	<cffunction name="LoadRoundList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRounds="">
		
		<cfquery name="QRounds" datasource="#args.datasource#">
			SELECT *
			FROM tblRounds
			WHERE rndActive
			<cfif len(args.roundType)>AND rndType='#(args.roundType)#'</cfif>
		</cfquery>
		<cfset result.rounds=[]>
		<cfloop query="QRounds">
			<cfset ArrayAppend(result.rounds,{"rndRef"=#rndRef#, "rndTitle"=#rndTitle#})>
		</cfloop>
		<cfset result.qrounds=QRounds>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadRoundDataForWeek" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRound=0>
		<cfset var QRoundItems=0>
		<cfset var rec={}>
		<cfif application.site.showdumps><cfdump var="#args#" label="LoadRoundDataForWeek" expand="no"></cfif>
		<cfquery name="QRound" datasource="#args.datasource#">
			SELECT *
			FROM tblRounds
			WHERE rndRef=#val(args.roundNo)#
		</cfquery>
		<cfif QRound.recordcount eq 1>
			<cfset result.roundNo=args.roundNo>
			<cfset result.roundName=QRound.rndTitle>
			<cfset result.pubs={}>
			<cfset result.orders=[]>
			<cfquery name="QRoundItems" datasource="#args.datasource#">
				SELECT tblRoundItems.*, cltID,cltRef,cltName,cltDelHouse,cltDelAddr,cltDelCode,cltStreetCode,cltDelPostcode,stName
				FROM tblRoundItems,tblClients, tblStreets
				WHERE riRoundID=#QRound.rndRef#
				AND stRef=cltStreetCode
				AND cltID=riClientID
				AND cltAccountType<>"N"
				ORDER BY riOrder
			</cfquery>
			<cfif application.site.showdumps><cfdump var="#QRoundItems#" label="QRoundItems" expand="false"></cfif>
			<cfloop query="QRoundItems">
				<cfset data={}>
				<cfset data.cltRef=cltRef>
				<cfset data.cltName=cltName>
				<cfset data.cltDelHouse=cltDelHouse>
				<cfset data.cltDelAddr=cltDelAddr>
				<cfset data.stName=stName>
				<cfset data.datasource=args.datasource>
				<cfset data.clientID=cltID>
				<cfset data.cltDelCode=cltDelCode>
				<cfset data.order=processOrder(data)>
				<cfset ArrayAppend(result.orders,data)>
			</cfloop>
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadRoundData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRound=0>
		<cfset var QRoundItems=0>
		<cfset var streetCode=-1>
		<cfset var street={}>
		<cfset var consig=[]>
		<cfif application.site.showdumps><cfdump var="#args#" label="LoadRoundData" expand="no"></cfif>
		<cfquery name="QRound" datasource="#args.datasource#">
			SELECT *
			FROM tblRounds
			WHERE rndRef=#val(args.roundNo)#
		</cfquery>
		<cfif QRound.recordcount eq 1>
			<cfset result.roundNo=args.roundNo>
			<cfset result.roundName=QRound.rndTitle>
			<!---<cfset result.dayNo=args.dayNo>--->

			<cfset result.pubs={}>
			<cfset this.roundPubs={}>
			<cfset this.charges={}>
			<cfset this.roundTitleCount=0>
			<cfquery name="QRoundItems" datasource="#args.datasource#">
				SELECT tblRoundItems.*, cltID,cltRef,cltName,cltDelHouse,cltDelAddr,cltDelCode,cltStreetCode,cltDelPostcode,stName
				FROM tblRoundItems,tblClients, tblStreets
				WHERE riRoundID=#QRound.rndRef#
				AND stRef=cltStreetCode
				AND cltID=riClientID
				AND cltAccountType<>"N"
				ORDER BY riOrder
				<!---LIMIT 0,20;--->
			</cfquery>
			<cfif application.site.showdumps><cfdump var="#QRoundItems#" label="QRoundItems" expand="false"></cfif>
			<cfset result.streets=[]>
			<cfset result.dropCount=0>
			<cfloop query="QRoundItems">
				<cfif cltStreetCode neq streetCode>
					<cfif StructKeyExists(street,"houses")>
						<cfset street.drops=ArrayLen(street.houses)>
						<cfset result.dropCount=result.dropCount+street.drops>
						<cfset ArrayAppend(result.streets,street)>
					</cfif>
					<cfset street={}>
					<cfset street.name=stName>
					<cfset street.houses=[]>
					<cfset streetCode=cltStreetCode>
				</cfif>
				<cfset args.clientID=cltID>
				<cfset args.delCode=cltDelCode>
				<cfset consig=LoadDrops(args)>
				<cfif ArrayLen(consig) gt 0>
					<cfset House=ReReplace(cltDelHouse, '[^0-9A-Za-z ]', '', 'all')>
					<cfset ArrayAppend(street.houses,{
						"Account"=cltRef,
						"HouseID"=cltID,
						"House"=House,
						"Order"=riOrder,
						"ID"=riID,
						"Cons"=consig
					})>
				</cfif>
			</cfloop>
			<cfif StructKeyExists(street,"houses")>
				<cfset street.drops=ArrayLen(street.houses)>
				<cfset result.dropCount=result.dropCount+street.drops>
				<cfset ArrayAppend(result.streets,street)>
			</cfif>
		</cfif>
		<cfset result.pubs=this.roundPubs>
		<cfset result.charges=this.charges>
		<cfset result.roundTitleCount=this.roundTitleCount>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientAddress" access="public" returntype="string">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QAddress="">
							<!--- untidy! --->
			<cfquery name="QAddress" datasource="#args.datasource#">
				SELECT *
				FROM tblClients, tblStreets
				WHERE cltID=#args.clientID#
				AND stRef=cltStreetCode
			</cfquery>
			<cfset House=ReReplace(QAddress.cltDelHouse, '[^0-9A-Za-z ]', '', 'all')>
			<cfset Address=ReReplace(QAddress.cltDelAddr, '[^0-9A-Za-z ]', '', 'all')>
			<cfif len(QAddress.cltDelPostcode)>
				<cfset Postcode=", #ReReplace(QAddress.cltDelPostcode, '[^0-9A-Za-z ]', '', 'all')#">
			<cfelse>
				<cfset Postcode="">
			</cfif>
			<cfset string="#House# #Address##Postcode#">
			<cfset findinfo=Find(string,"truro")>
			<cfif findinfo>
				<cfset result="#House# #Address##Postcode#">
			<cfelse>
				<cfset result="#House# #Address#, Truro#Postcode#">
			</cfif>
			
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SaveDropOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdateRoundItems="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"riID")>
				<cfloop list="#args.form.riID#" index="i" delimiters=",">
					<cfif StructKeyExists(args.form, i)>
						<cfset ID=ListLast(i,"_")>
						<cfset Order=StructFind(args.form, i)>
						<cfquery name="QUpdateRoundItems" datasource="#args.datasource#">
							UPDATE tblRoundItems
							SET riOrder=#Order#
							WHERE riID=#ID#
						</cfquery>
					</cfif>
				</cfloop>
				<cfset result.msg="Order Updated">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="GetCharge" access="private" returntype="numeric" hint="returns the rate to charge for a specific day">
		<cfargument name="delItem" type="numeric" required="yes">
		<cfargument name="dayNo" type="numeric" required="yes">
		<cfset var rate=-0.01>
		<cfset var delRec=StructFind(application.site.delCharges,delItem)>
		<cfif delRec.delType neq "Per Week">
			<cfif dayNo eq 7 AND delRec.delPrice3 gt 0>
				<cfset rate=delRec.delPrice3>
			<cfelseif dayNo eq 6 AND delRec.delPrice2 gt 0>
				<cfset rate=delRec.delPrice2>
			<cfelse>
				<cfset rate=delRec.delPrice1>
			</cfif>
		</cfif>
		<cfreturn rate>
	</cffunction>

	<cffunction name="LoadDrops" access="private" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var QOrders="">
		<cfset var item={}>
		<cfset var pub=0>
		<cfset var itemsAdded=0>
		
		<cfquery name="QOrders" datasource="#args.datasource#">
			SELECT *
			FROM tblOrder, tblOrderItem, tblPublication
			WHERE ordClientID=#val(args.clientID)#
			AND oiOrderID=ordID
			AND oiPubID=pubID
			ORDER BY pubTitle
		</cfquery>
		<cfif args.dayNo gt 0>
			<cfloop query="QOrders">
				<cfset item={}>
				<cfset item.ID=pubID>
				<cfset item.ref=pubRef>
				<cfset item.title=pubTitle>
				<cfset item.delcode=args.delCode>
				<cfset item.qty=0>
				<cfset item.delchg=0>
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
				<cfif item.qty neq 0>
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
				</cfif>
			</cfloop>
			<cfif args.chargeAccts>
				<cfset ChargeAccount(args,result)>
			</cfif>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="ChargeAccount" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="items" type="array" required="yes">
		<cfset var result={}>
		<cfset var pub="">
		<cfset var QExists="">
		<cfset var QBatch="">
		<cfset var QResult="">
		<cfset var batchID=0>
		<cfset var QQuery="">
		<cfquery name="QBatch" datasource="#args.datasource#">
			SELECT *
			FROM tblDelBatch
			WHERE dbRef='#args.roundDate#'
			AND dbRound=#args.roundNo#
			LIMIT 1;
		</cfquery>
		<cfif QBatch.recordcount eq 0>
			<cfquery name="QBatch" datasource="#args.datasource#" result="QResult">
				INSERT INTO tblDelBatch (
				dbRef,dbRound) VALUES ('#args.roundDate#',#args.roundNo#)
			</cfquery>
			<cfset batchID=QResult.generatedKey>
		<cfelse><cfset batchID=QBatch.dbID></cfif>
		
		<cfloop array="#items#" index="pub">
			<cfquery name="QExists" datasource="#args.datasource#">
				SELECT diBatchID
				FROM tblDelItems
				WHERE diClientID=#val(args.clientID)#
				AND diBatchID=#batchID#
				AND diPubID=#pub.ID#
				LIMIT 1;
			</cfquery>
			<cfif QExists.recordcount eq 0>
				<!--- Add Delivery Item--->
				<cfquery name="QQuery" datasource="#args.datasource#">
					INSERT INTO tblDelItems (
						diClientID,
						diBatchID,
						diPubID,
						diDate,
						diQty,
						diPrice,
						diCharge
					) VALUES (
						#val(args.clientID)#,
						#batchID#,
						#pub.ID#,
						'#args.roundDate#',
						#pub.qty#,
						#pub.price#,
						#pub.delchg#
					)
				</cfquery>
			<cfelse>
				<!--- Update Delivery Item --->
				<cfquery name="QQuery" datasource="#args.datasource#">
					UPDATE tblDelItems
					SET
						diQty=#pub.qty#,
						diPrice=#pub.price#,
						diCharge=#pub.delchg#
					WHERE diClientID=#val(args.clientID)#
					AND diBatchID=#batchID#
					AND diPubID=#pub.ID#
				</cfquery>
			</cfif>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadClientDelItems" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelItems="">
		<cfset var item={}>
		<cfquery name="QDelItems" datasource="#args.datasource#">
			SELECT *
			FROM tblDelItems, tblPublication
			WHERE diClientID=#val(args.rec.cltID)#
			AND diPubID=pubID
			ORDER BY diDate ASC
		</cfquery>
		<cfset result.delItems=[]>
		<cfloop query="QDelItems">
			<cfset item={}>
			<cfset item.ID=diID>
			<cfset item.date=diDate>
			<cfset item.price=diPrice>
			<cfset item.qty=diQty>
			<cfif pubArrival gt 0><cfset item.arrival=application.site.days[pubArrival]>
				<cfelse><cfset item.arrival=""></cfif>
			<cfset item.category=pubCategory>
			<cfset item.ref=pubRef>
			<cfset item.title=pubTitle>
			<cfset item.type=pubType>
			<cfset ArrayAppend(result.delItems,item)>
		</cfloop>
		<cfset result.QDelItems=QDelItems>
		<cfreturn result>
	</cffunction>

	<cffunction name="processOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var del={}>
		<cfset var QOrders="">
		<cfset var delCharge={}>

		<cfquery name="QOrders" datasource="#args.datasource#">
			SELECT *
			FROM tblOrder, tblOrderItem, tblPublication, tblPeriods
			WHERE ordClientID=#args.clientID#
			AND oiOrderID=ordID
			AND oiPubID=pubID
			AND perTitle=pubType
			AND pubActive
			<cfif StructKeyExists(args,"pubRef")>AND pubRef='#args.pubRef#'</cfif>
			ORDER BY pubType, pubTitle
		</cfquery>
		<cfif application.site.showdumps><cfdump var="#QOrders#" label="QOrders" expand="no"></cfif>
		<cfset del.mon=0>
		<cfset del.tue=0>
		<cfset del.wed=0>
		<cfset del.thu=0>
		<cfset del.fri=0>
		<cfset del.sat=0>
		<cfset del.sun=0>
		<cfset result.items=[]>		
		<cfset result.orderID=QOrders.ordID>
		<cfset result.orderPerWeek=0>
		<cfset result.orderPerMonth=0>
		<cfset result.voucherPerWeek=0>
		<cfset result.voucherPerMonth=0>
		<cfset result.voucherUser=false>
		<cfloop query="QOrders">
			<cfset item={}>
			<cfset item.class="normal">
			<cfset item.ID=oiID>
			<cfset item.ref=pubRef>
			<cfset item.title=pubTitle>
			<cfset item.arrival=pubArrival>
			<cfset item.type=pubType>
			<cfset item.nextIssue=pubNextIssue>
			<cfset item.arrival=pubArrival>
			<cfset item.discount=pubDiscount>
			<cfset item.multiplier=perInterval>
			<cfset item.voucher=oiVoucher>
			<cfset item.qtymon=oiMon>
			<cfset item.qtytue=oiTue>
			<cfset item.qtywed=oiWed>
			<cfset item.qtythu=oiThu>
			<cfset item.qtyfri=oiFri>
			<cfset item.qtysat=oiSat>
			<cfset item.qtysun=oiSun>
			<cfset item.price1=pubPrice1>							
			<cfset item.price2=pubPrice2>							
			<cfset item.price3=pubPrice3>							
			<cfset item.price4=pubPrice4>							
			<cfset item.price5=pubPrice5>							
			<cfset item.price6=pubPrice6>							
			<cfset item.price7=pubPrice7>							

			<cfset item.voucherPerWeek=0>
			<cfset item.voucherPerMonth=0>
			<cfset item.linePerWeek=0>
			<cfset item.linePerMonth=0>
			<cfif item.voucher>
				<cfset item.voucherPerWeek=oiMon*pubPrice1+oiTue*pubPrice2+oiWed*pubPrice3+oiThu*pubPrice4+oiFri*pubPrice5+oiSat*pubPrice6+oiSun*pubPrice7>
				<cfset item.voucherPerMonth=item.voucherPerWeek*item.multiplier>
				<cfif item.voucherPerWeek eq 0><cfset item.class="warning"></cfif>
				<cfset result.voucherPerWeek=result.voucherPerWeek+item.voucherPerWeek>
				<cfset result.voucherPerMonth=result.voucherPerMonth+item.voucherPerMonth>
				<cfset result.voucherUser=true>
			<cfelse>
				<cfset item.linePerWeek=oiMon*pubPrice1+oiTue*pubPrice2+oiWed*pubPrice3+oiThu*pubPrice4+oiFri*pubPrice5+oiSat*pubPrice6+oiSun*pubPrice7>
				<cfif item.linePerWeek eq 0><cfset item.class="warning"></cfif>
				<cfset item.linePerMonth=item.linePerWeek*item.multiplier>
				<cfset result.orderPerWeek=result.orderPerWeek+item.linePerWeek>
				<cfset result.orderPerMonth=result.orderPerMonth+item.linePerMonth>
			</cfif>
			<!--- count number of deliveries in the week --->
			<cfset del.mon=del.mon || int(oiMon gt 0)>
			<cfset del.tue=del.tue || int(oiTue gt 0)>
			<cfset del.wed=del.wed || int(oiWed gt 0)>
			<cfset del.thu=del.thu || int(oiThu gt 0)>
			<cfset del.fri=del.fri || int(oiFri gt 0)>
			<cfset del.sat=del.sat || int(oiSat gt 0)>
			<cfset del.sun=del.sun || int(oiSun gt 0)>
			
			<!--- add item line to items array --->
			<cfset ArrayAppend(result.items,item)>
		</cfloop>

		<!--- new del charges --->
		<cfset result.delcount=del.mon+del.tue+del.wed+del.thu+del.fri+del.sat+del.sun>
		<cfset delCharge=StructFind(application.site.delCharges,args.cltDelCode)>
		<cfif delCharge.delPrice2 gt 0>
			<!--- variable charges --->
			<cfset result.delPerWeek=delCharge.delPrice1*(del.mon+del.tue+del.wed+del.thu+del.fri)>
			<cfset result.delPerWeek=result.delPerWeek+(del.sat*delCharge.delPrice2)>
			<cfset result.delPerWeek=result.delPerWeek+(del.sun*delCharge.delPrice3)>
		<cfelseif delCharge.delType eq "Per Week">
			<cfset result.delPerWeek=delCharge.delPrice1>
		<cfelse>
			<!--- single charge --->
			<cfset result.delPerWeek=result.delcount*delCharge.delPrice1>
		</cfif>
		<cfset result.delPerMonth=result.delPerWeek*4>
		<cfif result.delPerWeek is 0>
			<cfset result.delClass="freedel">
		<cfelse>
			<cfset result.delClass="normal">
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var Street="">
		<cfset var QCheckClient="">
		<cfset var QClientOrder="">
		<cfset var item={}>
		<cfset var data={}>
		
		<cftry>
			<cfquery name="QCheckClient" datasource="#args.datasource#">
				SELECT tblClients.*, delType, delPrice1, delPrice2, delPrice3
				FROM tblClients, tblDelCharges
				WHERE cltRef=#val(args.rec.cltRef)#
				AND cltDelCode=delCode
				AND cltAge=0
				ORDER BY cltRef
				LIMIT 1;
			</cfquery>
			<cfquery name="Street" datasource="#args.datasource#">
				SELECT *
				FROM tblStreets2
				WHERE stID=#QCheckClient.cltStreetCode#
			</cfquery>
			<cfset result.cltRef=args.rec.cltRef>
			<cfset result.cltID=QCheckClient.cltID>
			<cfset result.cltStreetCode=QCheckClient.cltStreetCode>
			<cfset result.cltName=QCheckClient.cltName>
			<cfset result.cltDelCode=QCheckClient.cltDelCode>
			<cfset result.cltDelHouse=QCheckClient.cltDelHouse>
			<cfset result.cltDelAddr=QCheckClient.cltDelAddr>
			<cfset result.stName=Street.stName>
			<cfset result.order={}>
			<cfif QCheckClient.recordcount is 1>
				<cfset data={}>
				<cfset data.datasource=args.datasource>
				<cfset data.clientID=QCheckClient.cltID>
				<cfset data.cltDelCode=QCheckClient.cltDelCode>
				<cfset data.delType=QCheckClient.delType>
				<cfset data.prices=[QCheckClient.delPrice1, QCheckClient.delPrice2, QCheckClient.delPrice3]>
				<cfset result.order=processOrder(data)>
			<cfelse>
				<cfset result.msg="Specified client record does not exist.">
				<cfset result.order.orderID=0>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientOrder2" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckClient="">
		<cfset var QClientOrder="">
		<cfset var item={}>
		<cfset var data={}>
		
		<cftry>
			<cfquery name="QCheckClient" datasource="#args.datasource#">
				SELECT tblClients.*, stName, delType, delPrice1, delPrice2, delPrice3
				FROM tblClients, tblStreets2, tblDelCharges
				WHERE stID=cltStreetCode
				AND cltDelCode=delCode
				AND cltAge=0
				AND cltRef=#val(args.rec.cltRef)#
				ORDER BY cltRef
				LIMIT 1;
			</cfquery>
			<cfset result.cltRef=args.rec.cltRef>
			<cfset result.cltID=QCheckClient.cltID>
			<cfset result.cltStreetCode=QCheckClient.cltStreetCode>
			<cfset result.cltName=QCheckClient.cltName>
			<cfset result.cltDelCode=QCheckClient.cltDelCode>
			<cfset result.cltDelHouse=QCheckClient.cltDelHouse>
			<cfset result.cltDelAddr=QCheckClient.cltDelAddr>
			<cfset result.stName=QCheckClient.stName>
			<cfset result.order={}>
			<cfif QCheckClient.recordcount is 1>
				<cfset data={}>
				<cfset data.datasource=args.datasource>
				<cfset data.clientID=QCheckClient.cltID>
				<cfset data.cltDelCode=QCheckClient.cltDelCode>
				<cfset data.delType=QCheckClient.delType>
				<cfset data.prices=[QCheckClient.delPrice1, QCheckClient.delPrice2, QCheckClient.delPrice3]>
				<cfset result.order=processOrder(data)>
			<cfelse>
				<cfset result.msg="Specified client record does not exist.">
				<cfset result.order.orderID=0>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddPublicationToOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QAdd="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"oiOrderID")>	
				<cfif args.form.oiOrderID is 0>
					<cfquery name="QCreateOrder" datasource="#args.datasource#">
						INSERT INTO tblOrder (
							ordClientID,
							ordDate
						) VALUES (
							#args.form.oiOrderID#,
							#Now()#
						)
					</cfquery>
				</cfif>
				<cfquery name="QAdd" datasource="#args.datasource#">
					INSERT INTO tblOrderItem (
						oiOrderID,
						oiPubID,
						oiSun,
						oiMon,
						oiTue,
						oiWed,
						oiThu,
						oiFri,
						oiSat
					) VALUES (
						#args.form.oiOrderID#,
						#args.form.oiPubID#,
						#args.form.oiSun#,
						#args.form.oiMon#,
						#args.form.oiTue#,
						#args.form.oiWed#,
						#args.form.oiThu#,
						#args.form.oiFri#,
						#args.form.oiSat#
					)
				</cfquery>
				<cfset result.msg="Publication has been added.">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="RemovePublicationFromOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRemove="">
		
		<cfquery name="QRemove" datasource="#args.datasource#">
			DELETE FROM tblOrderItem
			WHERE oiID=#args.ID#
		</cfquery>
		<cfset result.msg="Publication has been removed.">

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientOrderForDay" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckClient="">
		<cfset var QClientOrder="">
		<cfset var item={}>
		
		<cfquery name="QCheckClient" datasource="#args.datasource#">
			SELECT cltID,cltName,cltDelHouse,cltStreetCode,stName
			FROM tblClients, tblStreets
			WHERE stRef=cltStreetCode
			AND cltRef=#val(args.clientRef)#
			LIMIT 1;
		</cfquery>
		<cfset result.cltRef=args.clientRef>
		<cfset result.cltID=QCheckClient.cltID>
		<cfset result.cltStreetCode=QCheckClient.cltStreetCode>
		<cfset result.cltName=QCheckClient.cltName>
		<cfset result.cltDelHouse=QCheckClient.cltDelHouse>
		<cfset result.stName=QCheckClient.stName>		
		<cfif QCheckClient.recordcount is 1>
			<cfquery name="QOrders" datasource="#args.datasource#">
				SELECT *
				FROM tblOrder, tblOrderItem, tblPublication
				WHERE ordClientID=#result.cltID#
				AND oiOrderID=ordID
				AND oiPubID=pubID
				ORDER BY pubTitle
			</cfquery>
			<cfset result.orderDetails=QOrders>
			<cfset result.roundItems=[]>
			<cfif args.dayNo gt 0>
				<cfloop query="QOrders">
					<cfset item={}>
					<cfset item.title=pubTitle>
					<cfset item.qty=0>
					<cfswitch expression="#args.dayNo#">
						<cfcase value="1">	<!--- sunday --->
							<cfif oiSun neq 0><cfset item.qty=oiSun></cfif>
						</cfcase>
						<cfcase value="2">
							<cfif oiMon neq 0><cfset item.qty=oiMon></cfif>
						</cfcase>
						<cfcase value="3">
							<cfif oiTue neq 0><cfset item.qty=oiTue></cfif>
						</cfcase>
						<cfcase value="4">
							<cfif oiWed neq 0><cfset item.qty=oiWed></cfif>
						</cfcase>
						<cfcase value="5">
							<cfif oiThu neq 0><cfset item.qty=oiThu></cfif>
						</cfcase>
						<cfcase value="6">
							<cfif oiFri neq 0><cfset item.qty=oiFri></cfif>
						</cfcase>
						<cfcase value="7">	<!--- saturday --->
							<cfif oiSat neq 0><cfset item.qty=oiSat></cfif>
						</cfcase>
					</cfswitch>
					<cfif item.qty neq 0>
						<cfset ArrayAppend(result.roundItems,item)>
					</cfif>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset result.msg="Specified client record does not exist.">
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPublications" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var QPublications="">
		
		<cfquery name="QPublications" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE pubActive
			AND pubCategory='NEWS'
			ORDER BY pubTitle asc
		</cfquery>
		<cfloop query="QPublications">
			<cfset item={}>
			<cfset item.ID=pubID>
			<cfset item.Title=pubTitle>
			<cfset item.Cat=pubCategory>
			
			<cfset ArrayAppend(result.list,item)>
		</cfloop>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPublicationOptions" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCategories="">
		<cfset var QTypes="">
		
		<cfset result.types=[]>
		<cfset result.categories=[]>
		<cfquery name="QTypes" datasource="#args.datasource#">
			SELECT pubType
			FROM tblPublication
			WHERE pubType<>''
			GROUP BY pubType
		</cfquery>
		<cfquery name="QCategories" datasource="#args.datasource#">
			SELECT pubCategory
			FROM tblPublication
			WHERE pubCategory<>''
			GROUP BY pubCategory
		</cfquery>
		<cfloop query="QTypes">
			<cfset ArrayAppend(result.types,pubType)>
		</cfloop>
		<cfloop query="QCategories">
			<cfset ArrayAppend(result.categories,pubCategory)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPublicationList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPublications="">
		
		<cfquery name="QPublications" datasource="#args.datasource#">
			SELECT tblPublication.*, (SELECT COUNT(*) FROM tblOrderItem WHERE oiPubID=pubID) as ordCount
			FROM tblPublication
			WHERE 1=1
			<cfif val(args.form.srchRefFrom) gt 0> 
				AND (pubRef>=#val(args.form.srchRefFrom)# AND pubRef<=#val(args.form.srchRefTo)#)
			</cfif>
			<cfif len(args.form.srchTitle) gt 0> AND pubTitle LIKE '%#args.form.srchTitle#%'</cfif>
			<cfif len(args.form.srchCategory) gt 0> AND pubCategory LIKE '%#args.form.srchCategory#%'</cfif>
			<cfif len(args.form.srchType) gt 0> AND pubType='#args.form.srchType#'</cfif>
			<cfif args.form.srchArrival gt 0> AND pubArrival=#args.form.srchArrival#</cfif>
			<cfif len(args.form.srchGroup) gt 0> AND pubGroup='#args.form.srchGroup#'</cfif>
			ORDER BY #args.form.srchSort#
		</cfquery>
		<cfset result.pubs=QPublications>
		<cfreturn result>
	</cffunction>

	<cffunction name="PubOrders" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPub="">
		<cfset var QOrders="">
		<cfset var QOrderItems="">
		<cfset var parms={}>
		<cfset var item={}>
		
		<cfquery name="QPub" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE pubRef=#args.ref#
		</cfquery>
		<cfquery name="QOrderItems" datasource="#args.datasource#">
			SELECT *
			FROM tblOrderItem, tblOrder, tblPublication, tblClients
			WHERE pubRef=#args.ref#
			AND cltID=ordClientID
			AND oiOrderID=ordID
			AND oiPubID=pubID
			AND cltAccountType<>"N"
		</cfquery>
		<cfset result.clientorders=[]>
		<cfset result.totals={}>
		<cfset result.totals.qtymon=0>
		<cfset result.totals.qtytue=0>
		<cfset result.totals.qtywed=0>
		<cfset result.totals.qtythu=0>
		<cfset result.totals.qtyfri=0>
		<cfset result.totals.qtysat=0>
		<cfset result.totals.qtysun=0>
		<cfset result.totals.line=0>
		<cfloop query="QOrderItems">
			<cfset item={}>
			<cfset item.ref=cltRef>
			<cfset item.name=cltName>
			<cfset item.accountType=cltAccountType>
			<cfset item.qtymon=oiMon>
			<cfset item.qtytue=oiTue>
			<cfset item.qtywed=oiWed>
			<cfset item.qtythu=oiThu>
			<cfset item.qtyfri=oiFri>
			<cfset item.qtysat=oiSat>
			<cfset item.qtysun=oiSun>
			<cfset item.linePerWeek=(oiMon*QPub.pubPrice1)+(oiTue*QPub.pubPrice2)+(oiWed*QPub.pubPrice3)+(oiThu*QPub.pubPrice4)+(oiFri*QPub.pubPrice5)
				+(oiSat*QPub.pubPrice6)+(oiSun*QPub.pubPrice7)>
			<cfset ArrayAppend(result.clientorders,item)>
			<cfset result.totals.qtymon=result.totals.qtymon+item.qtymon>
			<cfset result.totals.qtytue=result.totals.qtytue+item.qtytue>
			<cfset result.totals.qtywed=result.totals.qtywed+item.qtywed>
			<cfset result.totals.qtythu=result.totals.qtythu+item.qtythu>
			<cfset result.totals.qtyfri=result.totals.qtyfri+item.qtyfri>
			<cfset result.totals.qtysat=result.totals.qtysat+item.qtysat>
			<cfset result.totals.qtysun=result.totals.qtysun+item.qtysun>
			<cfset result.totals.line=result.totals.line+item.linePerWeek>
		</cfloop>
		<cfset result.pub.ref=QPub.pubRef>
		<cfset result.pub.title=QPub.pubTitle>
		<cfset result.pub.price1=QPub.pubPrice1>
		<cfset result.pub.price2=QPub.pubPrice2>
		<cfset result.pub.price3=QPub.pubPrice3>
		<cfset result.pub.price4=QPub.pubPrice4>
		<cfset result.pub.price5=QPub.pubPrice5>
		<cfset result.pub.price6=QPub.pubPrice6>
		<cfset result.pub.price7=QPub.pubPrice7>
		<cfset result.orderItems=QOrderItems>
		<cfreturn result>
	</cffunction>

	<cffunction name="SavePubs" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var i="">
		<cfset var rec={}>
		<cfset var QPub="">
		<cfif application.site.showdumps><cfdump var="#args#" label="SavePubs" expand="no"></cfif>

		<cfset result.pubRecs=[]>
		
		<cfif StructKeyExists(args.form,"recordCount")>
			<cfloop from="1" to="#args.form.recordCount#" index="i">
				<cfset rec={}>
				<cfset rec.ID=ListGetAt(args.form.ID,i,",")>
				<cfset rec.pubType=ListGetAt(args.form.pubType,i,",")>
				<cfset rec.pubArrival=ListGetAt(args.form.pubArrival,i,",")>
				<cfset rec.pubPrice1=ListGetAt(args.form.pubPrice1,i,",")>
				<cfset rec.pubPrice2=ListGetAt(args.form.pubPrice2,i,",")>
				<cfset rec.pubPrice3=ListGetAt(args.form.pubPrice3,i,",")>
				<cfset rec.pubPrice4=ListGetAt(args.form.pubPrice4,i,",")>
				<cfset rec.pubPrice5=ListGetAt(args.form.pubPrice5,i,",")>
				<cfset rec.pubPrice6=ListGetAt(args.form.pubPrice6,i,",")>
				<cfset rec.pubPrice7=ListGetAt(args.form.pubPrice7,i,",")>
				<cfset ArrayAppend(result.pubRecs,rec)>
				<cfquery name="QPub" datasource="#args.datasource#">
					UPDATE tblPublication
					SET
						pubType='#rec.pubType#',
						pubArrival=#rec.pubArrival#,
						pubPrice1=#rec.pubPrice1#,
						pubPrice2=#rec.pubPrice2#,
						pubPrice3=#rec.pubPrice3#,
						pubPrice4=#rec.pubPrice4#,
						pubPrice5=#rec.pubPrice5#,
						pubPrice6=#rec.pubPrice6#,
						pubPrice7=#rec.pubPrice7#						
					WHERE pubID=#rec.ID#
				</cfquery>
			</cfloop>
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SavePayments" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var setFlag=0>
		<cfset var QResult="">
		<cfset var i=0>
		
		<cfset result.tickList="">
		<cfloop from="1" to="#args.form.tranCount#" index="i">
			<cfif StructKeyExists(args.form,"tick#i#")>
				<cfset result.tickList=ListAppend(result.tickList,StructFind(args.form,"tick#i#"),",")>
			</cfif>
		</cfloop>
		<cfset result.preticked=ListLen(result.tickList,",")>
		<cfif StructKeyExists(args.form,"btnClicked") AND args.form.btnClicked eq "btnSavePayment">
			<cfquery name="QTrans" datasource="#args.datasource#" result="QResult">
				INSERT INTO tblTrans (
					trnClientID,
					trnClientRef,
					trnRef,
					trnDate,
					trnMethod,
					trnType,
					trnAlloc,
					trnAmnt1,
					trnAmnt2
				) VALUES (
					#val(args.form.clientID)#,
					#val(args.form.clientRef)#,
					'#args.form.trnRef#',
					'#LSDateFormat(args.form.trnDate,"yyyy-mm-dd")#',
					<cfif args.form.trnType eq 'pay'>'#args.form.trnMethod#'<cfelse>''</cfif>,
					'#args.form.trnType#',
					#int(result.preticked gt 0)#,
					#-1*val(args.form.trnAmnt1)#,
					#-1*val(args.form.trnAmnt2)#
				)
			</cfquery>
			<cfset result.qresult=qresult>
			<cfset result.tickList=ListAppend(result.tickList,qresult.generatedkey,",")>
		</cfif>
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnClientRef=#val(args.form.clientRef)#
			<cfif NOT StructKeyExists(args.form,"allTrans")>AND trnAlloc=0</cfif>
			ORDER BY trnDate
		</cfquery>
		<cfset result.trans=qtrans>
		<cfloop query="QTrans">
			<cfif result.preticked AND ListFind(result.tickList,trnID,",")>
				<cfset setFlag=1>
			<cfelse><cfset setFlag=0></cfif>
			<cfquery name="QPub" datasource="#args.datasource#">
				UPDATE tblTrans
				SET trnAlloc=#setFlag#
				WHERE trnID=#trnID#
				LIMIT 1;
			</cfquery>				
		</cfloop>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AgedDebtors" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClients=0>
		<cfset var QTrans=0>
		<cfset var item={}>
		<cfset var QResult="">
		<cfset var method=0>
		<cfset var methodItem={}>
		
		<cfset result.clients=[]>		
		<cfquery name="QClients" datasource="#args.datasource#" result="QResult">
			SELECT tblClients.*
			FROM tblClients
			WHERE true
			<cfif len(StructFind(args.form,"srchType"))>AND cltAccountType="#args.form.srchType#"</cfif>
			<cfif len(StructFind(args.form,"srchMethod"))>AND cltPayMethod="#args.form.srchMethod#"</cfif>
			<cfif len(StructFind(args.form,"srchName"))>AND cltName LIKE "%#args.form.srchName#%"</cfif>
			<cfif len(args.form.srchSort)>
				ORDER BY #args.form.srchSort#
			</cfif>
		</cfquery>
		<cfif val(args.form.srchMin) gt 0><cfset minVal=val(args.form.srchMin)>
			<cfelse><cfset minVal=0></cfif>
		<cfset result.QResult=QResult>
		<cfloop query="QClients">
			<cfset item={}>
			<cfset item.methods={}>
			<cfset item.ref=cltRef>
			<cfset item.name=cltName>
			<cfset item.type=cltAccountType>
			<cfset item.methodKey=cltPayMethod>
			<cfset item.balance0=0>
			<cfset item.balance1=0>
			<cfset item.balance2=0>
			<cfset item.balance3=0>
			<cfset item.balance4=0>
			<cfset item.date1=DateAdd("d",-30,Now())>
			<cfquery name="QTrans" datasource="#args.datasource#">
				SELECT *
				FROM tblTrans
				WHERE trnClientRef=#val(item.ref)#
				<!---AND trnAlloc=0--->
				ORDER BY trnDate
			</cfquery>
			<cfloop query="QTrans">
				<cfset item.balance0=item.balance0+trnAmnt1>
				<cfif DateCompare(trnDate,DateAdd("d",-30,Now())) gt 0>
					<cfset item.balance1=item.balance1+trnAmnt1>
				<cfelseif DateCompare(trnDate,DateAdd("d",-60,Now())) gt 0>
					<cfset item.balance2=item.balance2+trnAmnt1>
				<cfelseif DateCompare(trnDate,DateAdd("d",-90,Now())) gt 0>
					<cfset item.balance3=item.balance3+trnAmnt1>
				<cfelse>
					<cfset item.balance4=item.balance4+trnAmnt1>
				</cfif>
				<cfif trnType eq "pay">
					<cfif StructKeyExists(item.methods,trnMethod)>
						<cfset method=StructFind(item.methods,trnMethod)>
						<cfset StructUpdate(item.methods,trnMethod,method+1)>
					<cfelse>
						<cfset StructInsert(item.methods,trnMethod,1)>
					</cfif>
				</cfif>
			</cfloop>
			<cfif StructKeyExists(args.form,"srchUpdate")>
				<cfset method=0>
				<cfloop collection="#item.methods#" item="methodItem">
					<cfif StructFind(item.methods,methodItem) gt method>
						<cfset item.methodKey=methodItem>
					</cfif>
				</cfloop>
				<cfquery name="QTrans" datasource="#args.datasource#">
					UPDATE tblClients
					SET cltPayMethod='#item.methodKey#'
					WHERE cltRef=#cltRef#
				</cfquery>
			</cfif>
			<cfif item.balance0 gt minVal OR minVal eq 0>
				<cfset ArrayAppend(result.clients,item)>
			</cfif>
		</cfloop>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SalesReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClients=0>
		<cfset var QTrans=0>
		<cfset var item={}>
		<cfset var QResult="">

		<cfset result.clients=[]>		
		<cfquery name="QClients" datasource="#args.datasource#" result="QResult">
			SELECT tblClients.*
			FROM tblClients
			WHERE true
			<cfif len(StructFind(args.form,"srchType"))>AND cltAccountType="#args.form.srchType#"</cfif>
			<cfif len(StructFind(args.form,"srchName"))>AND cltName LIKE "%#args.form.srchName#%"</cfif>
			<cfif len(args.form.srchSort)>
				ORDER BY #args.form.srchSort#
			</cfif>
		</cfquery>
		<cfif val(args.form.srchMin) gt 0><cfset minVal=val(args.form.srchMin)>
			<cfelse><cfset minVal=0></cfif>
		<cfset result.QResult=QResult>
		<cfloop query="QClients">
			<cfset item={}>
			<cfset item.ref=cltRef>
			<cfset item.name=cltName>
			<cfset item.type=cltAccountType>
			<cfset item.voucher=GetToken(" ,V",cltVoucher+1,",")>
			<cfset item.balance0=0>
			<cfset item.balance1=0>
			<cfset item.balance2=0>
			<cfset item.balance3=0>
			<cfset item.balance4=0>
			<cfset item.balance5=0>
			<cfset item.balance6=0>
			<cfset item.balance7=0>
			<cfset item.balance8=0>
			<cfset item.balance9=0>
			<cfset item.balance10=0>
			<cfset item.balance11=0>
			<cfset item.balance12=0>
			<cfquery name="QTrans" datasource="#args.datasource#">
				SELECT *
				FROM tblTrans
				WHERE trnClientRef=#val(item.ref)#
				AND trnType IN ('inv','crn')
				ORDER BY trnDate
			</cfquery>
			<cfloop query="QTrans">
				<cfset item.balance0=item.balance0+trnAmnt1>
				<cfswitch expression="#Month(trnDate)#">
					<cfcase value="1"><cfset item.balance1=item.balance1+trnAmnt1></cfcase>
					<cfcase value="2"><cfset item.balance2=item.balance2+trnAmnt1></cfcase>
					<cfcase value="3"><cfset item.balance3=item.balance3+trnAmnt1></cfcase>
					<cfcase value="4"><cfset item.balance4=item.balance4+trnAmnt1></cfcase>
					<cfcase value="5"><cfset item.balance5=item.balance5+trnAmnt1></cfcase>
					<cfcase value="6"><cfset item.balance6=item.balance6+trnAmnt1></cfcase>
					<cfcase value="7"><cfset item.balance7=item.balance7+trnAmnt1></cfcase>
					<cfcase value="8"><cfset item.balance8=item.balance8+trnAmnt1></cfcase>
					<cfcase value="9"><cfset item.balance9=item.balance9+trnAmnt1></cfcase>
					<cfcase value="10"><cfset item.balance10=item.balance10+trnAmnt1></cfcase>
					<cfcase value="11"><cfset item.balance11=item.balance11+trnAmnt1></cfcase>
					<cfcase value="12"><cfset item.balance12=item.balance12+trnAmnt1></cfcase>
				</cfswitch>
			</cfloop>
			<cfset ArrayAppend(result.clients,item)>
		</cfloop>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadPrintList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClient="">
		
		<cftry>
			<cfquery name="QClient" datasource="#args.datasource#">
				SELECT *
				FROM tblRoundItems,tblClients,tblStreets
				WHERE 1
				<cfif len(args.form.type)>AND cltAccountType='#args.form.type#'</cfif>
				<cfif len(args.form.roundID)>AND riRoundRef=#args.form.roundID#</cfif>
				AND stRef=cltStreetCode
				AND cltID=riClientID
				ORDER BY riOrder
			</cfquery>
			<cfset result.list=ArrayNew(1)>
			<cfloop query="QClient">
				<cfset item={}>
				<cfset item.ID=cltID>
				<cfset item.Ref=cltRef>
				<cfset item.Name=cltName>
				<cfset item.Addr1=cltAddr1>
				<cfset item.Addr2=cltAddr2>
				<cfset item.Town=cltTown>
				<cfset item.City=cltCity>
				<cfset item.Postcode=cltPostcode>
				
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
			<cfset result.count=QClient.recordcount>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="PrintStatements" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		
		<cftry>
			<cfif StructKeyExists(args,"client")>
				<cfquery name="QClient" datasource="#args.datasource#">
					SELECT cltID,cltName
					FROM tblClients
					WHERE cltID=#args.client#
				</cfquery>
				<cfset s="#application.site.dir_data#statements/">
				<cfset f="stat_#QClient.cltID#.pdf">
				<cfif FileExists("#s##f#")>
					<cfset result.ID=QClient.cltID>
					<cfset result.Name=QClient.cltName>
					<cfset result.file="#application.site.url_data#statements/#f#">
					<cfset result.status="Ok">
				<cfelse>
					<cfset result.ID=QClient.cltID>
					<cfset result.Name=QClient.cltName>
					<cfset result.file="">
					<cfset result.status="File not found">
				</cfif>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="BuildInvoice" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelItems=0>
		
		<cfquery name="QDelItems" datasource="#args.datasource#">
			SELECT tblDelItems.*, cltID,cltRef,cltName, pubRef,pubTitle
			FROM (tblDelItems, tblClients, tblPublication
			AND diClientID=cltID) 
			AND diPubID=pubID
			WHERE cltID=5031
			ORDER BY diDate;
		</cfquery>
		<cfset result.QDelItems=QDelItems>
		<cfreturn result>
	</cffunction>

</cfcomponent>




