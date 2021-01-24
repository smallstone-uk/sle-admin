<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<!---<cfoutput>
<link href="#ExpandPath("css")#/accounts.css" rel="stylesheet" type="text/css">
<link href="#ExpandPath("css")#/main3.css" rel="stylesheet" type="text/css">
<link href="#ExpandPath("css")#/chosen.css" rel="stylesheet" type="text/css">
<link href="#ExpandPath("css")#/tabs.css" rel="stylesheet" type="text/css">
</cfoutput>
---><title>Remittance Advice</title>
		<style type="text/css">
			html, body, div, span, applet, object, iframe, 
			h2, h3, h4, h5, h6, p, blockquote, pre, 
			a, abbr, acronym, address, big, cite, code, 
			del, dfn, em, font, img, ins, kbd, q, s, samp, 
			small, strike, strong, sub, sup, tt, var, 
			dl, dt, dd, ol, ul, li, 
			fieldset, form, label, legend, 
			table, caption, tbody, tfoot, thead, tr, th, td{ 
			  font-family: Arial, Helvetica, sans-serif;
			  font-size:12px !important;
			}
			.tableList {font-size:11px;border-left: solid 1px ##ccc;border-top: solid 1px ##ccc;}
			.tableList th {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##fff;}
			.tableList td {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##fff;}
			.clienthead {background:##ddd;font-weight:bold;font-size:11px;}
			.client {background:##eee;}
			.normal {background:##fff;}
			.warning {background:##FFD7D7;}
			.freedel {background:##B3F4EC}
			.amount {text-align:right !important;padding:2px;}
			.credit {text-align:right !important;padding:2px;color:##ff0000;}
			.accNum {font-size:12px;}
			.amountTotal {text-align:right !important;padding:2px;font-weight:bold;}
			.amountTotal-box {text-align:right !important;padding:2px;font-weight:bold;font-size: 18px;}
			.centre {text-align:center !important;text-transform: uppercase;}
			.ref {font-size:12px;font-weight:bold;color:##00C;}
			.ordertotal {font-weight:bold;}
			.address td {border:none;font-size:13px;}
			.compTable td {border:none;padding:0px 4px;;}
			.compName {font-family:"Arial Black";font-size:24px;font-weight:bold;color:##075086;}
			.compAddr {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;color:##075086;}
			.compDetailTitle {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;color:##075086;text-align:right !important;}
			.compDetail {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;}
			.clientHeader-nav ul {list-style:none;}
			.clientHeader-nav li {display:inline;}
		</style>
</head>

<cftry>
	<cfset totAmnt1 = 0>
	<cfset totAmnt2 = 0>
<body>
<!---
	<cfdump var="#data#" label="data" expand="false">
	<cfdump var="#application#" label="application" expand="false">
--->
	<cfoutput>
		<table border="1" class="tableList" width="900" id="tranListTable">
			<tr>
				<td colspan="4" align="center"><h1>Remittance Advice</h1></td>
			</tr>
			<tr>
				<td>#data.QSupplier.accName#</td>
				<td align="right">#application.siteClient.cltTelTitle1#</td>
				<td>#application.siteClient.cltTel1#</td>
				<td>#application.siteClient.cltCompanyName#</td>
			</tr>
			<tr>
				<td></td>
				<td align="right">EMail</td>
				<td>#application.siteClient.cltMailSupport#</td>
				<td>#application.siteClient.cltAddress1#</td>
			</tr>
			<tr>
				<td></td>
				<td></td>
				<td></td>
				<td>#application.siteClient.cltAddress2#</td>
			</tr>
			<tr>
				<td></td>
				<td align="right">Date</td>
				<td>#DateFormat(now(),"dd-mmm-yyyy")#</td>
				<td>#application.siteClient.cltTown#</td>
			</tr>
			<tr>
				<td></td>
				<td></td>
				<td></td>
				<td>#application.siteClient.cltPostcode#</td>
			</tr>
			<tr>
				<td></td>
				<td align="right">Our Ref.</td>
				<td>#data.QSupplier.accCode#</td>
				<td>#application.siteClient.cltVATNo#</td>
			</tr>
		</table>
		<hr />
		<table border="1" class="tableList" width="900" id="tranListTable">
			<tr>
				<th>Date</th>
				<th>Type</th>
				<th>Ref</th>
				<th>Description</th>
				<th>Net</th>
				<th>VAT</th>
				<th>Gross</th>
				<th>Balance</th>
				<th class="noPrint">Allocated</th>
			</tr>
			<cfloop query="data.QTrans">
				<cfset totAmnt1 += val(trnAmnt1)>
				<cfset totAmnt2 += val(trnAmnt2)>
				<cfset amountClass="amount">
				<cfif ListFind("crn,pay,jnl",trnType,",")><cfset amountClass="creditAmount"></cfif>
				<tr id="trnItem_#trnID#">
					<td id="trnItem_Date" align="right">#LSDateFormat(trnDate,"ddd dd/mm/yyyy")#</td>
					<td id="trnItem_Type" align="center">#trnType#</td>
					<td id="trnItem_Ref">#trnRef#</td>
					<td id="trnItem_Desc">#trnDesc#</td>
					<td id="trnItem_Amount1" class="#amountClass#">#DecimalFormat(val(trnAmnt1))#</td>
					<td id="trnItem_Amount2" class="#amountClass#">#DecimalFormat(val(trnAmnt2))#</td>
					<td id="trnItem_Amount3" class="#amountClass#">#DecimalFormat(val(trnAmnt1) + val(trnAmnt2))#</td>
					<td id="trnItem_Balance" class="#amountClass#">#DecimalFormat(totAmnt1 + totAmnt2)#</td>
					<td id="trnItem_Alloc" align="center" class="noPrint">#trnAllocID#</td>
				</tr>
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
