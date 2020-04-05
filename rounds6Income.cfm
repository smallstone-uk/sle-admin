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
</head>

<cftry>
	<cfparam name="startDate" default="">
	<cfparam name="interval" default="">
	<cfparam name="showTrans" default="0">
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfoutput>
					<form name="roundForm" id="roundForm" method="post">
						Start Date: <input type="text" name="startDate" id="startDate" size="10" class="datepicker" value="#startDate#" /><br>
						Period (weeks): <input type="text" size="3" name="interval" value="#interval#" /><br>
						<input name="showTrans" type="checkbox" value="1"<cfif showTrans> checked</cfif> /> Show Transactions?<br>
						<input type="submit" name="btnSubmit" id="btnSubmit" value="View" />
					</form>
				</cfoutput>
				<cfif len(startDate)>
					<cfset interval = val(interval)>
					<cfset drivers = {}>
					<cfset drivers.alec = {1=25,2=25,3=25,4=25,5=25,6=25,7=30}>
					<cfset drivers.dave = {1=25,2=30,3=30,4=30,5=30,6=30,7=35}>
					<cfset drivers.allan = {1=22,2=27,3=27,4=27,5=27,6=27,7=27}>
					<cfset drivers.sle = {1=3,2=3,3=3,4=3,5=3,6=3,7=3}>
					<cfset drivers.laura = {1=10,2=10,3=10,4=10,5=10,6=10,7=10}>
					<cfset mileage = {}>
					<cfset mileage.dave = {miles=17, mpg=27,mph=17}>
					<cfset mileage.allan = {miles=21, mpg=28,mph=19}>
					<cfquery name="QData" datasource="#application.site.datasource1#">
						SELECT rndID,rndTitle, Sum( diQty ) AS qty, sum((diPrice * diQty) - (diPriceTrade * diQty)) AS profit, 
							sum( diCharge ) AS charge, count(diID) AS recCount, dayofweek( diDate ) AS dayNum
						FROM `tblDelItems`
						INNER JOIN tblRounds ON rndID = diRoundID
						WHERE diDate <= '#startDate#'
						AND diDate > DATE_ADD('#startDate#', INTERVAL -#val(interval)# WEEK)
						GROUP BY diRoundID, dayNum
					</cfquery>
					<cfif showTrans>
						<cfquery name="QItems" datasource="#application.site.datasource1#">
							SELECT rndID,rndTitle, diType,diIssue,diQty,diPrice,diPriceTrade,diCharge,diDate, pubID,pubtitle
							FROM tblDelItems
							INNER JOIN tblRounds ON rndID = diRoundID
							INNER JOIN tblPublication ON pubID=diPubID
							WHERE diDate <= '#startDate#'
							AND diDate > DATE_ADD('#startDate#', INTERVAL -#val(interval)# WEEK)
							ORDER BY diRoundID, pubtitle, diDate
						</cfquery>
					</cfif>
					<cfoutput>
						<h1>#LSDateFormat(DateAdd("ww",-interval,startDate))# #LSDateFormat(startDate,"dd-mmm-yyyy")# Average over #interval# week period</h1>
						<table class="tableList" border="1">
						<cfset roundID = 0>
						<cfset totpr = 0>
						<cfset totch = 0>
						<cfset grandtotpr = 0>
						<cfset grandtotch = 0>
						<cfset grandtotPay = 0>
						<cfset grandtotprofit = 0>
						<cfset day1pr = 0>
						<cfset day2pr = 0>
						<cfset day3pr = 0>
						<cfset day4pr = 0>
						<cfset day5pr = 0>
						<cfset day6pr = 0>
						<cfset day7pr = 0>
						<cfset day1ch = 0>
						<cfset day2ch = 0>
						<cfset day3ch = 0>
						<cfset day4ch = 0>
						<cfset day5ch = 0>
						<cfset day6ch = 0>
						<cfset day7ch = 0>
						<cfset total1 = 0>
						<cfset total2 = 0>
						<cfset total3 = 0>
						<cfset total4 = 0>
						<cfset total5 = 0>
						<cfset total6 = 0>
						<cfset total7 = 0>
						<cfset gtotalPay = 0>
						<cfloop query="QData">
							<cfif roundID eq 0>
								<tr>
									<th>Round</th>
									<th colspan="2">Sun</th>
									<th colspan="2">Mon</th>
									<th colspan="2">Tue</th>
									<th colspan="2">Wed</th>
									<th colspan="2">Thu</th>
									<th colspan="2">Fri</th>
									<th colspan="2">Sat</th>
									<th colspan="3">Total</th>
									<th>Delivery</th>
									<th colspan="2">Round</th>
								</tr>
								<tr>
									<th></th>
									<cfloop from="1" to="8" index="i">
										<th>profit</th>
										<th>charge</th>
									</cfloop>
									<th>Total</th>
									<th>Cost</th>
									<th>Profit</th>
									<th>%</th>
								</tr>
								<tr>	<!--- open first row --->
									<td>#rndTitle#</td>
							<cfelseif rndID neq roundID>
								</tr><tr>	<!--- close and open new row --->
									<td>#rndTitle#</td>
								<cfset totpr = 0>
								<cfset totch = 0>
							</cfif>
							<cfset roundID = rndID>
							<cfset pr = profit / interval>
							<cfset ch = charge / interval>
							<cfset totpr += pr>
							<cfset totch += ch>
							<cfset showpr = DecimalFormat(pr)>
							<cfset showch = DecimalFormat(ch)>
							<cfif dayNum eq 1>
								<cfset day1pr += pr>
								<cfset day1ch += ch>
								<td align="right">#showpr#</td>
								<td align="right">#showch#</td>
							</cfif>
							<cfif dayNum eq 2>
								<cfset day2pr += pr>
								<cfset day2ch += ch>
								<td align="right">#showpr#</td>
								<td align="right">#showch#</td>
							</cfif>
							<cfif dayNum eq 3>
								<cfset day3pr += pr>
								<cfset day3ch += ch>
								<td align="right">#showpr#</td>
								<td align="right">#showch#</td>
							</cfif>
							<cfif dayNum eq 4>
								<cfset day4pr += pr>
								<cfset day4ch += ch>
								<td align="right">#showpr#</td>
								<td align="right">#showch#</td>
							</cfif>
							<cfif dayNum eq 5>
								<cfset day5pr += pr>
								<cfset day5ch += ch>
								<td align="right">#showpr#</td>
								<td align="right">#showch#</td>
							</cfif>
							<cfif dayNum eq 6>
								<cfset day6pr += pr>
								<cfset day6ch += ch>
								<td align="right">#showpr#</td>
								<td align="right">#showch#</td>
							</cfif>
							<cfif dayNum eq 7>
								<cfset day7pr += pr>
								<cfset day7ch += ch>
								<td align="right">#showpr#</td>
								<td align="right">#showch#</td>
								<cfset grandtotpr += totpr>
								<cfset grandtotch += totch>
								<cfset roundpr = DecimalFormat(totpr)>
								<cfset roundch = DecimalFormat(totch)>
								<td align="right">#roundpr#</td>
								<td align="right">#roundch#</td>
								<td align="right">#roundpr + roundch#</td>
								<cfif StructKeyExists(drivers,rndTitle)>
									<cfset driver = StructFind(drivers,rndTitle)>
									<cfset totalPay = driver.1 + driver.2 + driver.3 + driver.4 + driver.5 + driver.6 + driver.7>
								<cfelse>
									<cfset totalPay = 0>
								</cfif>
								<cfset grandtotPay += totalPay>
								<cfset weekProfit = totpr + totch - totalPay>
								<cfset grandtotprofit += weekProfit>
								<td align="right">#DecimalFormat(totalPay)#</td>
								<td align="right">#DecimalFormat(weekProfit)#</td>
								<td align="right">#DecimalFormat((weekProfit / (roundpr + roundch))*100)#%</td>
							</cfif>
						</cfloop>
						</tr>
						<!---<cfset groundpr = DecimalFormat(grandtotpr)>
						<cfset groundch = DecimalFormat(grandtotch)>--->
						<cfset grandTotal = (grandtotpr + grandtotch)>
						<tr>
							<th></th>
							<th>#DecimalFormat(day1pr)#</th>
							<th>#DecimalFormat(day1ch)#</th>
							<th>#DecimalFormat(day2pr)#</th>
							<th>#DecimalFormat(day2ch)#</th>
							<th>#DecimalFormat(day3pr)#</th>
							<th>#DecimalFormat(day3ch)#</th>
							<th>#DecimalFormat(day4pr)#</th>
							<th>#DecimalFormat(day4ch)#</th>
							<th>#DecimalFormat(day5pr)#</th>
							<th>#DecimalFormat(day5ch)#</th>
							<th>#DecimalFormat(day6pr)#</th>
							<th>#DecimalFormat(day6ch)#</th>
							<th>#DecimalFormat(day7pr)#</th>
							<th>#DecimalFormat(day7ch)#</th>
							<th>#DecimalFormat(grandtotpr)#</th>
							<th>#DecimalFormat(grandtotch)#</th>
							<th>#DecimalFormat(grandtotpr + grandtotch)#</th>
							<th>#DecimalFormat(grandtotPay)#</th>
							<th>#DecimalFormat(grandtotprofit)#</th>
							<th>#DecimalFormat((grandtotprofit / (grandtotpr + grandtotch)) * 100)#%</th>
						</tr>
						<tr>
							<td>Total Net Income</td>
							<td colspan="2" align="right">#DecimalFormat(day1pr + day1ch)#</td>
							<td colspan="2" align="right">#DecimalFormat(day2pr + day2ch)#</td>
							<td colspan="2" align="right">#DecimalFormat(day3pr + day3ch)#</td>
							<td colspan="2" align="right">#DecimalFormat(day4pr + day4ch)#</td>
							<td colspan="2" align="right">#DecimalFormat(day5pr + day5ch)#</td>
							<td colspan="2" align="right">#DecimalFormat(day6pr + day6ch)#</td>
							<td colspan="2" align="right">#DecimalFormat(day7pr + day7ch)#</td>
							<td colspan="2" align="right">#DecimalFormat(grandTotal)#</td>
							<td colspan="4"></td>
						</tr>
						<tr>
							<td colspan="21">&nbsp;</td>
						</tr>
						<tr>
							<th>Costs</td>
							<th colspan="2">Sun</th>
							<th colspan="2">Mon</th>
							<th colspan="2">Tue</th>
							<th colspan="2">Wed</th>
							<th colspan="2">Thu</th>
							<th colspan="2">Fri</th>
							<th colspan="2">Sat</th>
							<th colspan="2">Total</th>
						</tr>
						<cfset total1 = 0>
						<cfloop collection="#drivers#" item="key">
							<cfset driver = StructFind(drivers,key)>
							<cfset totalPay = driver.1 + driver.2 + driver.3 + driver.4 + driver.5 + driver.6 + driver.7>
							<cfset gtotalPay += totalPay>
							<cfset total1 += driver.1>
							<cfset total2 += driver.2>
							<cfset total3 += driver.3>
							<cfset total4 += driver.4>
							<cfset total5 += driver.5>
							<cfset total6 += driver.6>
							<cfset total7 += driver.7>
							<tr>
								<td>#key#</td>
								<td colspan="2" align="right">#driver.1#</td>
								<td colspan="2" align="right">#driver.2#</td>
								<td colspan="2" align="right">#driver.3#</td>
								<td colspan="2" align="right">#driver.4#</td>
								<td colspan="2" align="right">#driver.5#</td>
								<td colspan="2" align="right">#driver.6#</td>
								<td colspan="2" align="right">#driver.7#</td>
								<td colspan="2" align="right">#totalPay#</td>
							</tr>
						</cfloop>
							<tr>
								<th>Total Expenses</th>
								<th colspan="2" align="right">#total1#</th>
								<th colspan="2" align="right">#total2#</th>
								<th colspan="2" align="right">#total3#</th>
								<th colspan="2" align="right">#total4#</th>
								<th colspan="2" align="right">#total5#</th>
								<th colspan="2" align="right">#total6#</th>
								<th colspan="2" align="right">#total7#</th>
								<th colspan="2" align="right">#gtotalPay#</th>
							</tr>
							<cfset profit1 = day1pr + day1ch - total1>
							<cfset profit2 = day2pr + day2ch - total2>
							<cfset profit3 = day3pr + day3ch - total3>
							<cfset profit4 = day4pr + day4ch - total4>
							<cfset profit5 = day5pr + day5ch - total5>
							<cfset profit6 = day6pr + day6ch - total6>
							<cfset profit7 = day7pr + day7ch - total7>
							<cfset tprofit = grandTotal - gtotalPay>
							<tr>
								<td>Profit by Day</td>
								<td colspan="2" align="right">#DecimalFormat(profit1)#</td>
								<td colspan="2" align="right">#DecimalFormat(profit2)#</td>
								<td colspan="2" align="right">#DecimalFormat(profit3)#</td>
								<td colspan="2" align="right">#DecimalFormat(profit4)#</td>
								<td colspan="2" align="right">#DecimalFormat(profit5)#</td>
								<td colspan="2" align="right">#DecimalFormat(profit6)#</td>
								<td colspan="2" align="right">#DecimalFormat(profit7)#</td>
								<td colspan="2" align="right">#DecimalFormat(tprofit)#</td>
							</tr>
							<cfset percent1 = profit1 / (day1pr + day1ch) * 100>
							<cfset percent2 = profit2 / (day2pr + day2ch) * 100>
							<cfset percent3 = profit3 / (day3pr + day3ch) * 100>
							<cfset percent4 = profit4 / (day4pr + day4ch) * 100>
							<cfset percent5 = profit5 / (day5pr + day5ch) * 100>
							<cfset percent6 = profit6 / (day6pr + day6ch) * 100>
							<cfset percent7 = profit7 / (day7pr + day7ch) * 100>
							<cfset tpercent = tprofit / grandTotal * 100>
							<tr>
								<td></td>
								<td colspan="2" align="right">#DecimalFormat(percent1)#%</td>
								<td colspan="2" align="right">#DecimalFormat(percent2)#%</td>
								<td colspan="2" align="right">#DecimalFormat(percent3)#%</td>
								<td colspan="2" align="right">#DecimalFormat(percent4)#%</td>
								<td colspan="2" align="right">#DecimalFormat(percent5)#%</td>
								<td colspan="2" align="right">#DecimalFormat(percent6)#%</td>
								<td colspan="2" align="right">#DecimalFormat(percent7)#%</td>
								<td colspan="2" align="right">#DecimalFormat(tpercent)#%</td>
							</tr>
						</table>
						<cfif showTrans>
							<table class="tableList" border="1">
								<cfset totQty = 0>
								<cfset totRetail = 0>
								<cfset totTrade = 0>
								<cfset totProfit = 0>
								<cfset totCharge = 0>
								<cfset roundID = 0>
								<cfloop query="QItems">
									<cfif roundID gt 0 AND rndID neq roundID>
										<cfif StructKeyExists(drivers,roundTitle)>
											<cfset driver = StructFind(drivers,roundTitle)>
											<cfset weeklyPay = driver.1 + driver.2 + driver.3 + driver.4 + driver.5 + driver.6 + driver.7>
											<cfset totalPay = weeklyPay * interval>
										<cfelse><cfset totalPay = 0></cfif>
										<cfset roundProfit = totCharge + (totRetail - totTrade)>
										<tr>
											<th>#roundTitle# Totals (#DecimalFormat(totalPay)#)</th>
											<th colspan="3"></th>
											<th>#totQty#</th>
											<th></th>
											<th></th>
											<th align="right">#totCharge#</th>
											<th align="right">#totRetail#</th>
											<th align="right">#totTrade#</th>
										</tr>
										<tr>
											<th colspan="8" align="right">Gross Profit</th>
											<th align="right">#roundProfit#</th>
											<th align="right">#DecimalFormat((roundProfit / (totCharge + totRetail)) * 100)#%</th>
										</tr>
										<tr>
											<th colspan="8" align="right">Net Profit</th>
											<th align="right">#roundProfit - totalPay#</th>
											<th align="right">#DecimalFormat(((roundProfit - totalPay) / (totCharge + totRetail)) * 100)#%</th>
										</tr>
										<cfset totQty = 0>
										<cfset totRetail = 0>
										<cfset totTrade = 0>
										<cfset totProfit = 0>
										<cfset totCharge = 0>
									</cfif>
									<cfset roundID = rndID>
									<cfset roundTitle = rndTitle>
									<cfset lineRetail = diQty * diPrice>
									<cfset lineTrade = diQty * diPriceTrade>
									<cfset totRetail += lineRetail>
									<cfset totTrade += lineTrade>
									<cfset totCharge += diCharge>
									<cfset totQty += diQty>
									<tr>
										<td>#pubTitle#</td>
										<td>#diIssue#</td>
										<td>#LSDateFormat(diDate,"dd-mmm-yyyy")#</td>
										<td>#diType#</td>
										<td>#diQty#</td>
										<td align="right">#diPrice#</td>
										<td align="right">#diPriceTrade#</td>
										<td align="right">#diCharge#</td>
										<td align="right">#lineRetail#</td>
										<td align="right">#lineTrade#</td>
									</tr>
								</cfloop>
								
								<cfif StructKeyExists(drivers,roundTitle)>
									<cfset driver = StructFind(drivers,roundTitle)>
									<cfset totalPay = driver.1 + driver.2 + driver.3 + driver.4 + driver.5 + driver.6 + driver.7>
								<cfelse><cfset totalPay = 0></cfif>
								<cfset roundProfit = totCharge + (totRetail - totTrade)>
								<tr>
									<th>#roundTitle# Totals (#totalPay#)</th>
									<th colspan="3"></th>
									<th>#totQty#</th>
									<th></th>
									<th></th>
									<th align="right">#totCharge#</th>
									<th align="right">#totRetail#</th>
									<th align="right">#totTrade#</th>
								</tr>
								<tr>
									<th colspan="8" align="right">Gross Profit</th>
									<th align="right">#roundProfit#</th>
									<th align="right">#DecimalFormat((roundProfit / (totCharge + totRetail)) * 100)#%</th>
								</tr>
								<tr>
									<th colspan="8" align="right">Net Profit</th>
									<th align="right">#roundProfit - totalPay#</th>
									<th align="right">#DecimalFormat(((roundProfit - totalPay) / (totCharge + totRetail)) * 100)#%</th>
								</tr>
							</table>
						</cfif>
					</cfoutput>
				</cfif>
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

