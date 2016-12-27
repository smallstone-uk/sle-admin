
<cfparam name="drop" default="0">
<cfobject component="code/functions" name="cust">
<cfset parms={}>
<cfset parms.clientID=drop>
<cfset parms.datasource=application.site.datasource1>
<cfset address=cust.LoadClientAddress(parms)>

<cfoutput>
	<h1><img src="images/map.png" style="float:left;margin: 4px 10px 0 0;" />#address#</h1>
	<iframe width="600" height="600" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.co.uk/maps?f=q&amp;source=s_q&amp;hl=en&amp;geocode=&amp;q=#address#&amp;t=h&amp;ie=UTF8&amp;hq=&amp;hnear=#address#,+United+Kingdom&amp;iwloc=A&amp;output=embed"></iframe>
	<p>Not being found, try <a href="https://maps.google.co.uk/maps?source=s_q&f=q&hl=en&geocode=&q=#address#&t=h&ie=UTF8&hq=&hnear=#address#,+United+Kingdom&iwloc=A&vpsrc=6&oi=map_misc&ct=api_logo">refining the search</a></p>
</cfoutput>

