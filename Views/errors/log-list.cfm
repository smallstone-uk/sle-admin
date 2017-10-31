<cftry>
    <style>
        table {border-spacing: 0px;border-collapse: collapse;border: 1px solid #BBB;font-size: 14px;font-weight: normal;}
        table th {padding: 4px 5px;color: inherit;font-weight: bold;background: #FFF;}
        table td {padding: 4px 5px;border-color: #BBB;color: inherit;}
        table[border="0"] {border:none;}
    </style>

    <cfdirectory
        directory = "#getDataDir('/logs')#"
        action = "list"
        listInfo = "all"
        name = "logList"
        recurse = "no"
        sort = "datelastmodified DESC"
        type = "file">

    <cfset del = structKeyExists(form, "delAllLogs")>

    <cfif del>
        <cfloop query="logList">
            <cffile action="delete" file="#directory#\#name#">
        </cfloop>

        <cflocation url="#getUrl('/logs')#" addtoken="no">
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
                    <td>#lsDateFormat(datelastmodified, "dd/mm/yyyy")# @ #lsTimeFormat(datelastmodified, "HH:mm:ss")#</td>
                    <td>
                        <cffile action="read" file="#directory#\#name#" variable="fileContent">
                        #fileContent#
                    </td>
                </tr>
            </cfloop>
        </table>
    </cfoutput>

    <cfcatch type="any">
        <cfdump var="#cfcatch#" label="cfcatch" expand="no">
    </cfcatch>
</cftry>
