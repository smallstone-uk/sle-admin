<!DOCTYPE html>
<html>
<head>
	<title>Round Income</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="common/scripts/common.js"></script>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script src="scripts/autoCenter.js" type="text/javascript"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
	<script src="scripts/jquery.tablednd.js"></script>
	<script src="scripts/main.js"></script>
	<script type="text/javascript" src="scripts/checkDates.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, maxDate: new Date, minDate: new Date(2013, 1 - 1, 1)});
			$('#btnSubmit').click(function(e) {
				$('#roundForm').submit();
			});
		});
	</script>
	<style>
		.roundList {border-spacing: 0px;border-collapse: collapse;border-color: #CCC;border: 1px solid #CCC;font-size: 12px;}
		.roundList th {padding:4px; border-color: #ccc;}
		.summaryList {border-spacing: 0px;border-collapse: collapse;border-color: #CCC;border: 1px solid #CCC;font-size: 14px;}
		.summaryList th {padding:4px 5px; border-color: #ccc;}
		.summaryList td {padding:2px 5px; border-color: #ccc;}

		.header td {background-color:#55BFFF; padding:4px 5px;}
		.footer {background-color:#AAFFFF}
		.rndheader {background-color:#55BF55; font-weight:bold; font-size:20px !important}
		.rndfooter td {background-color:#D6FE89; padding:4px 0px; font-weight:bold; font-size:14px !important}
	</style>
</head>
<!---
		<cfset mileage = {}>
		<cfset mileage.east = {miles=12, mpg=28, mph=18, time=120}>
		<cfset mileage.south = {miles=17, mpg=27, mph=17, time=120}>
		<cfset mileage.west = {miles=20, mpg=30, mph=20, time=120}>
		<cfset mileage.sle = {miles=3, mpg=27, mph=20, time=20}>
		<cfset mileage.north = {miles=12, mpg=30, mph=20, time=30}>

3.	Add selective delivery code
4.	Assign new delivery codes to clients
6.	Tidy round totals
7.	Document page
8.	RESTORE LIVE DATA TO EPOS

--->
<cftry>
	<cfparam name="showTrans" default="0">
	<cfparam name="showDumps" default="0">
	<cfparam name="useNewCode" default="0">
	<cfparam name="useSamples" default="0">
	<cfparam name="DeliveryCode" default="">
	<cfparam name="driverRate" default="0.65">
	<cfparam name="fuelRate" default="0.30">
	
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

<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfoutput>
					<form name="roundForm" id="roundForm" method="post">
						<input name="showTrans" type="checkbox" value="1"<cfif showTrans> checked</cfif> /> Show Transactions?<br>
						<input name="showDumps" type="checkbox" value="1"<cfif showDumps> checked</cfif> /> Show Dumps?<br>
						<input name="useNewCode" type="checkbox" value="1"<cfif useNewCode> checked</cfif> /> Use New Delivery Code?<br>
						<input name="useSamples" type="checkbox" value="1"<cfif useSamples> checked</cfif> /> Use Sample Data?<br>
						Select a delivery code to view:-
						<select name="DeliveryCode" data-placeholder="Choose a delivery charge..." class="chargeSelect">
							<option value="">any code</option>
							<cfloop query="QDelRates">
								<option value="#delCode#" <cfif DeliveryCode eq delCode>selected="selected"</cfif>>#delCode# - &pound;#delPrice1#</option>
							</cfloop>
						</select><br>
						<input type="submit" name="btnSubmit" id="btnSubmit" value="View" />
					</form>
				</cfoutput>

				<!---<cfdump var="#QOrigCodeDelCounts#" label="QOrigCodeDelCounts" expand="false">--->

				<cfif StructKeyExists(form,"fieldnames")>
					<cfquery name="QData" datasource="#application.site.datasource1#">
							SELECT rndID,rndRef,rndTitle,rndMileage,
							cltID,cltRef,cltName,cltCompanyName,cltAccountType, 
							ordID,ordHouseName,ordHouseNumber,
							stName,
							delCode,delPrice1,delPrice2,delPrice3,
							pubTitle,pubPrice,pubTradePrice,pubActive,
							ordSun,ordMon,ordTue,ordWed,ordThu,ordFri,ordSat,
							oiSun,oiMon,oiTue,oiWed,oiThu,oiFri,oiSat,
							riOrder
							FROM tblorderitem
							INNER JOIN tblOrder ON ordID=oiOrderID
							INNER JOIN tblClients ON cltID=ordClientID
							INNER JOIN tblStreets2 ON ordStreetCode=stID
							INNER JOIN tblPublication ON pubID=oiPubID
							<cfif useNewCode>
								INNER JOIN tblDelCharges ON ordDelCodeNew=delCode
								<cfif len(form.DeliveryCode)>AND ordDelCodeNew = '#form.DeliveryCode#'</cfif>
							<cfelse>
								INNER JOIN tblDelCharges ON ordDeliveryCode=delCode
								<cfif len(form.DeliveryCode)>AND ordDeliveryCode = '#form.DeliveryCode#'</cfif>
							</cfif>
							INNER JOIN tblrounditems ON riOrderID=ordID
							INNER JOIN tblRounds ON riRoundID=rndID
							WHERE 1
							<cfif useSamples>AND (ordID < 600 OR ordID IN (7121,591))</cfif>
							<!---AND riRoundID=241 --->
							AND oiStatus='active'
							AND ordActive
							AND pubActive
							AND cltAccountType NOT IN ('N','H')
							<!---AND ordStreetCode != 1--->
							AND riDay = 'thu'
							ORDER BY rndRef,riOrder,ordID,pubTitle
					</cfquery>
					<cfif showDumps><cfdump var="#QData#" label="QData" expand="false"></cfif>
					<cfset roundID = 0>
					<cfset orderID = 0>
					<cfset roundData = {}>
					<cfloop query="QData">
						<cfif orderID neq ordID OR (QData.recordcount eq currentrow)>
							<cfif StructKeyExists(variables,"recn")>
								<cfif !StructKeyExists(roundData,recn.rndRef)>
									<cfset StructInsert(roundData,recn.rndRef, {"roundTitle" = recn.rndTitle, "Mileage" = rndMileage, "drops" = []})>
								</cfif>
								<cfset key = StructFind(roundData,recn.rndRef)>
								<cfset ArrayAppend(key.drops,recn)>
								<cfset StructUpdate(roundData,recn.rndRef,key)>
							</cfif>
							<cfset recn = {}>
							<cfset recn.rndID = rndID>
							<cfset recn.rndRef = rndRef>
							<cfset recn.rndTitle = rndTitle>
							<cfset recn.cltID = cltID>
							<cfset recn.cltRef = cltRef>
							<cfset recn.cltName = cltName>
							<cfset recn.cltCompanyName = cltCompanyName>
							<cfset recn.address = "#ordHouseNumber# #ordHouseName# #stName#">
							<cfset recn.cltAccountType = cltAccountType>
							<cfset recn.ordID = ordID>
							<cfset recn.ordSun = ordSun>
							<cfset recn.ordMon = ordMon>
							<cfset recn.ordTue = ordTue>
							<cfset recn.ordWed = ordWed>
							<cfset recn.ordThu = ordThu>
							<cfset recn.ordFri = ordFri>
							<cfset recn.ordSat = ordSat>
							<cfset recn.oiSun = 0>
							<cfset recn.oiMon = 0>
							<cfset recn.oiTue = 0>
							<cfset recn.oiWed = 0>
							<cfset recn.oiThu = 0>
							<cfset recn.oiFri = 0>
							<cfset recn.oiSat = 0>
							<cfset recn.pubs = []>
						</cfif>
						<cfset recn.delPrice1 = delPrice1>
						<cfset recn.delPrice2 = delPrice2>
						<cfset recn.delPrice3 = delPrice3>
						<cfset recn.delCode = delCode>
						<cfset ArrayAppend(recn.pubs, {
							pubTitle = pubTitle,
							pubPrice = pubPrice,
							pubTradePrice = pubTradePrice,
							pubProfit = pubPrice - pubTradePrice,
							oiSun = oiSun,
							oiMon = oiMon,
							oiTue = oiTue,
							oiWed = oiWed,
							oiThu = oiThu,
							oiFri = oiFri,
							oiSat = oiSat
						})>
						<cfset orderID = ordID>
						<cfset roundID = rndID>
					</cfloop>
					<cfif showDumps><cfdump var="#roundData#" label="roundData 1st pass" expand="false"></cfif>
					<cfoutput>
						<table class="roundList" border="1">
							<cfset iKeys = ListSort(StructKeyList(roundData,","),"text","asc")>
							<cfloop list="#iKeys#" index="key">
								<cfset item = StructFind(roundData,key)>
								<cfset item.pubRetail = 0>
								<cfset item.pubTrade = 0>
								<cfset item.pubProfit = 0>
								<cfset item.charges = 0>							 
								<cfset item.pubQty = 0>
								<cfset item.dropQty = 0>
								<cfset item.days = {}>
								<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="day">
									<cfset StructInsert(item.days,day,{
											Retail = 0,
											Profit = 0,
											Charge = 0
									})>
								</cfloop>
								<cfif showTrans>
									<tr>
										<th class="rndheader">#key#</th>
										<th colspan="16" class="rndheader">#item.roundTitle#</th>
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
										<th width="20" align="center">Qty Weekly</th>
										<th width="40" align="right">Retail Value</th>
										<th width="40" align="right">Trade Total</th>
										<th width="40" align="right">Profit</th>
										<th width="40" align="right">Delivery</th>
										<th width="40" align="right">Total</th>
									</tr>
								</cfif>
								<cfloop array="#item.drops#" index="drop">
									<cfif showTrans>
										<tr class="header">
											<td><a href="clientDetails.cfm?row=0&ref=#drop.cltRef#" target="_new">#drop.cltRef#</a></td>
											<td>#drop.cltName#</td>
											<td colspan="6">#drop.address#</td>
											<td align="center">#drop.cltAccountType#</td>
											<td>#drop.delCode#</td>
											<td>#drop.delPrice1#</td>
											<td>#drop.delPrice2#</td>
											<td>#drop.delPrice3#</td>
											<td colspan="4">#drop.ordID#</td>
										</tr>
									</cfif>
									<cfset item.dropQty++>
									<cfset drop.pubWeekly = 0>
									<cfset drop.pubTradeWeekly = 0>
									<cfset drop.pubProfit = 0>
									<cfset ipubQty = 0>
									<cfloop array="#drop.pubs#" index="pub">
										<cfset iqtyWeekly = pub.oiSun+pub.oiMon+pub.oiTue+pub.oiWed+pub.oiThu+pub.oiFri+pub.oiSat>
										<cfset ipubRetail = iqtyWeekly * pub.pubPrice>
										<cfset ipubTrade = iqtyWeekly * pub.pubTradePrice>
										<cfset ipubProfit = iqtyWeekly * pub.pubProfit>
										<cfset ipubQty += iqtyWeekly>
										
										<cfset drop.pubWeekly += ipubRetail>
										<cfset drop.pubTradeWeekly += ipubTrade>
										<cfset drop.pubProfit += ipubProfit>
										
										<cfset item.pubQty += iqtyWeekly>									
										<cfset item.pubRetail += ipubRetail>
										<cfset item.pubTrade += ipubTrade>
										<cfset item.pubProfit += ipubProfit>
										
										<cfif pub.oiSun neq 0>
											<cfset iDay = StructFind(item.days,"Sun")>
											<cfset StructUpdate(iDay,"Retail",iDay.Retail + pub.oiSun * pub.pubPrice)>
											<cfset StructUpdate(iDay,"Profit",iDay.Profit + pub.oiSun * pub.pubProfit)>
										</cfif>
										<cfif pub.oiMon neq 0>
											<cfset iDay = StructFind(item.days,"Mon")>
											<cfset StructUpdate(iDay,"Retail",iDay.Retail + pub.oiMon * pub.pubPrice)>
											<cfset StructUpdate(iDay,"Profit",iDay.Profit + pub.oiMon * pub.pubProfit)>
										</cfif>
										<cfif pub.oiTue neq 0>
											<cfset iDay = StructFind(item.days,"Tue")>
											<cfset StructUpdate(iDay,"Retail",iDay.Retail + pub.oiTue * pub.pubPrice)>
											<cfset StructUpdate(iDay,"Profit",iDay.Profit + pub.oiTue * pub.pubProfit)>
										</cfif>
										<cfif pub.oiWed neq 0>
											<cfset iDay = StructFind(item.days,"Wed")>
											<cfset StructUpdate(iDay,"Retail",iDay.Retail + pub.oiWed * pub.pubPrice)>
											<cfset StructUpdate(iDay,"Profit",iDay.Profit + pub.oiWed * pub.pubProfit)>
										</cfif>
										<cfif pub.oiThu neq 0>
											<cfset iDay = StructFind(item.days,"Thu")>
											<cfset StructUpdate(iDay,"Retail",iDay.Retail + pub.oiThu * pub.pubPrice)>
											<cfset StructUpdate(iDay,"Profit",iDay.Profit + pub.oiThu * pub.pubProfit)>
										</cfif>
										<cfif pub.oiFri neq 0>
											<cfset iDay = StructFind(item.days,"Fri")>
											<cfset StructUpdate(iDay,"Retail",iDay.Retail + pub.oiFri * pub.pubPrice)>
											<cfset StructUpdate(iDay,"Profit",iDay.Profit + pub.oiFri* pub.pubProfit)>
										</cfif>
										<cfif pub.oiSat neq 0>
											<cfset iDay = StructFind(item.days,"Sat")>
											<cfset StructUpdate(iDay,"Retail",iDay.Retail + pub.oiSat * pub.pubPrice)>
											<cfset StructUpdate(iDay,"Profit",iDay.Profit + pub.oiSat * pub.pubProfit)>
										</cfif>
										<cfif showTrans>
											<tr>
												<td></td>
												<td>#pub.pubTitle#</td>
												<td align="right">#pub.pubPrice#</td>
												<td align="right">#pub.pubTradePrice#</td>
												<td align="center">#pub.oiSun#</td>
												<td align="center">#pub.oiMon#</td>
												<td align="center">#pub.oiTue#</td>
												<td align="center">#pub.oiWed#</td>
												<td align="center">#pub.oiThu#</td>
												<td align="center">#pub.oiFri#</td>
												<td align="center">#pub.oiSat#</td>
												<td align="center">#iqtyWeekly#</td>
												<td align="right">#DecimalFormat(ipubRetail)#</td>
												<td align="right">#DecimalFormat(ipubTrade)#</td>
												<td align="right">#DecimalFormat(ipubProfit)#</td>
												<td colspan="2"></td>
											</tr>
										</cfif>
										<cfset drop.oiSun += pub.oiSun>
										<cfset drop.oiMon += pub.oiMon>
										<cfset drop.oiTue += pub.oiTue>
										<cfset drop.oiWed += pub.oiWed>
										<cfset drop.oiThu += pub.oiThu>
										<cfset drop.oiFri += pub.oiFri>
										<cfset drop.oiSat += pub.oiSat>
									</cfloop>
									<cfset drop.actSun = int(drop.oiSun gt 0 AND drop.ordSun)>
									<cfset drop.actMon = int(drop.oiMon gt 0 AND drop.ordMon)>
									<cfset drop.actTue = int(drop.oiTue gt 0 AND drop.ordTue)>
									<cfset drop.actWed = int(drop.oiWed gt 0 AND drop.ordWed)>
									<cfset drop.actThu = int(drop.oiThu gt 0 AND drop.ordThu)>
									<cfset drop.actFri = int(drop.oiFri gt 0 AND drop.ordFri)>
									<cfset drop.actSat = int(drop.oiSat gt 0 AND drop.ordSat)>
									
									<cfif drop.delPrice3 neq 0><cfset drop.chgSun = drop.actSun * drop.delPrice3>
										<cfelse><cfset drop.chgSun = drop.actSun * drop.delPrice1></cfif>
									<cfif drop.delPrice2 neq 0><cfset drop.chgSat = drop.actSat * drop.delPrice2>
										<cfelse><cfset drop.chgSat = drop.actSat * drop.delPrice1></cfif>
									<cfset drop.chgMon = drop.actMon * drop.delPrice1>
									<cfset drop.chgTue = drop.actTue * drop.delPrice1>
									<cfset drop.chgWed = drop.actWed * drop.delPrice1>
									<cfset drop.chgThu = drop.actThu * drop.delPrice1>
									<cfset drop.chgFri = drop.actFri * drop.delPrice1>
									<cfset drop.chgWeekly = drop.chgSun+drop.chgMon+drop.chgTue+drop.chgWed+drop.chgThu+drop.chgFri+drop.chgSat>
									
									<cfif drop.chgSun neq 0>
										<cfset iDay = StructFind(item.days,"Sun")>
										<cfset StructUpdate(iDay,"Charge",iDay.Charge + drop.chgSun)>
									</cfif>
									<cfif drop.chgMon neq 0>
										<cfset iDay = StructFind(item.days,"Mon")>
										<cfset StructUpdate(iDay,"Charge",iDay.Charge + drop.chgMon)>
									</cfif>
									<cfif drop.chgTue neq 0>
										<cfset iDay = StructFind(item.days,"Tue")>
										<cfset StructUpdate(iDay,"Charge",iDay.Charge + drop.chgTue)>
									</cfif>
									<cfif drop.chgWed neq 0>
										<cfset iDay = StructFind(item.days,"Wed")>
										<cfset StructUpdate(iDay,"Charge",iDay.Charge + drop.chgWed)>
									</cfif>
									<cfif drop.chgThu neq 0>
										<cfset iDay = StructFind(item.days,"Thu")>
										<cfset StructUpdate(iDay,"Charge",iDay.Charge + drop.chgThu)>
									</cfif>
									<cfif drop.chgFri neq 0>
										<cfset iDay = StructFind(item.days,"Fri")>
										<cfset StructUpdate(iDay,"Charge",iDay.Charge + drop.chgFri)>
									</cfif>
									<cfif drop.chgSat neq 0>
										<cfset iDay = StructFind(item.days,"Sat")>
										<cfset StructUpdate(iDay,"Charge",iDay.Charge + drop.chgSat)>
									</cfif>
									
									<cfset item.charges += drop.chgWeekly>	
									<cfif showTrans>						 
										<tr>
											<td></td>
											<td></td>
											<td colspan="2">Delivery Days</td>
											<td align="center">#drop.ordSun#</td>
											<td align="center">#drop.ordMon#</td>
											<td align="center">#drop.ordTue#</td>
											<td align="center">#drop.ordWed#</td>
											<td align="center">#drop.ordThu#</td>
											<td align="center">#drop.ordFri#</td>
											<td align="center">#drop.ordSat#</td>
											<td colspan="6"></td>
										</tr>
										<tr>
											<td></td>
											<td></td>
											<td colspan="2">Active Days</td>
											<td align="center">#drop.actSun#</td>
											<td align="center">#drop.actMon#</td>
											<td align="center">#drop.actTue#</td>
											<td align="center">#drop.actWed#</td>
											<td align="center">#drop.actThu#</td>
											<td align="center">#drop.actFri#</td>
											<td align="center">#drop.actSat#</td>
											<td colspan="6"></td>
										</tr>
										<tr>
											<td></td>
											<td></td>
											<td colspan="2">Delivery Charges</td>
											<td align="center"><cfif drop.chgSun>#DecimalFormat(drop.chgSun)#</cfif></td>
											<td align="center"><cfif drop.chgMon>#DecimalFormat(drop.chgMon)#</cfif></td>
											<td align="center"><cfif drop.chgTue>#DecimalFormat(drop.chgTue)#</cfif></td>
											<td align="center"><cfif drop.chgWed>#DecimalFormat(drop.chgWed)#</cfif></td>
											<td align="center"><cfif drop.chgThu>#DecimalFormat(drop.chgThu)#</cfif></td>
											<td align="center"><cfif drop.chgFri>#DecimalFormat(drop.chgFri)#</cfif></td>
											<td align="center"><cfif drop.chgSat>#DecimalFormat(drop.chgSat)#</cfif></td>
										</tr>
										<tr class="footer">
											<td></td>
											<td></td>
											<td colspan="2">Totals</td>
											<td align="center">#drop.oiSun#</td>
											<td align="center">#drop.oiMon#</td>
											<td align="center">#drop.oiTue#</td>
											<td align="center">#drop.oiWed#</td>
											<td align="center">#drop.oiThu#</td>
											<td align="center">#drop.oiFri#</td>
											<td align="center">#drop.oiSat#</td>
											<td align="center">#ipubQty#</td>
											<td align="right" width="50">#DecimalFormat(drop.pubWeekly)#</td>
											<td align="right" width="50">#DecimalFormat(drop.pubTradeWeekly)#</td>
											<td align="right" width="50">#DecimalFormat(drop.pubProfit)#</td>
											<td align="right" width="50">#DecimalFormat(drop.chgWeekly)#</td>
											<td align="right" width="50">#DecimalFormat(drop.pubWeekly+drop.chgWeekly)#</td>
										</tr>
									</cfif>
								</cfloop>
								<cfif showTrans>
									<tr class="rndfooter">
										<td align="center">#ArrayLen(item.drops)#</td>
										<td>drops</td>
										<td align="right" colspan="10">#item.roundTitle# Totals</td>
										<td align="right">#DecimalFormat(item.pubRetail)#</td>
										<td align="right">#DecimalFormat(item.pubTrade)#</td>
										<td align="right">#DecimalFormat(item.pubProfit)#</td>
										<td align="right">#DecimalFormat(item.charges)#</td>
										<td align="right">#DecimalFormat(item.pubRetail + item.charges)#</td>
									</tr>
								</cfif>
							</cfloop>
						</table>
							
						<cfif showDumps><cfdump var="#roundData#" label="roundData end" expand="false"></cfif>
						
						<table class="roundList" width="900" style="margin:10px">
							<tr>
								<th>Round</th>
								<th>Daily<br>Mileage</th>
								<th align="center">Drop<br>Qty</th>
								<th align="center">Pub<br>Qty</th>
								<th align="right">Pub<br> Retail</th>
								<th align="right">Pub<br> Trade</th>
								<th align="right">Pub<br> Profit</th>
								<th align="right">Charges</th>
								<th align="right">Retail<br>Value</th>
								<th align="right">Gross<br>Profit</th>
								<th align="right">POR</th>
								<th align="right">Driver<br>(#driverRate*100#%)</th>
								<th align="right">Fuel<br>(#fuelRate*100#p/m)</th>
								<th align="right">Income</th>
								<th align="right">Net Profit</th>
							</tr>
								<cfset tot = {}>
								<cfset tot.dropQty = 0>
								<cfset tot.pubQty = 0>
								<cfset tot.pubRetail = 0>
								<cfset tot.pubTrade = 0>
								<cfset tot.pubProfit = 0>
								<cfset tot.charges = 0>
								<cfset tot.total = 0>
								<cfset tot.driver = 0>
								<cfset tot.iFuel = 0>
								<cfset tot.income = 0>
								<cfset tot.netProfit = 0>
								<cfset iKeys = ListSort(StructKeyList(roundData,","),"text","asc")>
								<cfloop list="#iKeys#" index="key">
									<cfset rnd = StructFind(roundData,key)>
									<cfset tot.dropQty += rnd.dropQty>
									<cfset tot.pubQty += rnd.pubQty>
									<cfset tot.pubRetail += rnd.pubRetail>
									<cfset tot.pubTrade += rnd.pubTrade>
									<cfset tot.pubProfit += rnd.pubProfit>
									<cfset tot.charges += rnd.charges>
									<cfset tot.total += (rnd.pubProfit + rnd.charges)>
									<cfset iGrossProfit = rnd.pubProfit + rnd.charges>
									<cfset iRetailValue = rnd.pubRetail + rnd.charges>
									<cfset iPOR = 0>
									<cfif iRetailValue neq 0>
										<cfset iPOR = (iGrossProfit / iRetailValue) * 100>
									</cfif>
									<cfif rnd.mileage gt 0>
										<cfset iDriver = iGrossProfit * val(driverRate)>
										<cfset iFuel = rnd.mileage * val(fuelRate) * 7>
										<cfset iIncome = iDriver + iFuel>
									<cfelse>
										<cfset iDriver = 0>
										<cfset iFuel = 0>
										<cfset iIncome = 0>
									</cfif>
									<cfset iNetProfit = iGrossProfit - iDriver - iFuel>
									<cfset tot.driver += iDriver>
									<cfset tot.iFuel += iFuel>
									<cfset tot.income += iIncome>
									<cfset tot.netProfit += iNetProfit>
									<tr>
										<td>#rnd.roundTitle#</td>
										<td align="center">#rnd.Mileage#</td>
										<td align="center">#rnd.dropQty#</td>
										<td align="center">#rnd.pubQty#</td>
										<td align="right">#DecimalFormat(rnd.pubRetail)#</td>
										<td align="right">#DecimalFormat(rnd.pubTrade)#</td>
										<td align="right">#DecimalFormat(rnd.pubProfit)#</td>
										<td align="right">#DecimalFormat(rnd.charges)#</td>
										<td align="right">#DecimalFormat(iRetailValue)#</td>
										<td align="right">#DecimalFormat(iGrossProfit)#</td>
										<td align="right">#DecimalFormat(iPOR)#%</td>
										<td align="right">#DecimalFormat(iDriver)#</td>
										<td align="right">#DecimalFormat(iFuel)#</td>
										<td align="right">#DecimalFormat(iIncome)#</td>
										<td align="right">#DecimalFormat(iNetProfit)#</td>
									</tr>
								</cfloop>
								<cfset iPOR = 0>
								<cfif tot.pubRetail neq 0>
									<cfset iPOR = (tot.total / (tot.pubRetail + tot.charges)) * 100>
								</cfif>
								<tr>
									<th colspan="2">Totals</th>
									<th align="center">#tot.dropQty#</th>
									<th align="center">#tot.pubQty#</th>
									<th align="right">#DecimalFormat(tot.pubRetail)#</th>
									<th align="right">#DecimalFormat(tot.pubTrade)#</th>
									<th align="right">#DecimalFormat(tot.pubProfit)#</th>
									<th align="right">#DecimalFormat(tot.charges)#</th>
									<th align="right">#DecimalFormat(tot.pubRetail + tot.charges)#</th>
									<th align="right">#DecimalFormat(tot.total)#</th>
									<th align="right">#DecimalFormat(iPOR)#%</th>
									<th align="right">#DecimalFormat(tot.driver)#</th>
									<th align="right">#DecimalFormat(tot.iFuel)#</th>
									<th align="right">#DecimalFormat(tot.income)#</th>
									<th align="right">#DecimalFormat(tot.netProfit)#</th>
								</tr>
						</table>
						<table class="summaryList" style="margin:10px">
							<cfset iKeys = ListSort(StructKeyList(roundData,","),"text","asc")>
							<cfloop list="#iKeys#" index="key">
								<cfset rnd = StructFind(roundData,key)>
								<tr>
									<th colspan="9" class="rndheader">#rnd.roundTitle#</th>
								</tr>
								<tr>
									<th></th>
									<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="thisday">
										<th>#thisday#</th>
									</cfloop>
									<th>Total</th>
								</tr>
								<tr>
									<td>Media Profit</td>
									<cfset iweekTotal = 0>
									<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="thisday">
										<cfset iDay = StructFind(rnd.days,thisday)>
										<cfset iweekTotal += iDay.Profit>
										<td align="right">#DecimalFormat(iDay.Profit)#</td>
									</cfloop>
									<td align="right">#DecimalFormat(iweekTotal)#</td>
								</tr>
								<tr>
									<td>Charges</td>
									<cfset iweekTotal = 0>
									<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="thisday">
										<cfset iDay = StructFind(rnd.days,thisday)>
										<cfset iweekTotal += iDay.Charge>
										<td align="right">#DecimalFormat(iDay.Charge)#</td>
									</cfloop>
									<td align="right">#DecimalFormat(iweekTotal)#</td>
								</tr>
								<tr style="font-weight:bold">
									<td>Gross Profit</td>
									<cfset iweekTotal = 0>
									<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="thisday">
										<cfset iDay = StructFind(rnd.days,thisday)>
										<cfset iTotal = iDay.Profit + iDay.Charge>
										<cfset iweekTotal += iTotal>
										<td align="right">#DecimalFormat(iTotal)#</td>
									</cfloop>
									<td align="right">#DecimalFormat(iweekTotal)#</td>
								</tr>
								<cfif rnd.mileage gt 0>
									<tr>
										<td>Driver</td>
										<cfset iweekTotal = 0>
										<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="thisday">
											<cfset iDay = StructFind(rnd.days,thisday)>
											<cfset iDriver = (iDay.Profit + iDay.Charge) * val(driverRate)>
											<cfset iweekTotal += iDriver>
											<td align="right">#DecimalFormat(iDriver)#</td>
										</cfloop>
										<td align="right">#DecimalFormat(iweekTotal)#</td>
									</tr>
									<tr>
										<td>Fuel</td>
										<cfset iweekTotal = 0>
										<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="thisday">
											<cfset iDay = StructFind(rnd.days,thisday)>
											<cfif rnd.mileage gt 0>
												<cfset iFuel = rnd.mileage * val(fuelRate)>
											<cfelse>
												<cfset iFuel = 0>
											</cfif>
											<cfset iweekTotal += iFuel>
											<td align="right">#DecimalFormat(iFuel)#</td>
										</cfloop>
										<td align="right">#DecimalFormat(iweekTotal)#</td>
									</tr>
									<tr>
										<td>Total</td>
										<cfset iweekTotal = 0>
										<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="thisday">
											<cfset iDay = StructFind(rnd.days,thisday)>
											<cfset iDriver = (iDay.Profit + iDay.Charge) * val(driverRate)>
											<cfif rnd.mileage gt 0>
												<cfset iFuel = rnd.mileage * val(fuelRate)>
											<cfelse>
												<cfset iFuel = 0>
											</cfif>
											<cfset iTotal = iDriver + iFuel>
											<cfset iweekTotal += iTotal>
											<td align="right">#DecimalFormat(iTotal)#</td>
										</cfloop>
										<td align="right">#DecimalFormat(iweekTotal)#</td>
									</tr>
									<tr class="rndfooter">
										<th>Actual Pay</th>
										<cfset iweekTotal = 0>
										<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="thisday">
											<cfset iDay = StructFind(rnd.days,thisday)>
											<cfset iTotal = (iDay.Profit + iDay.Charge) * val(driverRate) + (rnd.mileage * val(fuelRate))>
											<cfset iWhole = int(iTotal)>
											<cfset iRem = iTotal - iWhole>
											<cfset iTotal = iWhole + (int(iRem gt 0))>
											<cfset iweekTotal += iTotal>
											<th align="right">#DecimalFormat(iTotal)#</th>
										</cfloop>
										<th align="right">#DecimalFormat(iweekTotal)#</th>
									</tr>
								</cfif>
							</cfloop>
						</table>
						<table>
							<tr>
								<td valign="top">
									<table class="summaryList" style="margin:10px">
										<tr>
											<th colspan="3">Original Delivery Charge Counter</th>
										</tr>
										<tr>
											<th>Code</th>
											<th>Price</th>
											<th>Count</th>
										</tr>
										<cfset iCount = 0>
										<cfloop query="QOrigCodeDelCounts">
											<tr>
												<td align="center">#ordDeliveryCode#</td>
												<td align="right">#delPrice1#</td>
												<td align="right">#delCount#</td>
											</tr>
											<cfset iCount += delCount>
										</cfloop>
										<tr>
											<th>#iCount# orders</th>
										</tr>
									</table>
								</td>
								<td valign="top">
									<table class="summaryList" style="margin:10px">
										<tr>
											<th colspan="3">New Delivery Charge Counter</th>
										</tr>
										<tr>
											<th>Code</th>
											<th>Price</th>
											<th>Count</th>
										</tr>
										<cfset iCount = 0>
										<cfloop query="QNewCodeDelCounts">
											<tr>
												<td align="center">#ordDelCodeNew#</td>
												<td align="right">#delPrice1#</td>
												<td align="right">#delCount#</td>
											</tr>
											<cfset iCount += delCount>
										</cfloop>
										<tr>
											<th>#iCount# orders</th>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</cfoutput>
				</cfif>
				<cfif showDumps><cfdump var="#roundData#" label="roundData end" expand="false"></cfif>
			</div>
		</div>
	</div>
</body>
</html>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

