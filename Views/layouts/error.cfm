<cfoutput>
    <!DOCTYPE html>

    <html>
        <head>
            <title>#structFindDefault(variables, 'title', 'Error')#</title>
            <cfset includeView('layouts.resources')>
        </head>

        <body>
            <div class="container">
                #includeViewContent()#
            </div>
        </body>
    </html>
</cfoutput>
