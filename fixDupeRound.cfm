<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Duplicated Round</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
<style>
	.red {color:#FF0000;}
	.blue {color:#00F;}
	.header {background-color:#CCCCCC;}
	.tranheader {background-color:#eee;}
	input[type="submit"]{float: left; clear:both;}
</style>
</head>

<body>
<cfset process = 0>
<cfsetting requesttimeout="300">
<cfflush interval="200">
<cfparam name="srchDate" default="#Now()#">
<cfquery name="QDelItems" datasource="#application.site.datasource1#">
	SELECT cltName, pubTitle, tbldelitems.*
	FROM tbldelitems
	INNER JOIN tblClients ON diClientID = cltID
	INNER JOIN tblPublication ON diPubID = pubID
	WHERE diDate = '#DateFormat(srchDate,"yyyy-mm-dd")#'
	ORDER BY diClientID, diOrderID, diPubID, diType
</cfquery>
<cfset errorCount = 0>
<cfset runNow = StructKeyExists(form,"btnConfirmRequest")>
<cfoutput>
	<p><a href="#cgi.SCRIPT_NAME#">Preview</a></p>
	<p>
		This routine will find duplicated news items for #DateFormat(srchDate,"ddd dd-mmm-yyyy")# and create a credit for each customer to reverse one of the duplicates.<br />
		These credits will be date-stamped in the current invoicing period so they appear on the customers next invoice.<br />
		To skip specific records, set diTest to 1, e.g. for records that have already been credited.<br />
		To select the date in question add ?srchDate=yyyy-mm-dd to the URL<br />	
	</p>
	<p>WARNING RUN ONCE:- Running this routine more than once will create multiple credits for each customer.</p>
	<div>
		<cfif StructKeyExists(form,"btnConfirmRequest")>
			<h1>Running...</h1>
		<cfelseif StructKeyExists(form,"btnRunRequest")>
			<h1>Are you sure you want to run this?</h1>
			<form action="#cgi.SCRIPT_NAME#" method="POST" enctype="multipart/form-data">
				<input type="hidden" name="srchDate" value="#srchDate#" />
				<input type="submit" name="btnConfirmRequest" value="Run Now" />
			</form>
		<cfelse>
			<form action="#cgi.SCRIPT_NAME#" method="POST" enctype="multipart/form-data">
				<input type="hidden" name="srchDate" value="#srchDate#" />
				<input type="submit" name="btnRunRequest" value="Run Process" />
			</form>
		</cfif>
	</div>
	<div style="clear:both; width:100%; margin-bottom:20px;"></div>
	<table class="tableList" border="1">
		<tr class="header">
			<th colspan="8">Duplicated Round Items</th>
		</tr>
		<tr>
			<th align="right">ID</th>
			<th align="right">Date</th>
			<th align="right">Order</th>
			<th>Key</th>
			<th>Customer</th>
			<th>Publication</th>
			<th>Type</th>
			<th></th>
		</tr>
		<cfset delCount = 0>
		<cfset creditList = []>
		<cfset lastRec = {}>
		<cfloop query="QDelItems">
			<cfset rowStyle = "blue">
			<cfif !StructIsEmpty(lastRec)>
				<cfif diTest eq 0 AND diClientID eq lastRec.clientID AND diOrderID eq lastRec.orderID AND diPubID eq lastRec.pubID AND diType eq lastRec.type>
					<cfset ArrayAppend(creditList,{"diID" = diID, "cltName" = cltName, "pubTitle" = pubTitle, "diType" = diType})>
					<cfset rowStyle = "red">
					<cfset delCount++>
				</cfif>
			</cfif>
			<tr class="#rowStyle#">
				<td align="right">#diID#</td>
				<td align="right">#DateFormat(diDate,'ddd dd-mmm-yy')#</td>
				<td align="right">#diOrderID#</td>
				<td>#diClientID##diOrderID##diPubID#</td>
				<td>#cltName#</td>
				<td>#pubTitle#</td>
				<td>#diType#</td>
				<td><cfif diTest>Skipped</cfif></td>
			</tr>
			<cfset lastRec = {
				"clientID" = diClientID,
				"orderID" = diOrderID,
				"pubID" = diPubID,
				"type" = diType
			}>
		</cfloop>
		<tr>
			<th colspan="8">#delCount# records marked in red to be reversed.</th>
		</tr>
	</table>

	<table class="tableList" border="1" width="600">
		<tr class="header">
			<th colspan="4"><cfif runNow>Creating Credits<cfelse>Previewing Credits</cfif></th>
		</tr>
		<cfif ArrayIsEmpty(creditList)>
			<tr>
				<td colspan="4">No duplicates found</td>
			</tr>
		</cfif>
		<cfset lineCount = 0>
		<cfloop array="#creditList#" index="item">
			<cfset lineCount++>
			<cfquery name="QSrcRec" datasource="#application.site.datasource1#" result="QSrcRecResult">
				SELECT tbldelitems.*
				FROM tbldelitems
				WHERE diID = #item.diID#
			</cfquery>
			<cfif QSrcRec.recordcount eq 1>
				<cfset rec = {}>
				<cfloop list="#QSrcRecResult.columnlist#" index="key">
					<cfset StructInsert(rec,key,QSrcRec[key])>
				</cfloop>
				<cfset rec.diType = "credit">
				<cfset rec.diPrice = -rec.diPrice>
				<cfset rec.diPriceTrade = -rec.diPriceTrade>
				<cfset rec.diDateStamp = DateFormat(Now(),'yyyy-mm-dd')>
				<cfset rec.diCharge = -rec.diCharge>
				<cfset rec.diReason = "Duplicated 07-Mar">
				<cfset rec.diInvoiceID = 0>
				<cfset rec.diID = 0>
				<cfset sqlStr = "INSERT INTO tbldelitems (">
				<cfloop list="#QSrcRecResult.columnlist#" index="key"><cfset sqlStr = "#sqlStr##key#,"></cfloop>
				<cfset sqlStr = Mid(sqlStr,1,Len(sqlStr)-1)>	<!--- remove last comma --->
				<cfset sqlStr = "#sqlStr#) VALUES (">
				<cfloop list="#QSrcRecResult.columnlist#" index="key">
					<cfset itemData = StructFind(rec,key)>
					<cfif IsNumeric(itemData)>
						<cfset sqlStr = "#sqlStr##itemData#,">
					<cfelseif IsDate(itemData)>
						<cfset sqlStr = "#sqlStr#'#DateFormat(itemData,"yyyy-mm-dd")#',">
					<cfelse>
						<cfset sqlStr = "#sqlStr#'#itemData#',">
					</cfif>
				</cfloop>
				<cfset sqlStr = Mid(sqlStr,1,Len(sqlStr)-1)>	<!--- remove last comma --->
				<cfset sqlStr = "#sqlStr#)">
				<tr><td>#lineCount#</td><td>#item.cltName#</td><td>#item.pubTitle#</td><td>#sqlStr#</td></tr>
				<cfif runNow>
					<cfquery name="QInsertRec" datasource="#application.site.datasource1#">
						#PreserveSingleQuotes(sqlStr)#
					</cfquery>
				</cfif>
			</cfif>
			<!---<cfif lineCount gt 3><cfbreak></cfif>--->
		</cfloop>
	</table>
</cfoutput>

</body>
</html>