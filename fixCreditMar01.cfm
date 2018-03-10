<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Credit 01-03-18</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<body>
<cfparam name="target" default="">

<cfif len(target) is 0 OR NOT IsDate(target)>
	Please choose a target date e.g. ?target=2018-01-01<br />
	<cfexit>
</cfif>
<cftry>
	<cfset doIt=false>
	<cfquery name="QDels" datasource="#application.site.datasource1#" result="QDelResult">
		SELECT pubTitle, cltRef,cltName,cltCompanyName, tbldelitems.*
		FROM `tbldelitems` 
		INNER JOIN tblPublication ON pubID=diPubID
		INNER JOIN tblClients ON cltID=diClientID
		WHERE `diType` = 'debit' 
		AND `diDate` = '#target#'
		AND pubGroup='news'
		AND pubType='morning'
		ORDER BY diClientID,diPubID
		LIMIT 10
	</cfquery>
	<cfoutput>
		<table class="tableList" width="800">
		<cfset flds = "">
		<cfset qline = 0>
		<cfloop list="#QDels.columnList#" index="name">
			<cfif Left(name,2) eq "di" AND name neq "diID">
				<cfset flds = "#flds#,#name#">
			</cfif>
		</cfloop>
		<cfloop query="QDels">
			<cfset qline++>
			<cfset rec = {}>
			<cfset sqlCols = "">
			<cfset sqlValues = "">
			<cfloop list="#flds#" index="name">
				<cfset "rec.#name#" = QDels[name][qline]>
			</cfloop>
			<cfset rec.diPrice = -rec.diPrice>
			<cfset rec.diPriceTrade = -rec.diPriceTrade>
			<cfset rec.diType = 'credit'>
			<cfset rec.diReason = 'shop closed'>
			<cfset delim = "">
			<cfloop collection="#rec#" item="key">
				<cfset value = StructFind(rec,key)>
				<cfif IsDate(value)>
					<cfset value = "'#value#'">
				<cfelseif NOT IsNumeric(value)>
					<cfset value = "'#value#'">
				</cfif>
				<cfset sqlCols = "#sqlCols##delim##key#">
				<cfset sqlValues = "#sqlValues##delim##value#">
				<cfset delim = ",">
			</cfloop>
			<tr>
				<td>#currentrow#</td>
				<td>#diID#</td>
				<td>#cltRef#</td>
				<td>#cltName#</td>
				<td>#cltCompanyName#</td>
				<td>#pubTitle#</td>
				<td>#diIssue#</td>
				<td>#diQty#</td>
				<td>#diPrice#</td>
				<td>#diCharge#</td>
				<td>#diVoucher#</td>
				<td>#diInvoiceID#</td>
				<td>
					<cfset sql = "INSERT INTO tbldelitems (">
					<cfset sql = "#sql##sqlCols#">
					<cfset sql = "#sql#) VALUES (#sqlValues#)">
					#sql#
					<cfif doIt>
						<cfquery name="QInsert" datasource="#application.site.datasource1#" result="QDelResult">
							#PreserveSingleQuotes(sql)#
						</cfquery>
						Done.
					</cfif>
				</td>
				<td><cfdump var="#rec#" label="" expand="false"></td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</body>
</html>