<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="1200">
<cfparam name="print" default="false">

<cfobject component="code/rounds5" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset report=rnd.RoundReport(parm)>

<cfoutput>
	<table border="1" class="tableList trhover" width="100%">
		<tr>
			<th align="left">Round</th>
			<th width="70" align="center">Pub Qty</th>
			<th width="70" align="center">Drop Qty</th>
			<th width="70" align="right">Pub Total</th>
			<th width="70" align="right">Pub Cost</th>
			<th width="70" align="right">Pub Gross</th>
			<th width="70" align="right">Drop Total</th>
			<th width="70" align="right">Wages</th>
			<th width="70" align="right">Net</th>
		</tr>
		<cfif ArrayLen(report.list)>
			<cfloop array="#report.list#" index="i">
				<tr>
					<td>#i.Title# (#Ucase(i.date)#)</td>
					<td align="center">#i.pubqty#</td>
					<td align="center">#i.dropqty#</td>
					<td align="right">&pound;#DecimalFormat(i.pubtotal)#</td>
					<td align="right" style="color:##ff0000;">-&pound;#DecimalFormat(i.roundexp)#</td>
					<td align="right">&pound;#DecimalFormat(i.grosstotal)#</td>
					<td align="right">&pound;#DecimalFormat(i.deltotal)#</td>
					<td align="right" style="color:##ff0000;">-&pound;#DecimalFormat(i.wage)#</td>
					<td align="right">&pound;#DecimalFormat(i.profit)#</td>
				</tr>
			</cfloop>
		<cfelse>
			<tr><td colspan="9">No records found</td></tr>
		</cfif>
		<tr>
			<th align="right" colspan="3">Totals</th>
			<td align="right"><strong>&pound;#DecimalFormat(report.pubtotal)#</strong></td>
			<td align="right" style="color:##ff0000;"><strong>-&pound;#DecimalFormat(report.pubcost)#</strong></td>
			<td align="right"><strong>&pound;#DecimalFormat(report.grossgrandtotal)#</strong></td>
			<td align="right"><strong>&pound;#DecimalFormat(report.droptotal)#</strong></td>
			<td align="right" style="color:##ff0000;"><strong>-&pound;#DecimalFormat(report.wagecost)#</strong></td>
			<td align="right"><strong>&pound;#DecimalFormat(report.Total)#</strong></td>
		</tr>
		<tr>
			<th align="right" colspan="8">Admin Fee</th>
			<td align="right" style="color:##ff0000;"><strong>-&pound;#DecimalFormat(report.adminfee)#</strong></td>
		</tr>
		<tr>
			<th align="right" colspan="8">Bank Charges</th>
			<td align="right" style="color:##ff0000;"><strong>-&pound;#DecimalFormat(report.bankcharges)#</strong></td>
		</tr>
		<tr>
			<th align="right" colspan="8">Overall Profit</th>
			<td align="right"><strong>&pound;#DecimalFormat(report.grandtotal)#</strong></td>
		</tr>
	</table>
</cfoutput>

