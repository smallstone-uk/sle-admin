<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>EMail Client Invoices</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
<link rel="stylesheet" type="text/css" href="css/main3.css">

<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script>
	$(document).ready(function(e) {
		$('#selectAllOnList').click(function(event) {
			if (this.checked) {
				$('.selectitem').prop({checked: true});
				$('#selectAllOnList').prop({checked: true});
			} else {
				$('.selectitem').prop({checked: false});
				$('#selectAllOnList').prop({checked: false});
			}
		})
		$('#btnReload').click(function(e) {
			location.reload();
		})
		$('#btnSend').click(function(e) {
			$.ajax({
				type: 'POST',
				url: 'clientEmailSend.cfm',
				data: $('#emailForm').serialize(),
				beforeSend:function(){
					$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Sending...").fadeIn();
				},
				success:function(data){
					$('#loadingDiv').fadeOut();
					$('#resultDiv').html(data).show();
				},
				error:function(data){
					$('#resultDiv').html(data);
					$('#loadingDiv').loading(false);
				}
			});
			e.preventDefault();
		})
	});
</script>
<style>
	#resultDiv {float:left; clear:both;}
</style>
</head>

<cfparam name="sendMsgs" default="false">
<cftry>
	<cfobject component="code/clients" name="cust">
	<cfset parms = {}>
	<cfset parms.datasource = application.site.datasource1>
	<cfset parms.emailTemplate = 'invoice'>
	<cfset emailList = cust.LoadLatestInvoicesForEmail(parms)>
	<cfset aFewDaysAgo = DateAdd("d",-7,now())>
	<cfdirectory action="list" directory="#application.site.dir_invoices#letters" name="QDir" filter="*.pdf">
	<cfoutput>
		<h1>Send invoices by email...</h1>
		<form name="emailForm" id="emailForm">
			<input type="hidden" name="srchDate" id="srchDate" value="#emailList.ctlNextInvDate#" />
			<input type="hidden" name="srchPwd" id="srchPwd" value="#cust.DecryptStr(application.siteclient.cltMailPassword,application.siteRecord.scCode1)#" />
			<table class="tableList" style="font-size:12px;" width="700">
				<tr>
					<td>Current invoice date</td>
					<td>#emailList.invDate#</td>
				</tr>
				<tr>
					<td colspan="2">
						<cfif emailList.ctlNextInvDate lt aFewDaysAgo>
							<cfset startDate = DateAdd("d",-27,emailList.ctlNextInvDate)>
							<h1 class="warning">
								WARNING: Current invoice date is too far in the past. <br />
								The last invoice run was from #DateFormat(startDate,'ddd dd-mm-yyyy')# to #DateFormat(emailList.ctlNextInvDate,'ddd dd-mm-yyyy')#
							</h1>
						</cfif>		
					</td>
				</tr>
				<tr>
					<td>Attach File to Email<br />(no spaces allowed in filenames)</td>
					<td>
						<select name="attachFile" id="attachFile">
							<option value="">No attachment</option>
							<cfloop query="QDir">
								<option value="#name#">#name# #DateFormat(DateLastModified,"dd-mmm-yyyy")#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td>Options</td>
					<td>
						<input type="checkbox" name="testMsgs" value="1" checked="checked" />Send to test address?<br />
						<input type="checkbox" name="sendMsgs" value="1" />Send these messages?<br />
					</td>
				</tr>
				<tr>
					<td><input type="button" name="btnReload" id="btnReload" value="Reload Invoices" /></td>
					<td><input type="submit" name="btnSend" id="btnSend" value="Send Emails" /></td>
				</tr>
			</table>
			<div id="loadingDiv" style="width:700px; clear:both; background-color:##CCC"></div>		
			<div id="resultDiv">
				<table class="tableList" width="700">
					<tr>
						<th><input type="checkbox" name="selectAllOnList" id="selectAllOnList" style="width:20px; height:20px;"></th>
						<th>Ref</th>
						<th>name</th>
						<th>email</th>
						<th>trnRef</th>
						<th>Preview</th>
					</tr>
					<cfloop array="#emailList.msgs#" index="msg">
						<tr>
							<td><input type="checkbox" name="sendme" class="selectitem" value="#msg.trnRef#" /></td>
							<td>#msg.cltRef#</td>
							<td>#msg.name#</td>
							<td>#msg.email#</td>
							<td>#msg.trnRef#</td>
							<td><a href="#msg.url#" target="#msg.trnRef#"><img src="images/pdfIcon.gif" /></a></td>
						</tr>
					</cfloop>
				</table>
			</div>
		</form>
		
			
<!---		<form enctype="multipart/form-data" method="post">
			
			<table class="tableList">
				<tr>
					<th><input type="checkbox" name="selectAllOnList" class="selectAllOnList" style="width:20px; height:20px;"></th>
					<th>Ref</th>
					<th>name</th>
					<th>email</th>
					<th>trnRef</th>
					<th></th>
					<th></th>
				</tr>
				<cfloop array="#emailList.msgs#" index="msg">
					<tr>
						<td><input type="checkbox" name="sendme" class="selectitem" value="#msg.cltRef#" /></td>
						<td>#msg.cltRef#</td>
						<td>#msg.name#</td>
						<td>#msg.email#</td>
						<td>#msg.trnRef#</td>
						<td><a href="#msg.url#" target="_blank"><img src="images/pdfIcon.gif" /></a></td>
						<cfif sendMsgs AND ListFind(form.sendMe,msg.cltRef,",")>
							<cfif StructKeyExists(form,"testMsgs")>
								<cfset sendTo="#application.company.email_news#">
							<cfelse><cfset sendTo=msg.email></cfif>
							<cfset msgText = "Dear #msg.name#,<br />#ParagraphFormat(msg.text)#">
							<cfif 1 eq 2> <!--- safe while testing --->
							<cfmail 
								to="#sendTo#" 
								bcc="#application.siteclient.cltMailOffice#"
								from="#application.siteclient.cltMailOffice#"
								server="#application.siteclient.cltMailServer#"
								username="#application.siteclient.cltMailAccount#"
								password="#cust.DecryptStr(application.siteclient.cltMailPassword,application.siteRecord.scCode1)#"
								subject="#msg.subject# - #application.siteclient.cltCompanyName#">
								<cfmailpart charset="utf-8" type="text/plain">#cust.textMessage(msgText)#</cfmailpart>
								<cfmailpart charset="utf-8" type="text/html">#msgText#</cfmailpart>
								<cfmailparam type="application/pdf" disposition="attachment" file="#msg.attach#"></cfmailparam>
								<cfif len(attachLetter) AND attachment>
									<cfmailparam type="application/pdf" disposition="attachment" file="#attachFile1#"></cfmailparam>								
								</cfif>
							</cfmail>
							</cfif>
							<cffile action="append" addnewline="yes" 
								file="D:\HostingSpaces\SLE-Production\sle-admin.co.uk\data\logs\email\mail-#DateFormat(Now(),'yyyymmdd')#.txt"
								output="Message sent to: #sendTo# - #msg.subject# #msg.cltRef# #application.siteclient.cltMailAccount#">
							<td>sent to #sendTo#</td>
						<cfelse>
							<td>not sent</td>
						</cfif>
					</tr>
				</cfloop>
				<tr>
					<td colspan="7">#ArrayLen(emailList.msgs)#</td>
				</tr>
			</table>
		</form>
--->
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
<body>
</body>
</html>
