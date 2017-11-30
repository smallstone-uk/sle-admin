<!DOCTYPE html>
<html>
<head>
<title>Sales Report</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="common/scripts/common.js"></script>
<!---<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>--->
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
	.amount, .amountTotal {text-align:right}
</style>

</head>

<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchType" default="">
<cfparam name="srchPayType" default="">
<cfparam name="srchMin" default="">
<cfparam name="srchSort" default="">
<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post">
						<div class="form-header">
							Search Sales Reports
							<span><input type="submit" name="btnSearch" value="Search" /></span>
						</div>
						<table border="0">
								<tr>
									<td><b>Search by Name</b></td>
									<td><input type="text" name="srchName" size="20" /></td>
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
									<td><b>Search by Account Type</b></td>
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
									<td><b>Search by Payment Type</b></td>
									<td>
										<select name="srchPayType">
											<option value=""<cfif srchPayType eq ""> selected="selected"</cfif>>Any Type</option>
											<option value="post"<cfif srchPayType eq "post"> selected="selected"</cfif>>Sends payment by post</option>
											<option value="bacs"<cfif srchPayType eq "bacs"> selected="selected"</cfif>>Pays direct into bank account</option>
											<option value="collect"<cfif srchPayType eq "collect"> selected="selected"</cfif>>Collected on the rounds</option>
											<option value="shop"><cfif srchPayType eq "shop"> selected="selected"</cfif>Pays in the shop</option>
											<option value="noshop"<cfif srchPayType eq "noshop"> selected="selected"</cfif>>All but shop payments</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Minimum Balance</b></td>
									<td><input type="text" name="srchMin" value="#srchMin#" size="5" value="0" /></td>
								</tr>
								<tr>
									<td><b>Sort By</b></td>
									<td>
										<select name="srchSort">
											<option value=""<cfif srchSort eq ""> selected="selected"</cfif>>Any order</option>
											<option value="cltRef"<cfif srchSort eq "cltRef"> selected="selected"</cfif>>Reference</option>
											<option value="cltName"<cfif srchSort eq "cltName"> selected="selected"</cfif>>Name</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Options</b></td>
									<td><input type="checkbox" name="srchIgnoreZero" value="1"<cfif StructKeyExists(form,"srchIgnoreZero")> checked="checked"</cfif> />Ignore zero balances?</td>
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
				<cfobject component="code/functions" name="func">
				<cfset sales=func.SalesReport(parms)>
				<cfset totals=[0,0,0,0,0,0,0,0,0,0,0,0,0]>
				<cfset debitCount=0>
				<cfset style="amount">
				<table class="tableList" border="1">
					<tr>
						<th height="24">Ref</th>
						<th>Name</th>
						<th width="60">Account Type</th>
						<th width="60">Pay Type</th>
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
				<cfloop array="#sales.clients#" index="item">
					<cfset debitCount++>
					<cfset totals[1]=totals[1]+item.balance1>
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
					<cfset totals[13]=totals[13]+item.balance0>
					<tr>
						<td><a href="clientPayments.cfm?rec=#item.ref#">#item.ref#</a></td>
						<td><a href="checkClient.cfm?client=#item.ref#&allTrans=false&print=true" target="_blank" title="view statement">#item.name#</a></td>
						<td align="center">#item.type# #item.voucher#</td>
						<td>#item.payType# #item.payMethod#</td>
						<td class="#style#"><cfif item.balance1 neq 0>#DecimalFormat(item.balance1)#</cfif></td>
						<td class="#style#"><cfif item.balance2 neq 0>#DecimalFormat(item.balance2)#</cfif></td>
						<td class="#style#"><cfif item.balance3 neq 0>#DecimalFormat(item.balance3)#</cfif></td>
						<td class="#style#"><cfif item.balance4 neq 0>#DecimalFormat(item.balance4)#</cfif></td>
						<td class="#style#"><cfif item.balance5 neq 0>#DecimalFormat(item.balance5)#</cfif></td>
						<td class="#style#"><cfif item.balance6 neq 0>#DecimalFormat(item.balance6)#</cfif></td>
						<td class="#style#"><cfif item.balance7 neq 0>#DecimalFormat(item.balance7)#</cfif></td>
						<td class="#style#"><cfif item.balance8 neq 0>#DecimalFormat(item.balance8)#</cfif></td>
						<td class="#style#"><cfif item.balance9 neq 0>#DecimalFormat(item.balance9)#</cfif></td>
						<td class="#style#"><cfif item.balance10 neq 0>#DecimalFormat(item.balance10)#</cfif></td>
						<td class="#style#"><cfif item.balance11 neq 0>#DecimalFormat(item.balance11)#</cfif></td>
						<td class="#style#"><cfif item.balance12 neq 0>#DecimalFormat(item.balance12)#</cfif></td>
						<td class="#style#"><cfif item.balance0 neq 0>#DecimalFormat(item.balance0)#</cfif></td>
					</tr>
				</cfloop>
					<tr>
						<td colspan="2" height="30">#debitCount# Clients</td>
						<td colspan="2">Totals</td>
						<td class="amountTotal">#DecimalFormat(totals[1])#</td>
						<td class="amountTotal">#DecimalFormat(totals[2])#</td>
						<td class="amountTotal">#DecimalFormat(totals[3])#</td>
						<td class="amountTotal">#DecimalFormat(totals[4])#</td>
						<td class="amountTotal">#DecimalFormat(totals[5])#</td>
						<td class="amountTotal">#DecimalFormat(totals[6])#</td>
						<td class="amountTotal">#DecimalFormat(totals[7])#</td>
						<td class="amountTotal">#DecimalFormat(totals[8])#</td>
						<td class="amountTotal">#DecimalFormat(totals[9])#</td>
						<td class="amountTotal">#DecimalFormat(totals[10])#</td>
						<td class="amountTotal">#DecimalFormat(totals[11])#</td>
						<td class="amountTotal">#DecimalFormat(totals[12])#</td>
						<td class="amountTotal">#DecimalFormat(totals[13])#</td>
					</tr>
				</table>
			</cfif>
			<div class="clear"></div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
</html>

