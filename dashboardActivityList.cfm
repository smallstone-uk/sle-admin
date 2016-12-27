<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/core" name="core">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.days=days>
<cfset list=core.LoadActivity(parm)>

<cfoutput>
	<table border="1" class="tableList" width="100%">
		<tr>
			<th width="30">Time</th>
			<th>Desciption</th>
			<th width="120">Type</th>
		</tr>
		<cfif ArrayLen(list)>
			<cfloop array="#list#" index="item">
				<tr>
					<td align="center">#TimeFormat(item.Timestamp,"HH:mm")#</td>
					<td><cfif val(item.Ref) neq 0><a href="clientDetails.cfm?row=0&ref=#item.Ref#" target="_blank">#item.Text#</a><cfelse>#item.Text#</cfif><cfif len(item.info)><br />#item.info#</cfif></td>
					<td align="center" style="text-transform:capitalize;">#item.Type#<br />#item.Pub#</td>
				</tr>
			</cfloop>
		<cfelse>
			<tr>
				<td colspan="3">No activity today</td>
			</tr>
		</cfif>
	</table>
</cfoutput>


