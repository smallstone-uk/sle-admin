<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/core" name="core">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.orderID=ID>
<cfset list=core.ExpiringVouchers(parm)>
					
<cfoutput>
	<cfif ArrayLen(list)>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th colspan="3" align="left">Latest Vouchers</th>
			</tr>
			<tr>
				<th align="left">Publication</th>
				<th width="80">Start</th>
				<th width="80">Stop</th>
			</tr>
			<cfloop array="#list#" index="item">
				<tr>
					<td>
						#item.pub#
						<cfif item.stop lte Now()>
							<i class="expired" style="float:right;">Expired</i>
						<cfelse>
							<i style="float:right;"<cfif item.reDays lte 3> class="expiring"</cfif>>
								<cfif item.reDays gt 0>#item.reDays# <cfif item.reDays neq 1>days<cfelse>day</cfif><cfelse>Expired</cfif> left
							</i>
						</cfif>
					</td>
					<td>#item.start#</td>
					<td>
						<cfif item.stop lte Now()>
							<b class="expired">#LSDateFormat(item.stop,"dd/mm/yyyy")#</b>
						<cfelse>
							<b>#LSDateFormat(item.stop,"dd/mm/yyyy")#</b>
						</cfif>
					</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cfoutput>


