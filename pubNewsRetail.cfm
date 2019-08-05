<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>Newspaper Prices</title>
	<link rel="stylesheet" type="text/css" href="css/main4.css">
	<style type="text/css">
		body {background-color:#FFFFFF;}
		.tableList {font-size:16px; font-family:Arial, Helvetica, sans-serif; font-weight:bold;}
	</style>
</head>

<cfquery name="QNewspapers" datasource="#application.site.datasource1#" result="QResult">
	SELECT pubTitle,pubRoundTitle,pubArrival,pubCategory,pubGroup,pubPrice,pubType,pubActive 
	FROM tblPublication
	WHERE (pubCategory='news' OR pubCategory='sunday' OR pubCategory='local')
	AND pubGroup='news'
	AND pubPrice>0
	AND pubActive
	ORDER BY pubRoundTitle, pubPrice
</cfquery>
<cfset pubList=[]>
<cfset weeklyList=[]>
<cfset pubClass="">
<cfset priceIndex=1>
<cfset rec={}>
<cfset rec.type="">
<cfset rec.price1="">
<cfset rec.price2="">
<cfset rec.price3="">
<cfloop query="QNewspapers">
	<cfif pubClass NEQ "" AND pubRoundTitle NEQ pubClass>
		<cfif rec.type IS "weekly">
			<cfset ArrayAppend(weeklyList,rec)>
		<cfelse>
			<cfset ArrayAppend(pubList,rec)>
		</cfif>
		<cfset rec={}>
		<cfset rec.type="">
		<cfset rec.price1="">
		<cfset rec.price2="">
		<cfset rec.price3="">
		<cfset priceIndex=1>
	</cfif>
	<cfset rec.title=pubRoundTitle>
	<cfset rec.type=pubType>
	<cfset rec.arrival=pubArrival>
	<cfif pubArrival LT 6>
		<cfset rec.price1=pubPrice>
	<cfelseif pubArrival EQ 6>
		<cfset rec.price2=pubPrice>
	<cfelse>
		<cfset rec.price3=pubPrice>
	</cfif>
	<cfset pubClass=pubRoundTitle>		
	<cfset priceIndex++>
</cfloop>
<cfif rec.type IS "weekly">
	<cfset ArrayAppend(weeklyList,rec)>
<cfelse>
	<cfset ArrayAppend(pubList,rec)>
</cfif>
<body>
<cfoutput>
<table class="tableList" border="1">
	<tr>
		<th colspan="5">#application.company.companyname#</th>
	</tr>
	<tr>
		<th colspan="5">#application.company.telephone#</th>
	</tr>
	<tr>
		<th colspan="5">Newspaper Price List &nbsp; as at #DateFormat(now(),"dd-mmm-yy")#</th>
	</tr>
	<tr>
		<th width="260">Title</th>
		<th></th>
		<th align="right" width="60">Weekday</th>
		<th align="right" width="60">Saturday</th>
		<th align="right" width="60">Sunday</th>
	</tr>
	<tr>
		<td colspan="5" height="30" align="center">DAILY PAPERS</td>
	</tr>
	<cfloop array="#pubList#" index="item">
	<tr>
		<td>#item.title#</td>
		<td></td>
		<td align="right">#item.price1#</td>
		<td align="right">#item.price2#</td>
		<td align="right">#item.price3#</td>
	</tr>
	</cfloop>
	<tr>
		<td colspan="5" height="30" align="center">WEEKLY PAPERS</td>
	</tr>
	<cfloop array="#weeklyList#" index="item">
	<tr>
		<td>#item.title#</td>
		<td>#GetToken("Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday",item.arrival,",")#</td>
		<td align="right">#item.price1#</td>
		<td align="right">#item.price2#</td>
		<td align="right">#item.price3#</td>
	</tr>
	</cfloop>
</table>
</cfoutput>
</body>
</html>
