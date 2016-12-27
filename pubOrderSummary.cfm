<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Paper Order Summary</title>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>


<cfquery name="QPubOrders" datasource="#application.site.datasource1#">
	SELECT pubTitle, count( * )
	FROM tblOrderItem , tblPublication
	WHERE pubID = oiPubID
	<!---AND pubType = 'Morning'--->
	GROUP BY pubID
</cfquery>
<body>
	<p><a href="index.cfm">Home</a></p>
	<cfif application.site.showdumps><cfdump var="#QPubOrders#" label="QPubOrders" expand="yes"></cfif>
</body>
</html>