
<cfquery name="QHeader" datasource="#application.site.dataSource0#"> <!--- Get transaction records --->
	SELECT *
	FROM cmsclients
	WHERE cltSiteID=#application.site.clientID#
	LIMIT 1;
</cfquery>
<cfoutput query="QHeader">
	<table class="compTable">
		<tr><td class="compName" colspan="3">#cltCompanyName#</td></tr>
		<tr><td class="compAddr" width="300" >#cltAddress1#</td><td width="100" class="compDetailTitle">#cltTelTitle1#</td><td width="200" class="compDetail">#cltTel1#</td></tr>
		<tr><td class="compAddr">#cltAddress2#</td><td class="compDetailTitle">#cltTelTitle2#</td><td class="compDetail">#cltTel2#</td></tr>
		<tr><td class="compAddr">#cltTown#</td><td class="compDetailTitle">Website</td><td class="compDetail">#cltWebSite#</td></tr>
		<tr><td class="compAddr">#cltCounty#</td><td class="compDetailTitle">EMail</td><td class="compDetail">#cltMailOffice#</td></tr>
		<tr><td class="compAddr">#cltPostcode#</td><td class="compDetailTitle"></td><td class="compDetail"></td></tr>
	</table>
</cfoutput>
