<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Smiths Order</title>
</head>

<body>
<cftry>
	<cfset loc={}>
	<cfset loc.fileDir="#application.site.dir_data#stock\">
	<cfset loc.sourcefile="Connect2U-150813.htm">
	<cffile action="read" file="#loc.fileDir##loc.sourcefile#" variable="loc.content">
	<cfscript>
		loc.jsoup = createObject("java","org.jsoup.Jsoup");
		loc.doc = loc.jsoup.parse(loc.content);
		loc.bits=loc.doc.select("tr:has(td.tabletext)");
		for (loc.bit in loc.bits) {
			WriteOutput(loc.bit.text());
		}
	//		WriteOutput(loc.bits);
	//	loc.rows = loc.items.select("tr.genericListItem");
	</cfscript>
	<cfdump var="#loc.bits#" label="loc" expand="false">
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
</body>
</html>