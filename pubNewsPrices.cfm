<link rel="stylesheet" type="text/css" href="css/main4.css">
<style type="text/css">
	body {background-color:#FFFFFF;}
	.tableList {font-size:16px; font-family:Arial, Helvetica, sans-serif;}
	.boldie {border:solid 2px #000;}
	.msg {font-size:14px; font-weight:bold; margin-left:35px;}
	.ref {border-bottom:solid 1px #000;}
	.instructions {font-family:Arial, Helvetica, sans-serif; font-size:16px;}
</style>

<cfset tempdate=Now()>
<cfset tempdate=createdate(2016,08,23)>
<cfif StructKeyExists(variables,"parm")>
	<cfset adate=parm.roundDate>
<cfelse>
	<cfset adate=tempdate>
	<cfset adate=DateAdd("d",1,adate)>
</cfif>
<cfset dayNo=DayofWeek(adate)-1>
<cfif dayNo eq 0><cfset dayNo=7></cfif>
								
<cfquery name="QNewspapers" datasource="#application.site.datasource1#" result="QResult">
	SELECT pubID,pubTitle,pubRoundTitle,pubShortTitle,pubType,pubArrival,pubCategory,pubGroup,pubPrice,pubActive 
	FROM tblPublication
	WHERE (pubCategory='news' OR pubCategory='sunday' OR pubCategory='local')
	AND pubGroup='news'
	AND pubActive
	AND pubPrice>0	<!--- excludes supplements --->
	<cfif dayNo LT 6>
		AND (pubType = 'weekly' AND pubArrival=#val(dayNo)# OR pubType = 'morning')
	<cfelseif dayNo eq 6>
		AND pubType='saturday'
	<cfelseif dayNo eq 7>
		AND pubType='sunday'
	</cfif>
	ORDER BY pubType, pubShortTitle, pubPrice
</cfquery>
<!---<cfdump var="#QResult#" label="QResult" expand="false">--->
<cfset pubList=[]>
<cfset pubClass="">
<cfset priceIndex=1>
<cfset rec={}>
<cfset rec.pubID=0>
<cfset rec.price="">
<cfset rec.qty="">
<cfloop query="QNewspapers">
	<cfif pubClass NEQ "" AND pubRoundTitle NEQ pubClass>
		<cfset ArrayAppend(pubList,rec)>
		<cfset rec={}>
		<cfset rec.pubID=pubID>
		<cfset rec.price="">
		<cfset rec.qty="">
		<cfset priceIndex=1>
	</cfif>
	<cfset rec.title=pubShortTitle>
	<cfset rec.price=pubPrice>
	<cfif StructKeyExists(variables,"drops")>
		<cfif StructKeyExists(drops.GrandTotalQty,pubID)>
			<cfset paper=StructFind(drops.GrandTotalQty,pubID)>
			<cfset rec.qty=paper.qty>
		</cfif>
	</cfif>
	<cfset pubClass=pubRoundTitle>		
	<cfset priceIndex++>
</cfloop>
<cfset ArrayAppend(pubList,rec)>	<!--- add last one --->

<cfoutput>
<div style="page-break-before:always;"></div>
<table class="tableList" border="1">
	<tr>
		<th colspan="3">Newspaper Stock Movement</th>
		<th colspan="5"> #DateFormat(adate,"ddd dd-mmm-yyyy")#</th>
		<th>#dayNo#</th>
	</tr>
	<tr>
		<th width="230">Publication Title</th>
		<th align="right" width="50">Price</th>
		<th align="center" width="50">Round Stock</th>
		<th align="center" width="50">Shop Stock</th>
		<th align="center" width="50">Hotels</th>
		<th align="center" width="50">Spoilt</th>
		<th align="center" width="50">Received Smiths</th>
		<th align="center" width="50">Diff</th>
		<th align="center" width="50">Claimed</th>
	</tr>
	<tr>
		<th></th>
		<th></th>
		<th>A</th>
		<th>B</th>
		<th>C</th>
		<th>D</th>
		<th>E</th>
		<th></th>
		<th></th>
	</tr>
	<cfloop array="#pubList#" index="item">
	<tr>
		<td>#item.title#</td>
		<td align="right">#item.price#</td>
		<td align="right">#item.qty#</td>
		<td class="boldie"></td>
		<td></td>
		<td></td>
		<td class="boldie"></td>
		<td></td>
		<td></td>
	</tr>
	</cfloop>
	<cfloop from="1" to="2" index="i">
		<tr>
			<td>&nbsp;</td>
			<td></td>
			<td></td>
			<td class="boldie"></td>
			<td></td>
			<td></td>
			<td class="boldie"></td>
			<td></td>
			<td></td>
		</tr>
	</cfloop>
	<tr>
		<td colspan="8" align="right">Amount Claimed</td>
		<td class="boldie">&pound;</td>
	</tr>
</table>
<div class="instructions">
	<ol>
		<li>Select papers required for Shop Save (these are included in the Round Stock figure).</li>
		<li>Count the papers left for shop sale and enter under Shop Stock (B).</li>
		<li>Enter the quantities sent out to hotels from the telephone sheet (C).</li>
		<li>Enter the quantities of spoilt papers (D).</li>
		<li>Enter the quantities received from the Smiths delivery note (E).</li>
		<li>Add A+B+C+D then subtract column E and enter the result in the Difference column.</li>
		<li>Negative differences indicate a shortage to be claimed from Smiths.</li>
		<li>Positive differences indicate an excess to be ignored.</li>
		<li>Enter the quantities claimed from Smiths.</li>
	</ol>
	
	<p class="msg">Missing newspaper claims must be reported to Smiths by 9:00am.<br />
	Please call Smiths on <strong>0845 125 2750</strong> quoting our box number <strong>212956</strong></p>
	<table>
		<tr>
			<td width="140">Call Reference : </td>
			<td width="120" class="ref"></td>
			<td width="80" align="right">Time : </td>
			<td width="120" class="ref"></td>
			<td width="80" align="right">Signed : </td>
			<td width="120" class="ref"></td>
		</tr>
	</table>
</div>
</cfoutput>

<!---
Magazines claims by noon same day.
Missing credits by Tuesday noon.
--->
