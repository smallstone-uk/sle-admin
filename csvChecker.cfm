<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>CSV Checker</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
<style type="text/css">
	table {border-collapse:collapse}
	td {border:solid 1px #ccc; padding:2px;}
</style>
</head>

<cffunction name="stripQuote" access="public" returntype="string">
	<cfargument name="str" type="string" required="yes">		
	<cfreturn Replace(str,'"','',"all")>
</cffunction>
	
<cfsetting showdebugoutput="no" requesttimeout="900">
<cfflush interval="500">
<cfoutput>
<body>
	<cfdirectory action="list" directory="#application.site.fileDir#\csv" name="QDir" filter="*.csv">
	<cfset errors=0>
	<cfset goods=0>
	<cfset report=[]>
	<cfloop query="QDir">
		<cfif type eq "file">
			<p><a href="source/csv/#name#" target="_blank">#name#</a></p>
			<cffile action="read" file="#application.site.fileDir#\csv\#name#" variable="content">
			<cfset lineCount=0>
			<cfloop list="#content#" delimiters="#chr(13)##chr(10)#" index="line">
				<cfset lineCount++>
				<cfset err={}>
				<cfif linecount gt 1>
					<cfset r={}>
					<cfset data=ListToArray(line,",")>
					<cfset arrLen=ArrayLen(data)>
					<cfset r.accRef=stripQuote(data[1])>
					<cfset r.invNo=stripQuote(data[arrLen-2])>
					<cfset r.invDate=LSDateFormat(stripQuote(data[arrLen-1]),"dd/mm/yyyy")>
					<cfset r.invAmnt=stripQuote(data[arrLen])>
					<cfquery name="QTran" datasource="#application.site.datasource1#">
						SELECT trnID,trnAmnt1,trnClientRef,trnDate
						FROM tblTrans
						WHERE trnRef='#trim(r.invNo)#'
						AND trnType='inv'
						AND trnLedger='sales'
					</cfquery>
					<cfset rpt=StructCopy(r)>
					<cfset rpt.count=QTran.recordcount>
					<cfset rpt.msg="">
					<cfset rpt.diff=0>
					<cfif rpt.count eq 0>
						<cfset rpt.msg="#rpt.msg#<li>no record found</li>">
						<cfset rpt.colour="##ff0000">
					<cfelseif rpt.count neq 1>
						<cfset rpt.msg="#rpt.msg#<li>duplicate records</li>">
							<cfset rpt.colour="##ff0000">
					</cfif>
					<cfloop query="QTran">
						<cfif r.accRef neq QTran.trnClientRef>
							<cfset rpt.msg="#rpt.msg#<li>account incorrect</li>">
							<cfset rpt.colour="##ff0000">
						</cfif>
						<cfif r.invAmnt neq QTran.trnAmnt1>
							<cfif r.invAmnt IS 0 OR QTran.trnAmnt1 IS 0>
								<cfset rpt.msg="#rpt.msg#<li>Amount zero</li>">
								<cfset rpt.colour="##ff0000">							
							<cfelse>
								<cfset rpt.diff=r.invAmnt-val(QTran.trnAmnt1)>
								<cfif rpt.diff/r.invAmnt gt 0.1>
									<cfset rpt.msg="#rpt.msg#<li>wrong amount</li>">
									<cfset rpt.colour="##ff00ff">
								</cfif>
							</cfif>
						</cfif>
						<cfif r.invDate neq LSDateFormat(QTran.trnDate,"dd/mm/yyyy")>
							<cfset rpt.msg="#rpt.msg#<li>date mismatch</li>">
							<cfset rpt.colour="##ff0000">
						</cfif>
						<cfset rpt.ID=QTran.trnID>
						<cfset rpt.invno=r.invNo>
						<cfset rpt.count=QTran.recordcount>
						<cfset rpt.ref=QTran.trnClientRef>
						<cfset rpt.date=QTran.trnDate>
						<cfset rpt.amnt=QTran.trnAmnt1>
						<cfif len(rpt.msg)>
							<cfset errors++>
						<cfelse>
							<cfset goods++>
							<cfset rpt.colour="##00ff00">
						</cfif>
						<cfset ArrayAppend(report,rpt)>						
					</cfloop>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>
	<table width="600">
		<tr>
			<td>C-Ref</td>
			<td>C-InvNo</td>
			<td>C-Date</td>
			<td>C-Amnt</td>
			<td>----</td>
			<td>ID</td>
			<td>D-Ref</td>
			<td>D-Date</td>
			<td>D-Amnt</td>
			<td>Diff</td>
			<td>Count</td>
			<td>Msg</td>
		</tr>
		<cfloop array="#report#" index="item">
			<cfif len(item.msg)>
				<tr style="background-color:#item.colour#">
					<td>#item.accRef#</td>
					<td>#item.invno#</td>
					<td>#LSDateFormat(item.invdate,"dd-mmm-yyyy")#</td>
					<td>#item.invAmnt#</td>
					<td>&nbsp;</td>
					<td>#item.ID#</td>
					<td>#item.ref#</td>
					<td>#LSDateFormat(item.date,"dd-mmm-yyyy")#</td>
					<td>#item.amnt#</td>
					<td>#item.diff#</td>
					<td>#item.count#</td>
					<td><ul>#item.msg#</ul></td>
				</tr>
			</cfif>
		</cfloop>
	</table>
	<p>Errors=#errors#. Good Records=#goods#</p>
</body>
</cfoutput>
</html>
