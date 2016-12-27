<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>VAT Summary</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
<style type="text/css">
	table {border-collapse:collapse;}
	td {border:solid 1px #ccc; padding:2px;}
	.header {font-weight:bold;}
	.total {font-weight:bold;}
</style>
</head>

<cfsetting requesttimeout="900">
<cfobject component="code/accounts" name="accts">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>
<cfset summary=accts.TranSummary(parm)>
<body>
	<table width="700">
		<cfoutput>
			<cfset ledgers=ListSort(StructKeyList(summary,","),"text","desc")>
			<cfloop list="#ledgers#" delimiters="," index="ledger">
				<tr><td colspan="6"><h1>#ledger# Ledger</h1></td></tr>
				<cfset data=StructFind(summary,ledger)>
				<cfset dateKeys=ListToArray(ListSort(StructKeyList(data.dates,","),"text","asc"),",")>
				<tr class="header">
					<td colspan="2"></td>
					<cfloop array="#dateKeys#" index="key">
						<td align="right">#StructFind(data.dates,key).colheader#</td>
					</cfloop>
					<td align="right">Total</td>
				</tr>
				<cfset codelist=ListSort(StructKeyList(data.codes,","),"text","asc")>
				<cfloop list="#codelist#" delimiters="," index="code">
					<cfset item=StructFind(data.codes,code)>
					<tr>
						<td><a href="transDetail.cfm?code=#code#">#code#</a></td>
						<td>#item.Title#</td>
						<cfloop array="#dateKeys#" index="key">
							<cfif StructKeyExists(item.Values,key)>
								<td align="right">#DecimalFormat(StructFind(item.Values,key))#</td>
							<cfelse>
								<td align="right">-</td>
							</cfif>
						</cfloop>
						<td align="right">#DecimalFormat(item.Total)#</td>
					</tr>
				</cfloop>
				<tr class="header">
					<td colspan="2">Totals</td>
					<cfset grandTotal=0>
					<cfloop array="#dateKeys#" index="key">
						<cfset mnthTotal=StructFind(data.dates,key).monthTotal>
						<cfset grandTotal=grandTotal+mnthTotal>
						<td align="right">#DecimalFormat(mnthTotal)#</td>
					</cfloop>
					<td align="right">#DecimalFormat(grandTotal)#</td>
				</tr>
			</cfloop>
		</cfoutput>
	</table>
</body>
</html>