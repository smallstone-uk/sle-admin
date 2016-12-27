<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset vch=func.LoadVoucherReport(parm)>

<cfoutput>
	<table border="1" width="100%" class="tableList">
		<tr>
			<th width="45" align="center">Ref</th>
			<th width="300" align="left">Name</th>
			<th align="left">Vouchers</th>
		</tr>
		<cfif ArrayLen(vch)>
			<cfloop array="#vch#" index="c">
				<tr>
					<td align="center">#c.clientRef#</td>
					<td><a href="clientDetails.cfm?row=0&ref=#c.clientRef#" target="_blank">#c.clientName#</a></td>
					<td>
						<table border="1" class="tableList" width="100%">
							<tr>
								<th colspan="3" align="left">Latest Vouchers</th>
							</tr>
							<tr>
								<th align="left">Publication</th>
								<th width="80">Start</th>
								<th width="80">Stop</th>
							</tr>
							<cfloop array="#c.vouchers#" index="item">
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
					</td>
				</tr>
			</cfloop>
		</cfif>
	</table>
</cfoutput>

