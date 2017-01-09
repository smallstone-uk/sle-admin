<cfscript>
    route().get('/dir', 'dir get');
    route().handle();
</cfscript>

<cfoutput>
    <form method="post" action="#getUrl('/dir')#">
        <input type="submit" value="Submit">
    </form>
</cfoutput>
