<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Fix Cheques Banked</title>
</head>

<cfquery name="QChequesBanked" datasource="#application.site.datasource1#">
	SELECT trnPaidIn, sum( trnAmnt1 ) AS total
	FROM `tblTrans`
	WHERE `trnLedger` = 'sales'
	AND `trnType` = 'pay'
	AND `trnMethod` LIKE '%chq%'
	GROUP BY trnPaidIn
</cfquery>
<table>
<cfoutput>
	<cfloop query="QChequesBanked">
		<cfif len(trnPaidIn) EQ 6>
			<cfset bankDate=CreateDate(mid(trnPaidIn,1,2),mid(trnPaidIn,3,2),mid(trnPaidIn,5,2))>
			<cfset bankRef="JNL">
			<cfset bankDesc="Cheques Banked">
			<cfset bankAmnt1=total>
			<cfset bankType="nom">
			<cfset bankLedger="nom">
			<cfset bankAccountID=3>
			<cfset drItem=1501>
			<cfset crItem=1472>
			<cfquery name="QAddTran" datasource="#application.site.datasource1#" result="QAddTran">
				INSERT INTO tblTrans (
					trnLedger,
					trnAccountID,
					trnType,
					trnRef,
					trnDesc,
					trnDate,
					trnAmnt1,
					trnTest
				) VALUES (
					'#bankLedger#',
					#bankAccountID#,
					'#bankType#',
					'#bankRef#',
					'#bankDesc#',
					#bankDate#,
					#bankAmnt1#,
					1
				)
			</cfquery>
			<cfset tranID=QAddTran.generatedkey>
			<cfquery name="QAddItems" datasource="#application.site.datasource1#">
				INSERT INTO tblNomItems
					(niNomID,niTranID,niAmount)
				VALUES
					(#drItem#,#tranID#,#abs(bankAmnt1)#),
					(#crItem#,#tranID#,#bankAmnt1#)
			</cfquery>
			<tr>
				<td>#tranID#</td>
				<td>#LSDateFormat(bankDate,"yyyy-mm-dd")#</td>
				<td>#bankRef#</td>
				<td>#bankDesc#</td>
				<td>#bankAmnt1#</td>
				<td>#bankType#</td>
			</tr>
		</cfif>
	</cfloop>
</cfoutput>
</table>
<body>
</body>
</html>
