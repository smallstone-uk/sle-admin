<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Client Statement</title>
	<style type="text/css">
		body {font-family:"Courier New", Courier, monospace}
		table {
			font-family:Arial, Helvetica, sans-serif;
			font-size:10px;
			border-collapse:collapse;
		}
		td {padding:4px 2px;}
		.clienthead {
			background-color:#ddd;
			font-weight:bold;
			font-size:11px;
		}
		.client {
			background-color:#eee;
		}
	</style>
</head>

	<cfquery name="QClients" datasource="#application.site.datasource1#">
		SELECT *
		FROM tblClients
		WHERE 1
		<!---AND cltAge=0--->
		ORDER BY cltRef
		<!---LIMIT 0,10;--->
	</cfquery>

<body>	
	<p><a href="index.cfm">Home</a></p>
	<cfset totalInv=0>
	<cfset totalPay=0>
	<cfset grandTotal=0>
	<cfset nobill=0>
	<cfset debtors=[]>
	<cfoutput>
	<table border="1">
	<cfloop query="QClients">
		<cfset clientTotal=0>
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
			<td>Balance</td>
		</tr>
		<tr class="client">
			<td>#cltID#</td>
			<td>#cltRef#</td>
			<td>#cltName#</td>
			<td>#cltDelHouse# #cltDelAddr#</td>
			<td>#cltDelTown#</td>
			<td>#cltDelPostcode#</td>
			<td>#cltDelTel#</td>
			<td>#cltDelCode#</td>
			<td>#cltAccountType#</td>
			<td>#DateFormat(cltLastDel,"dd-mmm-yyyy")#</td>
			<td>#DateFormat(cltLastPaid,"dd-mmm-yyyy")#</td>
			<td>#cltBalance#</td>
		</tr>
		<cfquery name="QTrans" datasource="#application.site.datasource1#">
			SELECT *
			FROM tblTrans
			WHERE trnClientRef=#QClients.cltRef#
			AND trnTest=0
			ORDER BY trnDate
		</cfquery>
			<tr>
				<td colspan="12">
					<cfif QTrans.recordcount gt 0>
						<table border="1">
						<cfset balance=0>
						<cfset totalDebit=0>
						<cfset totalCredit=0>
						<cfloop query="QTrans">
							<cfset balance=balance+trnAmnt1>
							<cfset grandTotal=grandTotal+trnAmnt1>
							<cfif trnType is "inv"><cfset totalInv=totalInv+trnAmnt1></cfif>
							<cfif trnType is "pay"><cfset totalPay=totalPay+trnAmnt1></cfif>
							<tr>
								<td width="120">#DateFormat(trnDate,"dd-mmm-yyyy")#</td>
								<td width="120">#trnType#</td>
								<td width="120">#trnRef#</td>
								<cfif trnAmnt1 lt 0>
									<cfset totalCredit=totalCredit+trnAmnt1>
									<td width="120">&nbsp;</td>
									<td width="120" align="right" style="color:##FF0000">&pound;#DecimalFormat(trnAmnt1)#</td>
								<cfelse>
									<cfset totalDebit=totalDebit+trnAmnt1>
									<td width="120" align="right">&pound;#DecimalFormat(trnAmnt1)#</td>
									<td width="120">&nbsp;</td>
								</cfif>
								<td width="120" align="right">&pound;#DecimalFormat(balance)#</td>
							</tr>
						</cfloop>
						<cfif balance neq 0>
							<cfset ArrayAppend(debtors,{"Account"=QClients.cltRef,"Name"=cltName,"Balance"=balance})>
						</cfif>
						</table>
					<cfelse>
						<strong>No transactions found for this account.</strong>
						<cfset nobill++>
					</cfif>
				</td>
			</tr>
	</cfloop>
		<tr>
			<td>Total Invoices</td>
			<td>&pound;#DecimalFormat(totalInv)#</td>
			<td>Total Payments</td>
			<td>&pound;#DecimalFormat(totalPay)#</td>
			<td>Total Outstanding</td>
			<td>&pound;#DecimalFormat(grandTotal)#</td>
			<td>Unbilled</td>
			<td>#nobill#</td>
		</tr>
	</table>
	<table border="1">
		<cfset linecount=0>
		<cfset countDebit=0>
		<cfset countCredit=0>
		<cfset totalDebit=0>
		<cfset totalCredit=0>
		<cfloop array="#debtors#" index="item">
			<cfset linecount++>
			<tr><td>#linecount#</td><td>#item.account#</td><td>#item.name#</td>
			<cfif item.balance lt 0>
				<cfset countCredit++>
				<cfset totalCredit=totalCredit+item.balance>
				<td>&nbsp;</td>
				<td align="right" style="color:##FF0000">&pound;#DecimalFormat(item.balance)#</td>
			<cfelse>
				<cfset countDebit++>
				<cfset totalDebit=totalDebit+item.balance>
				<td align="right">&pound;#DecimalFormat(item.balance)#</td>
				<td>&nbsp;</td>
			</cfif>
			</tr>
		</cfloop>
		<tr>
			<td colspan="3" height="40">Total Outstanding Debtors: #countDebit# Creditors: #countCredit#</td>
			<td align="right">&pound;#DecimalFormat(totalDebit)#</td>
			<td align="right">&pound;#DecimalFormat(totalCredit)#</td>
		</tr>
	</table>
	</cfoutput>
</body>
</html>