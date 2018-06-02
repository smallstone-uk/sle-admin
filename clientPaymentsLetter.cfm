<cftry>
	<cfobject component="code/functions" name="func">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.ID=id>
	<cfset parm.clientID=userID>
	<cfset parm.preview=preview>
	<cfset user=func.LoadClientByID(parm)>
	<cfset letter=func.LoadLetter(parm)>
	<cfif parm.preview is 0>
		<cfset parm.date=LSDateFormat(now(),"yyyy-mm-dd")>
		<cfset parm.level=letter.Level>
		<cfset parm.text=letter.Title>
		<cfset chase=func.UpdateClientChase(parm)>
	</cfif>
	
	<cfquery name="QHeader" datasource="#application.site.dataSource0#">
		SELECT *
		FROM cmsclients
		WHERE cltSiteID=#application.site.clientID#
		LIMIT 1;
	</cfquery>
	
	<cfoutput>
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
			<title>Letter-#user[1].cltRef#-#DateFormat(Now(),"yyyy-mm-dd")#</title>
		</head>
		<body>
		<table border="0" cellspacing="0" cellpadding="0" style="margin:0;font-family:Arial, Helvetica, sans-serif;line-height:22px;" width="100%">
			<tr>
				<td width="50%" style="margin:20px 0 0 0 ;font-size:32px;font-weight:bold;color:##075086;padding:10px 0;" align="left">#QHeader.cltCompanyName#</td>
				<td width="50%" style="font-size:22px;font-weight:normal;color:##333;" align="right">#letter.Title#</td>
			</tr>
			<tr>
				<td align="left" style="font-size:14px;color:##333;line-height:16px;" rowspan="2">
					<strong>#QHeader.cltAddress1#<br />#QHeader.cltAddress2#<br />#QHeader.cltTown#<br />#QHeader.cltPostcode#</strong></td>
				<td align="right"><strong style="font-size:16px;color:##333;">Telephone: #QHeader.cltTel1#</strong></td>
			</tr>
			<tr>
				<td align="right" style="font-size:13px;color:##333;line-height:16px;">Email: #QHeader.cltMailOffice#<br />Website: #QHeader.cltWebSite#</td>
			</tr>
		</table>
		<div style="border-bottom:1px solid ##999;">&nbsp;</div>
		
		<div style="float:left;width:310px;margin:60px 0 0 60px;">
			<table border="0" cellspacing="0" cellpadding="1" style="font-size:13px;">
				<cfif len(user[1].cltName)>
					<tr>
						<td valign="top">
							<cfif len(user[1].cltTitle)>#user[1].cltTitle# </cfif>
							<cfif len(user[1].cltInitial)>#user[1].cltInitial# </cfif>
							#user[1].cltName#
						</td>
					</tr>
				</cfif>
				<cfif len(user[1].cltDept)><tr><td valign="top">#user[1].cltDept#</td></tr></cfif>
				<cfif len(user[1].cltCompanyName)><tr><td valign="top">#user[1].cltCompanyName#</td></tr></cfif>
				<cfif len(user[1].cltAddr1)><tr><td valign="top">#user[1].cltAddr1#</td></tr></cfif>
				<cfif len(user[1].cltAddr2)><tr><td valign="top">#user[1].cltAddr2#</td></tr></cfif>
				<cfif len(user[1].cltTown)><tr><td valign="top">#user[1].cltTown#</td></tr></cfif>
				<cfif len(user[1].cltCity)><tr><td valign="top">#user[1].cltCity#</td></tr></cfif>
				<cfif len(user[1].cltCounty)><tr><td valign="top">#user[1].cltCounty#</td></tr></cfif>
				<cfif len(user[1].cltPostcode)><tr><td valign="top">#user[1].cltPostcode#</td></tr></cfif>
			</table>
		</div>
		<div style="float:right;width:280px;margin:20px 0 0 0;">
			<table border="1" cellspacing="0" class="tableList" width="100%">
				<tr><th width="110" align="left">Account Number</th><td>#user[1].cltRef#</td></tr>
				<tr><th width="110" align="left">Date</th><td>#LSDateFormat(Now(),"DD/MM/YYYY")#</td></tr>
			</table>
		</div>
		<div style="clear:both;padding:20px 0;"></div>
		
		<div style="font-size:13px; width:600px; margin:60px 60px 0 60px;">
			<p>Dear 
				<cfif len(user[1].cltTitle)>#user[1].cltTitle# </cfif>
				<cfif len(user[1].cltName)>#user[1].cltName#,
					<cfelse>Sirs,</cfif>
			</p>
			#letter.Text#
		</div>
		</body>
		</html>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
