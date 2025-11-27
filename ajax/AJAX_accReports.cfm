
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
				<cfcase value="4">
					<cfset data = report.SalesDataCorrections(parms)>
					<cfset report.ViewCorrections(data)>
				</cfcase>
				<cfcase value="5">
					<cfset data = report.LoadBalanceSheet(parms)>
					<cfdump var="#data#" label="BalanceSheet" expand="false">
					<cfset report.ViewBalanceSheet(data)>
				</cfcase>
				<cfcase value="6">
					<cfset data = report.LoadSuppliersReport(parms)>
					<!---<cfdump var="#data#" label="Suppliers" expand="false">--->
					<cfset report.ViewSuppliersReport(data)>
				</cfcase>
			</cfswitch>
		</cfif>
	<cfelseif mode eq 2>
		<cfset data = report.SaveGroup(parms)>
		<cfoutput>#data.msg#</cfoutput>
	</cfif>
</cfif>
 