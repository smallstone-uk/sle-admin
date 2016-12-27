
<!---<cfdump var="#report#" label="report" expand="false">--->
<style type="text/css">
	.tableSheet {border-spacing: 0px;border-collapse: collapse;border-color: #CCC;border: 1px solid #CCC;font-size: 11px;}
	.tableSheet th, .tableSheet td {padding:2px;}
	.tableSheet th, .tableSheet td {padding:2px;}
	.tableSheet .qtys {width:60px; text-align:right; margin-right:2px;}
	.tableSheet .qtytotals {width:60px; text-align:right; margin-right:2px; font-weight:bold;}
</style>

<cftry>
	<cfoutput>
		<table class="tableSheet" border="1">
		<cfset totReceived=0>
		<cfset totReturned=0>
		<cfset totClaimed=0>
		<cfset totCredited=0>
		<cfset totSold=0>
		<cfset totMissing=0>
		<cfset totValue=0>
		<cfset prevPub="">
		<cfset pubKeys=ListSort(StructKeyList(report.pubs,","),"text","asc",",")>
		<cfloop list="#pubKeys#" index="key">
			<cfset item=StructFind(report.pubs,key)>
			<!---<cfif item.missing neq 0>--->
				<cfset currPub=ListFirst(key,"-")>
				<cfif len(prevPub) AND prevPub neq currPub>
					<tr>
						<td colspan="2">&nbsp;</td>
						<td class="qtytotals">#totReceived#</td>
						<td class="qtytotals">#totReturned#</td>
						<td class="qtytotals">#totClaimed#</td>
						<td class="qtytotals">#totSold#</td>
						<td class="qtytotals">#totCredited#</td>
						<td class="qtytotals">#totMissing#</td>
						<td class="qtytotals">&pound;#totValue#</td>
					</tr>
					<tr>
						<td colspan="9">&nbsp;</td>
					</tr>
				</cfif>
				<cfif prevPub neq currPub>
					<cfset totReceived=0>
					<cfset totReturned=0>
					<cfset totClaimed=0>
					<cfset totCredited=0>
					<cfset totSold=0>
					<cfset totMissing=0>
					<cfset totValue=0>
					<tr>
						<td colspan="9"><strong>#currPub# - #item.pubTitle# - &pound;#item.psRetail# - &pound;#item.unitTrade#</strong></td>
					</tr>
					<tr>
						<th width="120">Date</th>
						<th width="60">Issue</th>
						<th class="qtys">Received</th>
						<th class="qtys">Returned</th>
						<th class="qtys">Claimed</th>
						<th class="qtys">Sold</th>
						<th class="qtys">Credited</th>
						<th class="qtys">Missing</th>
						<th class="qtys">Value</th>
					</tr>
				</cfif>
				<cfset totReceived += item.received>
				<cfset totReturned += item.returned>
				<cfset totClaimed += item.claim>
				<cfset totCredited += item.credited>
				<cfset totSold += item.sold>
				<cfset totMissing += item.missing>
				<cfset totValue += (item.missing * item.unitTrade)>
				<tr>
					<td>#item.psDate#</td>
					<td>#item.psIssue#</td>
					<td class="qtys">#item.received#</td>
					<td class="qtys">#item.returned#</td>
					<td class="qtys">#item.claim#</td>
					<td class="qtys">#item.sold#</td>
					<td class="qtys">#item.credited#</td>
					<td class="qtys"><cfif item.missing neq 0>#item.missing#</cfif></td>
					<td class="qtys"><cfif item.missing neq 0>&pound;#item.missing * item.unitTrade#</cfif></td>
				</tr>
				<cfset prevPub=currPub>
			<!---</cfif>--->
		</cfloop>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td class="qtytotals">#totReceived#</td>
			<td class="qtytotals">#totReturned#</td>
			<td class="qtytotals">#totClaimed#</td>
			<td class="qtytotals">#totSold#</td>
			<td class="qtytotals">#totCredited#</td>
			<td class="qtytotals">#totMissing#</td>
			<td class="qtytotals">&pound;#totValue#</td>
		</tr>
		</table>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
