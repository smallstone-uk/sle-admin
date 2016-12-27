<!--- AJAX call - check client do not show debug data at all --->
<cftry>
<cfset callback=1> <!--- force exit of onrequestend.cfm --->
<cfset tabWidth="600">
<cfsetting showdebugoutput="no">
<cfif StructKeyExists(url,"client")>
	<cfquery name="QClient" datasource="#application.site.datasource1#"> <!--- Get selected client record --->
		SELECT *
		FROM tblClients
		WHERE true
		AND cltRef=#val(url.client)#
		LIMIT 1;
	</cfquery>
	<cfif QClient.recordcount is 0>
		<div id="ajaxMsg" style="color:#FF0000">Client not found.</div>
	<cfelseif QClient.recordcount is 1>
		<cfset currClient=QClient.cltRef>
		<cfoutput>
			<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<title>Letter-#QClient.cltRef#-#DateFormat(Now(),"yyyy-mm-dd")#</title>
				<link rel="stylesheet" type="text/css" href="css/invoice.css"/>
			</head>
			<body>
				<cfinclude template="busHeader.cfm">
				<div id="address">
					<cfloop query="QClient">
						<div style="float:left;width:310px;margin:40px 0 0 50px;">
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
								<tr><td>Date: #DateFormat(now(),"dd mmmm yyyy")#</td></tr>
								<tr><td>Reference: #cltRef#</td></tr>
								<tr><td height="40">&nbsp;</td></tr>
								<tr><td>
									Dear 
									<cfif len(cltName)>
										<cfif len(cltTitle)>#cltTitle#<cfelse>Mr.</cfif> #cltName#,
									<cfelse>
										Sir or Madam,
									</cfif>
								</td></tr>
							</table>
						</div>
					</cfloop>
					<div style="clear:both;"></div>
				</div>
				<div style="float:left;width:600px;margin:0px 0 0 50px;">
				<table border="0" cellspacing="0" cellpadding="1" width="#tabWidth#" style="font-size:13px;">
					<tr>
						<td>
							<p>Please find enclosed copy of your account statement. We are sending this to you because
							there are some missing payments on your account. It may well be that you have paid these invoices
							but for some reason your payment has not been recorded on your account.</p>
							<p>I would be grateful if you could check your records and let me know the date on which the 
							invoices in question were paid and the method by which you paid, e.g. card, cheque or cash.</p>
							<p>The unpaid invoices are those listed without an asterisk in the 'allocated' column.</p>
							<p>If you find any invoices that have not been paid would you please pay them either by return or
							when you pay your next invoice. If the amount outstanding would cause you financial difficulty or
							distress, please contact me at your earliest convenience to make alternative arrangements to 
							settle the account.</p>
							<p>
								Yours sincerely,<br /><br /><br /><br /><br />
								Steven Kingsley<br />
								Shortlanesend Store
							</p>							
						</td>
					</tr>
				</table>
				</div>
			</body>
			</html>
		</cfoutput>
	</cfif>
</cfif>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
