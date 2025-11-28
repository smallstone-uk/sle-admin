
<!---<cfdump var="#form#" label="form import" expand="false">--->

<cfobject component="code/import3" name="import">

<cfset parms = {}>
<cfset parms.form = form>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.dataDir = "#application.site.dir_data#spreadsheets\">

<cfif form.srchProcess eq 1>
	<cfset data = import.PreviewFile(parms)>
<cfelseif form.srchProcess eq 2>
	<cfset data = import.ProcessFile(parms)>
	<cfset import.ViewFile(data)>
<cfelseif form.srchProcess eq 3>
	<cfset data = import.ImportFile(parms)>
	<!---<cfdump var="#data#" label="import data" expand="false">--->
	<cfset import.ViewImportFile(data)>
</cfif>


