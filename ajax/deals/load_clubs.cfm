<cfobject component="code/deals" name="deals">

<cfoutput>
	<cfloop array="#deals.LoadRetailClubs()#" index="item">
		<a href="javascript:void(0)" class="club_item" data-id="#item.ercID#">
			#item.ercID# - #item.ercTitle# (#LSDateFormat(item.ercStarts,"dd/mm/yy")# - #LSDateFormat(item.ercEnds,"dd/mm/yy")#)</a>
	</cfloop>
</cfoutput>
