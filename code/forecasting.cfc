<cfcomponent displayname="forecasting" extends="functions">

	<cffunction name="ForecastOrders" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var data={}>
		<cfset var item={}>
		<cfset var pubs={}>
		<cfset var custompubs={}>
		<cfset var shopstock={}>
		<cfset var QClients="">
		<cfset var QPubStock="">
		<cfset var QOrderItems="">
		<cfset var QHolidayOrder="">
		<cfset var QHolidayItems="">
		
		<cftry>
			<cfquery name="QClients" datasource="#args.datasource#">
				SELECT *
				FROM tblClients,tblOrder,tblDelCharges,tblStreets2
				WHERE cltAccountType <> 'N'
				AND ordActive=1
				AND cltID=ordClientID
				AND cltDelCode=delCode
				AND stID=cltStreetCode
				<cfif args.limit neq 0>LIMIT #args.limit#;</cfif>
			</cfquery>
			<cfloop query="QClients">
				<cfset data={}>
				<cfset data.datasource=args.datasource>
				<cfset data.clientID=QClients.cltID>
				<cfset data.orderID=QClients.ordID>
				<cfset data.cltDelCode=QClients.cltDelCode>
				<cfset data.delType=QClients.delType>
				<cfset data.prices=[QClients.delPrice1, QClients.delPrice2, QClients.delPrice3]>
				<cfset order=processOrder(data)>
				<cfloop array="#order.list#" index="ord">
					<cfloop array="#ord.items#" index="item">
						<cfif StructKeyExists(pubs,item.pubID)>
							<cfset pub=StructFind(pubs,item.pubID)>
							<cfset set={}>
							<cfset set.sort="#item.group##item.title#">
							<cfset set.ID=item.pubID>
							<cfset set.title=item.title>
							<cfset set.group=item.group>
							<cfset set.saleType=item.SaleType>
							<cfset set.price=item.price>
							<cfset set.stockmon=pub.stockmon>
							<cfset set.stocktue=pub.stocktue>
							<cfset set.stockwed=pub.stockwed>
							<cfset set.stockthu=pub.stockthu>
							<cfset set.stockfri=pub.stockfri>
							<cfset set.stocksat=pub.stocksat>
							<cfset set.stocksun=pub.stocksun>
							<cfset set.mon=pub.mon+item.qtymon>
							<cfset set.tue=pub.tue+item.qtytue>
							<cfset set.wed=pub.wed+item.qtywed>
							<cfset set.thu=pub.thu+item.qtythu>
							<cfset set.fri=pub.fri+item.qtyfri>
							<cfset set.sat=pub.sat+item.qtysat>
							<cfset set.sun=pub.sun+item.qtysun>
<!---							<cfquery name="QHolidayOrder" datasource="#args.datasource#">
								SELECT *
								FROM tblHolidayOrder
								WHERE hoOrderID=#QClients.ordID#
								AND hoStop <= '#LSDateFormat(args.Date,"yyyy-mm-dd")#'
								AND hoStart >= '#LSDateFormat(args.Date,"yyyy-mm-dd")#'
								LIMIT 1;
							</cfquery>
							<cfif QHolidayOrder.recordcount is 1>
								<cfquery name="QHolidayItems" datasource="#args.datasource#">
									SELECT *
									FROM tblHolidayItem
									WHERE hiHolidayID=#QHolidayOrder.hoID#
									AND hiOrderItemID=#item.ID#
									AND hiAction='cancel'
									LIMIT 1;
								</cfquery>
								<cfif QHolidayItems.recordcount is 0>
									<cfset StructUpdate(pubs,item.pubID,set)>
								</cfif>
							<cfelse>
							</cfif>
--->
							<cfset StructUpdate(pubs,item.pubID,set)>
						<cfelse>
							<cfquery name="QPubStock" datasource="#args.datasource#">
								SELECT *
								FROM tblPubStock
								WHERE psPubID=#item.pubID#
								AND psType='received'
								ORDER BY psDate desc
								LIMIT 7;
							</cfquery>
							<cfset set={}>
							<cfset set.stockmon=0>
							<cfset set.stocktue=0>
							<cfset set.stockwed=0>
							<cfset set.stockthu=0>
							<cfset set.stockfri=0>
							<cfset set.stocksat=0>
							<cfset set.stocksun=0>
							<cfset latestmon=0>
							<cfset latesttue=0>
							<cfset latestwed=0>
							<cfset latestthu=0>
							<cfset latestfri=0>
							<cfset latestsat=0>
							<cfset latestsun=0>
							<cfloop query="QPubStock">
								<cfset sdname=LSDateFormat(QPubStock.psDate,"DDD")>
								<cfif sdname is "mon">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestmon>
										<cfset latestmon=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset set.stockmon=QPubStock.psQty>
									</cfif>
								<cfelseif sdname is "tue">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latesttue>
										<cfset latesttue=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset set.stocktue=QPubStock.psQty>
									</cfif>
								<cfelseif sdname is "wed">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestwed>
										<cfset latestwed=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset set.stockwed=QPubStock.psQty>
									</cfif>
								<cfelseif sdname is "thu">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestthu>
										<cfset latestthu=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset set.stockthu=QPubStock.psQty>
									</cfif>
								<cfelseif sdname is "fri">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestfri>
										<cfset latestfri=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset set.stockfri=QPubStock.psQty>
									</cfif>
								<cfelseif sdname is "sat">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestsat>
										<cfset latestsat=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset set.stocksat=QPubStock.psQty>
									</cfif>
								<cfelseif sdname is "sun">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestsun>
										<cfset latestsun=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset set.stocksun=QPubStock.psQty>
									</cfif>
								</cfif>
							</cfloop>
							<cfset set.sort="#item.group##item.title#">
							<cfset set.ID=item.pubID>
							<cfset set.title=item.title>
							<cfset set.group=item.group>
							<cfset set.saleType=item.SaleType>
							<cfset set.price=item.price>
							<cfset set.mon=item.qtymon>
							<cfset set.tue=item.qtytue>
							<cfset set.wed=item.qtywed>
							<cfset set.thu=item.qtythu>
							<cfset set.fri=item.qtyfri>
							<cfset set.sat=item.qtysat>
							<cfset set.sun=item.qtysun>
							<cfset StructInsert(pubs,item.pubID,set)>
						</cfif>
						
						<cfif StructKeyExists(shopstock,item.pubID)>
							<cfset spub=StructFind(shopstock,item.pubID)>
							<cfset shop={}>
							<cfset shop.sort="#item.group##item.title#">
							<cfset shop.ID=item.pubID>
							<cfset shop.title=item.title>
							<cfset shop.group=item.group>
							<cfset shop.saleType=item.SaleType>
							<cfset shop.price=item.price>
							<cfset shop.mon=spub.mon-item.qtymon>
							<cfset shop.tue=spub.tue-item.qtytue>
							<cfset shop.wed=spub.wed-item.qtywed>
							<cfset shop.thu=spub.thu-item.qtythu>
							<cfset shop.fri=spub.fri-item.qtyfri>
							<cfset shop.sat=spub.sat-item.qtysat>
							<cfset shop.sun=spub.sun-item.qtysun>
							<cfset StructUpdate(shopstock,item.pubID,shop)>
						<cfelse>
							<cfquery name="QPubStock" datasource="#args.datasource#">
								SELECT *
								FROM tblPubStock
								WHERE psPubID=#item.pubID#
								AND psType='received'
								ORDER BY psDate desc
								LIMIT 7;
							</cfquery>
							<cfset shop={}>
							<cfset shop.sort="#item.group##item.title#">
							<cfset shop.ID=item.pubID>
							<cfset shop.title=item.title>
							<cfset shop.group=item.group>
							<cfset shop.saleType=item.SaleType>
							<cfset shop.price=item.price>
							<cfset shop.mon=0>
							<cfset shop.tue=0>
							<cfset shop.wed=0>
							<cfset shop.thu=0>
							<cfset shop.fri=0>
							<cfset shop.sat=0>
							<cfset shop.sun=0>
							<cfset latestmon=0>
							<cfset latesttue=0>
							<cfset latestwed=0>
							<cfset latestthu=0>
							<cfset latestfri=0>
							<cfset latestsat=0>
							<cfset latestsun=0>
							<cfloop query="QPubStock">
								<cfset sdname=LSDateFormat(QPubStock.psDate,"DDD")>
								<cfif sdname is "mon">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestmon>
										<cfset latestmon=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset shop.mon=QPubStock.psQty-item.qtymon>
									</cfif>
								<cfelseif sdname is "tue">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latesttue>
										<cfset latesttue=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset shop.tue=QPubStock.psQty-item.qtytue>
									</cfif>
								<cfelseif sdname is "wed">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestwed>
										<cfset latestwed=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset shop.wed=QPubStock.psQty-item.qtywed>
									</cfif>
								<cfelseif sdname is "thu">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestthu>
										<cfset latestthu=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset shop.thu=QPubStock.psQty-item.qtythu>
									</cfif>
								<cfelseif sdname is "fri">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestfri>
										<cfset latestfri=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset shop.fri=QPubStock.psQty-item.qtyfri>
									</cfif>
								<cfelseif sdname is "sat">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestsat>
										<cfset latestsat=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset shop.sat=QPubStock.psQty-item.qtysat>
									</cfif>
								<cfelseif sdname is "sun">
									<cfif LSDateFormat(QPubStock.psDate,"yyyy-mm-dd") gt latestsun>
										<cfset latestsun=LSDateFormat(QPubStock.psDate,"yyyy-mm-dd")>
										<cfset shop.sun=QPubStock.psQty-item.qtysun>
									</cfif>
								</cfif>
							</cfloop>
							<cfset StructInsert(shopstock,item.pubID,shop)>
						</cfif>
					</cfloop>
				</cfloop>
			</cfloop>
			
			<cfquery name="QOrderItems" datasource="#args.datasource#">
				SELECT *
				FROM tblDelItems,tblPublication
				WHERE diOrderID IN (2301,7091,7181) 
				AND diDate >= '#LSDateFormat(DateAdd("d",-7,Now()),"yyyy-mm-dd")#'
				AND diType='debit'
				AND diPubID=pubID
				AND pubGroup='News'
			</cfquery>
			<cfloop query="QOrderItems">
				<cfset dname=LSDateFormat(QOrderItems.diDate,"DDD")>
				<cfif StructKeyExists(custompubs,QOrderItems.diPubID)>
					<cfset pub=StructFind(custompubs,QOrderItems.diPubID)>
					<cfset set={}>
					<cfset set.sort="#QOrderItems.pubGroup##QOrderItems.pubTitle#">
					<cfset set.ID=QOrderItems.pubID>
					<cfset set.title=QOrderItems.pubTitle>
					<cfset set.group=QOrderItems.pubGroup>
					<cfset set.saleType=QOrderItems.pubSaleType>
					<cfset set.price=QOrderItems.pubPrice>
					<cfset set.moncount=pub.moncount>
					<cfset set.tuecount=pub.tuecount>
					<cfset set.wedcount=pub.wedcount>
					<cfset set.thucount=pub.thucount>
					<cfset set.fricount=pub.fricount>
					<cfset set.satcount=pub.satcount>
					<cfset set.suncount=pub.suncount>
					<cfset set.mon=pub.mon>
					<cfset set.tue=pub.tue>
					<cfset set.wed=pub.wed>
					<cfset set.thu=pub.thu>
					<cfset set.fri=pub.fri>
					<cfset set.sat=pub.sat>
					<cfset set.sun=pub.sun>
					<cfif dname is "mon">
						<cfset set.moncount=pub.moncount+1>
						<cfset set.mon=pub.mon+QOrderItems.diQty/set.moncount>
					<cfelseif dname is "tue">
						<cfset set.tuecount=pub.tuecount+1>
						<cfset set.tue=pub.tue+QOrderItems.diQty/set.tuecount>
					<cfelseif dname is "wed">
						<cfset set.wedcount=pub.wedcount+1>
						<cfset set.wed=pub.wed+QOrderItems.diQty/set.wedcount>
					<cfelseif dname is "thu">
						<cfset set.thucount=pub.thucount+1>
						<cfset set.thu=pub.thu+QOrderItems.diQty/set.thucount>
					<cfelseif dname is "fri">
						<cfset set.fricount=pub.fricount+1>
						<cfset set.fri=pub.fri+QOrderItems.diQty/set.fricount>
					<cfelseif dname is "sat">
						<cfset set.satcount=pub.satcount+1>
						<cfset set.sat=pub.sat+QOrderItems.diQty/set.satcount>
					<cfelseif dname is "sun">
						<cfset set.suncount=pub.suncount+1>
						<cfset set.sun=pub.sun+QOrderItems.diQty/set.suncount>
					</cfif>
					<cfset StructUpdate(custompubs,QOrderItems.diPubID,set)>
				<cfelse>
					<cfset set={}>
					<cfset set.sort="#QOrderItems.pubGroup##QOrderItems.pubTitle#">
					<cfset set.ID=QOrderItems.pubID>
					<cfset set.title=QOrderItems.pubTitle>
					<cfset set.group=QOrderItems.pubGroup>
					<cfset set.saleType=QOrderItems.pubSaleType>
					<cfset set.price=QOrderItems.pubPrice>
					<cfset set.moncount=0>
					<cfset set.tuecount=0>
					<cfset set.wedcount=0>
					<cfset set.thucount=0>
					<cfset set.fricount=0>
					<cfset set.satcount=0>
					<cfset set.suncount=0>
					<cfset set.mon=0>
					<cfset set.tue=0>
					<cfset set.wed=0>
					<cfset set.thu=0>
					<cfset set.fri=0>
					<cfset set.sat=0>
					<cfset set.sun=0>
					<cfif dname is "mon">
						<cfset set.moncount=1>
						<cfset set.mon=QOrderItems.diQty/set.moncount>
					<cfelseif dname is "tue">
						<cfset set.tuecount=1>
						<cfset set.tue=QOrderItems.diQty/set.tuecount>
					<cfelseif dname is "wed">
						<cfset set.wedcount=1>
						<cfset set.wed=QOrderItems.diQty/set.wedcount>
					<cfelseif dname is "thu">
						<cfset set.thucount=1>
						<cfset set.thu=QOrderItems.diQty/set.thucount>
					<cfelseif dname is "fri">
						<cfset set.fricount=1>
						<cfset set.fri=QOrderItems.diQty/set.fricount>
					<cfelseif dname is "sat">
						<cfset set.satcount=1>
						<cfset set.sat=QOrderItems.diQty/set.satcount>
					<cfelseif dname is "sun">
						<cfset set.suncount=1>
						<cfset set.sun=QOrderItems.diQty/set.suncount>
					</cfif>
					<cfset StructInsert(custompubs,QOrderItems.diPubID,set)>
				</cfif>
				
				<cfif StructKeyExists(shopstock,QOrderItems.diPubID)>
					<cfset spub=StructFind(shopstock,QOrderItems.diPubID)>
					<cfset shop={}>
					<cfset shop.sort="#QOrderItems.pubGroup##QOrderItems.pubTitle#">
					<cfset shop.ID=QOrderItems.pubID>
					<cfset shop.title=QOrderItems.pubTitle>
					<cfset shop.group=QOrderItems.pubGroup>
					<cfset shop.saleType=QOrderItems.pubSaleType>
					<cfset shop.price=QOrderItems.pubPrice>
					<cfset shop.mon=spub.mon>
					<cfset shop.tue=spub.tue>
					<cfset shop.wed=spub.wed>
					<cfset shop.thu=spub.thu>
					<cfset shop.fri=spub.fri>
					<cfset shop.sat=spub.sat>
					<cfset shop.sun=spub.sun>
					<cfif dname is "mon">
						<cfset shop.mon=spub.mon-set.mon>
					<cfelseif dname is "tue">
						<cfset shop.tue=spub.tue-set.tue>
					<cfelseif dname is "wed">
						<cfset shop.wed=spub.wed-set.wed>
					<cfelseif dname is "thu">
						<cfset shop.thu=spub.thu-set.thu>
					<cfelseif dname is "fri">
						<cfset shop.fri=spub.fri-set.fri>
					<cfelseif dname is "sat">
						<cfset shop.sat=spub.sat-set.sat>
					<cfelseif dname is "sun">
						<cfset shop.sun=spub.sun-set.sun>
					</cfif>
					<cfset StructUpdate(shopstock,QOrderItems.diPubID,shop)>
				<cfelse>
					<cfset shop={}>
					<cfset shop.sort="#QOrderItems.pubGroup##QOrderItems.pubTitle#">
					<cfset shop.ID=QOrderItems.pubID>
					<cfset shop.title=QOrderItems.pubTitle>
					<cfset shop.group=QOrderItems.pubGroup>
					<cfset shop.saleType=QOrderItems.pubSaleType>
					<cfset shop.price=QOrderItems.pubPrice>
					<cfset shop.mon=0>
					<cfset shop.tue=0>
					<cfset shop.wed=0>
					<cfset shop.thu=0>
					<cfset shop.fri=0>
					<cfset shop.sat=0>
					<cfset shop.sun=0>
					<cfif dname is "mon">
						<cfset shop.mon=0-set.mon>
					<cfelseif dname is "tue">
						<cfset shop.tue=0-set.tue>
					<cfelseif dname is "wed">
						<cfset shop.wed=0-set.wed>
					<cfelseif dname is "thu">
						<cfset shop.thu=0-set.thu>
					<cfelseif dname is "fri">
						<cfset shop.fri=0-set.fri>
					<cfelseif dname is "sat">
						<cfset shop.sat=0-set.sat>
					<cfelseif dname is "sun">
						<cfset shop.sun=0-set.sun>
					</cfif>
					<cfset StructInsert(shopstock,QOrderItems.diPubID,shop)>
				</cfif>
			</cfloop>
			
			<cfset result.pubs=pubs>
			<cfset result.custompubs=custompubs>
			<cfset result.shopstock=shopstock>
			<cfset result.sorted=StructSort(pubs,"textnocase","asc","sort")>
			<cfset result.customsorted=StructSort(custompubs,"textnocase","asc","sort")>
			<cfset result.shopsorted=StructSort(shopstock,"textnocase","asc","sort")>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="MagazineOrdersOld" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClients="">
		<cfset var QOrder="">
		<cfset var QRound="">
		<cfset var qty=0>
		<cfset var rset={}>
		<cfset var set={}>
		<cfset var box=true>
			
		<cfset result.rounds={}>
		<cfset result.shopsave={}>
		<cfset result.box={}>
		
		<cftry>
			<cfquery name="QClients" datasource="#args.datasource#">
				SELECT ordID
				FROM tblOrder,tblClients
				WHERE ordActive=1
				AND (cltAccountType='M' OR cltAccountType='W' OR cltAccountType='C')
				AND cltID=ordClientID
			</cfquery>
			<cfloop query="QClients">
				<cfquery name="QRound" datasource="#args.datasource#">
					SELECT *
					FROM tblRoundItems,tblRounds
					WHERE riOrderID=#QClients.ordID#
					AND riRoundID=rndID
					GROUP BY riOrderID
					LIMIT 1;
				</cfquery>
				<cfif QRound.recordcount is 1>
					<cfquery name="QOrder" datasource="#args.datasource#">
						SELECT oiPubID,oiSun,oiMon,oiTue,oiWed,oiThu,oiFri,oiSat, pubTitle,pubGroup
						FROM tblOrderItem,tblPublication
						WHERE oiOrderID=#QClients.ordID#
						AND oiStatus='active'
						AND oiPubID=pubID
					</cfquery>
					<cfset box=true>
					<cfloop query="QOrder">
						<cfif QOrder.pubGroup is "news">
							<cfset box=false>
						</cfif>
					</cfloop>
					<cfloop query="QOrder">
						<cfif QOrder.pubGroup is "magazine">
							<cfset qty=val(QOrder.oiSun)+val(QOrder.oiMon)+val(QOrder.oiTue)+val(QOrder.oiWed)+val(QOrder.oiThu)+val(QOrder.oiFri)+val(QOrder.oiSat)>
										
							<cfset set={}>
							<cfset set.ID=QOrder.oiPubID>
							<cfset set.Title=QOrder.pubTitle>
							<cfset set.Box=box>
							<cfset set.Qty=qty>
							
							<cfif QRound.rndView is "name">
								<cfif box>
									<cfset pubStruct=result.box>
								<cfelse>
									<cfset pubStruct=result.shopsave>
								</cfif>
							<cfelse>
								<cfset pubStruct=result.rounds>
							</cfif>
							<cfif StructKeyExists(pubStruct,set.ID)>
								<cfset pub=StructFind(pubStruct,set.ID)>
								<cfset set.Qty=pub.qty+qty>
								<cfset StructUpdate(pubStruct,set.ID,set)>
							<cfelse>
								<cfset StructInsert(pubStruct,set.ID,set)>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
			
			<cfset result.RoundsSorted=StructSort(result.rounds,"textnocase","asc","title")>
			<cfset result.ShopsaveSorted=StructSort(result.Shopsave,"textnocase","asc","title")>
			<cfset result.boxSorted=StructSort(result.box,"textnocase","asc","title")>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="no"><cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
			
		<cfreturn result>
	</cffunction>

	<cffunction name="MagazineOrders" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QOrderItems" datasource="#args.datasource#">
				SELECT ordID,ordClientID, oiOrderID,oiPubID,oiSun,oiMon,oiTue,oiWed,oiThu,oiFri,oiSat, pubTitle,pubGroup,
					(SELECT riRoundID FROM tblRoundItems WHERE riOrderID=oiOrderID LIMIT 1) AS roundID,
					(SELECT cltRef FROM tblClients WHERE cltID=ordClientID) AS clientRef,
					(SELECT cltAccountType FROM tblClients WHERE cltID=ordClientID) AS AccountType,
					(SELECT rndView FROM tblRounds WHERE rndID=roundID) AS roundView
				FROM tblOrder,tblOrderItem
				INNER JOIN tblPublication ON oiPubID=pubID
				WHERE oiOrderID=ordID
				AND pubGroup='magazine'
				AND oiStatus='active'
				AND ordActive=1
				HAVING AccountType<>'N'
			</cfquery>
			<cfset loc.result.QOrderItems = loc.QOrderItems>
			<cfset loc.result.rounds={}>
			<cfset loc.result.shopsave={}>
			<cfloop query="loc.QOrderItems">
				<cfset loc.set={}>
				<cfset loc.set.ID=oiPubID>
				<cfset loc.set.title=pubTitle>
				<cfset loc.set.qty=val(oiSun)+val(oiMon)+val(oiTue)+val(oiWed)+val(oiThu)+val(oiFri)+val(oiSat)>
				<cfif roundView is "name">
					<cfset loc.bin=loc.result.shopsave>
				<cfelse>
					<cfset loc.bin=loc.result.rounds>
				</cfif>
				<cfif StructKeyExists(loc.bin,loc.set.ID)>
					<cfset loc.pub = StructFind(loc.bin,loc.set.ID)>
					<cfset loc.pub.qty += loc.set.qty>
					<cfset StructUpdate(loc.bin,loc.set.ID,loc.pub)>
				<cfelse>
					<cfset StructInsert(loc.bin,loc.set.ID,loc.set)>
				</cfif>
			</cfloop>
			<cfset loc.result.roundsSorted=StructSort(loc.result.rounds,"textnocase","asc","title")>
			<cfset loc.result.shopsaveSorted=StructSort(loc.result.shopsave,"textnocase","asc","title")>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="CustomersPerPublication" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfquery name="loc.QCustomers" datasource="#args.datasource#" result="loc.result.QQueryResult">
				SELECT pubID,pubTitle,pubGroup,pubPrice, oiStatus,oiSun,oiMon,oiTue,oiWed,oiThu,oiFri,oiSat,
					cltRef,cltTitle,cltInitial,cltName,cltCompanyName,cltAccountType,cltDelHouseName,cltDelHouseNumber, stName
				FROM tblOrderItem 
				INNER JOIN tblOrder ON oiOrderID = ordID
				INNER JOIN tblPublication ON oiPubID = pubID
				INNER JOIN tblClients ON ordClientID = cltID
				INNER JOIN tblStreets2 ON stID = cltStreetCode
				WHERE tblPublication.pubID=#val(args.pubID)#
				AND tblOrderItem.oiStatus="active"
				AND tblClients.cltAccountType NOT IN ('N','H')
				AND ordActive
				ORDER BY pubTitle, cltRef;
			</cfquery>
			<cfset loc.result.QCustomers=loc.QCustomers>
			<cfset loc.result.pubTitle=loc.QCustomers.pubTitle>
			<cfset loc.result.pubGroup=loc.QCustomers.pubGroup>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>