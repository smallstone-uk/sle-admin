
<cfobject component="code/functions" name="settings">
<cfset application.site.error = ''>
<cfset parms.datasource0 = application.site.datasource0>
<cfset parms.datasource = application.site.datasource1>
<cfset delCharges = settings.LoadDelCharges(parms)>
<cfif delCharges.err eq 0>
	<cfset application.controls = settings.LoadControls(parms)>
	<cfset application.siteRecord = settings.LoadSite(parms)>
	<cfset application.siteClient = settings.LoadSiteClient(parms)>
	
	<cfset application.site.FYDates={}>
	<cfloop from="#Year(application.controls.tradestart)#" to="#Year(application.controls.fyend)-1#" index="i">
		<cfset startDate=CreateDate(i,Month(application.controls.tradestart),Day(application.controls.tradestart))>
		<cfset endDate=CreateDate(i+1,Month(application.controls.fyend),Day(application.controls.fyend))>
		<cfset StructInsert(application.site.FYDates,"FY-#i#",{"key"=i,"title"="#i#-#i+1#",
			"start"=DateFormat(startDate,"YYYY-MM-DD"),"end"=DateFormat(endDate,"YYYY-MM-DD")},false)>
	</cfloop>
	<cfset parm = {}>
	<cfset parm.yyyy = Year(Now())>
	<cfset application.holidays = settings.BankHolidays(parm)>
<cfelse>
	<cfset application.site.error = 'A system error occurred.'>
	<cfset application.site.detail = 'Unable to load the database. Check the database connection exists.'>
</cfif>