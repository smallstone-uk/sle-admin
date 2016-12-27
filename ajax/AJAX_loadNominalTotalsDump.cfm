<cftry>
<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset totals = acc.LoadNominalTotalsDump(parm)>
<cfdump var="#totals#" label="totals" expand="no" abort="true">

<cfoutput>
	<table width="25%" border="1" class="tableList">
		<tr><th colspan="3">#totals.header.nomTitle#</th></tr>
		<tr>
			<th align="left">ID</th>
			<th align="right">Period</th>
			<th align="right">Balance</th>
		</tr>
		<cfloop array="#totals.items#" index="item">
			<tr>
				<td align="left">#item.ntID#</td>
				<td align="right">#item.ntPrd#</td>
				<td align="right">#DecimalFormat(item.ntBal)#</td>
			</tr>
		</cfloop>
		<tr>
			<th colspan="2" align="left">#totals.header.ntCount# records.</th>
			<th align="right">#DecimalFormat(totals.header.ntSum)#</th>
		</tr>
	</table>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>