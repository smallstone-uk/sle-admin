<cftry>
<cfsetting showdebugoutput="no">
<cfset index = RandRange(1024, 1220120, 'SHA1PRNG')>

<cfoutput>	
	<cffile action="write" file="#application.site.dir_data#epos\misc\openTill#index#.txt" addnewline="no" output="#Chr(27)##Chr(112)#011">
	
	<script>
		$(document).ready(function(e) {
			printFile('#application.site.url_data#epos/misc/openTill#index#.txt' );
		});
	</script>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>