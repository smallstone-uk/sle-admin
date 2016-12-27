<cffunction
name="renderLinkView"
returntype="string"
output="false"
hint="I render the link View for the given link and image.">
 
<!--- Define images. --->
<cfargument name="href" />
<cfargument name="imageSource" />
 
<!--- Render the link view. --->
<cfsavecontent variable="local.view">
<cfoutput>
 
<a href="#arguments.href#" target="_blank">
<img src="#arguments.imageSource#" height="100" />
</a>
 
</cfoutput>
</cfsavecontent>
 
<!--- Return the link view. --->
<cfreturn local.view />
 
</cffunction>
 
 
<cfscript>
 
// Create our JSoup class. The class mostly has static methods
// for parsing so we don't need to initialize it.
jSoupClass = createObject( "java", "org.jsoup.Jsoup" );
 
// Create a connection to the Tumblr blog and execute a GET HTTP
// request on the connection. Hello muscular women!
dom = jSoupClass.connect( "http://lweb.shortlanesendstore.co.uk" )
.get()
;
 
// Get all of the posts that have an image as the primary media
// element. From there, we can subsquently select both the image
// and the link to the blog post.
//
// NOTE: If you have a space around your inner selector, jSoup
// will throw an unexpected token error:
// == Could not parse query '': unexpected token at '' ==
posts = dom.select( "div##menu:has(li)" );
 
// Loop over the blog posts to generate the images and links.
for ( post in posts ){
 
// Once we have a node within the document, select() requests
// on the node will be relative to the given node within the
// Document Object Model.
 
// Get the link element. This is the immediate child of the
// current post.
link = post.select( "> a" );
 
// Get the media image for the post.
image = post.select( "li" );
 
// Render the link. Notice that we are preceeding the
// attribute name with "abs:". This gets jSoup to return the
// absolute URL for the attribute value. If we did not have
// it and the URL was relative, it would return only the
// relative value.
writeOutput(
 
renderLinkView(
link.attr( "abs:href" ),
image.attr( "abs:src" )
)
 
);
 
}
 
</cfscript>