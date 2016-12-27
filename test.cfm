<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>test</title>
</head>

<body>
	<cfoutput>
		<cfset item = {}>
		<cfset item.Retail = 7.09>
		<cfset item.pwretail = 1.90>
		<cfset item.qty = 1>
		<cfset item.vatrate = .2>
		<cfset item.discount = .225>
		
		<cfset item.whole = int(item.Retail * (1 - item.discount) * 100) / 100>
		<cfset item.gross = item.Retail * (1 - item.discount)>
		<cfset item.diff = item.gross - item.whole>
		<cfif item.diff gt 0><cfset item.whole = item.whole + 0.01></cfif>
		<cfset item.pwgross = item.pwretail * (1 - item.discount)>
		<cfset item.net=item.gross>
		<cfset item.pwnet=int(item.pwgross / (1 + item.vatrate) * 100) / 100>
		<cfset item.vat = item.pwgross - item.pwnet>
		<cfset item.linetotal = item.net * item.qty>
		<cfdump var="#item#">
	</cfoutput>
</body>
</html>