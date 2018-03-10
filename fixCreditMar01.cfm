<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Credit Delivery</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<body>
<cfparam name="srchDate" default="2018-01-09">
<cfparam name="srchLimit" default="10">
<cfparam name="srchFixData" default="false">
<cfoutput>
	<form method="post">
		<table>
			<tr>
				<td><b>Delivery Date</b></td>
				<td>
					<input type="text" name="srchDate" value="#srchDate#" />
				</td>
			</tr>
			<tr>
				<td><b>Limit</b></td>
				<td>
					<input type="text" name="srchLimit" value="#srchLimit#" />
				</td>
			</tr>
			<tr>
				<td><b>Update Database</b></td>
				<td><input type="checkbox" name="srchFixData" value="1" <cfif srchFixData>checked="checked"</cfif> /></td>
			</tr>
			<tr>
				<td colspan="2"><input type="submit" name="btnSearch" value="Search" /></td>
			</tr>
		</table>
	</form>
</cfoutput>
<cfif StructKeyExists(form,"btnSearch") AND len(srchDate) gt 0 AND IsDate(srchDate)>
	<cftry>
		<cfset doIt=false>
		<cfquery name="QDels" datasource="#application.site.datasource1#" result="QDelResult">
			SELECT pubTitle, cltRef,cltName,cltCompanyName, tbldelitems.*
			FROM `tbldelitems` 
			INNER JOIN tblPublication ON pubID=diPubID
			INNER JOIN tblClients ON cltID=diClientID
			WHERE `diType` = 'debit' 
			AND `diDate` = '#srchDate#'
			AND pubGroup='news'
			AND pubType='morning'
			ORDER BY diClientID,diPubID
			<cfif val(srchLimit) gt 0>LIMIT #srchLimit#</cfif>
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
						<cfif srchFixData>
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
</cfif>

</body>
</html>