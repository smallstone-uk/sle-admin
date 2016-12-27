<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="1200">
<cfparam name="print" default="false">

<cfobject component="code/rounds5" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset report=rnd.RoundWage(parm)>

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

<cfoutput>
	<table border="1" class="tableList" width="100%">
		<tr>
			<th align="left">Round</th>
			<th width="70" align="center">Mileage</th>
			<th width="70" align="center">Pub Qty</th>
			<th width="70" align="center">Drop Qty</th>
			<th width="70" align="right">Drop Total</th>
			<th width="70" align="right">Extras</th>
			<th width="70" align="right">Total</th>
			<th width="70" align="right">Pay</th>
		</tr>
		<cfif ArrayLen(report.list)>
			<cfloop array="#report.list#" index="i">
				<tr>
					<td><a href="##" class="showDetail" data-ID="#i.ID#">#i.Title#</a></td>
					<td align="center">#i.mileage#</td>
					<td align="center">#i.pubqty#</td>
					<td align="center">#i.dropqty#</td>
					<td align="right">&pound;#DecimalFormat(i.deltotal)#</td>
					<td align="right">&pound;#DecimalFormat(i.Bonus)#</td>
					<td align="right">&pound;#DecimalFormat(i.Total)#</td>
					<td align="right">
						<cfif i.Pay lt 180>
							£180.00
						<cfelse>
							&pound;#DecimalFormat(i.Pay)#
						</cfif>
					</td>
				</tr>
				<tr id="detail#i.ID#" class="detailbar" style="display:none;">
					<td colspan="8" align="center" style="padding:10px;">
						<table border="1" class="tableList trhover" width="60%" style="background:white;">
							<tr>
								<th align="left">Day</th>
								<th width="70" align="center">Pub Qty</th>
								<th width="70" align="center">Drop Qty</th>
								<th width="70" align="right">Drop Total</th>
								<th width="70" align="right">Extras</th>
								<th width="70" align="right">Total</th>
							</tr>
							<cfset dayTotal=0>
							<cfset dayPay=0>
							<cfloop array="#i.days#" index="d">
								<cfset dayTotal=dayTotal+d.Total>
								<cfset dayPay=dayPay+d.Pay>
								<tr>
									<td>#UCase(d.date)#</td>
									<td align="center">#d.PubQty#</td>
									<td align="center">#d.DropQty#</td>
									<td align="right">&pound;#DecimalFormat(d.DelTotal)#</td>
									<td align="right">&pound;#DecimalFormat(d.Bonus)#</td>
									<td align="right">&pound;#DecimalFormat(d.Total)#</td>
								</tr>
							</cfloop>
							<tr>
								<th align="right" colspan="5">Total</th>
								<td align="right"><strong>&pound;#DecimalFormat(dayTotal)#</strong></td>
							</tr>
						</table>
					</td>
				</tr>
			</cfloop>
		<cfelse>
			<tr><td colspan="8">No records found</td></tr>
		</cfif>
		<tr>
			<th align="right" colspan="4">Totals</th>
			<td align="right"><strong>&pound;#DecimalFormat(report.deltotal)#</strong></td>
			<td align="right"><strong>&pound;#DecimalFormat(report.bonuses)#</strong></td>
			<td align="right"><strong>&pound;#DecimalFormat(report.total)#</strong></td>
			<td align="right"><strong>&pound;#DecimalFormat(report.grandtotal)#</strong></td>
		</tr>
		<tr>
			<th align="right" colspan="6">Total Income</th>
			<cfset totIncome=report.profit.total+report.profit.droptotal>
			<td align="right"><strong>&pound;#DecimalFormat(totIncome)#</strong></td>
			<td align="right"><strong>&pound;#DecimalFormat(totIncome)#</strong></td>
		</tr>
		<tr>
			<th align="right" colspan="6">Less Driver Pay</th>
			<td align="right"><strong>-&pound;#DecimalFormat(report.total)#</strong></td>
			<td align="right"><strong>-&pound;#DecimalFormat(report.grandtotal)#</strong></td>
		</tr>
		<tr>
			<th align="right" colspan="6">Less Admin Fee</th>
			<td align="right"><strong>-&pound;#DecimalFormat(report.profit.adminfee)#</strong></td>
			<td align="right"><strong>-&pound;#DecimalFormat(report.profit.adminfee)#</strong></td>
		</tr>
		<tr>
			<th align="right" colspan="6">Less Bank Charges</th>
			<td align="right"><strong>-&pound;#DecimalFormat(report.profit.bankcharges)#</strong></td>
			<td align="right"><strong>-&pound;#DecimalFormat(report.profit.bankcharges)#</strong></td>
		</tr>
		<tr>
			<th align="right" colspan="6">Profit</th>
			<cfset grandtot1=(report.profit.total+report.profit.droptotal)-report.profit.adminfee-report.profit.bankcharges-report.total>
			<cfset grandtot2=(report.profit.total+report.profit.droptotal)-report.profit.adminfee-report.profit.bankcharges-report.grandtotal>
			<td align="right"><strong>&pound;#DecimalFormat(grandtot1)#</strong></td>
			<td align="right"><strong>&pound;#DecimalFormat(grandtot2)#</strong></td>
		</tr><!------>
	</table>
</cfoutput>

