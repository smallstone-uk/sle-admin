<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/tabs.css" rel="stylesheet" type="text/css">
<title>Transaction List</title>
</head>

<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<cfset parm.nomGroup=2>
<cfset parm.nomType="purch">
<cfset parm.accountID=#url.account#>
<cfset parm.datasource=application.site.datasource1>
<cfset suppData=supp.TranList(parm)>
<body>
<cfoutput>
	<table width="800">
		<tr>
			<td>Account</td>
			<td>#suppData.supplier[1].accCode#</td>
			<td></td>
			<td>#suppData.supplier[1].accName#</td>
			<td></td>
			<td>#suppData.supplier[1].accGroup#</td>
		</tr>
	</table>
	<table width="800">
		<tr>
			<th>ID</th>
			<th>Date</th>
			<th>Type</th>
			<th>Ref</th>
			<th>Net</th>
			<th>VAT/Disc</th>
			<th>Gross</th>
			<th>Balance</th>
			<th>Allocated</th>
		</tr>
		<cfif StructKeyExists(suppData,"trans")>
			<cfset total1=0>
			<cfset total2=0>
			<cfloop array="#suppData.trans#" index="item">
				<cfset total1=total1+item.trnAmnt1>
				<cfset total2=total2+item.trnAmnt2>
				<tr>
					<td>#item.trnID#</td>
					<td align="right">#LSDateFormat(item.trnDate,"dd-mmm-yyyy")#</td>
					<td align="center">#item.trnType#</td>
					<td>#item.trnRef#</td>
					<td align="right">#item.trnAmnt1#</td>
					<td align="right">#item.trnAmnt2#</td>
					<td align="right">#DecimalFormat(item.trnAmnt1+item.trnAmnt2)#</td>
					<td align="right">#DecimalFormat(total1+total2)#</td>
					<td align="center">#item.trnAlloc#</td>
				</tr>
			</cfloop> 
			<tr>
				<td colspan="4" height="40"></td>
				<td align="right"><strong>#DecimalFormat(total1)#</strong></td>
				<td align="right"><strong>#DecimalFormat(total2)#</strong></td>
				<td align="right"><strong>#DecimalFormat(total1+total2)#</strong></td>
				<td></td>
			</tr>
		<cfelse>
			<tr>
				<td colspan="8">#suppData.msg#</td>
			</tr>
		</cfif>
	</table>
</cfoutput>
</body>
</html>