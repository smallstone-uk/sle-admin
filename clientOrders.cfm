<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Paper Orders</title>
	<link rel="stylesheet" type="text/css" href="css/invoice.css"/>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>


	<cffunction name="processOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var del={}>
		<cfset var QOrders="">

		<cfquery name="QOrders" datasource="#site.datasource1#">
			SELECT *
			FROM tblOrder, tblOrderItem, tblPublication
			WHERE ordClientID=#args.clientID#
			AND oiOrderID=ordID
			AND oiPubID=pubID
			ORDER BY pubTitle
		</cfquery>

		<cfset del.mon=0>
		<cfset del.tue=0>
		<cfset del.wed=0>
		<cfset del.thu=0>
		<cfset del.fri=0>
		<cfset del.sat=0>
		<cfset del.sun=0>
		<cfset result.items=[]>		
		<cfset result.orderPerWeek=0>
		<cfset result.orderPerMonth=0>
		<cfloop query="QOrders">
			<cfset item={}>
			<cfset item.class="normal">
			<cfset item.ref=pubRef>
			<cfset item.title=pubTitle>
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

			<cfset item.linePerWeek=oiMon*pubPrice1+oiTue*pubPrice2+oiWed*pubPrice3+oiThu*pubPrice4+oiFri*pubPrice5+oiSat*pubPrice6+oiSun*pubPrice7>
			<cfif item.linePerWeek eq 0><cfset item.class="warning"></cfif>
			<cfset item.linePerMonth=item.linePerWeek*4>
			<cfset result.orderPerWeek=result.orderPerWeek+item.linePerWeek>
			<cfset result.orderPerMonth=result.orderPerMonth+item.linePerMonth>
			
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
		<cfset result.delcount=del.mon+del.tue+del.wed+del.thu+del.fri+del.sat+del.sun>
		<cfif args.delType is "Per Day">
			<cfset result.delPerWeek=result.delcount*args.prices[1]>
			<cfset result.delPerMonth=result.delPerWeek*4>
		<cfelse>
			<cfset result.delPerWeek=0>
			<cfset result.delPerMonth=0>
		</cfif>
		<cfif result.delPerWeek is 0>
			<cfset result.delClass="freedel">
		<cfelse>
			<cfset result.delClass="normal">
		</cfif>
		<cfreturn result>
	</cffunction>
	

<body>
	<p><a href="index.cfm">Home</a></p>
	<cfquery name="QClients" datasource="#site.datasource1#">
		SELECT tblClients.*, stName, delType, delPrice1, delPrice2, delPrice3
		FROM tblClients, tblStreets, tblDelCharges
		WHERE stRef=cltStreetCode
		AND cltDelCode=delCode
		AND cltAge=0
		ORDER BY cltRef
		<!---LIMIT 0,50;--->
	</cfquery>
	<cfset grandWeekOrder=0>
	<cfset grandMonthOrder=0>
	<cfset grandWeekDel=0>
	<cfset grandMonthDel=0>
	<cfset recordcount=0>
	<cfset freeDelivery=0>
	<cfset delCharges={}>
	<cfoutput>
		<table border="1">
			<cfloop query="QClients">
				<cfif NOT StructKeyExists(delCharges,cltDelCode)>
					<cfset StructInsert(delCharges,cltDelCode,{"type"=delType, "price1"=delPrice1, "price2"=delPrice2, "price3"=delPrice3, "count"=1})>
				<cfelse>
					<cfset delKey=StructFind(delCharges,cltDelCode)>
					<cfset delKey.count++>
					<cfset StructUpdate(delCharges,cltDelCode,delKey)>
				</cfif>
				<tr class="clienthead">
					<td>ID</td>
					<td>Ref</td>
					<td>Name</td>
					<td>Address</td>
					<td>Town</td>
					<td>Postcode</td>
					<td>Tel</td>
					<td>Del Code</td>
					<td>Acct Type</td>
					<td>Last Del</td>
					<td>Last Paid</td>
				</tr>
				<tr class="client">
					<td>#cltID#</td>
					<td>#cltRef#</td>
					<td>#cltName#</td>
					<td>#cltDelHouse# #stName#</td>
					<td>#cltDelTown#</td>
					<td>#cltDelPostcode#</td>
					<td>#cltDelTel#</td>
					<td align="center">#cltDelCode#</td>
					<td align="center">#cltAccountType#</td>
					<td>#DateFormat(cltLastDel,"dd-mmm-yyyy")#</td>
					<td>#DateFormat(cltLastPaid,"dd-mmm-yyyy")#</td>
				</tr>
				<tr>
					<td colspan="11">
						<cfset data={}>
						<cfset data.clientID=QClients.cltID>
						<cfset data.delType=QClients.delType>
						<cfset data.prices=[delPrice1, delPrice2, delPrice3]>
						<cfset data.date=Now()>
						<cfset order=processOrder(data)>
						<cfif application.site.showdumps><cfdump var="#order#" label="order" expand="false"></cfif>
						<table border="1">
							<tr>
								<th width="60">Ref</th>
								<th width="200">Title</th>
								<th width="30">Mon</th>
								<th width="30">Tue</th>
								<th width="30">Wed</th>
								<th width="30">Thu</th>
								<th width="30">Fri</th>
								<th width="30">Sat</th>
								<th width="30">Sun</th>
								
								<th width="30">Mon</th>
								<th width="30">Tue</th>
								<th width="30">Wed</th>
								<th width="30">Thu</th>
								<th width="30">Fri</th>
								<th width="30">Sat</th>
								<th width="30">Sun</th>
								<th width="70" align="right">Week Total</th>
								<th width="70" align="right">Month Total</th>
							</tr>
							<cfloop array="#order.items#" index="item">
								<tr class="#item.class#">
									<td align="center">#item.ref#</td>
									<td>#item.title#</td>
									<td align="center">#item.qtymon#</td>
									<td align="center">#item.qtytue#</td>
									<td align="center">#item.qtywed#</td>
									<td align="center">#item.qtythu#</td>
									<td align="center">#item.qtyfri#</td>
									<td align="center">#item.qtysat#</td>
									<td align="center">#item.qtysun#</td>
									
									<td align="center">#item.price1#</td>
									<td align="center">#item.price2#</td>
									<td align="center">#item.price3#</td>
									<td align="center">#item.price4#</td>
									<td align="center">#item.price5#</td>
									<td align="center">#item.price6#</td>
									<td align="center">#item.price7#</td>
									
									<td align="right">&pound;#DecimalFormat(item.linePerWeek)#</td>
									<td align="right">&pound;#DecimalFormat(item.linePerMonth)#</td>
								</tr>
							</cfloop>
							<tr>
								<td align="right" colspan="15">Sub-Total</td>
								<td align="right">&pound;#DecimalFormat(order.voucherPerWeek)#</td>					
								<td align="right">&pound;#DecimalFormat(order.orderPerWeek)#</td>					
								<td align="right">&pound;#DecimalFormat(order.orderPerMonth)#</td>
							</tr>
							<tr class="#order.delClass#">
								<td align="right" colspan="15">#order.delcount# Delivery Charges</td>
								<td></td>
								<td align="right">&pound;#DecimalFormat(order.delPerWeek)#</td>					
								<td align="right">&pound;#DecimalFormat(order.delPerMonth)#</td>
							</tr>
							<tr>
								<td align="right" colspan="15"> Order Total</td>
								<td></td>
								<td align="right">&pound;#DecimalFormat(order.orderPerWeek+order.delPerWeek)#</td>					
								<td align="right">&pound;#DecimalFormat(order.orderPerMonth+order.delPerMonth)#</td>
							</tr>
						</table>
					</td>
				</tr>
				<cfset grandWeekOrder=grandWeekOrder+order.orderPerWeek>
				<cfset grandMonthOrder=grandMonthOrder+order.orderPerMonth>
				<cfset grandWeekDel=grandWeekDel+order.delPerWeek>
				<cfset grandMonthDel=grandMonthDel+order.delPerMonth>
				<cfif order.delPerWeek is 0><cfset freeDelivery++></cfif>
			</cfloop>
			<tr>
				<td colspan="11">
					<table width="100%">
						<tr>
							<td>Clients</td><td>#QClients.recordcount#</td>
							<td align="right">Total Paper Orders Weekly</td><td align="right">&pound;#DecimalFormat(grandWeekOrder)#</td>
							<td align="right">Total Paper Orders Monthly</td><td align="right">&pound;#DecimalFormat(grandMonthOrder)#</td>
						</tr>
						<tr>
							<td>Free Deliveries</td><td>#freeDelivery#</td>
							<td align="right">Total Weekly Deliveries</td><td align="right">&pound;#DecimalFormat(grandWeekDel)#</td>
							<td align="right">Total Monthly Deliveries</td><td align="right">&pound;#DecimalFormat(grandMonthDel)#</td>
						</tr>
					</table>
				</td>
			</tr>
			<cfset keys=ListSort(StructKeyList(delCharges,","),"numeric")>
			<tr>
				<td colspan="11">
					<table width="400">
						<tr>
							<th align="center">key</th>
							<th align="right">price1</th>
							<th align="right">price2</th>
							<th align="right">price3</th>
							<th align="center">type</th>
							<th align="right">count</th>
						</tr>
						<cfset delCount=0>
						<cfloop list="#keys#" index="key">
							<cfset charges=StructFind(delCharges,key)>
							<cfset delCount=delCount+charges.count>
							<tr>
								<td align="center">#key#</td>
								<td align="right">#charges.price1#</td>
								<td align="right">#charges.price2#</td>
								<td align="right">#charges.price3#</td>
								<td align="center">#charges.type#</td>
								<td align="right">#charges.count#</td>
							</tr>
						</cfloop>
						<tr>
							<td align="right" colspan="5">Total Deliveries</td>
							<td align="right">#delCount#</td>
						</tr>
					</table>
				</td>			
			</tr>
		</table>
	</cfoutput>
</body>
</html>