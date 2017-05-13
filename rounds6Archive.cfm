<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">

<cfobject component="code/rounds5" name="rounds">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.html=form.html>

<cfoutput>
		<cfdocument 
			orientation="portrait" 
			mimetype="text/html"
			saveAsName="test.pdf" 
			filename="#application.site.dir_data#rounds\test.pdf"
			overwrite="yes"
			localUrl="yes" 
			format="PDF" 
			fontEmbed="yes" 
			encryption="none" 
			scale="100" 
			pagetype="a4" 
			unit="in" 
			margintop="0.5" 
			marginleft="0.3" 
			marginright="0.3" 
			marginbottom="0.5">
			
			<?xml version="1.0" encoding="UTF-8">
			<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			<html xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<style type="text/css" media="screen">@import "css/roundsPDF.css";</style>
			</head>
			
			<body>
				<div id="print-area">
					#parm.html#
				</div>
			</body>
			</html>
			
		</cfdocument>
</cfoutput>