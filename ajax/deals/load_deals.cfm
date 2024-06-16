<cfobject component="code/deals" name="deals">

<cfset parms = {}>
<cfset parms.retailClub = val(form.retail_Club)>
<cfset parms.status = form.status>
<cfset deals = deals.LoadLatestDeals(parms)>

<cfoutput>
	<cfloop array="#deals#" index="item">
		<a href="javascript:void(0)" class="deal_item" data-id="#item.edID#">
			#item.edIndex#: #item.edTitle# - #item.edDealType# (#item.edQty#) - &pound;#item.edAmount# #item.edStatus#</a>
	</cfloop>
	#ArrayLen(deals)# deals.
</cfoutput>
