<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Card Account</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<cfflush interval="200">
<cfsetting requesttimeout="900">
<cfquery name="QCardPayments" datasource="#application.site.datasource1#">
	SELECT trnID,trnActual,trnDate,trnRef,trnDesc, niAmount,niNomID
	FROM tblTrans
	INNER JOIN tblNomItems ON trnID=niTranID
	WHERE trnRef LIKE 'BGC'
	AND trnDesc LIKE '%CARDNET%'
	AND niNomID=191
	AND trnDate BETWEEN '2013-02-01' AND '2016-01-31'
	ORDER BY trnDate ASC
</cfquery>
<body>
<cfset errCount = 0>
<cfoutput>
	<table class="tableList" border="1" width="600">
	<cfloop query="QCardPayments">
		<cfset tranDate = LSDateFormat(QCardPayments.trnActual,"yyyy-mm-dd")>
		<cfquery name="QSale" datasource="#application.site.datasource1#">
			SELECT trnID,trnActual,trnDate,trnRef,trnDesc
			FROM tblTrans
			WHERE trnAccountID=1
			AND trnDate='#tranDate#'
		</cfquery>
		<cfif QSale.recordcount eq 1>
			<cfquery name="QCardReceived" datasource="#application.site.datasource1#">
				SELECT trnID,trnActual,trnDate,trnRef,trnDesc, niAmount,niNomID
				FROM tblTrans
				INNER JOIN tblNomItems ON trnID=niTranID
				AND niNomID=191
				AND niTranID=#val(QSale.trnID)#
			</cfquery>
		<cfelse>
			<cfset errCount++>
		</cfif>
		<tr>
			<td align="right">#trnID#</td>
			<td align="right">#LSDateFormat(trnActual)#</td>
			<td>#trnRef#</td>
			<td>#trnDesc#</td>
			<td align="right">#niAmount#</td>
			<td>Sale: #QSale.trnID#</td>
			<cfif QSale.recordcount eq 1>
				<td>
					<cfif val(QCardReceived.niAmount) + val(QCardPayments.niAmount) eq 0>
						found
					<cfelse>
						missing 
						<cfquery name="QInsertItem" datasource="#application.site.datasource1#">
							INSERT INTO tblNomItems
								(niAmount,niNomID,niTranID)
							VALUES
								(#val(-QCardPayments.niAmount)#,191,#QSale.trnID#)
						</cfquery>
						fixed
					</cfif>
				</td>
				<td>
					<cfquery name="QBalance" datasource="#application.site.datasource1#">
						SELECT SUM(niAmount) AS total
						FROM tblNomItems
						WHERE niTranID=#val(QSale.trnID)#
					</cfquery>
					<cfif QBalance.total neq 0>
						fix me 
						<cfquery name="QShopItem" datasource="#application.site.datasource1#">
							SELECT niAmount
							FROM tblNomItems
							WHERE niNomID=201
							AND niTranID=#val(QSale.trnID)#
						</cfquery>
						<cfquery name="QShopItemFix" datasource="#application.site.datasource1#">
							UPDATE tblNomItems
							SET niAmount = #QShopItem.niAmount# - #QBalance.total#
							WHERE niNomID=201
							AND niTranID=#val(QSale.trnID)#
						</cfquery>
					<cfelse>
						OK
					</cfif>
				</td>
				<td>
					<cfquery name="QShopItems" datasource="#application.site.datasource1#">
						SELECT niAmount
						FROM tblNomItems
						WHERE niNomID IN (191,201)
						AND niTranID=#val(QSale.trnID)#
					</cfquery>
					<table>
					<cfloop query="QShopItems">
						<tr>
							<td>#niAmount#</td>
						</tr>
					</cfloop>
					</table>
				</td>
			<cfelse>
				<td colspan="3">Sales transaction missing</td>
			</cfif>
		</tr>
	</cfloop>
	</table>
	#errCount# errors found.
</cfoutput>
</body>
</html>