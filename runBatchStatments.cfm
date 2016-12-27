<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1> <!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">

<cfoutput>
<cfif StructKeyExists(url,"client")>
	<cfif len(url.client)>
		<cfquery name="QClient" datasource="#application.site.datasource1#"> <!--- Get selected client record --->
			SELECT *
			FROM tblClients
			WHERE cltID=#val(url.client)#
		</cfquery>
		<cfdocument
		permissions="allowcopy,AllowPrinting" 
		orientation="portrait" 
		mimetype="text/html"
		saveAsName="inv#QClient.cltID#" 
		filename="#application.site.dir_invoices#statements\stat_#QClient.cltID#.pdf"
		overwrite="yes"
		localUrl="yes" 
		format="PDF" 
		fontEmbed="yes" 
		userpassword=""
		encryption="128-bit">
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
		<cfset currClient=QClient.cltRef>
		<cfquery name="QTrans" datasource="#application.site.datasource1#"> <!--- Get transaction records --->
			SELECT *
			FROM tblTrans
			WHERE trnClientRef='#val(currClient)#'
			<cfif NOT StructKeyExists(url,"allTrans")>AND trnAlloc=0</cfif>
			ORDER BY trnDate, trnID
		</cfquery>
		<cfif QTrans.recordcount gt 0>
			<cfinclude template="busHeader.cfm">
			<table class="compTable">
				<tr><td height="50" align="center"><h1>Newspaper Delivery Statement</h1></td></tr>
			</table>
			<cfset tabWidth=630>
			<table width="#tabWidth#" class="">
				<tr>
					<td colspan="10">
						<table>
							<tr><td width="30"></td><td>#QClient.cltName#</td></tr>
							<tr><td></td><td>#QClient.cltAddr1#</td></tr>
							<cfif len(QClient.cltAddr2)><tr><td></td><td>#QClient.cltAddr2#</td></tr></cfif>
							<tr><td></td><td>#QClient.cltTown#</td></tr>
							<cfif len(QClient.cltCounty)><tr><td></td><td>#QClient.cltCounty#</td></tr></cfif>
							<tr><td></td><td>#QClient.cltPostcode#</td></tr>
							<tr><td></td><td height="40">&nbsp;</td></tr>
							<tr><td></td><td>As at: <b class="date">#DateFormat(Now(),"dd-mmm-yyyy")#</b></td></tr>
							<tr><td></td><td><b class="accNum">Account Number: #QClient.cltRef#</b></td></tr>
							<tr><td></td><td><cfif len(QClient.cltInfo1)>Ref:</cfif> #QClient.cltInfo1#&nbsp;</td></tr>
						</table>
					</td>
				</tr>
			</table>
			<table width="#tabWidth#" border="0" cellspacing="0" class="tableList">
				<tr>
					<th align="left">Type</th>
					<th align="left">Reference</th>
					<th align="left">Date</th>
					<th align="center">Method</th>
					<th align="right">DR</th>
					<th align="right">CR</th>
					<th align="right">Balance</th>
				</tr>
				<cfset balance=0>
				<cfset totalDebit=0>
				<cfset totalCredit=0>
				<cfloop query="QTrans">
					<cfset balance=balance+QTrans.trnAmnt1>
					<tr>
						<td>#QTrans.trnType#</td>
						<td>#QTrans.trnRef#</td>
						<td>#DateFormat(QTrans.trnDate,"dd-mmm-yyyy")#</td>
						<td class="centre">#QTrans.trnMethod#</td>
						<cfif QTrans.trnAmnt1 gt 0>
							<cfset totalDebit=totalDebit+QTrans.trnAmnt1>
							<td width="80" align="right">&pound;#DecimalFormat(QTrans.trnAmnt1)#</td>
							<td width="80">&nbsp;</td>
						<cfelse>
							<cfset totalCredit=totalCredit+QTrans.trnAmnt1>
							<td width="80">&nbsp;</td>
							<td width="80" align="right" style="color:##FF0000">&pound;#DecimalFormat(QTrans.trnAmnt1)#</td>
						</cfif>
						<td width="80" align="right">&pound;#DecimalFormat(balance)#</td>
					</tr>
				</cfloop>
				<tr>
					<td height="40" colspan="6" class="amountTotal"><cfif balance lt 0>Account in credit<cfelse>Balance now due</cfif></td>
					<td class="amountTotal-box">&pound;#DecimalFormat(balance)#</td>
				</tr>
				<tr>
					<td height="40" colspan="7" style="padding:7px;">
						Please make payment to <strong>Shortlanesend Store.</strong><br />
						Payment can also be made online using internet banking.<br />
						Bank: Lloyds TSBS plc. Sort Code: <strong>30-98-76</strong> Account: <strong>3534 5860</strong><br />
						If you have already paid this amount or believe there is an error on your account, please let us know.
					</td>
				</tr>
			</table>
			<cfelse>
				<cfoutput>
				<div id="ajaxMsg" style="color:##FF0000"><div id="clientKey">#QClient.cltRef#</div>
					No unallocated transactions found. Click <strong>All Transactions</strong> to view the client's transaction history.</div>
				</cfoutput>
			</cfif>
			<!---<div style="clear:both; page-break-after:always;"></div>--->
		</cfdocument>
		<h1>In Progress</h1>
		<div id="progress"><cfif url.total neq url.row><img src='images/loading_2.gif' class='loadingGif'>&nbsp;#url.row# of #url.total#<cfelse>Completed</cfif></div>
	</cfif>
</cfif>
</cfoutput>