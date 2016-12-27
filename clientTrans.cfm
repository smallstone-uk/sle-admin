<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.rec.cltRef=customer.rec.cltRef>
<cfset custTrans=cust.LoadClientTrans(parm)>
<cfoutput>
	<h1>Transaction History</h1>
	<table class="tableList" border="1" width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<th>ID</th>
			<th>Type</th>
			<th>Reference</th>
			<th width="100">Date</th>
			<th>Method</th>
			<th>DR</th>
			<th>CR</th>
			<th>Balance</th>
			<th>Allocated?</th>
			<th>Paid In?</th>
		</tr>
		<cfset balance=0>
		<cfset totalDebit=0>
		<cfset totalCredit=0>
		<cfloop array="#custTrans.trans#" index="item">
			<cfset balance=balance+item.amnt1>
			<tr>
				<td>#item.ID#</td>
				<td>#item.type#</td>
				<td>#item.ref#</td>
				<td>#DateFormat(item.date,"dd-mmm-yyyy")#</td>
				<td class="centre">#item.method#</td>
				<cfif item.amnt1 gt 0>
					<cfset totalDebit=totalDebit+item.amnt1>
					<td width="80" align="right">&pound;#DecimalFormat(item.amnt1)#</td>
					<td width="80">&nbsp;</td>
				<cfelse>
					<cfset totalCredit=totalCredit+item.amnt1>
					<td width="80">&nbsp;</td>
					<td width="80" align="right" style="color:##FF0000">&pound;#DecimalFormat(item.amnt1)#</td>
				</cfif>
				<td width="80" align="right">&pound;#DecimalFormat(balance)#</td>
				<td width="80">#item.alloc#</td>
				<td width="80">#item.paidin#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
