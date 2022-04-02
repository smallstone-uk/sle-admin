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

<script src="scripts/main.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('.pencil_edit').click(function(event) {
			var noteID = $(this).attr("data-code");
			$.popupDialog({
				file: "AJAX_loadEditMsgForm",
				data: {"noteID": noteID},
				width: 700
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<h1>Recent Messages</h1>
	<table border="1" class="tableList" width="100%">
		<tr>
			<th width="50">ID</th>
			<th width="100">Timestamp</th>
			<th width="80" style="text-transform:capitalize;">Type</th>
			<th>Message</th>
			<th>Start</th>
			<th>Stop</th>
			<th width="80" style="text-transform:capitalize;">Status</th>
		</tr>
		<cfloop query="custMsgs.QMsgs">
			<tr>
				<td rowspan="2"><a href="javascript:void(0)" class="pencil_edit" data-code="#notID#" tabindex="-1"></a></td>
				<td rowspan="2">#DateFormat(notEntered,"dd-mmm-yy")# #TimeFormat(notEntered,"HH:MM")#</td>
				<td rowspan="2">#notType#</td>
				<td rowspan="2" width="400">#notText#</td>
				<td width="120"><strong>#DateFormat(notStart,"ddd dd-mmm")#</strong></td>
				<td width="120"><strong>#DateFormat(notEnd,"ddd dd-mmm")#</strong></td>
				<td rowspan="2">#notStatus#</td>
			</tr>
			<tr>
				<td colspan="2">
					<cfif notType eq "msg">
					<table border="0" class="tableList">
						<td width="26"><cfif notSun>Sun<cfelse>-</cfif></td>
						<td width="26"><cfif notMon>Mon<cfelse>-</cfif></td>
						<td width="26"><cfif notTue>Tue<cfelse>-</cfif></td>
						<td width="26"><cfif notWed>Wed<cfelse>-</cfif></td>
						<td width="26"><cfif notThu>Thu<cfelse>-</cfif></td>
						<td width="26"><cfif notFri>Fri<cfelse>-</cfif></td>
						<td width="26"><cfif notSat>Sat<cfelse>-</cfif></td>
					</table>
					</cfif>
				</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
