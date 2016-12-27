<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<h3>Example: Using SetLocale and GetLocale</h3>
<cfoutput>
    <!--- For each new request, the locale gets reset to the JVM locale --->
    Initial locale's ColdFusion name: #GetLocale()#<br>
    <br>
    <!--- Do this only if the form was submitted. --->
    <cfif IsDefined("form.mylocale")>
        <b>Changing locale to #form.mylocale#</b><br>
        <br>
        <!--- Set the locale to the submitted value and save the old ColdFusion locale name.--->
        <cfset oldlocale=SetLocale("#form.mylocale#")>
        <!--- Get the current locale. It should have changed. --->
        New locale: #GetLocale()#<br>
    </cfif>

    <!--- Self-submitting form to select the new locale. --->
    <cfform>
        <h3>Please select the new locale:</h3>
        <cfselect name="mylocale">
            <!--- The server.coldfusion.supportedlocales variable is a 
                    list of all supported locale names. Use a list cfloop tag 
                    to create an HTML option tag for each name in the list. --->
            <cfloop index="i" list="#server.coldfusion.supportedlocales#">
                <option value="#i#">#i#</option>
            </cfloop>
        </cfselect><br>
        <br>
        <cfinput type="submit" name="submitit" value="Change Locale">
    </cfform>
</cfoutput>
</body>
</html>
