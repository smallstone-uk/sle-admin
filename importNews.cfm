<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Import News</title>
</head>

<body>
	<cfobject component="code/importNews" name="import">
	<cfparam name="fileSrc" default="News-151124.htm">
	<cfset parm={}>
	<cfset parm.fileDir="#application.site.dir_data#News\">
	<cfset parm.sourcefile=fileSrc>
	<cfflush interval="200">
	<cfset records=import.processFile(parm)>
	<cfdump var="#records#" label="records" expand="false">
</body>
</html>