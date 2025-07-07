
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
<cfdump var="#customer#" label="customer" expand="false">
<cfdump var="#trans#" label="trans" expand="false">
--->
<cfset alltrans = StructKeyExists(form,"alltrans")>
<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>Statement-#trans.cltRef#-#DateFormat(Now(),"yyyy-mm")#</title>
		<link rel="stylesheet" type="text/css" href="css/invoice.css"/>
	</head>
	<style type="text/css">
		.shaded { background-color:##ddd; border:##ff0000;}
		.normal { background-color:##fff; border:##ccc;}
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
		<cfinclude template="busHeader.cfm">
		<cfloop query="customer.QClient">
			<div style="float:left;width:310px;margin:20px 0 40px 50px;">
				<cfset ln=0>
				<table border="0" cellspacing="0" cellpadding="2" style="font-size:16px;">
					<cfif len(cltName)>
						<cfset ln++>
						<tr>
							<td valign="top">
								<cfif len(cltTitle)>#cltTitle#</cfif>
								<cfif len(cltInitial)>#cltInitial#</cfif>
								#cltName#
							</td>
						</tr>
					</cfif>
					<cfif len(cltDept)><cfset ln++><tr><td valign="top">#cltDept#</td></tr></cfif>
					<cfif len(cltCompanyName)><cfset ln++><tr><td valign="top">#cltCompanyName#</td></tr></cfif>
					<cfif len(cltAddr1)><cfset ln++><tr><td valign="top">#cltAddr1#</td></tr></cfif>
					<cfif len(cltAddr2)><cfset ln++><tr><td valign="top">#cltAddr2#</td></tr></cfif>
					<cfif len(cltTown)><cfset ln++><tr><td valign="top">#cltTown#</td></tr></cfif>
					<cfif len(cltPostcode)><cfset ln++><tr><td valign="top">#cltPostcode#</td></tr></cfif>
					<cfloop from="#ln+1#" to="9" index="i">
						<tr><td>&nbsp;</td></tr>
					</cfloop>
					<tr><td>Date: #DateFormat(Now(),"dd-mmm-yyyy")#</td></tr>
					<tr><td>Account: #cltRef#</td></tr>
				</table>
			</div>
			<div style="clear:both;"></div>
			<div class="statementTitle">Statement</div>
		</cfloop>

		<table id="tranTable" class="tableList" border="1" style="font-size:14px; margin-left:50px;">
			<tr class="tranTable">
				<th width="40">Reference</th>
				<th width="150">Description</th>
				<th width="90">Date</th>
				<th width="50">Type</th>
				<th width="50">Method</th>
				<th width="40" align="right">Debits<br />(invoices)</th>
				<th width="40" align="right">Credits<br />(payments)</th>
				<th width="40" align="right">Balance</th>
				<th width="80" class="noPrint">Allocation</th>
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
					<th width="10" class="noPrint"></th>
				</tr>
			</cfif>
			<cfloop query="trans.QTrans">
				<cfset balance = balance + trnAmnt1 + trnAmnt2>
				<!---<cfset tipple = ReReplace(trnDesc,"\d+","","all")>--->
				<cfset tipple = ReReplace(trnDesc,"\d{7,}","","all")>
				<cfif allocCount neq trnAllocID>
					<tr><td colspan="9">&nbsp;</td></tr>
				</cfif>
				<tr>
					<td>#trnRef#</td>
					<td>#tipple#</td>
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
					<td class="centre noPrint">#trnAllocID#</td>
				</tr>
				<cfset allocCount = trnAllocID>
			</cfloop>
			<tr>
				<td height="40" colspan="7" class="amountTotal"><cfif balance lt 0>Account in credit<cfelse>Account Balance</cfif></td>
				<td class="amountTotal-box">#DecimalFormat(balance)#</td>
				<td class="noPrint"></td>
			</tr>
			<tr>
				<td height="40" colspan="8" style="padding:7px; font-size:12px">
					Please make payment to <strong>#application.company.companyName#.</strong><br />
					Payment can also be made online using internet banking.<br />
					Bank: #application.company.bankname#. Sort Code: <strong>#application.company.sortcode#</strong> Account: <strong>#application.company.accountno#.</strong><br />
					Please quote your account number <strong>"#trans.cltRef#"</strong> with your payment.<br />
					If you have already paid this amount or believe there is an error on your account, please let us know.
				</td>
				<td class="noPrint"></td>
			</tr>
		</table>
	</body>
	</html>
</cfoutput>

