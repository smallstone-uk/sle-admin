<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Parse HTML</title>
</head>

<body>
<cfparam name="form.url" default="http://www.cnn.com">
<cfparam name="form.selector" default="img">

<form class="well" method="post">
	<cfoutput>
	<p>
	<label for="url">URL:</label> <input type="url" name="url" id="url" required value="#form.url#">
	</p>
	<p>
	<label for="selector">Selector:</label> <input type="text" name="selector" id="selector" required value="#form.selector#">
	</p>
	<p>
	<input type="submit" value="Run Test" class="btn btn-primary">
	</p>
	</cfoutput>
</form>

<cftry>
<cfif isValid("url",form.url) and len(trim(form.selector))>
	<cfhttp url="#form.url#">
	<cfset html = cfhttp.filecontent>
	<cfset cachePut(form.url,html)>

	<cfset jsoup = createObject("java", "org.jsoup.Jsoup")>
	<cfset doc = jsoup.parse(html)>
	<cfset elements = doc.select(form.selector)>
	<cfoutput>
		<table class="table table-striped table-bordered">
			<cfset eleCount=0>
			<cfloop index="e" array="#elements#">
				<cfset eleCount++>
					<tr>
						<td>#htmlEditFormat(e.toString())#</td>
					</tr>
			</cfloop>
			<tr><td>#eleCount# elements.</td></tr>
		</table>
	</cfoutput>
<cfelse>
	Invalid URL
</cfif>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</body>
</html>
