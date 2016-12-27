<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset samples = epos.LoadCodeSamples(parm)>

<cfoutput>
	<cfloop array="#samples#" index="item">
		<tr>
			<td align="center">
				<button class="del" data-id="#item.csID#">Delete</button>
				<button
					class="edit"
					data-id="#item.csID#"
					data-code="#item.csCode#"
					data-item="#item.csItemID#"
					data-type="#item.csItemType#"
					data-title="#item.csTitle#"
					data-regexp="#item.csRegExp#"
					data-extract="#item.csExtract#"
					data-operator="#item.csOperator#"
					data-modifier="#item.csModifier#"
				>Edit</button>
			</td>
			<td align="center">#item.csID#</td>
			<td align="center">#item.csCode#</td>
			<td align="center">#item.csItemID#</td>
			<td align="center">#item.csItemType#</td>
			<td align="left">#item.csTitle#</td>
			<td align="left">#item.csRegExp#</td>
			<td align="center">#item.csExtract#</td>
			<td align="center">#item.csOperator#</td>
			<td align="right">#item.csModifier#</td>
		</tr>
	</cfloop>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>