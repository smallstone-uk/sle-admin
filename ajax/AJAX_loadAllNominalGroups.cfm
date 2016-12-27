<cftry>
	<cfobject component="code/accounts" name="acc">
	<cfsetting showdebugoutput="no">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset nominals = acc.LoadNominalGroupsWithItems(parm)>
	
	<cfoutput>
		<script>
			$(document).ready(function() {
				$('.nmrow-draggable').sortable();
				$('.delGroup').click(function(event) {
					var grpID = $(this).attr("data-grp");
					$.confirmation({
						accept: function() {
							$.ajax({
								type: "POST",
								url: "#parm.url#ajax/AJAX_deleteGroup.cfm",
								data: {"grpID": grpID},
								success: function(data) {
									loadAll();
									loadLeftIndexes();
									$.messageBox("Group Deleted", "success");
								}
							});
						}
					});
					event.preventDefault();
				});
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
				$('.nmrow-item').dblclick(function(event) {
					var row = $(this);
					row.addClass("nmrow-item_active");
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_loadNominalEditBox.cfm",
						data: {
							"nomcode": row.attr("data-code"),
							"nomgroup": row.attr("data-grp")
						},
						success: function(data) {
							$('.nomEditBox').remove();
							$('body').prepend(data);
							$('.nomEditBox').gravity(row);
							$('.nomEditBox').htmlRemove(function() {
								row.removeClass("nmrow-item_active");
							});
						}
					});
				});
				
				$('.nomMan-assignItems').submit(function(event) {
					var name = $(this).find('input[name="grpName"]').val();
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_addNomToGroup.cfm",
						data: $(this).serialize(),
						cache: false,
						success: function(data) {
							$.messageBox("Added to group", "success");
							setTimeout(function() {
								loadGroup(name);
							}, 1000);
						}
					});
					event.preventDefault();
				});
			});
		</script>
		<cfloop array="#nominals#" index="item">
			<div class="nomMan-itemWrapper" data-item="#item.group.name#">
				<span class="nomMan-groupTitle" data-group="#item.group.name#">
					<div class="hr-left"></div>
					<div class="nomMan-groupTitleStr">#item.group.name#</div>
					<div class="hr-right"></div>
				</span>
				<div class="module">
					<form method="post" enctype="multipart/form-data" class="nomMan-assignItems">
						<input type="hidden" name="grpName" value="#item.group.name#" />
						<input type="hidden" name="parent" value="#item.group.id#" />
						<input type="hidden" name="order" value="#ArrayLen(item.items) + 1#" />
						<select name="child" style="float:left;">
							<cfloop array="#acc.LoadNominalsNotInGroup(item.group.id)#" index="n">
								<option value="#n.nomID#">#n.nomCode# - #n.nomTitle#</option>
							</cfloop>
						</select>
						<input type="submit" name="submit" value="Add" style="float: left;height: 26px;border-radius: 3px;line-height: 11px;outline: 0;" />
					</form>
					<button class="button button_white saveGroupItems">Save Order</button>
					<button class="button button_white delGroup" data-grp="#item.group.id#">Delete Group</button>
					<ul class="nmrow-draggable">
						<cfset counter = 0>
						<cfif ArrayLen(item.items)>
							<cfloop array="#item.items#" index="i">
								<li class="nmrow-item" data-code="#i.nomCode#" data-grp="#item.group.id#">
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
			</div>
		</cfloop>
	</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>