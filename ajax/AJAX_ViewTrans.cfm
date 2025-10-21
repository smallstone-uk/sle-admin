
<cfobject component="code/accReports" name="report">

<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>

<cfset data = report.ViewTrans(parms)>
<cfif StructKeyExists(data,"msg")>
	<cfoutput><p>#data.msg#</p></cfoutput>
	<cfexit>
</cfif>

<cfset loc = {}>
<cfset loc.totalBalance = 0>
<cfset loc.errorCount = 0>
<cfoutput>
	<table class="tableList" border="1">
		<tr>
			<td colspan="5" align="center">
				<table>
					<tr>
						<td>Account:</td>
						<td>#form.title#</td>
						<td>From:</td>
						<td>#LSDateFormat(form.srchDateFrom,"dd-mmm-yyyy")#</td>
						<td>To:</td>
						<td>#LSDateFormat(form.srchDateTo,"dd-mmm-yyyy")#</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<th>Tran ID</th>
			<th>Reference</th>
			<th>Date</th>
			<th>Type</th>
			<th>Description</th>
		</tr>
		<cfloop array="#data.trans#" index="loc.tran">
			<tr>
				<td><a href="#application.site.normal#salesMain3.cfm?acc=1&tran=#loc.tran.trnID#" target="#loc.tran.trnID#">#loc.tran.trnID#</a></td>
				<td>#loc.tran.trnRef#</td>
				<td>#LSDateFormat(loc.tran.trnDate,'dd-mmm-yy')#</td>
				<td>#loc.tran.trnType#</td>
				<td>#loc.tran.trnDesc#</td>
			</tr>
			<tr>
				<td colspan="5">
					<table width="100%">
						<tr>
							<th>Code</th>
							<th>Account</th>
							<th>Group</th>
							<th>Value</th>
							<th>Invert</th>
						</tr>
						<cfset loc.balance = 0>
						<cfloop array="#loc.tran.items#" index="loc.item">
							<cfset loc.balance += loc.item.niAmount>
							<tr>
								<td>#loc.item.nomCode#</td>
								<td>#loc.item.nomTitle#</td>
								<td>#loc.item.nomGroup#</td>
								<td align="right"><i class="icon-text tran#loc.tran.trnID#" id="#loc.item.niID#">#loc.item.niAmount#</i></td>
								<td align="center">
									<span class="pm-flag" data-id="#loc.item.niID#" data-toggle="0" data-tran="#loc.tran.trnID#" data-value="#loc.item.niAmount#" title="click to invert this value">
										<i class="icon-img tick"></i>
									</span>
								</td>
							</tr>
						</cfloop>
						<cfif loc.balance lt 0.001><cfset loc.balance = 0></cfif>
						<cfif loc.balance neq 0>
							<cfset loc.class = "balanceError">
							<cfset loc.errorCount++>
						<cfelse><cfset loc.class = ""></cfif>
						<cfset loc.totalBalance += loc.balance>
						<tr>
							<th colspan="2">Balance #loc.class#</th>
							<th></th>
							<th align="right" id="bal#loc.tran.trnID#" class="#loc.class#">#DecimalFormat(loc.balance)#</th>
							<th></th>
						</tr>
					</table>
				</td>
			<tr>
		</cfloop>
		<cfif loc.totalBalance neq 0>
			<cfset loc.class = "balanceError">
		<cfelse><cfset loc.class = ""></cfif>
		<tr>
			<th colspan="5">
				<table width="100%" class="tableList">
					<tr>
						<th>#loc.errorCount# errors</th>
						<th>#data.tranCount# transactions.</th>
						<th>Balance</th>
						<th align="right" class="#loc.class#">#DecimalFormat(loc.totalBalance)#</th>
						<th></th>
					</tr>
				</table>
			</th>
		</tr>
	</table>
</cfoutput>

