<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfsetting requesttimeout="900">
<cfobject component="code/publications" name="pub">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfif form.type eq "newMissing">
	<cfset report=pub.PubMovementReport(parm)>
	<cfinclude template="pubStockMissing.cfm">
	<cfexit>
<cfelse>
	<cfset report=pub.BuildReport(parm)>
</cfif>
<style type="text/css">
	.tableList {}
	.tableList th, .tableList td {padding:2px;}
	.tableList th, .tableList td {padding:2px;}
	.tableList th .qtys {text-align:right; color:#FF0000;}
</style>

<script type="text/javascript">
	$(document).ready(function() {
		function BuildReport() {
			$.ajax({
				type: 'POST',
				url: 'GetPubStockReport.cfm',
				data : $('#reportForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					$('#printReport').prop("disabled",true);
				},
				success:function(data){
					$('#report').html(data);
					$('#loading').fadeOut();
					$('#printReport').prop("disabled",false);
				},
				error:function(data){
					$('#report').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		$('#btnUpdateReport').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'pubStockReportUpdate.cfm',
				data : $('#reportListForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Processing...").fadeIn();
				},
				success:function(data){
					$('#loading').html(data);
					BuildReport();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<a href="##" id="btnUpdateReport" class="button no-print">Close Selected Items</a>
	<h1 style="text-transform:capitalize;font-size:18px;">Publication #parm.form.type# Report</h1>
	<p style="text-transform:capitalize;font-weight:bold;font-size:12px;">From: #LSDateFormat(parm.form.from,"DD MMM YYYY")# - To: #LSDateFormat(parm.form.to,"DD MMM YYYY")#</p>
	<cfif ArrayLen(report.list)>
		<cfset title="">
		<cfset issue="">
		<cfset total=0>
		<cfset totalCost=0>
		<form method="post" id="reportListForm">
			<table border="1" class="tableList" style="font-size:11px;" width="100%">
				<tr>
					<th align="left" class="no-print"></th>
					<th align="left" class="no-print">ID</th>
					<th align="left">Publication</th>
					<th width="60">RRP</th>
					<th align="left" width="120"><cfif parm.form.type is "missing credit">Return Date<cfelse>Date</cfif></th>
					<th width="50">Issue</th>
					<th width="50">Type</th>
					<th width="50">Sub-Type</th>
					<th width="35">Received</th>
					<th width="35">Returned</th>
					<th width="35">Claimed</th>
					<th width="35">Credited</th>
					<th width="35"><cfif parm.form.type is "missing credit">Remaining<cfelse>Difference</cfif></th>
					<th width="80">Line Total</th>
				</tr>
				<cfloop array="#report.list#" index="i">
					<cfif title neq i.PubID>
						<cfif title neq "">
							<tr><td colspan="14" style="background:##ddd;padding:5px 0;"></td></tr>
						</cfif>
						<cfset title=i.PubID>
						<cfset issue="">
					</cfif>
					<cfif issue neq i.Issue>
						<cfif issue neq "">
							<tr><td colspan="14" style="background:##eee;"></td></tr>
						</cfif>
						<cfset issue=i.Issue>
					</cfif>
					<tr>
						<td align="center" width="10" class="no-print"><input type="checkbox" name="selectitem" value="#i.ID#" /></td>
						<td align="center" width="10" class="no-print">#i.ID#</td>
						<td align="left">#i.Title# <span style="float:right;color:##333;padding:0 10px 0 0;"><cfif len(i.ref)>(#i.Ref#)</cfif></span> <span style="float:right;color:##333;padding:0 10px 0 0;">#i.URN# #I.psAction#</span></td>
						<td align="center" style="font-weight:bold;">#DecimalFormat(i.Retail)#</td>
						<td align="left">#DateFormat(i.Date,"DD MMM YYYY")#<span style="float:right;color:##444;">#DateFormat(i.Date,"DDD")#</span></td>
						<td align="center">#i.Issue#</td>
						<td align="center">#i.Type#</td>
						<td align="center">#i.subType#</td>
						<td align="center" style="font-weight:bold;">
							<cfif i.type eq "received">#i.Qty#</cfif>
							<cfif StructKeyExists(i,"revQty")>#val(i.revQty)#</cfif>
						</td>
						<td align="center" style="font-weight:bold;"><cfif i.type eq "returned">#i.Qty#</cfif></td>
						<td align="center" style="font-weight:bold;"><cfif i.type eq "claim">#i.Qty#</cfif></td>
						<td align="center" style="font-weight:bold;"<cfif i.type eq "credited" AND i.Qty neq 0> class="#i.class#"</cfif>>
							<cfif i.type eq "credited">#i.Qty#</cfif>
							<cfif StructKeyExists(i,"crdQty")>#val(i.crdQty)#</cfif>
						</td>
						<td align="center" style="font-weight:bold;"<cfif i.diff neq 0> class="#i.class#"</cfif>>
							<cfif i.diff neq 0>#i.diff#<cfset total=total+i.diff></cfif>
						</td>
						<td align="right" style="font-weight:bold;">
							<cfset totalCost=totalCost+(i.Retail*i.diff)>
							<cfif i.Retail*i.diff neq 0>#DecimalFormat(i.Retail*i.diff)#</cfif>
						</td>
					</tr>
				</cfloop>
				<tr>
					<th colspan="12" align="right" style="font-size:16px;">Totals</th>
					<th align="center" style="font-size:14px;"><strong>#total#</strong></th>
					<th align="right" style="font-size:14px;"><strong>#DecimalFormat(totalCost)#</strong></th>
				</tr>
			</table>
		</form>
	<cfelse>
		<div>No #parm.form.type#s found</div>
	</cfif>
</cfoutput>
