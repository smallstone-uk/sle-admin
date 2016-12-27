<cfobject component="code/deals" name="deals">
<cfset parm.retailClub = val(retailClub)>

<cfif parm.retailClub gt -1>
    <cfset clubs = deals.LoadAllDeals(parm.retailClub)>
<cfelse>
    <cfset clubs = deals.LoadAllDeals()>
</cfif>

<cfoutput>
	<cfloop array="#clubs#" index="item">
		<a href="javascript:void(0)" class="deal_item" data-id="#item.edID#">#item.edRetailClub# - #item.edDealType# - #item.edTitle#</a>
	</cfloop>
</cfoutput>
