<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Trew</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<body>
<cftry>
	<cfspreadsheet 
		action = "read" 
		src="D:\HostingSpaces\SLE\shortlanesendstore.co.uk\data\spreadsheets\Trewithen.xlsx" 
		query="excelquery" 
		sheet="1" 
		headerrow="1"
		columns="1,2,3,4,5"> 
		
	<!---<cfdump var="#excelquery#" label="excelquery" expand="false">--->
	
	<cfoutput>
		<cfset lastYear = 0>
		<cfset lastMonth = 0>
		<cfset totalInv = 0>
		<cfset totalRecp = 0>
		<cfset lineCount = 0>
		<table class="tableList">
		<cfloop query="excelquery">
			<cfset lineCount++>
			<cfif lineCount gt 1>
				<cfif ListFind("Invoice|Credit Note",Type,"|")>
					<cfset newDate = CreateDate(ListLast(tranDate,"/"),ListFirst(tranDate,"/"),ListGetAt(tranDate,2,"/"))>
					<cfif lastYear + lastMonth gt 0 AND ((lastYear NEQ Year(newDate)) OR (lastMonth NEQ Month(newDate)))>
						<tr>
							<th>#DateFormat(CreateDate(lastYear,lastMonth,1),"mmm yyyy")#</th>
							<th align="right">#totalInv#</th>
							<th align="right">#totalRecp#</th>
						</tr>
						<cfset totalInv = 0>
						<cfset totalRecp = 0>
					</cfif>
					<cfset totalInv += value>
<!---					<tr>
						<td>#tranDate#</td>
						<td>#reference#</td>
						<td>#type#</td>
						<td align="right">#value#</td>
						<td align="right">#totalInv#</td>
					</tr>
--->					<cfset lastYear = Year(newDate)>
					<cfset lastMonth = Month(newDate)>
				<cfelse>
					<cfset totalRecp += value>
				</cfif>
			</cfif>
		</cfloop>
		<tr>
			<th>#DateFormat(CreateDate(lastYear,lastMonth,1),"mmm yyyy")#</th>
			<th align="right">#totalInv#</th>
			<th align="right">#totalRecp#</th>
		</tr>
		</table>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>
</body>
</html>