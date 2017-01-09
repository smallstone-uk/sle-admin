<cfscript>
    route().get('/dir', 'test');

    writeDump(route().findURI(url.url_payload));

    writeDump(request.routes);
</cfscript>
