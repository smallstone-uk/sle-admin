<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="1200">
<cfparam name="print" default="false">

<cfobject component="code/rounds5" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset report=rnd.RoundWage(parm)>
<cfdump var="#report#" label="report" expand="false">
<script type="text/javascript">
	$(document).ready(function() {
		$('.showDetail').click(function(e) {
			var id=$(this).attr("data-ID");
			$('.detailbar').hide();
			$('#detail'+id).show();
			e.preventDefault();
		});
	});
</script>

<cftry>
	<cfoutput>
		<table border="1" class="tableList trhover" width="100%">
			<tr>
				<th align="left">Round</th>
				<th width="70" align="center">Mileage</th>
				<th width="70" align="center">Pub Qty</th>
				<th width="70" align="center">Drop Qty</th>
				<th width="70" align="right">Drop Total</th>
			<!---	<th width="70" align="right">Wage</th>--->
				<th width="70" align="right">Extras</th>
				<th width="70" align="right">Total</th>
			</tr>
			<cfif ArrayLen(report.list)>
				<cfloop array="#report.list#" index="i">
					<tr>
						<td><a href="##" class="showDetail" data-ID="#i.ID#">#i.Title#</a></td>
						<td align="center">#i.mileage#</td>
						<td align="center">#i.pubqty#</td>
						<td align="center">#i.dropqty#</td>
						<td align="right">&pound;#DecimalFormat(i.deltotal)#</td>
						<!---<td align="right">&pound;#DecimalFormat(i.wage)#</td>--->
						<td align="right">&pound;#DecimalFormat(i.Bonus)#</td>
						<td align="right">&pound;#DecimalFormat(i.Total)#</td>
					</tr>
					<tr id="detail#i.ID#" class="detailbar" style="display:none;">
						<th colspan="8">
							<table border="1" class="tableList trhover" width="60%" style="background:white;">
								<tr>
									<th align="left">Day</th>
									<th width="70" align="center">Pub Qty</th>
									<th width="70" align="center">Drop Qty</th>
									<th width="70" align="right">Drop Total</th>
									<th width="70" align="right">Wage</th>
									<th width="70" align="right">Extras</th>
									<th width="70" align="right">Total</th>
								</tr>
								<cfset dayTotal=0>
								<cfloop array="#i.days#" index="d">
									<cfset dayTotal=dayTotal+d.Total>
									<tr>
										<td>#UCase(d.date)#</td>
										<td align="center">#d.PubQty#</td>
										<td align="center">#d.DropQty#</td>
										<td align="right">#DecimalFormat(d.DelTotal)#</td>
										<td align="right">#DecimalFormat(d.wage)#</td>
										<td align="right">#DecimalFormat(d.Bonus)#</td>
										<td align="right">#DecimalFormat(d.Total)#</td>
									</tr>
								</cfloop>
								<tr>
									<th align="right" colspan="6">Total</th>
									<td align="right"><strong>&pound;#DecimalFormat(dayTotal)#</strong></td>
								</tr>
							</table>
						</th>
					</tr>
				</cfloop>
			<cfelse>
				<tr><td colspan="8">No records found</td></tr>
			</cfif>
			<tr>
				<th align="right" colspan="4">Grand Total</th>
				<td align="right"><strong>&pound;#DecimalFormat(report.deltotal)#</strong></td>
				<td align="right"><strong>&pound;#DecimalFormat(report.wages)#</strong></td>
				<td align="right"><strong>&pound;#DecimalFormat(report.bonuses)#</strong></td>
				<td align="right"><strong>&pound;#DecimalFormat(report.grandtotal)#</strong></td>
			</tr>
			<tr>
				<th align="right" colspan="7">Loss</th>
				<td align="right"><strong>&pound;#DecimalFormat(report.loss)#</strong></td>
			</tr>
		</table>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
