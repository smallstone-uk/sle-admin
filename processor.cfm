<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>File Processor</title>
	<link rel="stylesheet" type="text/css" href="css/invoice.css"/>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>


<body>
	<p><a href="index.cfm">Home</a></p>
	<cfoutput>
		<table>
			<tr>
				<td colspan="2">
					<cfdirectory action="list" directory="#application.site.fileDir#" name="QDir">
					<form method="post">
					<table border="1" cellspacing="0">
						<tr>
							<th height="30">Filename</th>
							<th>Size</th>
							<th>Last Modified</th>
							<th>Type</th>
							<th>Process?</th>
						</tr>
						<cfloop query="QDir">
							<cfif type eq "file">
								<cfset dashPos=ReFind("\-",name,1,false)>
								<cfif dashPos gt 0>
									<cfset procNum=mid(name,1,dashPos-1)>
								<cfelse><cfset procNum=0></cfif>
								<tr>
									<td><a href="source/#name#" target="_blank">#name#</a></td>
									<td>#size#</td>
									<td>#DateFormat(datelastmodified,"dd-mmm-yyyy")# #TimeFormat(datelastmodified,"HH:MM:SS")#</td>
									<td>#procNum#</td>
									<td align="center"><input type="checkbox" name="fileName" value="#name#" /></td>
								</tr>
							</cfif>
						</cfloop>
						<tr>
							<td colspan="2">
								<table border="0" width="100%">
									<tr><td>Record Limit:</td><td><input type="text" name="limitRecs" size="5" value="0" /> (0=No Limit)</td></tr>
									<tr><td colspan="2"><input type="checkbox" name="showSource" value="1" /> Show source</td></tr>
									<tr><td colspan="2"><input type="checkbox" name="updateRecs" value="1" /> Update records</td></tr>
								</table>
							
							 </td>
							<td colspan="3">
								<input type="submit" name="btnGo" value="Process Files" />
							</td>
						</tr>
					</table>
					</form>
				</td>
			</tr>
		</table>
		<cfif StructKeyExists(form,"fieldnames")>
			<cfflush interval="200">
			<cfsetting requesttimeout="900">			
			<p><a href="#cgi.SCRIPT_NAME#">Home</a></p>
			<cfobject component="code/processor" name="proc">
			<cfset fileResults=proc.ProcessFiles(form,application.site)>
		</cfif>
	</cfoutput>
</body>
</html>