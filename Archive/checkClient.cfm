<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1> <!--- force exit of onrequestend.cfm --->
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
				<cfif StructKeyExists(url,"prev")>AND cltRef<'#val(url.client)#'
				<cfelseif StructKeyExists(url,"next")>AND cltRef>'#val(url.client)#'
				<cfelse>AND cltRef='#val(url.client)#'</cfif>
				LIMIT 1;
			</cfquery>
			<cfif QClient.recordcount is 0>
				<div id="ajaxMsg" style="color:#FF0000">Client not found.</div>
			<cfelseif QClient.recordcount is 1>
				<cfset currClient=QClient.cltRef>
				<cfquery name="QTrans" datasource="#application.site.datasource1#"> <!--- Get transaction records --->
					SELECT *
					FROM tblTrans
					WHERE trnClientRef='#val(currClient)#'
					<cfif NOT StructKeyExists(url,"allTrans")>AND trnAlloc=0</cfif>
					ORDER BY trnDate, trnID
				</cfquery>
				<cfif QTrans.recordcount gt 0>
					<cfif print>
						<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
						<html xmlns="http://www.w3.org/1999/xhtml">
						<head>
							<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
							<title>Print Statement</title>
							<link rel="stylesheet" type="text/css" href="css/main.css"/>
						<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>

						<body>
					</cfif>
					<cfoutput>
						<cfif print><cfinclude template="busHeader.cfm"></cfif>
						<table width="630">
							<cfif print>
								<tr>
									<td colspan="10">
										<cfloop query="QClient">
											<table class="address">
												<tr><td width="30"></td><td>#cltName#</td></tr>
												<tr><td></td><td>#cltAddr1#</td></tr>
												<cfif len(cltAddr2)><tr><td></td><td>#cltAddr2#</td></tr></cfif>
												<tr><td></td><td>#cltTown#</td></tr>
												<cfif len(cltCounty)><tr><td></td><td>#cltCounty#</td></tr></cfif>
												<tr><td></td><td>#cltPostcode#</td></tr>
												<tr><td></td><td height="40">&nbsp;</td></tr>
												<tr><td></td><td>As at: #DateFormat(Now(),"dd-mmm-yyyy")#</td></tr>
												<tr><td></td><td>Account: #cltRef#</td></tr>
												<tr><td></td><td><cfif len(cltInfo1)>Ref:</cfif> #cltInfo1#&nbsp;</td></tr>
											</table>
										</cfloop>
									</td>
								</tr>
							<cfelse>
								<tr>
									<td><div id="clientKey">#QClient.cltRef#</div></td>
									<td colspan="9" height="30">#QClient.cltName#</td>
								</tr>
							</cfif>
							<tr>
								<cfif NOT print><th>ID</th></cfif>
								<th>Type</th>
								<th>Reference</th>
								<th>Date</th>
								<th>Method</th>
								<th>DR</th>
								<th>CR</th>
								<th>Balance</th>
								<cfif NOT print>
									<th>Paid In?</th>
									<th>Allocate?</th>
								</cfif>
							</tr>
							<cfset balance=0>
							<cfset totalDebit=0>
							<cfset totalCredit=0>
							<cfloop query="QTrans">
								<cfset balance=balance+trnAmnt1>
								<tr>
									<cfif NOT print><td>#trnID#</td></cfif>
									<td>#trnType#</td>
									<td>#trnRef#</td>
									<td>#DateFormat(trnDate,"dd-mmm-yyyy")#</td>
									<td class="centre">#trnMethod#</td>
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
									<cfif NOT print>
										<td class="centre">#trnPaidin#</td>
										<td class="centre">
											<input type="hidden" name="amnt#currentrow#" value="#trnAmnt1#" />
											<input type="checkbox" name="tick#currentrow#" id="tick#currentrow#" onClick="checkTotal('payForm');" 
												value="#trnID#"<cfif trnAlloc> checked="checked"</cfif> />
										</td>
									</cfif>
								</tr>
							</cfloop>
							<cfif print>
								<tr>
									<td height="40" colspan="6" class="amountTotal">Balance now due</td>
									<td class="amountTotal">&pound;#DecimalFormat(balance)#</td>
								</tr>
								<tr>
									<td height="40" colspan="7">
										Please make payment to <strong>Shortlanesend Store.</strong><br />
										Payment can also be made online using internet banking.<br />
										Bank: Lloyds TSBS plc. Sort Code: <strong>30-98-76</strong> Account: <strong>3534 5860</strong><br />
										If you have already paid this amount or believe there is an error on your account, please let us know.
									</td>
								</tr>
							<cfelse>
								<tr>
									<td colspan="6" class="amountTotal">Allocated Balance</td>
									<td class="amountTotal">
										&pound; <input id="Total" type="text" style="text-align:right; font-weight:bold;" size="6" value="0.00" name="Total" />
										<input type="hidden" name="tranCount" id="tranCount" value="#QTrans.recordcount#" />
										<input type="hidden" name="clientID" value="#QClient.cltID#" />
									</td>
									<td colspan="2">Select All</td><td align="center"><input type="checkbox" name="selectAll" onClick="javascript:checkall('payForm',toggle)" /></td>
								</tr>
							</cfif>
						</table>
					</cfoutput>
					<cfif print>
						</body>
						</html>
					</cfif>
				<cfelse>
					No unallocated transactions found. Click <strong>All Transactions</strong> to view the client's transaction history.
				</cfif>
			</cfif>
		</cfif>
	<cfelse>
		<div id="ajaxMsg" style="color:#FF0000">Client reference field is empty</div>
	</cfif>
<cfelse>
	<div id="ajaxMsg" style="color:#FF0000">Client reference not supplied</div>
</cfif>
