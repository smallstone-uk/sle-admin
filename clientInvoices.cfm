<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cftry>
<cfobject component="code/Invoicing" name="inv">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.clientID=val(clientID)>
<cfset files=inv.LoadFiles(parm)>

<style type="text/css">
	.red {color:#ff0000;}
</style>

<h1>Client Invoices</h1>
<cfoutput>
	<cfset group="">
	<cfloop array="#files.inv#" index="item">
		<cfif item.type neq group>
			<cfif len(group)></table></cfif>
			<cfset group=item.type>
			<table border="1" class="tableList" width="300" style="float:left;margin:0 5px 0 0;">
			<tr>
				<th colspan="4">Invoices</th>
			</tr>
			<tr>
				<th align="left">Date</th>
				<th width="60">Ref</th>
				<th width="60" align="right">Amount</th>
				<th width="60">PDF</th>
			</tr>
		</cfif>
		<tr>
			<td>#LSDateFormat(item.Date,"dd/mm/yyyy")#</td>
			<td>#item.Ref#</td>
			<td align="right"<cfif item.Amount lt 0> class="red"</cfif>>&pound;#DecimalFormat(item.Amount)#</td>
			<td align="center">
				<cfif FileExists("#application.site.dir_invoices##DateFormat(item.Date,'yy-mm-dd')#/#item.Type#-#item.Ref#.pdf")>
					<a href="#application.site.url_invoices##DateFormat(item.Date,'yy-mm-dd')#/#item.Type#-#item.Ref#.pdf" target="_blank">View</a>
				</cfif>
			</td>
		</tr>
	</cfloop>
</table>
	<cfset group="">
	<cfloop array="#files.crn#" index="item">
		<cfif item.type neq group>
			<cfif len(group)></table></cfif>
			<cfset group=item.type>
			<table border="1" class="tableList" width="300" style="float:left;margin:0 5px 0 0;">
			<tr>
				<th colspan="4">Credit Notes</th>
			</tr>
			<tr>
				<th align="left">Date</th>
				<th width="60">Ref</th>
				<th width="60" align="right">Amount</th>
				<th width="60">PDF</th>
			</tr>
		</cfif>
		<tr>
			<td>#LSDateFormat(item.Date,"dd/mm/yyyy")#</td>
			<td>#item.Ref#</td>
			<td align="right"<cfif item.Amount lt 0> class="red"</cfif>>&pound;#DecimalFormat(item.Amount)#</td>
			<td align="center">
				<cfif FileExists("#application.site.dir_invoices##DateFormat(item.Date,'yy-mm-dd')#/#item.Type#-#item.Ref#.pdf")>
					<a href="#application.site.url_invoices##DateFormat(item.Date,'yy-mm-dd')#/#item.Type#-#item.Ref#.pdf" target="_blank">View</a>
				</cfif>
			</td>
		</tr>
	</cfloop>
</table>
</cfoutput>

    <cfcatch type="any">
         <cfdump var="#cfcatch#" label="cfcatch" expand="no">
    </cfcatch>
</cftry>