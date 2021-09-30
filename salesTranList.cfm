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

<cftry>
<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<!---<cfset parm.nomGroup=2>--->
<cfset parm.nomType="sales">
<cfset parm.accountID=#url.account#>
<cfset parm.datasource=application.site.datasource1>
<cfset suppData=supp.TranList(parm)>
<cfset SalesDuplicates=supp.SalesDuplicates(parm)>

<body>
	<cfoutput>
		<table width="800">
			<tr>
				<td>Account</td>
				<td>#suppData.supplier.accCode#</td>
				<td></td>
				<td>#suppData.supplier.accName#</td>
				<td></td>
				<td>#suppData.supplier.accGroup#</td>
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
						<td><a href="#application.site.normal#salesMain3.cfm?acc=1&tran=#item.trnID#" target="#item.trnID#">#item.trnID#</a></td>
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
		<h1>Data Exceptions</h1>
		<table width="500">
			<tr>
				<th>ID</th>
				<th>Date</th>
				<th>Net</th>
				<th>VAT</th>
			</tr>
			<cfset currDate = "">
			<cfloop array="#SalesDuplicates.dupes#" index="item">
				<cfif currDate neq item.trnDate>
					<tr><td>&nbsp;</td></tr>
				</cfif>
				<tr>
					<td align="right">#item.trnID#</td>
					<td align="right">#LSDateFormat(item.trnDate,"dd-mmm-yyyy")#</td>
					<td align="right">#item.trnAmnt1#</td>
					<td align="right">#item.trnAmnt2#</td>
				</tr>
				<cfset currDate = item.trnDate>
			</cfloop>
		</table>
	</cfoutput>
</body>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
</html>
