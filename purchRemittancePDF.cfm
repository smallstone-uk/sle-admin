
<cftry>
	<cfobject component="code/purchase" name="pur">
	<cfobject component="code/accounts" name="accts">
	<cfset parm={}>
	<cfset parm.accountID=#url.accountID#>
	<cfset parm.allocationID=#url.allocationID#>
	<cfset parm.datasource=application.site.datasource1>
	<cfset data = pur.TranRemittance(parm)>
	<cfset filename = "rem-#data.QSupplier.accCode#-#parm.allocationID#.pdf">
	<cfset totAmnt1 = 0>
	<cfset totAmnt2 = 0>

<cfdocument
	permissions="allowcopy,AllowPrinting" 
	orientation="portrait" 
	mimetype="text/html"
	saveAsName="rem01" 
	filename="#application.site.dir_data#remittances\#filename#"
	overwrite="yes"
	localUrl="yes" 
	format="PDF" 
	fontEmbed="yes" 
	userpassword=""
	encryption="128-bit">

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			<meta name="viewport" content="width=device-width,initial-scale=1.0">
			<title>Remittance Advice <cfoutput>#filename#</cfoutput></title>
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
				.tableList {font-size:11px;border-left: solid 1px #ccc;border-top: solid 1px #ccc;}
				.tableList th {padding:2px 4px;border-bottom: solid 1px #ccc;border-right: solid 1px #ccc;background:#fff;}
				.tableList td {padding:2px 4px;border-bottom: solid 1px #ccc;border-right: solid 1px #ccc;background:#fff;}
				.clienthead {background:#ddd;font-weight:bold;font-size:11px;}
				.client {background:#eee;}
				.normal {background:#fff;}
				.warning {background:#FFD7D7;}
				.freedel {background:#B3F4EC}
				.amount {text-align:right !important;padding:2px;}
				.credit {text-align:right !important;padding:2px;color:#ff0000;}
				.accNum {font-size:12px;}
				.amountTotal {text-align:right !important;padding:2px;font-weight:bold;}
				.amountTotal-box {text-align:right !important;padding:2px;font-weight:bold;font-size: 18px;}
				.centre {text-align:center !important;text-transform: uppercase;}
				.ref {font-size:12px;font-weight:bold;color:#00C;}
				.ordertotal {font-weight:bold;}
				.address td {border:none;font-size:13px;}
				.compTable td {border:none;padding:0px 4px;;}
				.compName {font-family:"Arial Black";font-size:24px;font-weight:bold;color:#075086;}
				.compAddr {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;color:#075086;}
				.compDetailTitle {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;color:#075086;text-align:right !important;}
				.compDetail {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;}
				.clientHeader-nav ul {list-style:none;}
				.clientHeader-nav li {display:inline;}
				.header {margin:10px;}
			</style>
		</head>
	<cfoutput>
	<body>
		<div class="header">
			<cfinclude template="busHeader.cfm">
		</div>
			<table border="0" class="tableList" width="100%" id="tranListTable">
				<tr>
					<td colspan="3" align="center"><h1>Remittance Advice</h1></td>
				</tr>
				<tr>
					<td width="300" align="right">Supplier</td>
					<td width="300">#data.QSupplier.accName#</td>
					<td width="300">&nbsp;</td>
				</tr>
				<tr>
					<td align="right">Date</td>
					<td>#DateFormat(now(),"dd-mmm-yyyy")#</td>
					<td></td>
				</tr>
				<tr>
					<td align="right">Our Ref.</td>
					<td>#data.QSupplier.accCode#</td>
					<td></td>
				</tr>
			</table>
			<hr />
			<table border="0" class="tableList" width="100%" id="tranListTable">
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
					<cfif ListFind("crn,pay,jnl",trnType,",")><cfset amountClass="credit"></cfif>
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
</html>
<!---<cfinclude template="purchRemittance.cfm">--->
</cfdocument>

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			<meta name="viewport" content="width=device-width,initial-scale=1.0">
		</head>
		<body>
			<cfoutput>
				<cfif len(data.QSupplier.accEmail)>
					<p>Email this remittance to: #data.QSupplier.accName#</p>
					Send to: #data.QSupplier.accEmail#<br />
					Attachment: #filename#<br />
				<cfelse>
					No email address available.<br />
				</cfif>
				Click to print: <a href="#application.site.url_data#remittances\#filename#" target="_blank">#filename#</a>
			</cfoutput>
			<cfdump var="#data#" label="data" expand="false">
		</body>
	</html>


<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
