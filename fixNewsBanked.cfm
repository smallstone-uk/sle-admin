<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix News Paid In</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
<style>
	.red {color:#FF0000;}
	.blue {color:#00F;}
	.header {background-color:#CCCCCC;}
	.tranheader {background-color:#eee;}
</style>
</head>

<body>
<cfset process = 0>
<cfset identKey = 4>	<!--- news payments --->
<cfparam name="doUpdate" default="false">
<cfsetting requesttimeout="300">
<cfflush interval="200">
<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT SUM(trnAmnt1) AS tranTotal, Count(*) AS num, trnPaidIn
	FROM tblTrans
	WHERE trnPaidIn > 5
	AND trnDate > '2013-02-01'
	AND trnDate BETWEEN '2013-01-01' AND '2017-04-15'
	GROUP BY trnPaidIn
	<!---LIMIT 80--->
</cfquery>
<cfset errorCount = 0>
<cfoutput>
	<p><a href = "#cgi.SCRIPT_NAME#?doUpdate=true">Fix Data</a> &nbsp; <a href = "#cgi.SCRIPT_NAME#">Preview</a></p>
	<table class="tableList" border="1">
		<tr class="header">
			<th colspan="5">Payments Banked</th>
		</tr>
		<tr>
			<th align="right">##</th>
			<th align="right">Paid In</th>
			<th></th>
			<th align="right">Count</th>
			<th align="right">Total</th>
		</tr>
		<cfloop query="QTrans">
			<cfif trnPaidIn gt 120000>
				<cfset process = 2>
				<cfset datePaidIn = CreateDate(mid(trnPaidIn,1,2),mid(trnPaidIn,3,2),mid(trnPaidIn,5,2))>
				<cfset dateStr = LSDateFormat(datePaidIn,'ddd dd-mmm-yyyy')>
			<cfelse>
				<cfset process = 0>
				<cfset dateStr = "invalid">
			</cfif>
			<tr class="header">
				<td align="right">#currentRow#</td>
				<td align="right">#dateStr#</td>
				<td align="center">#trnPaidIn#</td>
				<td align="right">#num# items </td>
				<td align="right">#tranTotal#</td>
			</tr>
			<cfif process eq 2>
				<cfset paidIn = trnPaidIn>
				<cfset bankAmnt = abs(tranTotal)>
				<cfquery name="QBankTran" datasource="#application.site.datasource1#">
					SELECT trnID,trnDate,trnRef,trnDesc,niAmount,trnPaidIn
					FROM tblTrans
					INNER JOIN tblNomItems ON trnID=niTranID
					WHERE trnRef LIKE 'DEP%'
					AND trnDate = '#LSDateFormat(datePaidIn,"yyyy-mm-dd")#'
					AND niNomID = 41
					AND niAmount = #bankAmnt#
					LIMIT 1;
				</cfquery>
				<cfif QBankTran.recordcount IS 1>
					<cfset bankRef = Replace(ListLast(QBankTran.trnDesc," "),"_","")>
					<cfif QBankTran.trnPaidIn neq identKey>
						<cfquery name="QSetPaidIn" datasource="#application.site.datasource1#">
							UPDATE tblTrans
							SET trnPaidIn=#identKey#
							WHERE trnID = #QBankTran.trnID#
						</cfquery>
					</cfif>
					<tr class="tranheader">
						<td>#QBankTran.trnID#</td>
						<td align="right">#LSDateFormat(QBankTran.trnDate,'ddd dd-mmm-yyyy')#</td>
						<td align="right">#QBankTran.trnRef# #bankRef#</td>
						<td align="right">#QBankTran.trnDesc#</td>
						<td align="right">#QBankTran.niAmount#</td>
					</tr>
					
					<tr>
						<td colspan="5">
							<cfquery name="QExistingItems" datasource="#application.site.datasource1#">
								SELECT niID,niAmount, nomID,nomCode,nomTitle, trnID
								FROM tblTrans
								INNER JOIN tblNomItems ON niTranID = trnID
								INNER JOIN tblNominal ON niNomID = nomID
								WHERE niTranID = #QBankTran.trnID#
								ORDER BY nomCode
							</cfquery>
							<cfif QExistingItems.recordcount GT 0>
								<p>Existing Items</p>
								<table width="100%">
									<cfset existingTotal = 0>
									<cfloop query="QExistingItems">
										<cfset existingTotal += niAmount>
										<tr>
											<td align="right">#niID#</td>
											<td align="right">#trnID#</td>
											<td>#nomCode#</td>
											<td>#nomTitle#</td>
											<td align="right">#niAmount#</td>
										</tr>
									</cfloop>
									<tr>
										<td colspan="4"></td>
										<td align="right">#existingTotal#</td>
									</tr>
								</table>
							</cfif>
						</td>
					</tr>
					<cfset postTranID = 0>
					<cfset posties = {}>
					<cfquery name="QPostTran" datasource="#application.site.datasource1#">
						SELECT trnID,trnDate,trnRef,trnDesc,trnAmnt1,trnPaidIn
						FROM tblTrans
						WHERE trnRef LIKE 'DEP #bankRef#'
						LIMIT 1;
					</cfquery>
					<cfif QPostTran.recordcount IS 1>
						<cfset postTranID = QPostTran.trnID>
						<tr>
							<td>#QPostTran.trnID#</td>
							<td align="right">#LSDateFormat(QPostTran.trnDate,'ddd dd-mmm-yyyy')#</td>
							<td align="right">#QPostTran.trnRef#</td>
							<td align="right">#QPostTran.trnDesc#</td>
							<td align="right">#QPostTran.trnAmnt1#</td>
						</tr>
					<cfelse>
						<tr>
							<td colspan="5" bgcolor="##FF0099">
								<cfset errorCount++>
								Deposit transaction missing.
							</td>
						</tr>
						<cfif StructKeyExists(url,"doUpdate")>
							<cfquery name="QInsertTran" datasource="#application.site.datasource1#" result="QIns">
								INSERT INTO tblTrans
									(trnRef,trnDate,trnDesc,trnPaidIn)
								VALUES
									('DEP #bankRef#',#datePaidIn#,'Deposit reallocation',#identKey#)
							</cfquery>
							<cfset postTranID = QIns.generatedkey>
						</cfif>
					</cfif>
					
					<cfif postTranID neq 0>
						<tr>
							<td colspan="5">
									<cfquery name="QPostItems" datasource="#application.site.datasource1#">
										SELECT trnID, nomID,nomCode,nomTitle, niAmount
										FROM tblTrans
										INNER JOIN tblNomItems ON niTranID = trnID
										INNER JOIN tblNominal ON niNomID = nomID
										WHERE trnID = #postTranID#
									</cfquery>
									<cfif QPostItems.recordcount GT 0>
										<span>Deposit Items</span>
										<table width="100%">
											<cfset postTotal = 0>
											<cfloop query="QPostItems">
												<cfif NOT StructKeyExists(posties,nomCode)>
													<cfset StructInsert(posties,nomCode,[niAmount])>
												<cfelse>
													<cfset postArray = StructFind(posties,nomCode)>
													<cfset ArrayAppend(postArray,niAmount)>
													<cfset StructUpdate(posties,nomCode,postArray)>
												</cfif>
												<cfset postTotal += niAmount>
												<tr>
													<td>#nomCode#</td>
													<td>#nomTitle#</td>
													<td align="right">#niAmount#</td>
												</tr>
											</cfloop>
										</table>
										<!---<cfdump var="#posties#" label="posties" expand="no">--->
									<cfelse>
										<cfset errorCount++>
										No items found for post tran.
									</cfif>
							</td>
						</tr>
					</cfif>
					
					<tr>
						<td colspan="5">
							<cfquery name="QExpectedItems" datasource="#application.site.datasource1#">
								SELECT trnMethod,SUM(trnAmnt1) AS groupTotal,Count(*) AS num, nomID,nomCode,nomTitle
								FROM tblTrans
								INNER JOIN tblNomItems ON niTranID = trnID
								INNER JOIN tblNominal ON niNomID = nomID
								WHERE trnPaidIn = #paidIn#
								AND nomID NOT IN (1,101)
								GROUP BY trnMethod
							</cfquery>
							<cfif QExpectedItems.recordcount GT 0>
								<cfset addBalance = false>
								<p>Expected Items</p>
								<table width="100%">
									<cfset expectedTotal = 0>
									<cfloop query="QExpectedItems">
										<cfset found = false>
										<cfif StructKeyExists(posties,nomCode)>
											<cfset postArray = StructFind(posties,nomCode)>
											<cfloop array="#postArray#" index="value">
												<cfif value eq groupTotal>
													<cfset found = true>
													<cfbreak>
												</cfif>
											</cfloop>
										</cfif>
										<cfset expectedTotal += groupTotal>
										<tr>
											<td>#nomCode#</td>
											<td>#nomTitle#</td>
											<td>#trnMethod#</td>
											<td align="right">#num#</td>
											<td align="right">#groupTotal#</td>
											<td>#found#
												<cfif StructKeyExists(url,"doUpdate") AND NOT found AND groupTotal neq 0>
													Insert Tran DEP #bankRef# #dateStr#<br />
													Add Item: #nomCode# #groupTotal#<br />
													<cfset addBalance = true>
													<cfquery name="QInsertItem" datasource="#application.site.datasource1#">
														INSERT INTO tblNomItems
															(niNomID,niTranID,niAmount)
														VALUES
															(#nomID#,#postTranID#,#groupTotal#)
													</cfquery>
												</cfif>
											</td>
										</tr>
									</cfloop>
									<cfif addBalance>
										<cfquery name="QInsertItem" datasource="#application.site.datasource1#">
											INSERT INTO tblNomItems
												(niNomID,niTranID,niAmount)
											VALUES
												(1501,#postTranID#,#bankAmnt#)
										</cfquery>
									</cfif>
								</table>
							</cfif>
						</td>
					</tr>
				<cfelse>
					<tr>
						<td colspan="5">
							<cfset errorCount++>
							<span class="red">Corresponding bank deposit not found for #trnPaidIn# of &pound;#bankAmnt#</span>
						</td>
					</tr>
				</cfif>
			</cfif>
		</cfloop>
		<tr>
			<td colspan="5">Error Count #errorCount#</td>
		</tr>
	</table>
</cfoutput>

</body>
</html>