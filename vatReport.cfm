<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>VAT Reports</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="common/scripts/common.js"></script>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
			$(".srchAccount, .srchTranType").chosen({width: "300px"});
		});
	</script>
</head>
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfsetting requesttimeout="900">
<cfparam name="srchReport" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post">
						<div class="form-header no-print">
							VAT Reports
							<span><input type="submit" name="btnSearch" value="Search" /></span>
						</div>
						<div class="module no-print">
							<table border="0">
								<tr>
									<td><b>Report</b></td>
									<td>
										<select name="srchReport">
											<option value="">Select...</option>
											<option value="1"<cfif srchReport eq "1"> selected="selected"</cfif>>VAT Report</option>
											<option value="2"<cfif srchReport eq "2"> selected="selected"</cfif>>Daily VAT Report</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Date From</b></td>
									<td>
										<input type="text" name="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
									</td>
								</tr>
								<tr>
									<td><b>Date To</b></td>
									<td>
										<input type="text" name="srchDateTo" value="#srchDateTo#" class="datepicker" />
									</td>
								</tr>
							</table>
						</div>
					</form>
				</div>
				<cfif StructKeyExists(form,"fieldnames")>
					<cfswitch expression="#srchReport#">
						<cfcase value="1">
							<cfquery name="QSaleItems" datasource="#parms.datasource#">
								SELECT ehMode, 
								eiTimestamp,eiType,eiPayType,eiRetail,eiTrade, SUM(eiQty) AS Qty, SUM(eiNet) AS Net, SUM(eiVAT) AS VAT, SUM(eiTrade) AS Trade,
								pgID,pgTitle,pgNomGroup
								FROM tblepos_items
								INNER JOIN tblepos_header ON eiParent=ehID
								INNER JOIN tblProducts ON prodID = eiProdID
								INNER JOIN tblProductCats ON pcatID = prodCatID
								INNER JOIN tblProductGroups ON pgID = pcatGroup
								WHERE eiTimestamp BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
								AND eiClass = 'sale'
								AND ehMode != 'wst'
								GROUP BY pgNomGroup, pgTitle
								ORDER BY pgNomGroup, pgTitle
							</cfquery>
							<!---<cfdump var="#QSaleItems#" label="QItems" expand="false">--->
							
							<cfset totNet = 0>
							<cfset totVAT = 0>
							<cfset totQty = 0>
							<cfset totTrd = 0>
							<cfset totPrf = 0>
							<h1>Sales Income</h1>
							<table border="1" class="tableList">
								<tr>
									<th>Group</th>
									<th>Description</th>
									<th>QTY</th>
									<th>NET</th>
									<th>VAT</th>
									<th>Trade</th>
									<th>Profit</th>
									<th>POR%</th>
								</tr>
								<cfloop query="QSaleItems">
									<cfset totNet += Net>
									<cfset totVAT += VAT>
									<cfset totQty += Qty>
									<cfset totTrd += Trade>
									<cfset profit = -(Net + Trade)>
									<cfset totPrf += profit>
									<cfif Net neq 0>
										<cfset POR = Round((profit / -Net) * 100)>
									</cfif>
									<tr>
										<td>#pgNomGroup#</td>
										<td>#pgTitle#</td>
										<td align="center">#Qty#</td>
										<td align="right">#Net#</td>
										<td align="right">#VAT#</td>
										<td align="right">#Trade#</td>
										<td align="right">#profit#</td>
										<td align="right">#POR#%</td>
									</tr>
								</cfloop>
								<cfif totNet neq 0>
									<cfset POR = Round((totPrf / -totNet) * 100)>
								</cfif>
								<tr>
									<th colspan="2">TOTALS</th>
									<th align="center">#totQty#</th>
									<th align="right">#totNet#</th>
									<th align="right">#totVAT#</th>
									<th align="right">#totTrd#</th>
									<th align="right">#totPrf#</th>
									<th>#POR#%</th>
								</tr>
							</table>
							<div style="page-break-before:always"></div>
							<h1>Purchases</h1>
							<cfquery name="QPurItems" datasource="#parms.datasource#">
								SELECT trnDate, nomID,nomGroup,nomCode,nomTitle, SUM(niAmount) AS Amount, SUM(niVATAmount) AS VATAmount, Count(*) AS Num
								FROM `tbltrans` 
								INNER JOIN tblAccount ON accID = trnAccountID
								INNER JOIN tblnomitems ON niTranID = trnID
								INNER JOIN tblNominal ON niNomID = nomID
								WHERE nomID NOT IN (11,201)
								AND `trnLedger` = 'purch' 
								AND `trnType` IN ('inv', 'crn') 
								AND trnDate BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
								GROUP BY nomGroup, nomCode
							</cfquery>
							<cfset nomFlag = 0>
							<cfset totNet = 0>
							<cfset totVAT = 0>
							<cfset totQty = 0>
							<table border="1" class="tableList">
								<tr>
									<th>Group</th>
									<th>Code</th>
									<th>Description</th>
									<th>QTY</th>
									<th>DR</th>
									<th>CR</th>
									<th>VAT</th>
								</tr>
								<cfloop query="QPurItems">
									<cfif nomGroup gte "C" AND nomFlag eq 0>
										<tr>
											<th colspan="3">TOTALS</th>
											<th align="center">#totQty#</th>
											<th align="right">#totNet#</th>
											<th></th>
											<th align="right">#totVAT#</th>
										</tr>
										<tr>
											<th colspan="7"><h1>Costs</h1></th>
										</tr>
										<cfset totNet = 0>
										<cfset totVAT = 0>
										<cfset totQty = 0>
										<cfset nomFlag++>
									</cfif>
									<cfif nomGroup gte "P" AND nomFlag eq 1>
										<tr>
											<th colspan="3">TOTALS</th>
											<th align="center">#totQty#</th>
											<th align="right">#totNet#</th>
											<th></th>
											<th align="right">#totVAT#</th>
										</tr>
										<tr>
											<th colspan="7"><h1>Capital</h1></th>
										</tr>
										<cfset totNet = 0>
										<cfset totVAT = 0>
										<cfset totQty = 0>
										<cfset nomFlag++>
									</cfif>
									<cfif nomCode neq "VAT">
										<cfset totNet += AMOUNT>
										<cfset totQty += NUM>
										<cfset totVAT += VATAmount>
										<tr>
											<td>#nomGroup#</td>
											<td>#nomCode#</td>
											<td>#nomTitle#</td>
											<td align="center">#NUM#</td>
											<td align="right">#AMOUNT#</td>
											<td align="right"></td>
											<td align="right">#VATAmount#</td>
										</tr>
									<cfelse>
										<tr>
											<td>#nomGroup#</td>
											<td>#nomCode#</td>
											<td>#nomTitle#</td>
											<td align="center">#NUM#</td>
											<td align="right"></td>
											<td align="right">#AMOUNT#</td>
											<td align="right"></td>
										</tr>
									</cfif>
								</cfloop>
								<tr>
									<th colspan="3">TOTALS</th>
									<th align="center">#totQty#</th>
									<th align="right">#totNet#</th>
									<th></th>
									<th align="right">#totVAT#</th>
								</tr>
							</table>
							<!---<cfdump var="#QPurItems#" label="QPurItems" expand="false">--->
						</cfcase>
						
						<cfcase value="2">
							<cfset salKeys = {}>
							<cfset purKeys = {}>
							<cfset dateTo = LSDateFormat(DateAdd("d",1,srchDateTo),"yyyy-mm-dd")>
							<cfquery name="QSaleItems" datasource="#parms.datasource#">
								SELECT ehMode, 
								eiTimestamp,eiType,eiPayType,eiRetail, SUM(eiTrade) AS Trade, SUM(eiQty) AS Qty, SUM(eiNet) AS Net, SUM(eiVAT) AS VAT							
								FROM tblepos_items
								INNER JOIN tblepos_header ON eiParent=ehID
								WHERE eiTimestamp BETWEEN '#srchDateFrom#' AND '#dateTo#'
								AND eiClass = 'sale'
								<!---AND ehMode != 'wst'--->
								GROUP BY Date(eiTimestamp), eiType
							</cfquery>
							<!---<cfdump var="#QSaleItems#" label="QSaleItems" expand="false">--->
							<cfloop query="QSaleItems">
								<cfset dateOnly = LSDateFormat(eiTimeStamp,"yyyy-mm-dd")>
								<cfif !StructKeyExists(salKeys,eiType)>
									<cfset StructInsert(salKeys,eiType,{})>
								</cfif>
								<cfset thisKey = StructFind(salKeys,eiType)>
								<cfif StructKeyExists(thisKey,dateOnly)>
									<cfset thisDate = StructFind(thisKey,dateOnly)>
								<cfelse>
									<cfset StructInsert(thisKey,dateOnly,{"net" = net,"trade" = trade})>
								</cfif>
								<cfif VAT neq 0>
									<cfif !StructKeyExists(salKeys,"VAT")>
										<cfset StructInsert(salKeys,"VAT",{})>
									</cfif>
									<cfset thisKey = StructFind(salKeys,"VAT")>
									<cfif StructKeyExists(thisKey,dateOnly)>
										<cfset thisDate = StructFind(thisKey,dateOnly)>
									<cfelse>
										<cfset StructInsert(thisKey,dateOnly,VAT)>
									</cfif>
								</cfif>
							</cfloop>
							<!---<cfdump var="#salKeys#" label="salKeys" expand="false">--->
							<table border="1" class="tableList" width="100%">
								<tr>
									<th>Ref</th>
									<th></th>
									<cfloop from="#srchDateFrom#" to="#dateTo#" index="i">
										<th>#LSDateFormat(i,"yyyy-mm-dd")#</th>
									</cfloop>
									<th>TOTALS</th>
									<th>PROFIT</th>
								</tr>
								<cfset keyList = ListSort(StructKeyList(salKeys,","),"text","asc")>
								<cfloop list="#keyList#" index="key">
									<cfset thisKey = StructFind(salKeys,key)>
									<tr>
										<td>#key#</td>
										<td>Sales<br />Trade</td>
										<cfset salesTotal = 0>
										<cfset tradeTotal = 0>
										<cfloop from="#srchDateFrom#" to="#dateTo#" index="i">
											<cfset thisDay = LSDateFormat(i,"yyyy-mm-dd")>
											
											<cfif StructKeyExists(thisKey,thisDay)>
												<cfset thisValue = StructFind(thisKey,thisDay)>
												<cfif key neq "VAT">
													<cfset salesTotal += thisValue.net>
													<cfset tradeTotal += thisValue.trade>
													<td align="right">#thisValue.net#<br />#thisValue.trade#</td>
												<cfelse>
													<cfset salesTotal += thisValue>
													<td align="right">#thisValue#</td>
												</cfif>
											<cfelse>
												<td></td>
											</cfif>
										</cfloop>
										<td align="right">#salesTotal#<br />#tradeTotal#</td>
										<cfif key neq "VAT">
											<cfset profit = -(salesTotal + tradeTotal)>
											<cfset por = int((profit / -salesTotal) * 100)>
											<td align="right">#profit#<br />#por#%</td>
										</cfif>
									</tr>
								</cfloop>
								<tr>
									<th colspan="40">&nbsp;</th>
								</tr>
								<cfquery name="QPurItems" datasource="#parms.datasource#">
									SELECT trnRef,trnDate,trnAmnt1,trnAmnt2, nomID,nomCode,nomGroup,nomTitle, SUM(niAmount) AS Amount, Count(*) AS Num
									FROM `tbltrans` 
									INNER JOIN tblAccount ON accID = trnAccountID
									INNER JOIN tblnomitems ON niTranID = trnID
									INNER JOIN tblNominal ON niNomID = nomID
									WHERE nomID NOT IN (11,201)
									AND `trnLedger` = 'purch' 
									AND `trnType` IN ('inv', 'crn') 
									AND trnDate BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
									GROUP BY trnDate, nomGroup, nomCode
								</cfquery>
								<!---<cfdump var="#QPurItems#" label="QPurItems" expand="false">--->
								<cfloop query="QPurItems">
									<cfset dateOnly = LSDateFormat(trnDate,"yyyy-mm-dd")>
									<cfset groupCode = "#nomGroup#-#nomCode#">
									<cfif !StructKeyExists(purKeys,groupCode)>
										<cfset StructInsert(purKeys,groupCode,{"nomTitle" = nomTitle})>
									</cfif>
									<cfset thisKey = StructFind(purKeys,groupCode)>
									<cfif StructKeyExists(thisKey,dateOnly)>
										<cfset thisDate = StructFind(thisKey,dateOnly)>
									<cfelse>
										<cfset StructInsert(thisKey,dateOnly,amount)>
									</cfif>
								</cfloop>
								<!---<cfdump var="#purKeys#" label="purKeys" expand="false">--->
								<cfset keyList = ListSort(StructKeyList(purKeys,","),"text","asc")>
								<cfloop list="#keyList#" index="key">
									<cfset thisKey = StructFind(purKeys,key)>
									<tr>
										<td>#key#</td>
										<td>#thisKey.nomTitle#</td>
										<cfset keyTotal = 0>
										<cfloop from="#srchDateFrom#" to="#dateTo#" index="i">
											<cfset thisDay = LSDateFormat(i,"yyyy-mm-dd")>
											<cfif StructKeyExists(thisKey,thisDay)>
												<cfset thisValue = StructFind(thisKey,thisDay)>
												<cfset keyTotal += thisValue>
												<td align="right">#thisValue#</td>
											<cfelse>
												<td></td>
											</cfif>
										</cfloop>
										<td align="right">#keyTotal#</td>
									</tr>
								</cfloop>
							</table>
						</cfcase>
					</cfswitch>
				</cfif>
			</div>
		</div>
	</div>
</body>
</cfoutput>
</html>

<!---
	SELECT ehMode, 
	eiTimestamp,eiType,eiPayType,eiRetail,eiTrade, SUM(eiQty) AS Qty, SUM(eiNet) AS Net, SUM(eiVAT) AS VAT,
	prodID,prodTitle, pcatID,pcatTitle, pgID,pgTitle,pgNomGroup
	FROM tblepos_items
	INNER JOIN tblepos_header ON eiParent=ehID
	INNER JOIN tblProducts ON prodID = eiProdID
	INNER JOIN tblProductCats ON pcatID = prodCatID
	INNER JOIN tblProductGroups ON pgID = pcatGroup
	WHERE eiTimestamp BETWEEN '2022-06-01' AND '2022-06-07'
	AND eiClass = 'sale'
	AND ehMode != 'wst'
	GROUP BY pgNomGroup, pgID, pcatID
	ORDER BY pgNomGroup, pgID, pcatID, prodID
--->