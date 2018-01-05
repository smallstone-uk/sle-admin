<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Bunnery</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<cfparam name="startDate" default="#Year(Now())#-01-01">
<cfparam name="endDate" default="#DateFormat(Now(),'yyyy-mm-dd')#">
<cfset period = int((endDate - startDate) / 7)>
<cfif period lt 1>
	<cfset startDate = DateFormat(DateAdd("yyyy",-1,startDate),'yyyy-mm-dd')>
	<cfset period = int((endDate - startDate) / 7)>
</cfif>
<cfset emps = {}>
<cfquery name="QLabour" datasource="#application.site.datasource1#">
	SELECT YEAR(phDate)*100 + MONTH(phDate) AS yymm, empID,empFirstName,empLastName, piDay, AVG( piHours ) AS Avg, SUM( piHours ) AS Hours, SUM(piGross) AS Pay, Count(phID) AS Count
	FROM `tblpayitems`
	INNER JOIN tblPayHeader ON phID = piParent
	INNER JOIN tblemployee ON phEmployee=empID
	WHERE phDate BETWEEN '#startDate#' AND '#endDate#'
	AND piHoliday = "No"
	AND piDept = 52
	GROUP BY empID,yymm,piHoliday
</cfquery>

<cfquery name="QSales" datasource="#application.site.datasource1#">
	SELECT YEAR(trnDate)*100 + MONTH(trnDate) AS yymm, nomTitle, SUM(niAmount) AS total
	FROM `tbltrans` 
	INNER JOIN tblNomItems ON niTranID=trnID
	INNER JOIN tblNominal ON niNomID=nomID
	WHERE `trnDate` BETWEEN '#startDate#' AND '#endDate#'
	AND niNomID IN (901,2212,2152)
	GROUP BY yymm, niNomID 
</cfquery>

<cfquery name="QStock" datasource="#application.site.datasource1#">
	SELECT YEAR(trnDate)*100 + MONTH(trnDate) AS yymm, nomTitle, SUM(niAmount) AS total
	FROM `tbltrans` 
	INNER JOIN tblNomItems ON niTranID=trnID
	INNER JOIN tblNominal ON niNomID=nomID
	WHERE `trnDate` BETWEEN '#startDate#' AND '#endDate#'
	AND niNomID IN (1252,1262)
	GROUP BY yymm, niNomID 
</cfquery>

<body>
	<cfset totSales = 0>
	<cfset totLabour = 0>
	<cfset totHours = 0>
	<cfset totStock = 0>
	<cfoutput>
		<h1>Bunnery Performance</h1>
		<h2>#DateFormat(startDate,'dd-mmm-yyyy')# to #DateFormat(endDate,'dd-mmm-yyyy')# Weeks: #period#</h2>
		<table width="500" border="1" class="tableList">
			<tr>
				<td>year/month</td>
				<td>title</td>
				<td align="right">hours</td>
				<td align="right">value</td>
				<td></td>
			</tr>
			<cfloop query="QSales">
				<cfset totSales -= total>
			<tr>
				<td>#yymm#</td>
				<td colspan="2">#nomTitle#</td>
				<td align="right">#DecimalFormat(-total)#</td>
			</tr>
			</cfloop>
			<tr>
				<td colspan="2" align="right">Total Sales</td>
				<td></td>
				<td align="right">#DecimalFormat(totSales)#</td>
			</tr>
			<cfif endDate eq DateFormat(Now(),'yyyy-mm-dd')>
				<tr>
					<td colspan="2" align="right">Projected Sales</td>
					<td></td>
					<td align="right">#DecimalFormat((totSales / period) * 52)#</td>
				</tr>
			</cfif>
			<tr><td colspan="5">&nbsp;</td>
			<cfloop query="QStock">
				<cfset totStock += total>
			<tr>
				<td>#yymm#</td>
				<td colspan="2">#nomTitle#</td>
				<td align="right">#DecimalFormat(total)#</td>
			</tr>
			</cfloop>
			<tr>
				<td colspan="2" align="right">Total Stock</td>
				<td></td>
				<td align="right">#DecimalFormat(totStock)#</td>
				<td align="right">#DecimalFormat((totStock / totSales) * 100)#%</td>
			</tr>
			<cfif endDate eq DateFormat(Now(),'yyyy-mm-dd')>
				<tr>
					<td colspan="2" align="right">Projected Stock</td>
					<td></td>
					<td align="right">#DecimalFormat((totStock / period) * 52)#</td>
				</tr>
			</cfif>
			<tr><td colspan="5">&nbsp;</td>
			<cfloop query="QLabour">
				<cfset totLabour += pay>
				<cfset totHours += hours>
				<cfif NOT StructKeyExists(emps,empID)>
					<cfset StructInsert(emps,empID,{name="#empFirstName# #empLastName#",hours=0,pay=0})>
				</cfif>
				<cfset emp = StructFind(emps,empID)>
				<cfset emp.hours += hours>
				<cfset emp.pay += pay>
			<tr>
				<td>#yymm#</td>
				<td>#empFirstName# #empLastName#</td>
				<td align="right">#hours#</td>
				<td align="right">#DecimalFormat(pay)#</td>
			</tr>
			</cfloop>
			<tr>
				<td colspan="2" align="right">Total Labour</td>
				<td align="right">#DecimalFormat(totHours)#</td>
				<td align="right">#DecimalFormat(totLabour)#</td>
				<td align="right">#DecimalFormat((totLabour / totSales) * 100)#%</td>
			</tr>
			<cfif endDate eq DateFormat(Now(),'yyyy-mm-dd')>
				<tr>
					<td colspan="2" align="right">Projected Labour</td>
					<td></td>
					<td align="right">#DecimalFormat((totLabour / period) * 52)#</td>
				</tr>
				<tr>
					<td colspan="2" align="right">Projected Labour (including Holiday)</td>
					<td></td>
					<td align="right">#DecimalFormat(((totLabour * 1.1207) / period) * 52)#</td>
				</tr>
			</cfif>
			<tr><td colspan="5">&nbsp;</td>
			<cfset profit = totSales - (totLabour * 1.1207) - totStock>
			<tr>
				<td colspan="2" align="right">Profit</td>
				<td></td>
				<td align="right">#DecimalFormat(profit)#</td>
				<td align="right">#DecimalFormat((profit / totSales) * 100)#%</td>
			</tr>
			<cfif endDate eq DateFormat(Now(),'yyyy-mm-dd')>
				<tr>
					<td colspan="2" align="right">Projected Profit</td>
					<td></td>
					<td align="right">#DecimalFormat((profit / period) * 52)#</td>
				</tr>
			</cfif>
		</table>
		<h2>Staff Analysis (#period# weeks) excluding holidays</h2>
		<table width="500" border="1" class="tableList">
			<tr>
				<td>Name</td>
				<td align="right">Hours</td>
				<td align="right">Pay</td>
				<td align="right">Avg Hours</td>
				<td align="right">Avg Pay</td>
			</tr>
		<cfset totHours = 0>
		<cfset totPay = 0>
		<cfloop collection="#emps#" item="key">
			<cfset emp = StructFind(emps,key)>
			<cfset totHours += emp.hours>
			<cfset totPay += emp.pay>
			<tr>
				<td>#emp.name#</td>
				<td align="right">#DecimalFormat(emp.hours)#</td>
				<td align="right">&pound;#DecimalFormat(emp.pay)#</td>
				<td align="right">#DecimalFormat(emp.hours/period)#</td>
				<td align="right">&pound;#DecimalFormat(emp.pay/period)#</td>
			</tr>
		</cfloop>
			<tr>
				<th>Totals</th>
				<th align="right">#DecimalFormat(totHours)#</th>
				<th align="right">&pound;#DecimalFormat(totPay)#</th>
				<th align="right">#DecimalFormat(totHours/period)#</th>
				<th align="right">&pound;#DecimalFormat(totPay/period)#</th>
			</tr>		
		</table>
	</cfoutput>
</body>
</html>