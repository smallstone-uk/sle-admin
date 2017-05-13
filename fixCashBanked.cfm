<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Cash Banked</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>
<!---
	DEP	1501
	SHOP 201
--->
<cftry>
<cfset newKey = 0>
<cfset identKey = 3>
<cfflush interval="200">
<cfsetting requesttimeout="900">
<cfquery name="QCashDeposits" datasource="#application.site.datasource1#">
	SELECT trnID,trnDate,trnRef,trnDesc,trnPaidIn, niID,niAmount,niNomID
	FROM tblTrans
	INNER JOIN tblNomItems ON trnID=niTranID
	WHERE trnRef IN ('DEP','COR')
	AND trnPaidIn IN (0,3)
	AND niNomID=1501
	AND trnDate BETWEEN '2016-10-01' AND '2017-04-05'
	ORDER BY trnDate ASC
</cfquery>

<body>
<cfset addedCount = 0>
<cfset foundCount = 0>
<cfoutput>
	<p><a href="#cgi.SCRIPT_NAME#">Refresh</a></p>
	<table class="tableList" border="1" width="900">
		<cfloop query="QCashDeposits">
		<tr>
			<td><a href="#cgi.SCRIPT_NAME#?add=#niID#">#niID#</a></td>
			<td>#LSDateFormat(trnDate)#</td>
			<td>#trnRef#</td>
			<td>#trnDesc#</td>
			<td>#trnPaidIn#</td>
			<td>#niAmount#</td>
			<td>#niNomID#</td>
			<td>
				<cfset tranRef = trnRef>
				<cfset paidIn = trnPaidIn>
				<cfset bankRef = Replace(ListLast(trnDesc," "),"_","")>
				<cfset tranDate = LSDateFormat(trnDate,"yyyy-mm-dd")>
				<cfquery name="QRealloc" datasource="#application.site.datasource1#">
					SELECT trnID,trnDate,trnRef,trnDesc
					FROM tblTrans
					WHERE trnRef LIKE '#tranRef# #bankRef#'
					AND trnPaidIn=#identKey#
					LIMIT 1;
				</cfquery>
				<cfif QRealloc.recordcount eq 1>
					#QRealloc.trnID# #QRealloc.trnRef#
					<cfset foundCount++>
				</cfif>
					<cfif StructKeyExists(url,"add") AND QCashDeposits.niID eq url.add>
						create tran for #url.add#<br />
						<cfquery name="QItem" datasource="#application.site.datasource1#">
							SELECT trnID,trnDate,trnRef,trnDesc,trnPaidIn, niID,niAmount,niNomID
							FROM tblTrans
							INNER JOIN tblNomItems ON trnID=niTranID
							WHERE niID = #url.add#
							LIMIT 1;
						</cfquery>
						<cfset value = QItem.niAmount>value = #value#<br />	<!--- negative --->
						Insert tran
						<cfquery name="QInserTran" datasource="#application.site.datasource1#" result="QRes">
							INSERT INTO tblTrans
								(trnDate,trnRef,trnDesc,trnPaidIn) 
							VALUES (#QItem.trnDate#,'#tranRef# #bankRef#','Deposit reallocation',#identKey#)
						</cfquery>
						<cfset newKey=QRes.generatedkey>newKey = #newKey#<br />
						<cfquery name="QInserItems" datasource="#application.site.datasource1#">
							INSERT INTO tblNomItems
								(niTranID,niNomID,niAmount) 
							VALUES 
								(#newKey#,1501,#-value#),
								(#newKey#,201,#value#)			
						</cfquery>
						<cfif QCashDeposits.trnPaidIn neq identKey>
							Update deposit tran #QCashDeposits.trnID#
							<cfquery name="QSetPaidIn" datasource="#application.site.datasource1#">
								UPDATE tblTrans
								SET trnPaidIn=#identKey#
								WHERE trnID = #QCashDeposits.trnID#
							</cfquery>
						</cfif>
						<cfset addedCount++>
					</cfif>
			</td>
		</tr>
		</cfloop>
	</table>
	#addedCount# added.<br />
	#foundCount# found.
</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
</body>
</html>
