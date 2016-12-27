
<cfparam name="lastRow" default="0">
<cfparam name="criteria" default="">
<cfquery name="QPubCats" datasource="#client.datasource1#">
	SELECT pubID,pubType,count(*) AS pubCount
	FROM tblPublication
	WHERE 1
	GROUP BY pubType;
</cfquery>
<cfoutput>
	<ul>
	<cfloop query="QPubCats">
		<li>
			<cfif len(pubType)><cfset type=pubType><cfelse><cfset type="Uncategorised"></cfif>
			<a href="#application.rootpage#?currentPage=#QPage.pgNavIndex#&amp;criteria=#pubType#&amp;lastRow=#pubCount#">
			#type# - #pubCount#
			</a>
		</li>
	</cfloop>
	</ul>
</cfoutput>
