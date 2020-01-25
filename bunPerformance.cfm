<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Bunnery</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
			$(".srchAccount, .srchTranType").chosen({width: "300px"});
		});
	</script>
</head>

<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfif IsDate(srchDateFrom) AND IsDate(srchDateTo)>
	<cfset period = int((srchDateTo - srchDateFrom) / 7)>
</cfif>

<cfset emps = {}>
<cfquery name="QLabour" datasource="#application.site.datasource1#">
	SELECT YEAR(phDate)*100 + MONTH(phDate) AS yymm, empID,empFirstName,empLastName,empStatus, piDay, AVG( piHours ) AS Avg, SUM( piHours ) AS Hours, SUM(piGross) AS Pay, Count(phID) AS Count
	FROM `tblpayitems`
	INNER JOIN tblPayHeader ON phID = piParent
	INNER JOIN tblemployee ON phEmployee=empID
	WHERE phDate BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
	AND piHoliday = "No"
	AND piDept = 52
	GROUP BY yymm,empID,piHoliday
</cfquery>

<cfquery name="QSales" datasource="#application.site.datasource1#">
	SELECT YEAR(trnDate)*100 + MONTH(trnDate) AS yymm, nomTitle, SUM(niAmount) AS total
	FROM `tbltrans` 
	INNER JOIN tblNomItems ON niTranID=trnID
	INNER JOIN tblNominal ON niNomID=nomID
	WHERE `trnDate` BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
	AND niNomID IN (901,2212,2152)
	GROUP BY yymm, niNomID 
</cfquery>

<cfquery name="QStock" datasource="#application.site.datasource1#">
	SELECT YEAR(trnDate)*100 + MONTH(trnDate) AS yymm, nomTitle, SUM(niAmount) AS total
	FROM `tbltrans` 
	INNER JOIN tblNomItems ON niTranID=trnID
	INNER JOIN tblNominal ON niNomID=nomID
	WHERE `trnDate` BETWEEN '#srchDateFrom#' AND '#srchDateTo#'
	AND niNomID IN (1252,1262)
	GROUP BY yymm, niNomID 
</cfquery>

<body>
	<cfset totSales = 0>
	<cfset totLabour = 0>
	<cfset totHours = 0>
	<cfset totStock = 0>
	<cfoutput>
		<div class="form-wrap">
			<form method="post">
				<div class="form-header no-print">
					Bunnery Performance
					<span><input type="submit" name="btnSearch" value="Search" /></span>
				</div>
				<div class="module no-print">
					<table border="0">
						<tr>
							<td><b>Date From</b></td>
							<td>
								<input type="text" name="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
							</td>
						</tr>
						<tr>
							<td><b>Date To</b></td>
							<td>
								<input type="text" name="srchDateTo" value="#srchDateTo#" class="datepicker" />
							</td>
						</tr>
					</table>
				</div>
			</form>
		</div>


		<cfif StructKeyExists(form,"fieldnames")>
			<table width="500" border="1" class="tableList">
				<tr>
					<th>year/month</th>
					<th>title</th>
					<th align="right">-</th>
					<th align="right">value</th>
					<th></th>
				</tr>
				<cfloop query="QSales">
					<cfset totSales -= total>
					<tr>
						<td>#yymm#</td>
						<td colspan="2">#nomTitle#</td>
						<td align="right">#DecimalFormat(-total)#</td>
						<td></td>
					</tr>
				</cfloop>
				<tr>
					<th colspan="2" align="right">Total Sales</th>
					<th></th>
					<th align="right">#DecimalFormat(totSales)#</th>
					<th></th>
				</tr>
				<cfif srchDateTo eq DateFormat(Now(),'yyyy-mm-dd')>
					<tr>
						<td colspan="2" align="right">Projected Sales</td>
						<td></td>
						<td align="right">#DecimalFormat((totSales / period) * 52)#</td>
					</tr>
				</cfif>
				<tr><td colspan="5">&nbsp;</td>
				<tr>
					<th>year/month</th>
					<th>title</th>
					<th align="right">-</th>
					<th align="right">value</th>
					<th></th>
				</tr>
				<cfloop query="QStock">
					<cfset totStock += total>
					<tr>
						<td>#yymm#</td>
						<td colspan="2">#nomTitle#</td>
						<td align="right">#DecimalFormat(total)#</td>
						<td></td>
					</tr>
				</cfloop>
				<tr>
					<th colspan="2" align="right">Total Stock</th>
					<th></th>
					<th align="right">#DecimalFormat(totStock)#</th>
					<th align="right">#DecimalFormat(totSales ? (totStock / totSales) * 100 : 0)#%</th>
				</tr>
				<cfif srchDateTo eq DateFormat(Now(),'yyyy-mm-dd')>
					<tr>
						<td colspan="2" align="right">Projected Stock</td>
						<td></td>
						<td align="right">#DecimalFormat((totStock / period) * 52)#</td>
					</tr>
				</cfif>
				<tr><td colspan="5">&nbsp;</td>
				<tr>
					<th>year/month</th>
					<th>name</th>
					<th align="right">hours</th>
					<th align="right">value</th>
					<th></th>
				</tr>
				<cfloop query="QLabour">
					<cfset totLabour += pay>
					<cfset totHours += hours>
					<cfif NOT StructKeyExists(emps,empID)>
						<cfset StructInsert(emps,empID,{name="#empFirstName# #empLastName#",status = empStatus, hours=0,pay=0})>
					</cfif>
					<cfset emp = StructFind(emps,empID)>
					<cfset emp.hours += hours>
					<cfset emp.pay += pay>
					<tr>
						<td>#yymm#</td>
						<td>#empFirstName# #empLastName#</td>
						<td align="right">#hours#</td>
						<td align="right">#DecimalFormat(pay)#</td>
						<td></td>
					</tr>
				</cfloop>
				<tr>
					<th colspan="2" align="right">Total Labour</th>
					<th align="right">#DecimalFormat(totHours)#</th>
					<th align="right">#DecimalFormat(totLabour)#</th>
					<th align="right">#DecimalFormat(totSales ? (totLabour / totSales) * 100 : 0)#%</th>
				</tr>
				<cfif srchDateTo eq DateFormat(Now(),'yyyy-mm-dd')>
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
					<th colspan="2" align="right">Profit</th>
					<th></th>
					<th align="right">#DecimalFormat(profit)#</th>
					<th align="right">#DecimalFormat(totSales ? (profit / totSales) * 100 : 0)#%</th>
				</tr>
				<cfif srchDateTo eq DateFormat(Now(),'yyyy-mm-dd')>
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
						<td>#emp.name# (#emp.status#)</td>
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
		</cfif>
	</cfoutput>
</body>
</html>