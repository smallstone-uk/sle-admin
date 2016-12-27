<cftry>
<cfobject component="code/accounts" name="acc">
<cfsetting showdebugoutput="no">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.grpName = grpName>
<cfset nominals = acc.LoadSpecificNominalGroupWithItems(parm)>

<cfoutput>
	<script>
		$(document).ready(function() {
			$('.nmrow-draggable').sortable();
			$('.saveGroupItems').click(function(event) {
				var list = $(this).parent('.module').find('.nmrow-draggable');
				var groupName = $(this).parent('.module').prev('.nomMan-groupTitle').find('.nomMan-groupTitleStr').html();
				var params = {
					group: groupName.trim(),
					items: []
				};
				list.find('li').each(function(i, e) {
					var str = $(e).html();
					$(e).find('i').html(i);
					params.items.push({
						code: str.substring(0, str.indexOf(" ")).trim(),
						index: i
					});
				});
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_saveNominalItemsOrder.cfm",
					data: {"params": JSON.stringify(params)},
					success: function(data) {
						$.messageBox("Save Successful", "success");
					}
				});
				event.preventDefault();
			});
		});
	</script>
	<cfloop array="#nominals#" index="item">
		<span class="nomMan-groupTitle">
			<div class="hr-left"></div>
			<div class="nomMan-groupTitleStr">#item.group.name#</div>
			<div class="hr-right"></div>
		</span>
		<div class="module">
			<button class="button saveGroupItems">Save</button>
			<ul class="nmrow-draggable">
				<cfset counter = 0>
				<cfif ArrayLen(item.items)>
					<cfloop array="#item.items#" index="i">
						<li>
							#i.nomCode# - #i.nomTitle#
							<i style="float:right;margin-right:10px;">#counter#</i>
						</li>
						<cfset counter++>
					</cfloop>
				<cfelse>
					<li>No nominal accounts exist in this group yet.</li>
				</cfif>
			</ul>
		</div>
	</cfloop>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>