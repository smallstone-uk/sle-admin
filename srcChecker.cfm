<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Source Checker</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
<style type="text/css">
	table {border-collapse:collapse}
	td {border:solid 1px #ccc; padding:2px;}
	.header {background-color:#CCCCCC; border:solid 1px #ccc; padding:2px;}
</style>
</head>

<cfsetting showdebugoutput="no" requesttimeout="900">
<cfflush interval="500">
<cfoutput>
<body>
	<cfset result={}>
	<cfset result.badRef=0>
	<cfset result.badAmt=0>
	<cfset result.badDate=0>
	<cfset result.dupeRecs=0>
	<cfset result.noRecs=0>
	<cfset result.goodRecs=0>
	<cfdirectory action="list" directory="#application.site.fileDir#\csv" name="QDir" filter="*.xls">
	<cfloop query="QDir">
		<cfset theFile="#application.site.fileDir#CSV\#name#">
		<strong><p>#name#</p></strong><!---sheetname="newsinv" --->
		<cfspreadsheet action="read" src="#theFile#" query="spreadsheetData" excludeHeaderRow="false">
		<cfset errors=0>
		<cfset goods=0>
		<cfset recs=[]>
		<!---<table>--->
		<cfloop query="spreadsheetData">
			<cfset r={}>
			<!---<tr>--->
			<cfloop list="#spreadsheetData.columnlist#" index="fld">
				<cfif fld eq 'COL_9' AND IsDate(spreadsheetData[fld][currentrow])>
					<cfset value=DateFormat(spreadsheetData[fld][currentrow],"dd-mmm-yyyy")>
				<cfelseif fld eq 'COL_10'>
					<cfset value=val(ReReplace(spreadsheetData[fld][currentrow],"[^\d.]",""))>
					<cfset value=val(ReReplace(value,",",""))>
				<cfelse>
					<cfset value=spreadsheetData[fld][currentrow]>				
				</cfif>
				<cfset StructInsert(r,fld,value)>
				<!---<td>#value#</td>--->
			</cfloop>
			<!---<tr>--->
			<cfquery name="QTran" datasource="#application.site.datasource1#" result="QResult">
				SELECT trnID,trnRef,trnClientRef,trnDate,trnAmnt1
				FROM tblTrans
				WHERE trnRef='#r.col_8#'
				AND trnType='inv'
				AND trnLedger='sales'
				AND trnClientRef>0
			</cfquery>
			<cfset r.tranCount=QTran.recordcount>
			<cfset r.msg="">
			<cfset r.diff=0>
			<cfset r.colour="">
			<cfif r.tranCount eq 0>
				<cfset r.msg="#r.msg#<li>no record found</li>">
				<cfset result.noRecs++>
				<cfset r.colour="##CC6600">
			<cfelseif r.tranCount neq 1>
				<cfset r.msg="#r.msg#<li>duplicate records</li>">
					<cfset result.dupeRecs++>
				<cfset r.colour="##ff0000">
			</cfif>
			<cfloop query="QTran">
				<cfset r.trnID=trnID>
				<cfset r.trnRef=trnRef>
				<cfset r.trnClientRef=trnClientRef>
				<cfset r.trnDate=LSDateFormat(trnDate,"dd-mmm-yyyy")>
				<cfset r.trnAmnt1=trnAmnt1>
				
				<cfif r.COL_1 neq r.trnClientRef>
					<cfset r.msg="#r.msg#<li>account incorrect</li>">
					<cfset result.badRef++>
					<cfif len(r.colour) IS 0><cfset r.colour="##99CCCC"></cfif>
					<cfdump var="#QResult#" label="" expand="no">
				</cfif>
				<cfif r.COL_10 neq r.trnAmnt1>
					<cfif r.COL_10 IS 0 OR r.trnAmnt1 IS 0>
						<cfset r.msg="#r.msg#<li>Amount zero</li>">
						<cfset result.badAmt++>
						<cfif len(r.colour) IS 0><cfset r.colour="##339966"></cfif>
					<cfelse>
						<cfset r.diff=r.COL_10-val(r.trnAmnt1)>
						<cfif r.diff/r.COL_10 gt 0.1>
							<cfset r.msg="#r.msg#<li>wrong amount</li>">
							<cfset result.badAmt++>
							<cfif len(r.colour) IS 0><cfset r.colour="##CCCCFF"></cfif>
						</cfif>
					</cfif>
				</cfif>
				<cfif r.COL_9 neq r.trnDate>
					<cfset r.days=abs(DateDiff("d",r.COL_9,r.trnDate))>
					<cfif r.days gt 1>
						<cfset r.msg="#r.msg#<li>date mismatch #r.days#</li>">
						<cfset result.badDate++>
						<cfif len(r.colour) IS 0><cfset r.colour="##FFFF99"></cfif>
					</cfif>
				</cfif>
				<cfif len(r.msg)>
					<cfset errors++>
				<cfelse>
					<cfset goods++>
					<cfset result.goodRecs++>
				</cfif>
				<cfset ArrayAppend(recs,r)>
			</cfloop>
		</cfloop>
		<!---</table>--->
		<!---<cfdump var="#recs#" label="recs" expand="false">--->
		<table width="600">
			<tr>
				<td colspan="5" class="header">Transaction</td>
				<td colspan="4" class="header">Spreadsheet</td>
			</tr>
			<tr>
				<td>Inv No</td>
				<td>Client</td>
				<td>Date</td>
				<td>Amount</td>
				<td>----</td>
				<td>Client</td>
				<td>Date</td>
				<td>Amount</td>
				<td>Msg</td>
			</tr>
			<cfloop array="#recs#" index="item">
				<cfif len(item.msg)>
					<tr style="background-color:#item.colour#">
						<td>#item.trnRef#</td>
						<td><a href="clientDetails.cfm?row=0&ref=#item.trnClientRef###trans" target="_blank">#item.trnClientRef#</a></td>
						<td>#LSDateFormat(item.trnDate,"dd-mmm-yyyy")#</td>
						<td>#item.trnAmnt1#</td>
						<td>&nbsp;</td>
						<td><a href="clientDetails.cfm?row=0&ref=#item.COL_1###trans" target="_blank">#item.COL_1#</a></td>
						<td>#LSDateFormat(item.COL_9,"dd-mmm-yyyy")#</td>
						<td>#item.COL_10#</td>
						<td><ul>#item.msg#</ul></td>
					</tr>
				</cfif>
			</cfloop>
		</table>
		<p>Errors=#errors#. Good Records=#goods#</p>
	</cfloop>
</body>
</cfoutput>
<cfdump var="#result#" label="result" expand="no">
</html>
