<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>year ends</title>
</head>
<body>
<cfdump var="#application.controls#" label="" expand="yes">
<cfoutput>
	<cfset FYDates={}>
	<cfloop from="#Year(application.controls.tradestart)#" to="#Year(application.controls.fyend)-1#" index="i">
		<cfset startDate=CreateDate(i,Month(application.controls.tradestart),Day(application.controls.tradestart))>
		<cfset endDate=CreateDate(i+1,Month(application.controls.fyend),Day(application.controls.fyend))>
		<cfset StructInsert(FYDates,"FY-#i#",{"key"=i,"title"="#i#-#i+1#","start"=DateFormat(startDate,"YYYY-MM-DD"),"end"=DateFormat(endDate,"YYYY-MM-DD")},false)>
		<!---<cfset ArrayAppend(FYDates,{"key"=i,"title"="#i#-#i+1#","start"=DateFormat(startDate,"YYYY-MM-DD"),"end"=DateFormat(endDate,"YYYY-MM-DD")})>--->
	</cfloop>
	<cfdump var="#FYDates#" label="FYDates" expand="no">
	<table width="400" border="1">
		<tr>
			<td>KEY</td>
			<td>TITLE</td>
			<td>FROM</td>
			<td>TO</td>
		</tr>
		<cfset dateKeys=ListSort(StructKeyList(FYDates,","),"text","ASC")>
		<cfloop list="#dateKeys#" index="key">
			<cfset item=StructFind(FYDates,key)>
			<tr>
				<td>#item.key#</td>
				<td>Year #item.title#</td>
				<td>#item.start#</td>
				<td>#item.end#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
</body>
</html>