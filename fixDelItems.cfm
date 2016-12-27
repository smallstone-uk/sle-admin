<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Fix Del Trade Price</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
	<style>
		.red {color:#FF0000;}
		.blue {color:#00F;}
		.badrow {background-color:#FF66FF}
		.okrow {background-color:#ffffff}
	</style>
</head>
<body>
<cftry>
	<cfsetting showdebugoutput="no" requesttimeout="500">
	<cfflush interval="200">
	<cfset fixme = true>
	<cfset showall = true>
	<cfset counters = {}>
	<cfset counters.start = Now()>
	<cfset counters.good = 0>
	<cfset counters.bad = 0>
	<cfset counters.wrong = 0>
	<cfset counters.fixed = 0>
	<cfquery name="QDels" datasource="#application.site.datasource1#">
		SELECT pubID, pubTitle, diID, diType, diDate, diQty, diPrice, diPriceTrade,
		(
			SELECT ABS(psTradePrice) * -1
			FROM `tblPubStock`
			WHERE psDate >= diDate
			AND psPubID = diPubID
			LIMIT 1
		) AS tradeprice
		FROM tblDelItems
		INNER JOIN tblPublication ON pubID = diPubID
		WHERE diType = 'credit'
		HAVING diPriceTrade <> tradeprice
		ORDER BY diDate
		LIMIT 3000;
	</cfquery>
	<cfdump var="#QDels#" label="QDels" expand="false">
	<cfset counters.recs = QDels.recordcount>
	<cfoutput>
		<table class="tableList" border="1">
			<tr>
				<th>##</th>
				<th>Pub</th>
				<th>Del</th>
				<th>Title</th>
				<th>Type</th>
				<th>Date</th>
				<th>Qty</th>
				<th>Price</th>
				<th>Trade</th>
				<th>trade price</th>
			</tr>
			<cfloop query="QDels">
				<cfif diPriceTrade neq tradeprice>
					<cfset style="red">
					<cfset counters.wrong++>
					<cfif fixme>
						<cfquery name="QFixDel" datasource="#application.site.datasource1#">
							UPDATE tblDelItems
							SET diPriceTrade = #val(tradeprice)#
							WHERE diID = #diID#
						</cfquery>
						<cfset counters.fixed++>
					</cfif>
				<cfelse>
					<cfset counters.good++>
					<cfset style="blue">
				</cfif>
				<cfif diPrice eq 0 OR diPriceTrade eq 0 or tradeprice eq 0>
					<cfset rowstyle = "badrow"><cfset counters.bad++><cfelse><cfset rowstyle = "okrow"></cfif>
				<cfif style neq "blue" OR showAll>
				<tr class="#rowstyle#">
					<td>#currentrow#</td>
					<td>#pubID#</td>
					<td>#diID#</td>
					<td>#pubTitle#</td>
					<td>#diType#</td>
					<td>#LSDateFormat(diDate,'dd-mmm-yyyy')#</td>
					<td>#diQty#</td>
					<td>#diPrice#</td>
					<td><span class="#style#">#diPriceTrade#</span></td>
					<td>#tradeprice#</td>
				</tr>
				</cfif>
			</cfloop>
		</table>
	</cfoutput>
	<cfset counters.stop = Now()>
	<cfdump var="#counters#" label="counters" expand="true">
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</body>
</html>