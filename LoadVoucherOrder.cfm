<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form.orderID=form.oiOrderID>
<cfset vouchers=cust.LoadVouchers(parm)>

<cfoutput>
	<table border="1" width="100%" class="tableList">
		<tr>
			<th width="20">ID</th>
			<th width="45">Order</th>
			<th width="200">Publication</th>
			<th width="100">Start</th>
			<th width="100">Stop</th>
		</tr>
		<cfif ArrayLen(vouchers.list)>
			<cfloop array="#vouchers.list#" index="item">
				<tr>
					<td>#item.ID#</td>
					<td><a href="#item.ID#" class="vchOrdLink" style="cursor:pointer;">#item.orderID#</a></td>
					<td>#item.Pub#</td>
					<td>#item.start#</td>
					<td>#item.stop#</td>
				</tr>
			</cfloop>
		</cfif>
	</table>
</cfoutput>

