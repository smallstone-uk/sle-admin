<cfoutput>
    <!DOCTYPE html>

    <html>
        <head>
            <title>SLE Admin</title>
            <cfset includeView('layouts.resources')>
        </head>

        <body>
            <div class="container">
                #includeViewContent()#
            </div>
        </body>
    </html>
</cfoutput>
