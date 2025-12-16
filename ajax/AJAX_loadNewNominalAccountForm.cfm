<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfobject component="code/core" name="core">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset groups = acc.LoadAllNominalGroups(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('input[name="cancel"]').click(function(event) {
				loadAll();
				$('body').scrollTo(0, 1000, {
					easing: "easeInOutCubic"
				});
				$('##nomMan-topContent').slideUp(500, "easeInOutCubic", function() {
					$(this).html("");
				});
				event.preventDefault();
			});
			$('##newNomAccForm').submit(function(event) {
				var title = $('input[name="title"]').val();
				var code = $('input[name="code"]').val();
				if (title.length > 0 && code.length > 0) {
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_addNewNominalAccount.cfm",
						data: $(this).serialize(),
						success: function(data) {
							$.messageBox($.parseReturn(data).message, $.parseReturn(data).type);
							$('body').scrollTo(0, 1000, {
								easing: "easeInOutCubic"
							});
							$('##nomMan-topContent').slideUp(500, "easeInOutCubic", function() {
								$(this).html("");
							});
							loadAll();
						}
					});
				} else {
					$.messageBox("You must enter a title and code.", "error");
				}
				event.preventDefault();
			});
		});
	</script>
	<h1 class="formHeader">Add Nominal Account</h1>
	<form method="post" enctype="multipart/form-data" id="newNomAccForm">
		<table class="tableList" width="100%" border="0" style="border:none;">
			<tr>
				<th align="left" class="clear">Title</th>
				<td><input type="text" name="title" style="width:300px;" /></td>
			</tr>
			<tr>
				<th align="left" class="clear">Code</th>
				<td><input type="text" name="code" style="text-transform:uppercase;" /></td>
			</tr>
			<tr>
				<th align="left" class="clear">Type</th>
				<td>
					<select name="type">
						<option value="sales">Sales</option>
						<option value="purch">Purchases</option>
						<option value="nom">Nominal</option>
					</select>
				</td>
			</tr>
			<tr>
				<th align="left" class="clear">Group</th>
				<td>
					<select name="group">
						<cfloop array="#groups#" index="i">
							<option value="#i.ngCode#">#i.ngCode#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<th align="left" class="clear">Class</th>
				<td>
					<select name="class">
						<option value="shop">Shop</option>
						<option value="news">News</option>
						<option value="ext">Ext</option>
						<option value="other">Other</option>
					</select>
				</td>
			</tr>
			<tr>
				<th align="left" class="clear">VAT</th>
				<td>
					<select name="vat">
						<cfloop array="#core.GetVatTypes()#" index="item">
							<option value="#item.vatCode#">#item.vatTitle# - #DecimalFormat(item.vatRate)#%</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<input type="submit" name="add" value="Add" style="margin-top:10px;float:right;" />
		<input type="button" name="cancel" class="button_white" value="Cancel" style="margin-top:10px;float:right;" />
	</form>
</cfoutput>