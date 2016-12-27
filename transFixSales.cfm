<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Sales</title>
</head>

<cfparam name="dateFrom" default="2013-02-24">
<cfparam name="dateTo" default="2013-02-28">
<!---trnID,trnDate,trnDesc,trnAmnt1,trnAmnt2--->
<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT *
	FROM tblTrans
	WHERE trnDate BETWEEN '#dateFrom#' AND '#dateTo#'
	AND trnLedger = 'sales'
	AND trnAccountID=1
	ORDER BY trnDate
</cfquery>
<cfdump var="#QTrans#" label="QTrans" expand="yes">
<cfoutput>
	<cfloop query="QTrans">
		<cfset tranID = trnID>
		<cfset tranDate = trnDate>
		<cfquery name="QNomSalesItems" datasource="#application.site.datasource1#">
			SELECT tblNomItems.*, nomCode,nomTitle
			FROM tblNomItems
			INNER JOIN tblNominal ON niNomID=nomID
			WHERE niTranID=#tranID#
			AND nomType='sales'
		</cfquery>
		<cfdump var="#QNomSalesItems#" label="QNomSalesItems" expand="yes">
		<cfquery name="QNomItems" datasource="#application.site.datasource1#">
			SELECT *
			FROM tblNomItems,tblNominal
			WHERE niTranID=#val(tranID)#
			AND niNomID=nomID
			AND nomType='nom'
			ORDER BY nomCode
		</cfquery>
		<cfdump var="#QNomItems#" label="QNomItems" expand="yes">

		<cfquery name="QSupItems" datasource="#application.site.datasource1#">
			SELECT trnID,trnDate, SUM(niAmount), niNomID
			FROM tblTrans 
			INNER JOIN tblNomItems ON trnID=niTranID
			WHERE trnType = 'pay' 
			AND trnDate = #tranDate#
			AND niNomID=181
			AND trnAccountID > 4
			GROUP BY niNomID
		</cfquery>
		<cfdump var="#QSupItems#" label="QSupItems" expand="yes">

		<cfquery name="QChqItems" datasource="#application.site.datasource1#">
			SELECT trnID,trnDate, niAmount, niNomID
			FROM tblTrans 
			INNER JOIN tblNomItems ON trnID=niTranID
			WHERE trnType = 'pay' 
			AND trnMethod LIKE 'chqs'
			AND trnDate = #tranDate#
			AND niNomID=1472
		</cfquery>
		<cfdump var="#QChqItems#" label="QChqItems" expand="yes">

		<cfquery name="QCardItems" datasource="#application.site.datasource1#">
			SELECT trnID,trnDate,trnDesc,trnActual, niAmount, niNomID
			FROM tblTrans 
			INNER JOIN tblNomItems ON trnID=niTranID
			WHERE trnType = 'nom' 
			AND trnRef LIKE 'BGC'
			AND trnActual = #tranDate#
			AND niNomID=191
		</cfquery>
		<cfdump var="#QCardItems#" label="QCardItems" expand="yes">
	</cfloop>
</cfoutput>
<body>
</body>
</html>


<!---
	CHQ Account	= 1472
	

--->