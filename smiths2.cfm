<cftry>
	<cfoutput>
		<cfhttp result="result" 
			method="GET" charset="utf-8" 
			url="https://www.snapponline.co.uk/##/user-login"
		 	useragent="Mozilla/5.0 (Windows NT 10.0; WOW64; rv:51.0) Gecko/20100101 Firefox/51.0">
			<cfhttpparam name="customerNumber" type="formfield" value="212956">
			<cfhttpparam name="customerPassword" type="formfield" value="Kcc150297">
		</cfhttp>
		<cfdump var="#result#" expand="no">
		#result.fileContent#
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
