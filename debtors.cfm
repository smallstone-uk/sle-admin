<!DOCTYPE html>
<html>
<head>
<title>Aged Debtors</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/report.css" rel="stylesheet" type="text/css">
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
	});
</script>
<style type="text/css">
	.drAmount {text-align:right; color:#000;}
	.crAmount {text-align:right; color:#F00;}
	.amountTotal {text-align:right; font-weight:bold;}
@media print {
	.noPrint {display:none;}
}
</style>

</head>

<cfparam name="srchReport" default="1">
<cfparam name="srchType" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchMethod" default="">
<cfparam name="srchPayType" default="">
<cfparam name="srchName" default="">
<cfparam name="srchSort" default="">
<cfparam name="srchSkipAllocated" default="true">
<cfparam name="srchSkipZeros" default="true">
<body>
	<cfoutput>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap noPrint">
					<form method="post">
						<input type="hidden" name="srchMin" value="0" />
						<div class="form-header">
							Aged Debtors
							<span><input type="submit" name="btnSearch" value="Search" /></span>
						</div>
						<table border="0">
							<tr>
								<td><b>Report</b></td>
								<td>
									<select name="srchReport">
										<option value="">Select...</option>
										<option value="1"<cfif srchReport eq "1"> selected="selected"</cfif>>Aged Debtors</option>
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
								<td><strong>Search by Account Type</strong></td>
								<td>
									<select name="srchType">
										<option value=""<cfif srchType eq ""> selected="selected"</cfif>>Any Type</option>
										<option value="M"<cfif srchType eq "M"> selected="selected"</cfif>>Monthly</option>
										<option value="W"<cfif srchType eq "W"> selected="selected"</cfif>>Weekly</option>
										<option value="N"<cfif srchType eq "N"> selected="selected"</cfif>>No Credit</option>
										<option value="C"<cfif srchType eq "C"> selected="selected"</cfif>>A/c Collect</option>
										<option value="X"<cfif srchType eq "X"> selected="selected"</cfif>>Special</option>
										<option value="Z"<cfif srchType eq "Z"> selected="selected"</cfif>>Unknown</option>
										<option value="notN"<cfif srchType eq "notN"> selected="selected"</cfif>>All except No Credit</option>
									</select>
								</td>
							</tr>
							<tr>
								<td>Search by Payment Type</td>
								<td>
									<select name="srchPayType">
										<option value=""<cfif srchPayType eq ""> selected="selected"</cfif>>Any Type</option>
										<option value="post"<cfif srchPayType eq "post"> selected="selected"</cfif>>post</option>
										<option value="bacs"<cfif srchPayType eq "bacs"> selected="selected"</cfif>>bacs</option>
										<option value="collect"<cfif srchPayType eq "collect"> selected="selected"</cfif>>collect</option>
										<option value="shop"<cfif srchPayType eq "shop"> selected="selected"</cfif>>shop</option>
									</select>
								</td>
							</tr>
							<tr>
								<td>Search by Payment Method</td>
								<td>
									<select name="srchMethod">
										<option value=""<cfif srchMethod eq ""> selected="selected"</cfif>>Any Method</option>
										<option value="cash"<cfif srchMethod eq "cash"> selected="selected"</cfif>>Cash</option>
										<option value="chq"<cfif srchMethod eq "chq"> selected="selected"</cfif>>Cheque</option>
										<option value="card"<cfif srchMethod eq "card"> selected="selected"</cfif>>Card Payment</option>
										<option disabled>-----------------</option>
										<option value="coll"<cfif srchMethod eq "coll"> selected="selected"</cfif>>Cash Collected</option>
										<option value="phone"<cfif srchMethod eq "phone"> selected="selected"</cfif>>Card by Phone</option>
										<option value="ib"<cfif srchMethod eq "ib"> selected="selected"</cfif>>Internet Banking</option>
										<option value="acct"<cfif srchMethod eq "acct"> selected="selected"</cfif>>Shop Credit Account</option>
										<option value="qs"<cfif srchMethod eq "qs"> selected="selected"</cfif>>Paid via Quickstop</option>
									</select>
								</td>
							</tr>
							<tr>
								<td>Search by Name</td>
								<td><input type="text" name="srchName" size="20" value="#srchName#" /></td>
							</tr>
							<tr>
								<td>Skip Allocated Transactions</td>
								<td><input type="checkbox" name="srchSkipAllocated" value="1"<cfif srchSkipAllocated> checked="checked"</cfif> /></td>
							</tr>
							<tr>
								<td>Skip Zero Balance</td>
								<td><input type="checkbox" name="srchSkipZeros" value="1"<cfif srchSkipZeros> checked="checked"</cfif> /></td>
							</tr>
							<tr>
								<td>Sort By</td>
								<td>
									<select name="srchSort">
										<option value="cltRef"<cfif srchSort eq "cltRef"> selected="selected"</cfif>>Reference</option>
										<option value="cltName"<cfif srchSort eq "cltName"> selected="selected"</cfif>>Name</option>
										<option value="cltBalance"<cfif srchSort eq "cltBalance"> selected="selected"</cfif>>Balance</option>
										<option value="cltChaseDate"<cfif srchSort eq "cltChaseDate"> selected="selected"</cfif>>Date Chased</option>
									</select>
								</td>
							</tr>
						</table>
					</form>
				</div>
			</div>
		</div>
	</div>
	
	</cfoutput>
	<cfif StructKeyExists(form,"fieldnames")>

		<cffunction name="showNum" access="private" returntype="string">
			<cfargument name="theNum" type="numeric" required="yes">
			<cfif theNum lt 0>
				<cfreturn '<span class="crAmount">#DecimalFormat(theNum)#</span>'>
			<cfelseif theNum gt 0>
				<cfreturn '<span class="drAmount">#DecimalFormat(theNum)#</span>'>
			</cfif>
			<cfreturn "">
		</cffunction>

		<cfsetting requesttimeout="900">
		<cfflush interval="200">
		<cfset parms={}>
		<cfset parms.datasource=application.site.datasource1>
		<cfset parms.form=form>
		<cfobject component="code/functions" name="func">
		<cfset debtors=func.AgedDebtors(parms)>

		<cfset totals=[0,0,0,0,0]>
		<cfset credits=[0,0,0,0,0]>
		<cfset debitCount=0>
		<cfset creditCount=0>
		<cfoutput>
			<table border="1" class="tableList">
				<tr>
					<th height="24" align="right">Ref</th>
					<th>Name</th>
					<th>Type</th>
					<th>Pay Type</th>
					<th>Method</th>
					<th width="60" align="right">28 days</th>
					<th width="60" align="right">56 Days</th>
					<th width="60" align="right">84 Days</th>
					<th width="60" align="right">112+ Days</th>
					<th width="60" align="right">Balance</th>
					<th width="40" align="left">Level</th>
					<th width="90" align="left">Chased</th>
				</tr>
				<cfif parms.form.srchSort eq "cltBalance">
					<cfloop array="#debtors.balances#" index="key">
						<cfset key = val(ListLast(key,"_"))>
						<cfset item = debtors.clients[key]>
						<cfif item.balance0 lt 0>	<!--- ooo that's nasty - duplicated code! --->
							<cfset style="credit">
							<cfset creditCount++>
							<cfset credits[1]=credits[1]+item.balance1>
							<cfset credits[2]=credits[2]+item.balance2>
							<cfset credits[3]=credits[3]+item.balance3>
							<cfset credits[4]=credits[4]+item.balance4>
							<cfset credits[5]=credits[5]+item.balance0>
						<cfelse>
							<cfset style="amount">
							<cfset debitCount++>
							<cfset totals[1]=totals[1]+item.balance1>
							<cfset totals[2]=totals[2]+item.balance2>
							<cfset totals[3]=totals[3]+item.balance3>
							<cfset totals[4]=totals[4]+item.balance4>
							<cfset totals[5]=totals[5]+item.balance0>
						</cfif>
						<tr>
							<td><a href="clientDetails.cfm?ref=#item.ref#" target="#item.ref#1" title="view statement">#item.ref#</a></td>
							<td><a href="clientPayments.cfm?rec=#item.ref#" target="#item.ref#2" title="view statement">#item.name#</a></td>
							<td align="center">#item.type#</td>
							<td align="center">#item.cltPayType#</td>
							<td align="center">#item.methodKey#</td>
							<td class="#style#">#showNum(item.balance1)#</td>
							<td class="#style#">#showNum(item.balance2)#</td>
							<td class="#style#">#showNum(item.balance3)#</td>
							<td class="#style#">#showNum(item.balance4)#</td>
							<td class="#style#"><strong>#showNum(item.balance0)#</strong></td>
							<td align="center">#item.cltChase#</td>
							<td>#LSDateFormat(item.cltChaseDate)#</td>
						</tr>
					</cfloop>
				<cfelse>
					<cfloop array="#debtors.clients#" index="item">
						<cfif item.balance0 lt 0>
							<cfset style="credit">
							<cfset creditCount++>
							<cfset credits[1]=credits[1]+item.balance1>
							<cfset credits[2]=credits[2]+item.balance2>
							<cfset credits[3]=credits[3]+item.balance3>
							<cfset credits[4]=credits[4]+item.balance4>
							<cfset credits[5]=credits[5]+item.balance0>
						<cfelse>
							<cfset style="amount">
							<cfset debitCount++>
							<cfset totals[1]=totals[1]+item.balance1>
							<cfset totals[2]=totals[2]+item.balance2>
							<cfset totals[3]=totals[3]+item.balance3>
							<cfset totals[4]=totals[4]+item.balance4>
							<cfset totals[5]=totals[5]+item.balance0>
						</cfif>
						<tr>
							<td><a href="clientDetails.cfm?ref=#item.ref#" target="#item.ref#1" title="view statement">#item.ref#</a></td>
							<td><a href="clientPayments.cfm?rec=#item.ref#" target="#item.ref#2" title="view statement">#item.name#</a></td>
							<td align="center">#item.type#</td>
							<td align="center">#item.cltPayType#</td>
							<td align="center">#item.methodKey#</td>
							<td class="#style#">#showNum(item.balance1)#</td>
							<td class="#style#">#showNum(item.balance2)#</td>
							<td class="#style#">#showNum(item.balance3)#</td>
							<td class="#style#">#showNum(item.balance4)#</td>
							<td class="#style#"><strong>#showNum(item.balance0)#</strong></td>
							<td align="center">#item.cltChase#</td>
							<td>#LSDateFormat(item.cltChaseDate)#</td>
						</tr>
					</cfloop>
				</cfif>
				<cfif debitCount gt 0>
					<tr>
						<td colspan="2">#debitCount# in debit</td>
						<td colspan="3">Debit Totals</td>
						<td class="amountTotal">#showNum(totals[1])#</td>
						<td class="amountTotal">#showNum(totals[2])#</td>
						<td class="amountTotal">#showNum(totals[3])#</td>
						<td class="amountTotal">#showNum(totals[4])#</td>
						<td class="amountTotal">#showNum(totals[5])#</td>
						<td></td>
					</tr>
				</cfif>
				<cfif creditCount gt 0>
					<tr>
						<td colspan="2">#creditCount# in credit</td>
						<td colspan="3">Credit Totals</td>
						<td class="amountTotal">#showNum(credits[1])#</td>
						<td class="amountTotal">#showNum(credits[2])#</td>
						<td class="amountTotal">#showNum(credits[3])#</td>
						<td class="amountTotal">#showNum(credits[4])#</td>
						<td class="amountTotal">#showNum(credits[5])#</td>
						<td></td>
					</tr>
				</cfif>
			</table>
		</cfoutput>
	</cfif>
</body>
</html>

