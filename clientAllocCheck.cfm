
<cfif StructIsEmpty(form)>
	<h1>This page must be called from the Customer Payments page.</h1>
	<cfabort>
</cfif>

<cfobject component="code/accounts2" name="acc">
<cfset parm = {}>
<cfset parm.datasource1 = application.site.datasource1>
<cfset parm.form = form>
<cfset customer = acc.LoadClient(parm)>
<cfset trans = acc.LoadAllocatedTrans(parm)>
<!---
<cfdump var="#trans#" label="trans" expand="false">
<cfdump var="#customer#" label="customer" expand="false">
--->
<cfset alltrans = StructKeyExists(form,"alltrans")>
<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Allocation Report - #trans.cltRef#-#DateFormat(Now(),"yyyy-mm")#</title>
		<link rel="stylesheet" type="text/css" href="css/invoice.css"/>
	</head>
	<style type="text/css">
		.shaded { background-color:##ddd; border:##ff0000;}
		.normal { background-color:##fff; border:##ccc;}
		##content {margin:20px;}
		@media print {
			.noPrint {display:none;}
			.tableList {font-size:14px; white-space: nowrap;}
			.description {width:300px;}
			body {
				font-family: serif;
				color: black;
				background-color: white;
			}
		}
	</style>

	<body>
		<div id="content">
			<table id="tranTable" class="tableList" border="1" style="font-size:14px; margin-left:20px;">
				<tr>
					<th colspan="2" align="right">Account Ref: </th>
					<th>#customer.QClient.cltRef#</th>
					<th colspan="2">#customer.QClient.cltCompanyName#</th>
					<th colspan="2" align="right">Contact: </th>
					<th colspan="2">#customer.QClient.cltContact#</th>
				</tr>
				<tr class="tranTable">
					<th width="40">Reference</th>
					<th width="150">Description</th>
					<th width="90">Date</th>
					<th width="50">Type</th>
					<th width="50">Payment<br />Method</th>
					<th width="40" align="right">Debits<br />(invoices)</th>
					<th width="40" align="right">Credits<br />(payments)</th>
					<th width="40" align="right">Balance</th>
					<th width="80">Allocation</th>
				</tr>
				<cfset balance = 0>
				<cfset totalDebit = 0>
				<cfset totalCredit = 0>
				<cfset allocCount = 0>
				<cfif trans.bfwd neq 0>
					<cfset balance = trans.bfwd>
					<tr>
						<td colspan="7" align="right" height="40"><span class="broughtFwd">Balance brought forward</span></td>
						<td align="right">#DecimalFormat(trans.bfwd)#</td>
						<th width="10"></th>
					</tr>
				</cfif>
				<cfloop query="trans.QTrans">
					<cfset balance = balance + trnAmnt1 + trnAmnt2>
					<cfset shortDesc = ReReplace(trnDesc,"\d{7,}","","all")>	<!--- remove long sequences of banking numbers --->
					<cfif allocCount neq trnAllocID>
						<tr><td colspan="9">&nbsp;</td></tr>
					</cfif>
					<tr>
						<td>#trnRef#</td>
						<td>#shortDesc#</td>
						<td>#DateFormat(trnDate,"dd-mmm-yyyy")#</td>
						<td class="centre">#acc.trantype(trnType)#</td>
						<td class="centre">#trnMethod#</td>
						<cfif trnAmnt1 gt 0>
							<cfset totalDebit = totalDebit + trnAmnt1 + trnAmnt2>
							<td align="right">#DecimalFormat(trnAmnt1 + trnAmnt2)#</td>
							<td>&nbsp;</td>
						<cfelse>
							<cfset totalCredit = totalCredit + trnAmnt1 + trnAmnt2>
							<td>&nbsp;</td>
							<td align="right" style="color:##FF0000">#DecimalFormat(trnAmnt1 + trnAmnt2)#</td>
						</cfif>
						<td align="right">#DecimalFormat(balance)#</td>
						<td class="centre">#trnAllocID#</td>
					</tr>
					<cfset allocCount = trnAllocID>
				</cfloop>
				<tr>
					<td height="40" colspan="7" class="amountTotal">Report Total</td>
					<td class="amountTotal-box">#DecimalFormat(balance)#</td>
					<td></td>
				</tr>
			</table>
		</div>
	</body>
	</html>
</cfoutput>

