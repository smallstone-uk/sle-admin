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
	<style type="text/css">
		.header {font-size:16px; font-weight:bold;}
		.amount {text-align:right}
		.amountTotal {text-align:right; font-weight:bold;}
		.tranList {	
			font-family:Arial, Helvetica, sans-serif;
			font-size:12px;
			border-collapse:collapse;
		}
		.tranList th, .tranList td {
			padding:2px 4px; 
			border: solid 1px #ccc;
			background-color:#fff;
		}
		.vatTable {
			margin:10px;
			border-spacing: 0px;
			border-collapse: collapse;
			border: 1px solid #CCC;
			font-size: 16px;
		}
		.vatTable th {padding: 5px; background:#eee; border-color: #ccc;}
		.vatTable td {padding: 5px; border-color: #ccc;}
		.err {background-color:#FF0000}
		.ok {background-color:#00DF00}
		.summary {font-size:11px; color:#0033FF;}
		.salesHeader { background-color:#0F3;}
		.purchHeader { background-color:#09F;}
		.nomHeader { background-color:#FF3;}
		.vatHeader {background-color:#FC9;}
	</style>
</head>
<cfsetting requesttimeout="900">
<cfparam name="srchReport" default="1">
<cfparam name="srchAccount" default="">
<cfparam name="srchExclude" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchSort" default="1">

<cfobject component="code/vatReport" name="report">
<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>


<cfquery name="QAccounts" datasource="#parms.datasource#">
	SELECT eaID, eaTitle
	FROM tblepos_account
	WHERE 1
	ORDER BY eaTitle
</cfquery>
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
											<option value="3"<cfif srchReport eq "3"> selected="selected"</cfif>>VAT Transactions</option>
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
								<tr>
									<td><b>Select Accounts</b></td>
									<td>
										<select name="srchAccount" class="srchAccount" multiple="multiple" data-placeholder="Select...">
											<cfloop query="QAccounts">
												<option value="#eaID#"<cfif eaID eq srchAccount> selected="selected"</cfif>>#eaTitle#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Options</b></td>
									<td>
										<input type="checkbox" name="srchExclude" value="1" /> Exclude the above accounts?
									</td>
								</tr>
								<tr>
									<td><b>Sort By</b></td>
									<td>
										<select name="srchSort">
											<option value="1"<cfif srchSort eq "1"> selected="selected"</cfif>>Nominal Code</option>
											<option value="2"<cfif srchSort eq "2"> selected="selected"</cfif>>Account Code</option>
										</select>
									</td>
								</tr>
							</table>
						</div>
					</form>
				</div>
				<cfif StructKeyExists(form,"fieldnames")>
					<cfswitch expression="#srchReport#">
						<cfcase value="1">
							<!--- Shop Sales --->
							<cfquery name="QSaleItems" datasource="#parms.datasource#" result="QSaleItemsResult">
								SELECT ehMode, ehPayAcct,
								eiTimestamp,eiType,eiPayType,eiRetail,eiTrade, SUM(eiQty) AS Qty, -SUM(eiNet) AS Net, -SUM(eiVAT) AS VAT, SUM(eiTrade) AS Trade,
								pgID,pgTitle,pgNomGroup
								FROM tblepos_items
								INNER JOIN tblepos_header ON eiParent=ehID
								INNER JOIN tblProducts ON prodID = eiProdID
								INNER JOIN tblProductCats ON pcatID = prodCatID
								INNER JOIN tblProductGroups ON pgID = pcatGroup
								WHERE eiTimestamp BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
								AND eiClass = 'sale'
								<!---AND ehMode != 'wst'--->
								<cfif len(srchAccount)>
									<cfif StructKeyExists(form,"srchExclude")>
										AND ehPayAcct NOT IN (#srchAccount#)
									<cfelse>
										AND ehPayAcct IN (#srchAccount#)
									</cfif>
								</cfif>
								GROUP BY pgNomGroup, pgTitle
								ORDER BY pgNomGroup, pgTitle
							</cfquery>
							<!---<cfdump var="#QSaleItemsResult#" label="QItems" expand="false">--->
							
							<cfset summary = {
								"box1" = {"title" = "VAT due on sales and other outputs", "value" = 0},
								"box2" = {"title" = "VAT due on acquisitions from other EC States", "value" = 0},
								"box3" = {"title" = "Total VAT due (sum of boxes 1 & 2)", "value" = 0},
								"box4" = {"title" = "VAT reclaimed on purchases", "value" = 0},
								"box5" = {"title" = "Net VAT payable or repayable", "value" = 0},
								"box6" = {"title" = "Total value of sales", "value" = 0},
								"box7" = {"title" = "Total value of purchases", "value" = 0},
								"box8" = {"title" = "Total value of supplies from EC States", "value" = 0},
								"box9" = {"title" = "Total value of acquisitions from EC States", "value" = 0}
							}>

							<cfset totNet = 0>
							<cfset totVAT = 0>
							<cfset totQty = 0>
							<cfset totTrd = 0>
							<cfset totPrf = 0>
							<cfset POR = 0>
							<table border="1" class="tableList">
								<tr>
									<td class="salesHeader" colspan="8"><h1>Shop Sales</h1></td>
								</tr>
								<tr>
									<th width="60">Group</th>
									<th>Description</th>
									<th width="60">QTY</th>
									<th width="60">NET</th>
									<th width="60">VAT</th>
									<th width="60">Trade</th>
									<th width="60">Profit</th>
									<th width="60">POR%</th>
								</tr>
								<cfset lineCount = 0>
								<cfloop query="QSaleItems">
									<cfset totNet += Net>
									<cfset totVAT += VAT>
									<cfset totQty += Qty>
									<cfset totTrd += Trade>
									<cfset profit = (Net - Trade)>
									<cfset totPrf += profit>
									<cfset lineCount++>
									<cfif Net neq 0>
										<cfset POR = Round((profit / Net) * 100)>
									</cfif>
									<tr>
										<td>#pgNomGroup#</td>
										<td>#pgTitle#</td>
										<td align="center">#NumberFormat(Qty,",")#</td>
										<td align="right">#DecimalFormat(Net)#</td>
										<td align="right">#DecimalFormat(VAT)#</td>
										<td align="right">#DecimalFormat(Trade)#</td>
										<td align="right">#DecimalFormat(profit)#</td>
										<td align="right">#POR#%</td>
									</tr>
								</cfloop>
								<cfif totNet neq 0>
									<cfset POR = Round((totPrf / totNet) * 100)>
								</cfif>
								<tr>
									<th align="center">#lineCount#</th>
									<th>TOTALS</th>
									<th align="center">#NumberFormat(totQty,",")#</th>
									<th align="right">#DecimalFormat(totNet)#</th>
									<th align="right">#DecimalFormat(totVAT)#</th>
									<th align="right">#DecimalFormat(totTrd)#</th>
									<th align="right">#DecimalFormat(totPrf)#</th>
									<th>#POR#%</th>
								</tr>
							</table>
							<cfset summary.box1.value = totVAT>				
							<cfset summary.box3.value = totVAT>				
							<cfset summary.box6.value = totNet>
							
							<!--- News Sales --->
							<cfquery name="QNewTrans" datasource="#parms.datasource#">
								SELECT trnDate,trnType, SUM(trnAmnt1) AS TOTAL, Count(*) AS Num 
								FROM tbltrans
								WHERE trnAccountID = 4 
								AND trnType IN ('inv','crn')
								AND trnDate BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
								GROUP BY trnDate ASC, trnType;
							</cfquery>
							<table border="1" class="tableList">
								<tr>
									<td class="salesHeader" colspan="8"><h1>News Sales</h1></td>
								</tr>
								<tr>
									<th width="40">Line</th>
									<th width="100">Date</th>
									<th width="40">Type</th>
									<th width="60">Qty</th>
									<th width="60">Total</th>
									<th width="180" colspan="3"></th>
								</tr>
								<cfset totNet = 0>
								<cfset newsTotal = 0>
								<cfset newsCount = 0>
								<cfset lineCount = 0>
								<cfloop query="QNewTrans">
									<cfset lineCount++>
									<cfset newsTotal += TOTAL>
									<cfset newsCount += NUM>
									<cfset totNet += TOTAL>
									<tr>
										<td>#lineCount#</td>
										<td>#LSDateFormat(trnDate,"dd-mmm-yyyy")#</td>
										<td>#trnType#</td>
										<td align="center">#NumberFormat(NUM,",")#</td>
										<td align="right">#DecimalFormat(TOTAL)#</td>
										<td align="right" colspan="3"></td>
									</tr>
								</cfloop>
								<tr>
									<th></th>
									<th></th>
									<th></th>
									<th>#NumberFormat(newsCount,",")#</th>
									<th>#DecimalFormat(newsTotal)#</th>
									<th width="30" colspan="3"></th>
								</tr>
							</table>
							<cfset summary.box6.value += totNet>
															
							<!--- Purchases --->		
							<div style="page-break-before:always"></div>
							<cfquery name="QPurItems" datasource="#parms.datasource#">
								SELECT trnDate, nomID,nomGroup,nomCode,nomTitle, SUM(niAmount) AS Amount, SUM(niVATAmount) AS VATAmount, Count(*) AS Num
								FROM `tbltrans` 
								INNER JOIN tblAccount ON accID = trnAccountID
								INNER JOIN tblnomitems ON niTranID = trnID
								INNER JOIN tblNominal ON niNomID = nomID
								WHERE nomID NOT IN (11,201)
								AND `trnLedger` IN ('purch','nom')
								AND `trnType` IN ('inv','crn','nom')
								AND nomGroup > 'A' AND nomGroup < 'C'
								AND trnDate BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
								GROUP BY nomGroup, nomCode
							</cfquery>
							<cfset lineCount = 0>
							<cfset nomFlag = 0>
							<cfset totNet = 0>
							<cfset totVAT = 0>
							<cfset totQty = 0>
							<table border="1" class="tableList">
								<tr>
									<td class="purchHeader" colspan="8"><h1>Purchases</h1></td>
								</tr>
								<tr>
									<th width="60">Group</th>
									<th width="60">Code</th>
									<th>Description</th>
									<th width="60">QTY</th>
									<th width="60">DR</th>
									<th width="60">CR</th>
									<th width="60">VAT</th>
									<th width="60"></th>
								</tr>
								<cfloop query="QPurItems">
									<cfset lineCount++>
									<cfset totNet += Amount>
									<cfset totQty += Num>
									<cfset totVAT += VATAmount>
									<tr>
										<td>#nomGroup#</td>
										<td>#nomCode#</td>
										<td>#nomTitle#</td>
										<td align="center">#NumberFormat(Num,",")#</td>
										<td align="right">#DecimalFormat(Amount)#</td>
										<td align="right"></td>
										<td align="right">#DecimalFormat(VATAmount)#</td>
										<td align="right"></td>
									</tr>
								</cfloop>
								<tr>
									<th align="center">#lineCount#</th>
									<th colspan="2">TOTALS</th>
									<th align="center">#NumberFormat(totQty,",")#</th>
									<th align="right">#DecimalFormat(totNet)#</th>
									<th></th>
									<th align="right">#DecimalFormat(totVAT)#</th>
									<th width="30"></th>
								</tr>
							</table>
							<cfset summary.box4.value += totVAT>
							<cfset summary.box7.value += totNet>				
							
							<!--- Running Costs --->
							<cfquery name="QCostItems" datasource="#parms.datasource#">
								SELECT trnDate, nomID,nomGroup,nomCode,nomTitle, SUM(niAmount) AS Amount, SUM(niVATAmount) AS VATAmount, Count(*) AS Num
								FROM `tbltrans` 
								INNER JOIN tblAccount ON accID = trnAccountID
								INNER JOIN tblnomitems ON niTranID = trnID
								INNER JOIN tblNominal ON niNomID = nomID
								WHERE nomID NOT IN (11,201)
								AND `trnLedger` IN ('purch','nom')
								AND `trnType` IN ('inv','crn','nom')
								AND nomGroup >= 'C' AND nomGroup <= 'F'
								AND trnDate BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
								GROUP BY nomGroup, nomCode
							</cfquery>
							<cfset lineCount = 0>
							<cfset totNet = 0>
							<cfset totVAT = 0>
							<cfset totQty = 0>
							<table border="1" class="tableList">
								<tr>
									<td class="nomHeader" colspan="8"><h1>Operating Costs</h1></td>
								</tr>
								<tr>
									<th width="60">Group</th>
									<th width="60">Code</th>
									<th>Description</th>
									<th width="60">QTY</th>
									<th width="60">DR</th>
									<th width="60">CR</th>
									<th width="60">VAT</th>
									<th width="60"></th>
								</tr>
								<cfloop query="QCostItems">
									<cfset lineCount++>
									<cfset totNet += AMOUNT>
									<cfset totQty += NUM>
									<cfset totVAT += VATAmount>
									<tr>
										<td>#nomGroup#</td>
										<td>#nomCode#</td>
										<td>#nomTitle#</td>
										<td align="center">#NumberFormat(NUM,",")#</td>
										<td align="right">#DecimalFormat(AMOUNT)#</td>
										<td align="right"></td>
										<td align="right">#DecimalFormat(VATAmount)#</td>
										<td align="right"></td>
									</tr>
								</cfloop>
								<tr>
									<th width="60" align="center">#lineCount#</th>
									<th colspan="2">TOTALS</th>
									<th width="60" align="center">#NumberFormat(totQty,",")#</th>
									<th width="60" align="right">#DecimalFormat(totNet)#</th>
									<th></th>
									<th width="60" align="right">#DecimalFormat(totVAT)#</th>
									<th width="60"></th>
								</tr>
							</table>
							<cfset summary.box4.value += totVAT>
							<cfset summary.box7.value += totNet>

							<!--- Other Nominal Accounts --->
							<cfquery name="QOtherItems" datasource="#parms.datasource#">
								SELECT trnDate, nomID,nomGroup,nomCode,nomTitle, SUM(niAmount) AS Amount, SUM(niVATAmount) AS VATAmount, Count(*) AS Num
								FROM `tbltrans` 
								INNER JOIN tblAccount ON accID = trnAccountID
								INNER JOIN tblnomitems ON niTranID = trnID
								INNER JOIN tblNominal ON niNomID = nomID
								WHERE nomID NOT IN (11,201)
								AND `trnLedger` IN ('purch','nom')
								AND `trnType` IN ('inv','crn','nom')
								AND nomGroup > 'F'
								AND trnDate BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
								GROUP BY nomGroup, nomCode
							</cfquery>
							<cfset lineCount = 0>
							<cfset totNet = 0>
							<cfset totVAT = 0>
							<cfset totQty = 0>
							<table border="1" class="tableList">
								<tr>
									<td class="nomHeader" colspan="8"><h1>Other Nominal Accounts</h1></td>
								</tr>
								<tr>
									<th width="60">Group</th>
									<th width="60">Code</th>
									<th>Description</th>
									<th width="60">QTY</th>
									<th width="60">DR</th>
									<th width="60">CR</th>
									<th width="60">VAT</th>
									<th width="60"></th>
								</tr>
								<cfloop query="QOtherItems">
									<cfset lineCount++>
									<cfset totNet += AMOUNT>
									<cfset totQty += NUM>
									<cfset totVAT += VATAmount>
									<tr>
										<td>#nomGroup#</td>
										<td>#nomCode#</td>
										<td>#nomTitle#</td>
										<td align="center">#NumberFormat(NUM,",")#</td>
										<td align="right">#DecimalFormat(AMOUNT)#</td>
										<td align="right"></td>
										<td align="right">#DecimalFormat(VATAmount)#</td>
										<td align="right"></td>
									</tr>
								</cfloop>
								<tr>
									<th align="center">#lineCount#</th>
									<th colspan="2">TOTALS</th>
									<th align="center">#NumberFormat(totQty,",")#</th>
									<th align="right">#DecimalFormat(totNet)#</th>
									<th></th>
									<th align="right">#DecimalFormat(totVAT)#</th>
									<th width="60"></th>
								</tr>
							</table>
<!---
									<cfif nomGroup gte "C" AND nomFlag eq 0>
										<tr>
											<th align="center">#lineCount#</th>
											<th colspan="2">TOTALS</th>
											<th align="center">#NumberFormat(totQty,",")#</th>
											<th align="right">#DecimalFormat(totNet)#</th>
											<th></th>
											<th align="right">#DecimalFormat(totVAT)#</th>
											<th width="30"></th>
										</tr>
										<tr>
											<td class="nomHeader" colspan="8"><h1>Costs</h1></td>
										</tr>
										<cfset summary.box4.value += totVAT>
										<cfset summary.box7.value += totNet>				
										
										<cfset lineCount = 0>
										<cfset totNet = 0>
										<cfset totVAT = 0>
										<cfset totQty = 0>
										<cfset nomFlag++>
									</cfif>
									<cfif nomGroup gt "F" AND nomFlag eq 1>
										<tr>
											<th width="60" align="center">#lineCount#</th>
											<th colspan="2">TOTALS</th>
											<th width="60" align="center">#NumberFormat(totQty,",")#</th>
											<th width="60" align="right">#DecimalFormat(totNet)#</th>
											<th></th>
											<th width="60" align="right">#DecimalFormat(totVAT)#</th>
											<th width="60"></th>
										</tr>
										<tr>
											<td class="nomHeader" colspan="8"><h1>Nominal</h1></td>
										</tr>
										<!---<cfset summary.box4.value += totVAT>
										<cfset summary.box7.value += totNet>	--->
													
										<cfset lineCount = 0>
										<cfset totNet = 0>
										<cfset totVAT = 0>
										<cfset totQty = 0>
										<cfset nomFlag++>
									<cfelseif nomCode neq "VAT">
										<cfset totNet += AMOUNT>
										<cfset totQty += NUM>
										<cfset totVAT += VATAmount>
										<tr>
											<td>#nomGroup#</td>
											<td>#nomCode#</td>
											<td>#nomTitle#</td>
											<td align="center">#NumberFormat(NUM,",")#</td>
											<td align="right">#DecimalFormat(AMOUNT)#</td>
											<td align="right"></td>
											<td align="right">#DecimalFormat(VATAmount)#</td>
											<td align="right"></td>
										</tr>
									<cfelse>
										<tr>
											<td>#nomGroup#</td>
											<td>#nomCode#</td>
											<td>#nomTitle#</td>
											<td align="center">#NumberFormat(NUM,",")#</td>
											<td align="right"></td>
											<td align="right">#AMOUNT#</td>
											<td align="right"></td>
											<td align="right"></td>
										</tr>
									</cfif>
								</cfloop>
								<tr>
									<th align="center">#lineCount#</th>
									<th colspan="2">TOTALS</th>
									<th align="center">#NumberFormat(totQty,",")#</th>
									<th align="right">#DecimalFormat(totNet)#</th>
									<th></th>
									<th align="right">#DecimalFormat(totVAT)#</th>
									<th width="60"></th>
								</tr>
							</table>
							<cfset summary.box4.value += totVAT>
							<cfset summary.box7.value += totNet>				
--->
							<cfset summary.box5.value = summary.box1.value - summary.box4.value>
							<table class="vatTable" border="1">
								<tr>
									<td class="vatHeader" colspan="2"><h1>VAT Summary</h1></td>
								</tr>
								<cfset boxKeys = ListSort(StructKeyList(summary,","),"text","asc",",")>
								<cfloop list="#boxKeys#" index="boxKey">
									<cfset box = StructFind(summary,boxKey)>
									<cfif boxKey eq "box5" and box.value lt 0>
										<cfset style = "color:red;">
										<cfset title = "(refund)">
									<cfelse>
										<cfset style = "">
										<cfset title = "">
									</cfif>
									<tr>
										<td style="#style#">#box.title# #title#</td><td style="#style#" align="right">#DecimalFormat(box.value)#</td>
									</tr>
								</cfloop>
							</table>
							<br /><br />
						</cfcase>
						
						<cfcase value="2">
							<cfset salKeys = {}>
							<cfset purKeys = {}>
							<cfset dateTo = LSDateFormat(DateAdd("d",1,srchDateTo),"yyyy-mm-dd")>
							<cfquery name="QSaleItems" datasource="#parms.datasource#">
								SELECT ehMode, ehPayAcct,
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
						<cfcase value="3">
							<!--- VAT Transactions --->
							<cfset data = report.TransactionList(parms)>
							<cfset sortCode = "">
							<!---<cfdump var="#data#" label="data" expand="false">--->
							<table border="1" class="tableList" width="100%">
								<tr>
									<th>Account Code</th>
									<th>Account Name</th>
									<th>Tran ID</th>
									<th width="100">Date</th>
									<th>Reference</th>
									<th>Description</th>
									<!---<th align="right">Tran Net</th>
									<th align="right">Tran VAT</th>--->
									<th align="right">Item Net</th>
									<th align="right">Item VAT</th>
									<th align="right">VAT Rate</th>
									<th>Nom Code</th>
									<th width="180">Description</th>
								</tr>
								<cfloop query="data.QTrans">
									<cfif srchSort eq 1><cfset thisCode = NOMCODE>
										<cfelse><cfset thisCode = ACCCODE></cfif>
									<cfif len(sortCode) AND sortCode neq thisCode>
										<cfset tots = StructFind(data.totals,sortCode)>
										<tr>
											<th colspan="3">#tots.title#</th>
											<th colspan="3">#tots.num# transactions</th>
											<th align="right">#DecimalFormat(tots.net)#</th>
											<th align="right">#DecimalFormat(tots.vat)#</th>
											<th colspan="3"></th>
										</tr>
									</cfif>
									<cfif srchSort eq 1><cfset sortCode = NOMCODE>
										<cfelse><cfset sortCode = ACCCODE></cfif>
									<tr>
										<td>#ACCCODE#</td>
										<td>#ACCNAME#</td>
										<td>#TRNID#</td>
										<td>#LSDateFormat(TRNDATE,"dd-mmm-yy")#</td>
										<td>#TRNREF#</td>
										<td>#TRNDESC#</td>
										<!---<td align="right">#DecimalFormat(TRNAMNT1)#</td>
										<td align="right">#DecimalFormat(TRNAMNT2)#</td>--->
										<td align="right">#DecimalFormat(NIAMOUNT)#</td>
										<td align="right">#DecimalFormat(NIVATAMOUNT)#</td>
										<td align="right">#NIVATRATE#%</td>
										<td>#NOMCODE#</td>
										<td>#NOMTITLE#</td>
									</tr>
								</cfloop>
								<!--- last one --->
								<cfset tots = StructFind(data.totals,sortCode)>
								<tr>
									<th colspan="3">#tots.title#</th>
									<th colspan="3">#tots.num# transactions</th>
									<th align="right">#DecimalFormat(tots.net)#</th>
									<th align="right">#DecimalFormat(tots.vat)#</th>
									<th colspan="3"></th>
								</tr>
								<!--- grand total --->
								<cfset tots = StructFind(data.totals,"zzGrand")>
								<tr>
									<th colspan="3">#tots.title#</th>
									<th colspan="3">#tots.num# transactions</th>
									<th align="right">#DecimalFormat(tots.net)#</th>
									<th align="right">#DecimalFormat(tots.vat)#</th>
									<th colspan="3"></th>
								</tr>
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