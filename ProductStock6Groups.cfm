<cftry>
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset records = pstock.LoadProductGroups(parm)>

	<script type="text/javascript">
		$(document).ready(function() {
			$('#btnNewGroup').click(function(e) {
				$.popupDialog({
					file: "AJAX_loadNewProdGroupForm",
					width: 350
				});
				e.preventDefault();
			});
			$('.editGroup').click(function(e) {
				var id = $(this).attr("data-group");
				$.popupDialog({
					file: "AJAX_ProductStock6AmendGroup",
					data: {"id": id},
					width: 500
				});
				e.preventDefault();
			});
			$('#btnNewCategory').click(function(e) {
				$.popupDialog({
					file: "AJAX_loadNewProdCategoryForm",
					width: 350
				});
				e.preventDefault();
			});
			$('.btnDelete').click(function(e) {
				var group = $(this).attr("data-group");
				var delGroup = confirm("delete group? "+group);
				if (delGroup) {
					DeleteGroup(group,"#result");
					setTimeout(function(){	// wait for db to update
						LoadGroups('#groupsdiv');
					},1000); ;
				}
				e.preventDefault();
			});
			$('.groupItem').click(function(e) {
				var group = $(this).attr("data-group");
				LoadCategories(group,'#catList');
				e.preventDefault();
			});
		});
	</script>
	<cfoutput>
		<div id="groupList">
			<table class="tableList" width="100%" border="1">
				<tr>
					<th></th>
					<th></th>
					<th>Groups</th>
					<th>Target</th>
					<th>Categories</th>
					<th>Live</th>
				</tr>
				<cfloop query="records.groups">
					<tr>
						<td align="center">
							<a href="?edit=#pgID#" class="editGroup" data-group=#pgID#>
								<img src="images/icons/edit_black.png" width="18" height="18" /></a>
						</td>
						<td align="center">
							<cfif Categories eq 0><a href="?delete=#pgID#" class="btnDelete" data-group=#pgID#>
								<img src="images/icons/bin_black.png" width="18" height="18" /></a>
							</cfif>
						</td>
						<td><a href="##" data-group=#pgID# class="groupItem">#pgTitle#</a></td>
						<td align="right">#pgTarget#%</td>
						<td align="center"><cfif Categories neq 0>#Categories#</cfif></td>
						<td align="center">#pgShow#</td>
					</tr>
				</cfloop>
			</table>
		</div>
		<div id="catList"></div>
		<div id="prodList"></div>
		<div id="cmds" style="clear:both">
		<table>
			<tr><td colspan="2">
				<a href="javascript:void(0)" class="button button_white" id="btnNewGroup" style="float:left;font-size: 14px;margin-left:0;" tabindex="-1">New Group</a>
			</td></tr>
		</table>
		</div>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

