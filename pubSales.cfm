<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Publication Sales</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>
<cftry>

<cfset end = DateAdd("d",-1,Now())>
<cfset start = DateAdd("d",-21,end)>
<cfparam name="startDate" default="#DateFormat(start,'yyyy-mm-dd')#">
<cfparam name="endDate" default="#DateFormat(end,'yyyy-mm-dd')#">

<cfset pubStruct = {}>

<cfquery name="QPubReceived" datasource="#application.site.datasource1#">
	SELECT pubID,pubTitle, psDate,psIssue,psType,psSubType, IF(psType='credited',psQty*-1,psQty) AS QTY
	FROM `tblpubstock`
	INNER JOIN tblPublication ON pubID=psPubID
	WHERE psDate BETWEEN '#startDate#' AND '#endDate#'
	AND `psType` = 'received' 
	AND pubGroup='news'
	<!---AND pubID=10041
	AND psIssue='28aug'--->
	AND psSubType='normal'
	ORDER BY pubTitle,psDate, psType
</cfquery>
<cfloop query="QPubReceived">
	<cfset issue = psIssue>
	<cfset key = "#pubID#-#issue#">
	<cfif NOT StructKeyExists(pubStruct,key)>
		<cfset StructInsert(pubStruct,key, {
			pubID=pubID,pubTitle=pubTitle, psIssue=psIssue, msg='', stock=[{psType=psType, QTY=QTY}]
		})>
	</cfif>
	<cfset pub = StructFind(pubStruct,key)>
	<cfquery name="QReturns" datasource="#application.site.datasource1#">
		SELECT pubID,pubTitle, psID,psDate,psIssue,psType, psQty
		FROM `tblpubstock`
		INNER JOIN tblPublication ON pubID=psPubID
		WHERE psDate > '#startDate#'
		AND `psType` = 'returned' 
		AND pubGroup='news'
		AND pubID=#pubID#
		AND psIssue='#issue#'
		ORDER BY pubTitle,psDate, psType
	</cfquery>
	<cfif QReturns.recordcount GT 0>
		<cfquery name="QCrd" datasource="#application.site.datasource1#">
			SELECT pubID,pubTitle, psIssue,psType, IF(psType='credited',psQty*-1,psQty) AS QTY
			FROM `tblpubstock`
			INNER JOIN tblPublication ON pubID=psPubID
			WHERE psDate >= '#startDate#'
			AND `psType` = 'credited' 
			AND pubGroup='news'
			AND pubID=#pubID#
			AND psIssue='#issue#'
			ORDER BY pubTitle,psDate, psType
		</cfquery>
		<cfif QCrd.recordcount gt 0>
			<cfset ArrayAppend(pub.stock, {
				psType=QCrd.psType, QTY=QCrd.QTY
			})>
		<cfelse>
			<cfset pub.msg = 'no credits found'>
		</cfif>
	<cfelse>
		<cfset pub.msg = 'no returns found'>
	</cfif>
</cfloop>
<!---<cfdump var="#pubStruct#" label="pubStruct" expand="false">--->
<body>
	<h1>Newspaper Sales including Shop & Deliveries</h1>
	<cfoutput>
		<h2>From #DateFormat(start,"ddd dd-mmm-yy")# To #DateFormat(end,"ddd dd-mmm-yy")#</h2>
		<table width="600" border="1" class="tableList">
		<cfset rec = {}>
		<cfset thisPub = 0>
		<cfset keys = ListSort(StructKeyList(pubStruct,","),"text")>
		<cfloop list="#keys#" index="key">
			<cfset pub = StructFind(pubStruct,key)>
			<cfif thisPub neq pub.pubID>
				<cfif thisPub gt 0>
				<tr>
					<td colspan="5">
						<table width="600" border="1" class="tableList">
							<tr>
								<th>SALES</th>
								<th>Total: #rec.qtot#</th>
								<th>Avg: #DecimalFormat(rec.qavg)#</th>
								<th>Min: #rec.qmin#</th>
								<th align="right"><strong>Max: #rec.qmax#</strong></th>
							</tr>
						</table>
					</td>
				</tr>
				</cfif>
				<cfset rec = {qmin=-1, qmax=0, qtot=0, qavg=0}>
				<cfset issueCount = 0>
				<cfset thisPub = pub.pubID>
			</cfif>
			<cfset netTotal = 0>
			<cfset issueCount++>
			<cfloop array="#pub.stock#" index="i">
				<cfset netTotal += i.QTY>
			</cfloop>
			
			<cfif len(pub.msg) eq 0>
				<cfif rec.qmin eq -1>
					<cfset rec.qmin = netTotal>
				<cfelseif netTotal lt rec.qmin>
					<cfset rec.qmin = netTotal>
				<cfelseif netTotal gt rec.qmax>
					<cfset rec.qmax = netTotal>
				</cfif>
				<cfset rec.qtot += netTotal>
				<cfset rec.qavg = rec.qtot / issueCount>
			</cfif>
			<tr>
				<td>#key#</td>
				<td>#pub.pubTitle#</td>
				<td>#pub.psIssue#</td>
				<td>#netTotal#</td>
				<td>#pub.msg#</td>
			</tr>
		</cfloop>
			<tr>
				<td colspan="5">
					<table width="600" border="1" class="tableList">
						<tr>
							<th>SALES</th>
							<th>Total: #rec.qtot#</th>
							<th>Avg: #DecimalFormat(rec.qavg)#</th>
							<th>Min: #rec.qmin#</th>
							<th align="right"><strong>Max: #rec.qmax#</strong></th>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
</body>
</html>