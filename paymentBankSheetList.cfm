<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset banking=func.LoadBankSheet(parm)>
<cfset cashDates={}>
<cfset chqDates={}>
<cfset OverallGrandTotal=0>

<script type="text/javascript">
	$(document).ready(function() {
		$('#selectallcash').click(function() {
			if (this.checked) {
				$('.selectitemcash').prop("checked",true);
			} else {
				$('.selectitemcash').prop("checked",false);
			}
		});
		$('#selectallchq').click(function() {
			if (this.checked) {
				$('.selectitemchq').prop("checked",true);
			} else {
				$('.selectitemchq').prop("checked",false);
			}
		});
	});
</script>

<cftry>
<cfoutput>
	<h1 style="line-height:normal;padding:0;margin:0 0 10px 0;font-size:20px;">
		<span style="float:right;color:##333;font-size:14px;font-weight:bold;padding:5px 0 0 0;" id="datelabel">
			<cfif StructKeyExists(parm.form,"date")>
				#LSDateFormat(parm.form.date,"dd/mm/yy")#
			<cfelse>
				#LSDateFormat(Now(),"dd/mm/yy")#
			</cfif>
		</span>
		Shortlanesend Store 
	</h1>
	<table border="1" class="tableList" width="350" style="float:left;">
		<tr>
			<th colspan="4" style="font-size:14px;">Cash</th>
		</tr>
		<tr>
			<th width="50"><input type="checkbox" id="selectallcash" class="no-print" value="1" style="float:left;margin:0 3px 0 0;">Acc</th>
			<th align="left">Name</th>
			<th width="70" align="left">Date</th>
			<th width="60" align="right">Amount</th>
		</tr>
		<cfif ArrayLen(banking.cash)>
			<cfloop array="#banking.cash#" index="cash">
				<cfif StructKeyExists(cashDates,cash.Date)>
					<cfset date=StructFind(cashDates,cash.Date)>
					<cfset set={}>
					<cfset set.date=cash.date>
					<cfset set.count=date.count+1>
					<cfset set.amount=date.amount+cash.amnt1>
					<cfset StructUpdate(cashDates,cash.Date,set)>
				<cfelse>
					<cfset set={}>
					<cfset set.date=cash.date>
					<cfset set.count=1>
					<cfset set.amount=cash.amnt1>
					<cfset StructInsert(cashDates,cash.Date,set)>
				</cfif>
				<tr>
					<td align="center">
						<input type="checkbox" name="selectitem" class="selectitemcash no-print" value="#cash.ID#" style="float:left;margin:0 3px 0 0;">
						<a href="clientPayments.cfm?rec=#cash.ClientRef#" target="payments">#cash.ClientRef#</a>
					</td>
					<td>#cash.ClientName#</td>
					<td>#cash.date#</td>
					<td align="right">&pound;#DecimalFormat(cash.Amnt1)#</td>
				</tr>
			</cfloop>
			<tr>
				<th colspan="4">Summary</th>
			</tr>
			<tr>
				<th align="right" colspan="2">Date</th>
				<th align="center">Qty</th>
				<th align="right">Total</th>
			</tr>
			<cfset cashQty=0>
			<cfset cashDatesSort=StructSort(cashDates,"textnocase","asc","date")>
			<cfloop array="#cashDatesSort#" index="date">
				<cfset i=StructFind(cashDates,date)>
				<cfset cashQty=cashQty+i.count>
				<tr>
					<td align="right" colspan="2">#i.date#</td>
					<td align="center">#i.count#</td>
					<td align="right">&pound;#DecimalFormat(i.amount)#</td>
				</tr>
			</cfloop>
			<tr>
				<th colspan="2" align="right">Total</th>
				<td align="center">#cashQty#</td>
				<td align="right">
					<cfset totalCash=DecimalFormat(banking.TotalCash)>
					<strong>&pound;#totalCash#</strong>
				</td>
			</tr>
			<cfset OverallGrandTotal=OverallGrandTotal+totalCash>
		<cfelse>
			<tr><td colspan="4">No payments found</td></tr>
		</cfif>
	</table>
	<table border="1" class="tableList" width="345" style="float:left;margin:0 0 0 5px;">
		<tr>
			<th colspan="4" style="font-size:14px;">Cheque</th>
		</tr>
		<tr>
			<th width="50"><input type="checkbox" id="selectallchq" class="no-print" value="1" style="float:left;margin:0 3px 0 0;">Acc</th>
			<th align="left">Name</th>
			<th width="70" align="left">Date</th>
			<th width="60" align="right">Amount</th>
		</tr>
		<cfif ArrayLen(banking.chq)>
			<cfloop array="#banking.chq#" index="chq">
				<cfif StructKeyExists(chqDates,chq.Date)>
					<cfset date=StructFind(chqDates,chq.Date)>
					<cfset set={}>
					<cfset set.date=chq.date>
					<cfset set.count=date.count+1>
					<cfset set.amount=date.amount+chq.amnt1>
					<cfset StructUpdate(chqDates,chq.Date,set)>
				<cfelse>
					<cfset set={}>
					<cfset set.date=chq.date>
					<cfset set.count=1>
					<cfset set.amount=chq.amnt1>
					<cfset StructInsert(chqDates,chq.Date,set)>
				</cfif>
				<tr>
					<td align="center">
						<input type="checkbox" name="selectitem" class="selectitemchq no-print" value="#chq.ID#" style="float:left;margin:0 3px 0 0;">
						<a href="clientPayments.cfm?rec=#chq.ClientRef#" target="payments">#chq.ClientRef#</a>
					</td>
					<td>#chq.ClientName#</td>
					<td>#chq.date#</td>
					<td align="right">&pound;#DecimalFormat(chq.Amnt1)#</td>
				</tr>
			</cfloop>
			<tr>
				<th colspan="4">Summary</th>
			</tr>
			<tr>
				<th align="right" colspan="2">Date</th>
				<th align="center">Qty</th>
				<th align="right">Total</th>
			</tr>
			<cfset qtyChq=0>
			<cfset chqDatesSort=StructSort(chqDates,"textnocase","asc","date")>
			<cfloop array="#chqDatesSort#" index="date">
				<cfset i=StructFind(chqDates,date)>
				<cfset qtyChq=qtyChq+i.count>
				<tr>
					<td align="right" colspan="2">#i.date#</td>
					<td align="center">#i.count#</td>
					<td align="right">&pound;#DecimalFormat(i.amount)#</td>
				</tr>
			</cfloop>
			<tr>
				<th colspan="2" align="right">Total</th>
				<td align="center">#qtyChq#</td>
				<td align="right">
					<cfset totalChq=banking.TotalChq>
					<strong>&pound;#DecimalFormat(totalChq)#</strong>
				</td>
			</tr>
			<cfset OverallGrandTotal=OverallGrandTotal+totalChq>
		<cfelse>
			<tr><td colspan="4">No payments found</td></tr>
		</cfif>
	</table>
	<div style="clear:both;display:block;text-align:center;font-size:30px;padding:50px 0 0 0;">
		<span style="display:block;font-size:14px;">Grand Total</span>
		&pound;#DecimalFormat(OverallGrandTotal)#
	</div>
</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

