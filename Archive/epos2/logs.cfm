<cftry>
<script src="../scripts/jquery-1.11.1.min.js"></script>
<script src="../scripts/jquery-ui.js"></script>

<style>
	table {border-spacing: 0px;border-collapse: collapse;border: 1px solid #BBB;font-size: 14px;font-weight: normal;}
	table th {padding: 4px 5px;color: inherit;font-weight: bold;background: #FFF;}
	table td {padding: 4px 5px;border-color: #BBB;color: inherit;}
	table[border="0"] {border:none;}
</style>

<cfdirectory
	directory = "#application.site.dir_logs#epos"
    action = "list"
    listInfo = "all"
    name = "logList"
    recurse = "no"
    sort = "datelastmodified DESC"
    type = "all">

<cfif StructKeyExists(form, "delAllLogs")>
	<cfloop query="logList">
		<cffile action="delete" file="#directory#\#name#">
	</cfloop>
	<cflocation url="#application.site.normal#epos2/logs.cfm" addtoken="no">
</cfif>

<cfoutput>
	<form method="post" enctype="multipart/form-data">
		<input type="submit" name="delAllLogs" value="Delete All">
	</form>
	<table width="100%" border="1">
		<tr>
			<th>Date/Time</th>
			<th>Content</th>
		</tr>
		<cfloop query="logList">
			<tr>
				<td>#LSDateFormat(datelastmodified, "dd/mm/yyyy")# @ #LSTimeFormat(datelastmodified, "HH:mm")#</td>
				<td>
					<cffile action="read" file="#directory#\#name#" variable="fileContent">
					#fileContent#
				</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>