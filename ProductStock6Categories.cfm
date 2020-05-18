<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset callback = true>
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset parm.form = form>
	<cfset data = pstock.LoadCategories(parm)>

	<script src="scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
	<script src="scripts/main.js"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('#btnNewCategory').click(function(e) {
				var group = $('#groupID').val();
				$.popupDialog({
					file: "AJAX_loadNewProdCategoryForm",
					data: {"group": group},
					width: 350
				});
				e.preventDefault();
			});
			$('.editCategory').click(function(e) {
				var id = $(this).attr("data-category");
				$.popupDialog({
					file: "AJAX_ProductStock6AmendCategory",
					data: {"id": id},
					width: 500
				});
				e.preventDefault();
			});

/*				$.ajax({
					type: "POST",
					url: "ajax/AJAX_ProductStock6AmendCategory.cfm",
					data: {"id": id},
					cache: false,
					beforeSend: function() {
						$('#FCPopupDialog').remove();
						$('#FCPopupDim').remove();
						$('body').prepend("<div id='FCPopupDim'></div>");
						$('body').prepend("<div id='FCPopupDialog' style='width:" + 500 + "px;'></div>");
					},
					success: function(data) {
						$('#FCPopupDialog').html("<div id='FCPopupDialogInner'>" + data + "</div>");
					}
				});
				e.preventDefault();
			});
*/			$('.btnDelete').click(function(e) {
				var group = $('#groupID').val();
				var category = $(this).attr("data-category");
				var delCat = confirm("delete category? "+category);
				if (delCat) {
					DeleteCategory(category,"#result");
					setTimeout(function(){	// wait for db to update
						LoadGroups('#groupsdiv');
						LoadCategories(group,'#catList');
					},1000); ;
				}
				e.preventDefault();
			});
			$('.categoryItem').click(function(e) {
				var category = $(this).attr("data-category");
				LoadProducts(category,'#prodList');
				e.preventDefault();
			});
		});
	</script>
	<cfoutput>
		<cfif data.categories.recordcount gt 0>
			<table class="tableList" width="100%" border="1">
				<tr>
					<th>
						<a href="javascript:void(0)" id="btnNewCategory" tabindex="-1">
							<img src="images/icons/Add-icon.png" width="24" height="24" />
						</a>
					</th>
					<th></th>
					<th>#data.categories.pgTitle#</th>
					<th align="right">Products</th>
				</tr>
				<cfloop query="data.categories">
					<tr>
						<td align="center">
							<a href="?edit=#pcatID#" class="editCategory" data-category=#pcatID#>
								<img src="images/icons/edit_black.png" width="18" height="18" /></a>
						</td>
						<td align="center">
							<cfif products eq 0><a href="?delete=#pcatID#" class="btnDelete" data-category=#pcatID#>
								<img src="images/icons/bin_black.png" width="16" height="16" /></a>
							</cfif>
						</td>
						<td><a href="##" data-category=#pcatID# class="categoryItem">#pcatTitle#</a></td>
						<td align="right">#products#</td>
					</tr>
				</cfloop>
			</table>
		<cfelse>
			<span class="title2">This group has no categories.</span>
		</cfif>
		<form method="post">
			<input type="hidden" name="groupID" id="groupID" value="#data.groupID#" />
		</form>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
