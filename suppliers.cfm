<!DOCTYPE html>
<html>
<head>
<title>Tran Reports</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
		
		getForm = function() {
			$.ajax({
				type: 'POST',
				url: 'eposSuppPayments.cfm',
				data: $('#search-form').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#supplier-form').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#supplier-form').html(data);
					$('#loading').fadeOut();
				}
			});
		}
		$('viewTrans').click(function() {
			getForm();
		});
	});
</script>
<style type="text/css">
	.title {font-size:12px}
	.crAmount {text-align:right; color:#FF0000; font-size:12px}
	.drAmount {text-align:right; color:#000000; font-size:12px}
	.crAmountTotal {text-align:right; color:#FF0000; font-weight:bold;}
	.drAmountTotal {text-align:right; color:#000000; font-weight:bold;}
</style>

</head>
<cftry>

<cfparam name="srchReport" default="">
<cfparam name="srchName" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchLedger" default="purch">
<cfparam name="srchMin" default="">
<cfparam name="srchType" default="">
<cfparam name="srchGroup" default="">
<cfparam name="srchPayType" default="">
<cfparam name="srchAllocated" default="1">
<cfparam name="srchIgnoreZero" default="1">
<cfparam name="srchGrossFigures" default="1">
<cfparam name="srchSort" default="accName">

<cfquery name="QGroups" datasource="#application.site.datasource1#">
	SELECT ttlValue,ttlTitle FROM tblATitles WHERE ttlType=1 ORDER BY ttlOrder
</cfquery>
<cfquery name="QPayTypes" datasource="#application.site.datasource1#">
	SELECT ttlValue,ttlTitle FROM tblATitles WHERE ttlType=2 ORDER BY ttlOrder
</cfquery>
<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" id="search-form">
						<div class="form-header">
							Transaction Reports
							<span><input type="submit" name="btnSearch" value="Search" /></span>
						</div>
						<table border="0">
							<tr>
								<td><b>Report</b></td>
								<td>
									<select name="srchReport">
										<option value="">Select...</option>
										<option value="1"<cfif srchReport eq "1"> selected="selected"</cfif>>Aged Balance Report</option>
										<option value="2"<cfif srchReport eq "2"> selected="selected"</cfif>>COD Payments Summary</option>
										<option value="3"<cfif srchReport eq "3"> selected="selected"</cfif>>COD Payments List</option>
									</select>
								</td>
							</tr>
							<tr>
								<td><b>Search by Name</b></td>
								<td><input type="text" name="srchName" value="#srchName#" size="20" /></td>
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
								<td><b>Search by Ledger Type</b></td>
								<td>
									<select name="srchLedger">
										<option value=""<cfif srchLedger eq ""> selected="selected"</cfif>>Any Type</option>
										<option value="sales"<cfif srchLedger eq "sales"> selected="selected"</cfif>>Sales</option>
										<option value="purch"<cfif srchLedger eq "purch"> selected="selected"</cfif>>Purchase</option>
										<option value="nom"<cfif srchLedger eq "nom"> selected="selected"</cfif>>Nominal</option>
									</select>
								</td>
							</tr>
							<tr>
								<td><b>Search by Transaction Types</b></td>
								<td>
									<select name="srchType">
										<option value=""<cfif srchType eq ""> selected="selected"</cfif>>All transactions</option>
										<option value="debits"<cfif srchType eq "debits"> selected="selected"</cfif>>Invoices &amp; Credit Notes</option>
										<option value="credits"<cfif srchType eq "credits"> selected="selected"</cfif>>Payments &amp; Journals</option>
									</select>
								</td>
							</tr>
							<tr>
								<td><b>Ledger Group Types</b></td>
								<td>
									<select name="srchGroup">
										<option value=""<cfif srchGroup eq ""> selected="selected"</cfif>>Any Group</option>
										<cfloop query="QGroups">
											<option value="#ttlValue#"<cfif srchGroup eq ttlValue> selected="selected"</cfif>>#ttlTitle#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td><b>Account Pay Types</b></td>
								<td>
									<select name="srchPayType">
										<option value=""<cfif srchPayType eq ""> selected="selected"</cfif>>Any Pay Types</option>
										<cfloop query="QPayTypes">
											<option value="#ttlValue#"<cfif srchPayType eq ttlValue> selected="selected"</cfif>>#ttlTitle#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td><b>Sort By</b></td>
								<td>
									<select name="srchSort">
										<option value="accID"<cfif srchSort eq "accID"> selected="selected"</cfif>>Record order</option>
										<option value="accCode"<cfif srchSort eq "accCode"> selected="selected"</cfif>>Reference</option>
										<option value="accName"<cfif srchSort eq "accName"> selected="selected"</cfif>>Name</option>
									</select>
								</td>
							</tr>
							<tr>
								<td><b>Options</b></td>
								<td><input type="checkbox" name="srchIgnoreZero" value="1"<cfif srchIgnoreZero> checked="checked"</cfif> />
									Ignore zero balances?<br>
									<input type="checkbox" name="srchAllocated" value="1"<cfif srchAllocated> checked="checked"</cfif> />
									Ignore Allocated Transactions?<br>
									<input type="checkbox" name="srchGrossFigures" value="1"<cfif srchGrossFigures> checked="checked"</cfif> />
									Show Gross Figures?
								</td>
							</tr>
						</table>
					</form>
				</div>
			</div>
			<cfif StructKeyExists(form,"fieldnames")>
				<cfsetting requesttimeout="900">
				<cfflush interval="200">
				<cfset parms={}>
				<cfset parms.datasource=application.site.datasource1>
				<cfset parms.form=form>
				<cfobject component="code/purchase" name="purch">
				<cfswitch expression="#srchReport#">
					<cfcase value="1">
						<cfset result=purch.PurchReport(parms)>
						<!---<cfdump var="#result#" label="result" expand="false">--->
						<cfset totals=[0,0,0,0,0,0,0,0,0,0,0,0,0]>
						<cfset debitCount=0>
						<h1>Suppliers Aged Balances Report</h1>
						<table class="tableList" border="1">
							<!---<tr><td colspan="15"><cfif IsStruct(result.QTransResult)>#result.QTransResult.sql#</cfif></td></tr>--->
							<tr>
								<th height="24">Ref</th>
								<th>Name</th>
								<th>Pay Type</th>
								<th width="50" align="right">Feb</th>
								<th width="50" align="right">Mar</th>
								<th width="50" align="right">Apr</th>
								<th width="50" align="right">May</th>
								<th width="50" align="right">Jun</th>
								<th width="50" align="right">Jul</th>
								<th width="50" align="right">Aug</th>
								<th width="50" align="right">Sep</th>
								<th width="50" align="right">Oct</th>
								<th width="50" align="right">Nov</th>
								<th width="50" align="right">Dec</th>
								<th width="50" align="right">Jan</th>
								<th width="50" align="right">Total</th>
							</tr>
							<cfloop array="#result.suppliers#" index="item">
								<cfset debitCount++>
								<cfset totals[2]=totals[2]+item.balance2>
								<cfset totals[3]=totals[3]+item.balance3>
								<cfset totals[4]=totals[4]+item.balance4>
								<cfset totals[5]=totals[5]+item.balance5>
								<cfset totals[6]=totals[6]+item.balance6>
								<cfset totals[7]=totals[7]+item.balance7>
								<cfset totals[8]=totals[8]+item.balance8>
								<cfset totals[9]=totals[9]+item.balance9>
								<cfset totals[10]=totals[10]+item.balance10>
								<cfset totals[11]=totals[11]+item.balance11>
								<cfset totals[12]=totals[12]+item.balance12>
								<cfset totals[1]=totals[1]+item.balance1>
								<cfset totals[13]=totals[13]+item.balance0>
								<cfset style="drAmount">
								<tr>
									<td class="title"><a href="tranmain2.cfm?acc=#item.ID#" target="_new">#item.ref#</a></td>
									<td class="title">#item.name#</td>
									<td class="title">#item.accPayType#</td>
									<cfif item.balance2 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance2 neq 0>#DecimalFormat(item.balance2)#</cfif></td>
									<cfif item.balance3 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance3 neq 0>#DecimalFormat(item.balance3)#</cfif></td>
									<cfif item.balance4 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance4 neq 0>#DecimalFormat(item.balance4)#</cfif></td>
									<cfif item.balance5 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance5 neq 0>#DecimalFormat(item.balance5)#</cfif></td>
									<cfif item.balance6 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance6 neq 0>#DecimalFormat(item.balance6)#</cfif></td>
									<cfif item.balance7 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance7 neq 0>#DecimalFormat(item.balance7)#</cfif></td>
									<cfif item.balance8 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance8 neq 0>#DecimalFormat(item.balance8)#</cfif></td>
									<cfif item.balance9 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance9 neq 0>#DecimalFormat(item.balance9)#</cfif></td>
									<cfif item.balance10 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance10 neq 0>#DecimalFormat(item.balance10)#</cfif></td>
									<cfif item.balance11 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance11 neq 0>#DecimalFormat(item.balance11)#</cfif></td>
									<cfif item.balance12 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance12 neq 0>#DecimalFormat(item.balance12)#</cfif></td>
									<cfif item.balance1 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance1 neq 0>#DecimalFormat(item.balance1)#</cfif></td>
									<cfif item.balance0 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance0 neq 0>#DecimalFormat(item.balance0)#</cfif></td>
								</tr>
							</cfloop>
							<tr>
								<cfset style="drAmountTotal">
								<td height="30">#debitCount# Suppliers</td>
								<td>Totals</td>
								<td></td>
								<cfif totals[2] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[2])#</td>
								<cfif totals[3] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[3])#</td>
								<cfif totals[4] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[4])#</td>
								<cfif totals[5] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[5])#</td>
								<cfif totals[6] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[6])#</td>
								<cfif totals[7] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[7])#</td>
								<cfif totals[8] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[8])#</td>
								<cfif totals[9] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[9])#</td>
								<cfif totals[10] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[10])#</td>
								<cfif totals[11] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[11])#</td>
								<cfif totals[12] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[12])#</td>
								<cfif totals[1] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[1])#</td>
								<cfif totals[13] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[13])#</td>
							</tr>
						</table>
					</cfcase>
					<cfcase value="2">
						<cfset result=purch.CODPaymentsReport(parms)>
						<cfdump var="#result#" label="result" expand="false">
						<cfset totals=[0,0,0,0,0,0,0,0,0,0,0,0,0]>
						<cfset debitCount=0>
						<h1>Shop COD Payments Report</h1>
						<table class="tableList" border="1">
							<tr>
								<th height="24">Ref</th>
								<th>Name</th>
								<th>Pay Type</th>
								<th width="50" align="right">Jan</th>
								<th width="50" align="right">Feb</th>
								<th width="50" align="right">Mar</th>
								<th width="50" align="right">Apr</th>
								<th width="50" align="right">May</th>
								<th width="50" align="right">Jun</th>
								<th width="50" align="right">Jul</th>
								<th width="50" align="right">Aug</th>
								<th width="50" align="right">Sep</th>
								<th width="50" align="right">Oct</th>
								<th width="50" align="right">Nov</th>
								<th width="50" align="right">Dec</th>
								<th width="50" align="right">Total</th>
							</tr>
							<cfloop array="#result.suppliers#" index="item">
								<cfset debitCount++>
								<cfset totals[2]=totals[2]+item.balance2>
								<cfset totals[3]=totals[3]+item.balance3>
								<cfset totals[4]=totals[4]+item.balance4>
								<cfset totals[5]=totals[5]+item.balance5>
								<cfset totals[6]=totals[6]+item.balance6>
								<cfset totals[7]=totals[7]+item.balance7>
								<cfset totals[8]=totals[8]+item.balance8>
								<cfset totals[9]=totals[9]+item.balance9>
								<cfset totals[10]=totals[10]+item.balance10>
								<cfset totals[11]=totals[11]+item.balance11>
								<cfset totals[12]=totals[12]+item.balance12>
								<cfset totals[1]=totals[1]+item.balance1>
								<cfset totals[13]=totals[13]+item.balance0>
								<cfset style="drAmount">
								<tr>
									<td class="title"><a href="tranmain2.cfm?acc=#item.ID#" target="_new">#item.ref#</a></td>
									<td class="title"><a href="eposSuppPayments.cfm?acc=#item.ID#" id="viewTrans" target="_new">#item.name#</a></td>
									<td class="title">#item.accPayType#</td>
									<cfif item.balance2 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance2 neq 0>#DecimalFormat(item.balance2)#</cfif></td>
									<cfif item.balance3 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance3 neq 0>#DecimalFormat(item.balance3)#</cfif></td>
									<cfif item.balance4 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance4 neq 0>#DecimalFormat(item.balance4)#</cfif></td>
									<cfif item.balance5 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance5 neq 0>#DecimalFormat(item.balance5)#</cfif></td>
									<cfif item.balance6 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance6 neq 0>#DecimalFormat(item.balance6)#</cfif></td>
									<cfif item.balance7 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance7 neq 0>#DecimalFormat(item.balance7)#</cfif></td>
									<cfif item.balance8 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance8 neq 0>#DecimalFormat(item.balance8)#</cfif></td>
									<cfif item.balance9 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance9 neq 0>#DecimalFormat(item.balance9)#</cfif></td>
									<cfif item.balance10 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance10 neq 0>#DecimalFormat(item.balance10)#</cfif></td>
									<cfif item.balance11 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance11 neq 0>#DecimalFormat(item.balance11)#</cfif></td>
									<cfif item.balance12 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance12 neq 0>#DecimalFormat(item.balance12)#</cfif></td>
									<cfif item.balance1 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance1 neq 0>#DecimalFormat(item.balance1)#</cfif></td>
									<cfif item.balance0 lt 0><cfset style="crAmount"><cfelse><cfset style="drAmount"></cfif>
									<td class="#style#"><cfif item.balance0 neq 0>#DecimalFormat(item.balance0)#</cfif></td>
								</tr>
							</cfloop>
							<tr>
								<cfset style="drAmountTotal">
								<td height="30">#debitCount# Suppliers</td>
								<td>Totals</td>
								<td></td>
								<cfif totals[2] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[2])#</td>
								<cfif totals[3] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[3])#</td>
								<cfif totals[4] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[4])#</td>
								<cfif totals[5] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[5])#</td>
								<cfif totals[6] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[6])#</td>
								<cfif totals[7] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[7])#</td>
								<cfif totals[8] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[8])#</td>
								<cfif totals[9] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[9])#</td>
								<cfif totals[10] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[10])#</td>
								<cfif totals[11] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[11])#</td>
								<cfif totals[12] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[12])#</td>
								<cfif totals[1] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[1])#</td>
								<cfif totals[13] lt 0><cfset style="crAmountTotal"><cfelse><cfset style="drAmountTotal"></cfif>
								<td class="#style#">#DecimalFormat(totals[13])#</td>
							</tr>
						</table>
					</cfcase>
					<cfcase value="3">
						<cfset result = purch.CODPaymentsList(parms)>
						<table class="tableList" border="1">
							<tr>
								<th colspan="4">Shop COD Payments List</th>
							</tr>
							<tr>
								<th>ID</th>
								<th>Account Name</th>
								<th>Date</th>
								<th>Amount</th>
							</tr>
							<cfset suppID = 0>
							<cfset suppTotal = 0>
							<cfset grandTotal = 0>
							<cfset dayTotals = {}>
							<cfloop query="result.QTrans">
								<cfif suppID gt 0 AND suppID neq accID>
									<tr>
										<th></th>
										<th>Total</th>
										<th></th>
										<th align="right">#DecimalFormat(suppTotal)#</th>
									</tr>
									<cfset suppTotal = 0>
								</cfif>
								<cfset suppID = accID>
								<cfset suppTotal += eiNet>
								<cfset grandTotal += eiNet>
								<cfset tranDate = DateFormat(eiTimestamp,'yyyy-mm-dd')>
								<cfif StructKeyExists(dayTotals,tranDate)>
									<cfset currTotal = StructFind(dayTotals,tranDate)>
									<cfset StructUpdate(dayTotals,tranDate,currTotal+eiNet)>
								<cfelse>
									<cfset StructInsert(dayTotals,tranDate,eiNet)>
								</cfif>
								<tr>
									<td>#accID#</td>
									<td>#accName#</td>
									<td align="right">#DateFormat(eiTimestamp,'ddd dd-mmm-yy')#</td>
									<td align="right">#eiNet#</td>
								</tr>
							</cfloop>
							<tr>
								<th></th>
								<th>Total</th>
								<th align="right"></th>
								<th align="right">#DecimalFormat(suppTotal)#</th>
							</tr>
							<tr>
								<th></th>
								<th>Grand Total</th>
								<th align="right"></th>
								<th align="right">#DecimalFormat(grandTotal)#</th>
							</tr>
						</table>
						<p>&nbsp;</p>
						<table class="tableList" border="1">
							<tr>
								<th colspan="2">Week Totals</th>
							</tr>
							<tr>
								<th>Date</th>
								<th>Total</th>
							</tr>
							<cfset keyList = ListSort(StructKeyList(result.weekends,","),"text","asc")>
							<cfloop list="#keyList#" index="key">
								<cfset keyDate = "#left(key,4)#-#mid(key,5,2)#-#right(key,2)#">
								<cfset value = StructFind(result.weekends,key)>
								<tr>
									<td>#DateFormat(keyDate,'ddd dd-mmm-yy')#</td>
									<td align="right">#value#</td>
								</tr>
							</cfloop>
							<tr>
								<th>Grand Total</th>
								<th align="right">#DecimalFormat(result.grandTotal)#</th>
							</tr>
						</table>
					</cfcase>
				</cfswitch>
			</cfif>
			<div class="clear"></div>
			<div id="supplier-form"></div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
</body>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="suppliers" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</html>
