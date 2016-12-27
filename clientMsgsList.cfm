<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfparam name="notClientID" default="0">
<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.rec.cltID=notClientID>
<cfset custMsgs=cust.LoadClientMsgs(parm)>

<cfoutput>
	<h1>Recent Messages</h1>
	<table border="1" class="tableList" width="100%">
		<tr>
			<th width="100">Timestamp</th>
			<th width="80" style="text-transform:capitalize;">Type</th>
			<th>Ref</th>
			<th>Telephone</th>
			<th>Name</th>
			<th>Message</th>
			<th width="80" style="text-transform:capitalize;">Status</th>
		</tr>
		<cfloop query="custMsgs.QMsgs">
			<tr>
				<td>#DateFormat(notEntered,"dd-mmm-yy")# #TimeFormat(notEntered,"HH:MM")#</td>
				<td>#notType#</td>
				<td>#cltRef#</td>
				<td>#cltDelTel#</td>
				<td>#cltName# #cltCompanyName#</td>
				<td width="400">#notText#</td>
				<td>#notStatus#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>