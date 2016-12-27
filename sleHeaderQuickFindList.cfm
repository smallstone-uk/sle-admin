<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/core" name="core">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.search=search>
<cfset list=core.SearchClients(parm)>

<cfoutput>
	<table class="tableList" width="100%" style="border-color:##fff;">
		<cfloop array="#list#" index="i">
			<tr>
				<td width="15" align="center">#i.Ref#</a></td>
				<td width="100"><a href="clientDetails.cfm?row=0&ref=#i.Ref#" target="_blank">#i.Name#</a></td>
				<td>#i.house# #i.street#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>


