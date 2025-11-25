
<cfobject component="code/functions" name="settings">
<cfset application.site.error = ''>
<cfset parms.datasource0 = application.site.datasource0>
<cfset parms.datasource = application.site.datasource1>
<cfset delCharges = settings.LoadDelCharges(parms)>
<cfif delCharges.err eq 0>
	<cfset application.controls = settings.LoadControls(parms)>
	<cfset application.siteRecord = settings.LoadSite(parms)>
	<cfset application.siteClient = settings.LoadSiteClient(parms)>
	
<!---
	<cfset application.site.FYDates={}>
	<cfloop from="#Year(application.controls.tradestart)#" to="#Year(application.controls.fyend)-1#" index="i">
		<cfset startDate=CreateDate(i,Month(application.controls.tradestart),Day(application.controls.tradestart))>
		<cfset endDate=CreateDate(i+1,Month(application.controls.fyend),Day(application.controls.fyend))>
		<cfset StructInsert(application.site.FYDates,"FY-#i#",{"key"=i,"title"="#i#-#i+1#",
			"start"=DateFormat(startDate,"YYYY-MM-DD"),"end"=DateFormat(endDate,"YYYY-MM-DD")},false)>
	</cfloop>
--->
	<cfset application.site.FYDates = {}>
	<cfloop from="#Year(application.controls.tradestart)#" to="#Year(application.controls.fyend)-1#" index="thisYear">
		<cfif thisYear gt 2023>		<!--- change to new tax year arrangement (apr to mar) from now on --->
			<cfset startDate = CreateDate(thisYear,4,1)>
			<cfset dayBefore = DateAdd("d",-1,startDate)>
			<cfset endDate = CreateDate(thisYear+1,Month(dayBefore),Day(dayBefore))>
			<cfset title = "#thisYear#-#thisYear+1#">
		<cfelse>	<!--- use original tax year (feb to jan) --->
			<cfset startDate = CreateDate(thisYear,Month(application.controls.tradestart),Day(application.controls.tradestart))>
			<cfset dayBefore = DateAdd("d",-1,startDate)>
			<cfset endDate = CreateDate(thisYear+1,Month(dayBefore),Day(dayBefore))>
			<cfset title = "#thisYear#-#thisYear+1#">
		</cfif>
		<cfif thisYear eq 2023>	<!--- 14 month year --->
			<cfset endDate = CreateDate(thisYear+1,3,31)>
			<cfset title = "#thisYear#-#thisYear+1# ext">
		</cfif>
		<cfset StructInsert(application.site.FYDates,"FY-#thisYear#",{
			"key" = thisYear,
			"title" = title,
			"start" = DateFormat(startDate,"YYYY-MM-DD"),
			"end" = DateFormat(endDate,"YYYY-MM-DD")
		},false)>
	</cfloop>

	<cfset parm = {}>
	<cfset parm.yyyy = Year(Now())>
	<cfset application.holidays = settings.BankHolidays(parm)>
<cfelse>
	<cfset application.site.error = 'A system error occurred.'>
	<cfset application.site.detail = 'Unable to load the database. Check the database connection exists.'>
</cfif>