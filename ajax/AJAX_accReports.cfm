
<!--- accReports.cfm --->
<cfobject component="code/accReports" name="report">

<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>

<!---<cfdump var="#form#" label="form accReports" expand="true">--->

<cfif StructKeyExists(form,"mode")>
	<cfif mode eq 1>
		<cfif StructKeyExists(form,"srchReport")>
			<cfswitch expression="#form.srchReport#">
				<cfcase value="1">
					<cfset data = report.LoadReport(parms)>
					<cfset report.ViewReport(data)>
				</cfcase>
				<cfcase value="2">
					<cfset data = report.LoadStockValue(parms)>
					<cfset report.ViewStockValue(data)>
				</cfcase>
				<cfcase value="3">
					<cfset data = report.AgedAccountReport(parms)>
					<cfdump var="#data#" label="AgedAccountReport" expand="false">
				</cfcase>
			</cfswitch>
		</cfif>
	<cfelseif mode eq 2>
		<cfset data = report.SaveGroup(parms)>
		<cfoutput>#data.msg#</cfoutput>
	</cfif>
</cfif>
 