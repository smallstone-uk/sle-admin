<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = 1>
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.form = form>
<cfset totals = acc.LoadNominalTotalsBetweenDates(parm)>
<cfsavecontent variable="totalsTable">
	<cfoutput>
		<table width="100%" border="1" class="tableList trhover">
			<tr>
				<th align="left" width="100">Code</th>
				<th align="left">Title</th>
				<th align="right" width="100">DR</th>
				<th align="right" width="100">CR</th>
			</tr>
			<cfloop array="#totals.items#" index="item">
				<tr>
					<td align="left">#item.NomCode#</td>
					<td align="left">#item.NomTitle#</td>
					<cfif item.Bal lt 0>
						<td colspan="1" align="right"></td>
						<td align="right">#DecimalFormat(abs(item.Bal))#</td>
					<cfelse>
						<td align="right">#DecimalFormat(abs(item.Bal))#</td>
						<td colspan="1" align="right"></td>
					</cfif>
				</tr>
			</cfloop>
			<tr>
				<th colspan="2" align="right">Total</th>
				<td align="right"><strong>#DecimalFormat(totals.header.drTotal)#</strong></td>
				<td align="right"><strong>#DecimalFormat(abs(totals.header.crTotal))#</strong></td>
			</tr>
		</table>
	</cfoutput>
</cfsavecontent>

<cfoutput>
	<a href="#parm.url#ajax/AJAX_createNomTotalReportPDF.cfm?Date_Start_Month=#parm.form.Date_Start_Month#&Date_Start_Year=#parm.form.Date_Start_Year#&Date_End_Month=#parm.form.Date_End_Month#&Date_End_Year=#parm.form.Date_End_Year#" id="ntrPrint" style="float:left;font-size:14px;margin-bottom:10px;" target="_newtab">Print</a>
	<div class="ntrContent">#totalsTable#</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="false">
</cfcatch>
</cftry>