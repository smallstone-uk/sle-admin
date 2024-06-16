<cfobject component="code/deals" name="deals">
<cfset parm.retailClub = val(retailClub)>

<cfif parm.retailClub gt -1>
    <cfset clubs = deals.LoadAllDeals(parm.retailClub)>
<cfelse>
    <cfset clubs = deals.LoadLatestDeals(parm.retailClub)>
</cfif>

<cfoutput>
	<cfloop array="#clubs#" index="item">
		<a href="javascript:void(0)" class="deal_item" data-id="#item.edID#">
			#item.edIndex#: #item.edTitle# - #item.edDealType# (#item.edQty#) - &pound;#item.edAmount# #item.edStatus#</a>
	</cfloop>
	#ArrayLen(clubs)# deals.
</cfoutput>
