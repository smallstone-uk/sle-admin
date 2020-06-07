<!--- AJAX call - check client do not show debug data at all --->
	
<script type="text/javascript">
	$(document).ready(function() {
		$('#selectAll').click(function(e) {   
			if(this.checked) {
				$('input.trans').each(function() {this.checked = true;});
			} else {
				$('input.trans').each(function() {this.checked = false;});
			}
		});
	});
</script>


<cftry>
	<cfset callback=1> <!--- force exit of onrequestend.cfm --->
	<cfset tabWidth="100%">
	<cfset bfwd = 0>
	<cfset dateFrom = "">
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	<cfif StructKeyExists(url,"client")>
		<cfif len(url.client)>
			<cfif ReFindNoCase("^[0-9]{1,4}$",url.client,1,false) is 0>
				<div id="ajaxMsg" style="color:#0000FF">The client reference must only contain numeric characters and be between 1 and 4 characters long.</div>
			<cfelse>
				<cfquery name="QClient" datasource="#application.site.datasource1#"> <!--- Get selected client record --->
					SELECT *
					FROM tblClients
					WHERE true
					<cfif StructKeyExists(url,"prev")>AND cltRef<#val(url.client)# ORDER BY cltRef DESC
					<cfelseif StructKeyExists(url,"next")>AND cltRef>#val(url.client)# ORDER BY cltRef ASC
					<cfelse>AND cltRef=#val(url.client)#</cfif>
					LIMIT 1;
				</cfquery>
				<cfif QClient.recordcount is 0>
					<div id="ajaxMsg" style="color:#FF0000">Client not found.</div>
				<cfelseif QClient.recordcount is 1>
					<cfset currClient=QClient.cltRef>
					<cfif StructKeyExists(url,"dateFrom") AND IsDate(url.dateFrom)>
						<cfset dateFrom = url.dateFrom>
						<cfquery name="QBfwd" datasource="#application.site.datasource1#"> <!--- Get transaction records --->
							SELECT SUM(trnAmnt1) AS total
							FROM tblTrans
							WHERE trnClientRef='#val(currClient)#'
							AND trnDate < '#dateFrom#'
						</cfquery>
						<cfset bfwd = QBfwd.total>
					</cfif>
					<cfquery name="QTrans" datasource="#application.site.datasource1#"> <!--- Get transaction records --->
						SELECT *
						FROM tblTrans
						WHERE trnClientRef='#val(currClient)#'
						<cfif len(dateFrom)>
							AND trnDate >= '#dateFrom#'
						<cfelseif StructKeyExists(url,"allTrans") AND url.allTrans eq false>
							AND trnAlloc=0
						</cfif>
						ORDER BY trnDate, trnType DESC, trnID	<!--- show all payments before invoices on same date --->
					</cfquery>
					<cfoutput>
					<cfif print>
						<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
						<html xmlns="http://www.w3.org/1999/xhtml">
						<head>
							<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
							<title>Statement-#QClient.cltRef#-#DateFormat(Now(),"yyyy-mm")#</title>
							<link rel="stylesheet" type="text/css" href="css/invoice.css"/>
						</head>
						<body>
					</cfif>
						<cfif print><cfinclude template="busHeader.cfm"></cfif>
						<cfif print>
							<cfset tabWidth=800>
							<cfloop query="QClient">
							<div style="float:left;width:310px;margin:20px 0 40px 50px;">
								<cfset ln=0>
								<table border="0" cellspacing="0" cellpadding="1" style="font-size:13px;">
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
						<cfelse>
							<div class="check-header">
								<span id="clientKey">#QClient.cltRef#&nbsp;</span>
								<cfif len(QClient.cltName) AND len(QClient.cltCompanyName)>#QClient.cltName# - #QClient.cltCompanyName#
								<cfelse>#QClient.cltName##QClient.cltCompanyName#</cfif>
								<span style="float:right;">Chase Level: <b<cfif QClient.cltChase neq 0> style="color:red;"</cfif>>#QClient.cltChase#</b></span>
							</div>
						</cfif>
						<table width="#tabWidth#" class="tableList" border="1">
							<tr>
								<cfif NOT print><th>ID</th></cfif>
								<th>Reference</th>
								<th width="200">Description</th>
								<th width="100">Date</th>
								<th>Type</th>
								<th>Method</th>
								<th align="right">Debits<br />(invoices)</th>
								<th align="right">Credits<br />(payments)</th>
								<th align="right">Balance</th>
								<th>Allocated</th>
								<cfif NOT print>
									<th>Paid In?</th>
								</cfif>
							</tr>
							<cfif bfwd neq 0>
								<tr>
									<td colspan="4"></td>
									<td colspan="3" align="right"><strong>Brought Forward from #DateFormat(dateFrom,'dd-mmm-yyyy')#</strong></td>
									<td align="right"><strong>#bfwd#</strong></td>
								</tr>
							</cfif>
							<cfset balance=bfwd>
							<cfset totalDebit=0>
							<cfset totalCredit=0>
							<cfloop query="QTrans">
								<cfset balance=balance+trnAmnt1>
								<tr>
									<cfif NOT print><td>#trnID#</td></cfif>
									<td>#trnRef#</td>
									<td>#trnDesc#</td>
									<td>#DateFormat(trnDate,"dd-mmm-yyyy")#</td>
									<td>
										<cfswitch expression="#trnType#">
											<cfcase value="inv">
												Invoice
											</cfcase>
											<cfcase value="crn">
												Credit
											</cfcase>
											<cfcase value="pay">
												Payment
											</cfcase>
											<cfcase value="jnl">
												Adjustment
											</cfcase>
										</cfswitch>
									</td>
									<td class="centre"><cfif trnMethod  eq "sv">VOUCHERS<cfelse>#trnMethod#</cfif></td>
									<cfif trnAmnt1 gt 0>
										<cfset totalDebit=totalDebit+trnAmnt1>
										<td width="80" align="right">&pound;#DecimalFormat(trnAmnt1)#</td>
										<td width="80">&nbsp;</td>
									<cfelse>
										<cfset totalCredit=totalCredit+trnAmnt1>
										<td width="80">&nbsp;</td>
										<td width="80" align="right" style="color:##FF0000">&pound;#DecimalFormat(trnAmnt1)#</td>
									</cfif>
									<td width="80" align="right">&pound;#DecimalFormat(balance)#</td>
									<cfif print>
										<td class="centre"><cfif trnAlloc>*</cfif></td>									
									<cfelse>
										<td class="centre">
											<input type="hidden" name="amnt#currentrow#" value="#trnAmnt1#" />
											<input type="checkbox" name="tick#currentrow#" id="tick#currentrow#" class="trans" onClick="checkTotal('payForm');" 
												value="#trnID#"<cfif trnAlloc> checked="checked"</cfif> />
										</td>
										<td class="centre">#trnPaidin#</td>
									</cfif>
								</tr>
							</cfloop>
							<cfif print>
								<tr>
									<td colspan="3" class="totalInfo">
										The balance includes any enclosed invoices
									</td>
									<td height="40" colspan="4" class="amountTotal">
										<cfif balance lt 0>Account in Credit<br />(nothing to pay)<cfelse>Balance Now Due</cfif></td>
									<td class="amountTotal-box">&pound;#DecimalFormat(balance)#</td>
									<td></td>
								</tr>
								<tr>
									<td height="40" colspan="9" style="padding:7px;">
										Please make payment to <strong>Shortlanesend Store.</strong><br />
										Payment can also be made online using internet banking.<br />
										Bank: Lloyds Bank plc. Sort Code: <strong>30-98-76</strong> Account: <strong>3534 5860</strong><br />
										Please quote your account number <strong>"ACC #QClient.cltRef#"</strong> with your payment.<br />
										If you have already paid this amount or believe there is an error on your account, please let us know.
									</td>
								</tr>
							<cfelse>
								<tr>
									<td colspan="7" class="amountTotal" style="text-align:right;">Allocated Balance&nbsp;&nbsp;&nbsp;&nbsp;</td>
									<td class="amountTotal" style="text-align:left;">
										<input id="Total" type="text" style="text-align:right; font-weight:bold;" size="6" value="0.00" name="Total" />
										<input type="hidden" name="tranCount" id="tranCount" value="#QTrans.recordcount#" />
										<input type="hidden" name="clientID" value="#QClient.cltID#" />
									</td>
									<td align="center"><input type="checkbox" name="selectAll" id="selectAll" title="Select All" /></td>
									<td></td>
								</tr>
							</cfif>
						</table>
					</cfoutput>
					<cfif print>
						</body>
						</html>
					</cfif>
				</cfif>
			</cfif>
		<cfelse>
			<div id="ajaxMsg" style="color:#FF0000">Client reference field is empty</div>
		</cfif>
	<cfelse>
		<div id="ajaxMsg" style="color:#FF0000">Client reference not supplied</div>
	</cfif>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
	
