
<cfparam name="currOrder" default="0">
<cfparam name="startRow" default="0">
<cfparam name="rowLimit" default="30">
<cfquery name="QPubList" datasource="#client.datasource1#" result="QResult">
	SELECT *
	FROM tblPublication
	WHERE 1
	<cfif len(criteria)>AND pubType='#criteria#'
	<cfelse>AND (pubType IS NULL OR pubType='')</cfif>
	ORDER BY pubTitle
	LIMIT #startRow#,#rowLimit#;
</cfquery>
<cfoutput>
	<table width="700">
	<cfloop query="QPubList">
		<tr>
			<td>#pubRef#</td>
			<td>#pubTitle#</td>
			<td>#pubCategory#</td>
			<td>#pubType#</td>
			<td>#pubWholesaler#</td>
			<td>#pubBarcode#</td>
			<td>#pubVATCode#</td>
		</tr>
	</cfloop>
	</table>
		<cfif lastRow gt rowLimit>
		<div id="pageButtons">
			<a class="datafieldBtns" href="#application.rootpage#?currentPage=#QPage.pgNavIndex#&amp;currOrder=#currOrder#&amp;criteria=#criteria#&amp;startRow=0&amp;lastRow=#lastRow#">First</a>
			<cfif startRow gt 0>
				<a class="datafieldBtns" href="#application.rootpage#?currentPage=#QPage.pgNavIndex#&amp;currOrder=#currOrder#&amp;criteria=#criteria#&amp;startRow=#startRow-rowLimit#&amp;lastRow=#lastRow#">Back</a>
			<cfelse>
				<span class="datafieldBtns">Back</span>
			</cfif>
			<cfif startRow+rowLimit lte lastRow>
				<a class="datafieldBtns" href="#application.rootpage#?currentPage=#QPage.pgNavIndex#&amp;currOrder=#currOrder#&amp;criteria=#criteria#&amp;startRow=#startRow+rowLimit#&amp;lastRow=#lastRow#">Next</a>
			<cfelse>
				<span class="datafieldBtns">Next</span>
			</cfif>
			<cfset lastBlock=int(lastRow/rowLimit)*rowLimit>
			<cfif lastBlock gte lastRow><cfset lastBlock=(int(lastRow/rowLimit)-1)*rowLimit></cfif>
			<a class="datafieldBtns" href="#application.rootpage#?currentPage=#QPage.pgNavIndex#&amp;currOrder=#currOrder#&amp;criteria=#criteria#&amp;startRow=#lastBlock#&amp;lastRow=#lastRow#">Last</a>
		</div>
		</cfif>
</cfoutput>
