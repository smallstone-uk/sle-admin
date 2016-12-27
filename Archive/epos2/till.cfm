<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.frame = session.epos_frame>
<cfset epos.CleanUpSession()>
<cfset session.cfc_version = epos.GetVersion()>
<cfset epos.LoadDealsIntoSession()>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('*').addClass("disable-select");
			$(document).keypress(function(e){
				console.log(e);
				if ( !( $('input').is(":focus") ) ) $.scanner(e);
			});
			findPrinter();
		});
	</script>
	<div class="style_overide">
		<cfinclude template="ajax/getStyleOveride.cfm">
	</div>
	<cfinclude template="datePicker2.cfm">
	<div class="header" style="font-family: Helvetica, Arial, 'lucida grande',tahoma,verdana,arial,sans-serif !important;">
		<cfinclude template="header.cfm">
	</div>
	<div class="content" style="font-family: Helvetica, Arial, 'lucida grande',tahoma,verdana,arial,sans-serif !important;">
		<cfinclude template="content_loader.cfm">
	</div>
	<div class="footer">
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</div>
</cfoutput>
</html>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>