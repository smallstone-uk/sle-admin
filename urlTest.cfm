<cfscript>
    route().get('/dir', 'ProductController@test');
    route().post('/dir', 'dir post');
    route().handle();
</cfscript>

<cfoutput>
    <form method="post" action="#getUrl('/dir')#">
        <input type="submit" value="Submit">
    </form>
</cfoutput>
