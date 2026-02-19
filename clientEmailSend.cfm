
<!---<cfdump var="#form#" label="form" expand="false">--->
<cfobject component="code/clients" name="cust">
<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.emailTemplate = 'invoice'>
<cfset filePath = "#application.site.dir_invoices#letters/">
<cfset logPath = "#application.site.dir_logs#email\">
<cfoutput>
	<table class="tableList" style="font-size:12px;" width="700">
		<tr>
			<td>Invoice Directory</td>
			<td>#application.site.dir_invoices#</td>
			<td></td>
			<td>
				<cfif DirectoryExists(application.site.dir_invoices)>
					<img src="images/icons/tick-green.png" width="36" height="36">
				<cfelse>
					<img src="images/icons/cross-red.png" width="36" height="36">
				</cfif>
			</td>
		</tr>
		<tr>
			<td>Attachment Directory</td>
			<td>#filePath#</td>
			<td></td>
			<td>
				<cfif DirectoryExists(filePath)>
					<img src="images/icons/tick-green.png" width="36" height="36">
				<cfelse>
					<img src="images/icons/cross-red.png" width="36" height="36">
				</cfif>
			</td>
		</tr>
		<tr>
			<td>Logs Directory</td>
			<td>#logPath#</td>
			<td></td>
			<td>
				<cfif DirectoryExists(logPath)>
					<img src="images/icons/tick-green.png" width="36" height="36">
				<cfelse>
					<img src="images/icons/cross-red.png" width="36" height="36">
				</cfif>
			</td>
		</tr>
		<tr>
			<td>File to Attach</td>
			<td>#attachFile#</td>
			<td></td>
			<td>
				<cfif FileExists("#filePath##attachFile#")>
					<img src="images/icons/tick-green.png" width="36" height="36">
					<cfset parms.attachFile = "#filePath##attachFile#">
					<cfset attachment = true>
				<cfelse>
					<cfset parms.attachFile = "">
					<cfset attachment = false>
					<img src="images/icons/cross-red.png" width="36" height="36">
				</cfif>
			</td>
		</tr>
		<tr>
			<td>Mail Server</td>
			<td>#application.siteclient.cltMailServer#</td>
			<td></td>
			<td><img src="images/icons/tick-green.png" width="36" height="36"></td>
		</tr>
		<tr>
			<td>Mail Account</td>
			<td>#application.siteclient.cltMailAccount#</td>
			<td></td>
			<td><img src="images/icons/tick-green.png" width="36" height="36"></td>
		</tr>
		<tr>
			<td>Mail Password</td>
			<td>#cust.DecryptStr(application.siteclient.cltMailPassword,application.siteRecord.scCode1)#</td>
			<td></td>
			<td><img src="images/icons/tick-green.png" width="36" height="36"></td>
		</tr>
		<tr>
			<td>From Address</td>
			<td>#application.siteclient.cltMailOffice#</td>
			<td></td>
			<td><img src="images/icons/tick-green.png" width="36" height="36"></td>
		</tr>
		<cfif StructKeyExists(form,"sendme")>
			<cfloop list="#form.sendme#" index="item">
				<cfset parms.tranRef = item>
				<cfset parms.srchDate = form.srchDate>
				<cfset parms.srchPwd = form.srchPwd>
				<cfset parms.testMsgs = StructKeyExists(form,"testMsgs")>
				<cfdump var="#parms#" label="parms" expand="yes" format="html" 
					output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
				<cfset detail = cust.CheckInvoiceToEmail(parms)>
				<cfdump var="#detail#" label="detail" expand="yes" format="html" 
					output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
				<cfif StructKeyExists(form,"sendMsgs")>
					<cfset result = cust.SendInvoiceByEmail(parms)>
					<tr>
						<td>Sent to:</td>
						<td>#item# - #result.data.name# - #result.data.address#</td>
						<td><a href="#result.data.url#" target="#result.data.trnRef#"><img src="images/pdfIcon.gif" /></a></td>
						<td>
							<cfif detail.status eq "found"><img src="images/icons/tick-green.png" width="36" height="36">
								<cfelse><img src="images/icons/cross-red.png" width="36" height="36"></cfif>
						</td>
						<td>#result.msg#</td>
					</tr>
				<cfelse>
					<tr>
						<td>Send messages option not ticked.</td>
					</tr>
				</cfif>
			</cfloop>
		<cfelse>
			<tr>
				<td>To Address</td>
				<td>No invoices selected</td>
				<td></td>
				<td><img src="images/icons/cross-red.png" width="36" height="36"></td>
			</tr>	
		</cfif>
	</table>
</cfoutput>
