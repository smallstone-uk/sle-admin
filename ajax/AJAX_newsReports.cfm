
<!--- newsReports.cfm --->
<cfobject component="code/newsReports" name="report">

<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>

<!---<cfdump var="#form#" label="form newsReports" expand="true">--->

<cfif StructKeyExists(form,"mode")>
	<cfif mode eq 1>
		<cfif StructKeyExists(form,"srchReport")>
			<cfswitch expression="#form.srchReport#">
				<cfcase value="1">
					<cfset data = report.ShopSales(parms)>
					<cfset report.ViewShopSalesReport(data)>
				</cfcase>
			</cfswitch>
		</cfif>
	</cfif>
</cfif>
 