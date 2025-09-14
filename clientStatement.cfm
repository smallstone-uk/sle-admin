<cftry>

<cfset callback=1> <!--- force exit of onrequestend.cfm --->
<cfset tabWidth="100%">
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfif StructKeyExists(url,"cust")>
	<cfif len(url.cust)>
		<cfquery name="QClient" datasource="#application.site.datasource1#"> <!--- Get selected customer record --->
			SELECT *
			FROM tblClients
			WHERE true
			<cfif StructKeyExists(url,"prev")>AND cltRef<#val(url.cust)# ORDER BY cltRef DESC
			<cfelseif StructKeyExists(url,"next")>AND cltRef>#val(url.cust)# ORDER BY cltRef ASC
			<cfelse>AND cltRef=#val(url.cust)#</cfif>
			LIMIT 1;
		</cfquery>
	</cfif>
	<cfif QClient.recordcount IS 1>
		<cfset allocatedTrans=StructKeyExists(url,"allTrans") AND url.allTrans>
		<cfquery name="QTrans" datasource="#application.site.datasource1#"> <!--- Get transaction records --->
			SELECT *
			FROM tblTrans
			WHERE trnClientRef='#val(QClient.cltRef)#'
			AND trnAlloc=#val(allocatedTrans)#
			ORDER BY trnDate, trnID
		</cfquery>
		<cfquery name="QTranBalance" datasource="#application.site.datasource1#"> <!--- Get transaction balance --->
			SELECT SUM(trnAmnt1) AS balance
			FROM tblTrans
			WHERE trnClientRef='#val(QClient.cltRef)#'
			AND trnAlloc=#val(allocatedTrans)#
		</cfquery>
		<cfif val(QTranBalance.balance) NEQ 0>
			<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml">
			<cfoutput>
				<head>
					<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
					<title>Statement-#QClient.cltRef#-#DateFormat(Now(),"yyyy-mm")#</title>
					<link rel="stylesheet" type="text/css" href="css/invoice.css"/>
				</head>
				<body>
					<cfinclude template="busHeader.cfm">
					<cfset tabWidth=630>
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
								<cfif len(cltCity)><cfset ln++><tr><td valign="top">#cltCity#</td></tr></cfif>
								<cfif len(cltCounty)><cfset ln++><tr><td valign="top">#cltCounty#</td></tr></cfif>
								<cfif len(cltPostcode)><cfset ln++><tr><td valign="top">#cltPostcode#</td></tr></cfif>
								<cfloop from="#ln+1#" to="9" index="i">
									<tr><td>&nbsp;</td></tr>
								</cfloop>
								<tr><td>Date: #DateFormat(Now(),"dd-mmm-yyyy")#</td></tr>
								<tr><td>Account: #cltRef#</td></tr>
							</table>
						</div>
						<div style="clear:both;"></div>
					</cfloop>
					<!--- transactions --->
					<table width="#tabWidth#" class="tableList" border="1">
						<tr>
							<cfif NOT print><th>ID</th></cfif>
							<th>Type</th>
							<th>Reference</th>
							<th>Date</th>
							<th>Method</th>
							<th>DR</th>
							<th>CR</th>
							<th>Balance</th>
							<th>Allocated</th>
						</tr>
						<cfset balance=0>
						<cfset totalDebit=0>
						<cfset totalCredit=0>
						<cfloop query="QTrans">
							<cfset balance=balance+trnAmnt1>
							<tr>
								<td>#trnID#</td>
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
								<td class="centre"><cfif trnAlloc>*</cfif></td>									
							</tr>
						</cfloop>
						<tr>
							<td height="40" colspan="7" class="amountTotal"><cfif balance lt 0>Account in credit<cfelse>Account Balance</cfif></td>
							<td class="amountTotal-box">&pound;#DecimalFormat(balance)#</td>
							<td></td>
						</tr>
						<tr>
							<td height="40" colspan="9" style="padding:7px; font-size:12px;">
								Please make payment to <strong>#application.company.companyname#</strong><br />
								Payment can also be made online using internet banking.<br />
								Bank: <strong>#application.company.bank_name#</strong><br />
								Sort Code: <strong>#application.company.bank_sortcode#</strong>&nbsp; Account: <strong>#application.company.bank_accountno#</strong><br />
								Please quote your account number <strong>ACC "#QClient.cltRef#"</strong> with your payment.<br />
								If you have already paid this amount or believe there is an error on your account, please let us know.
							</td>
						</tr>
					</table>
				</body>
			</cfoutput>
			</html>
		</cfif>
	</cfif>
<cfelse>
	No customer record specified.
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
