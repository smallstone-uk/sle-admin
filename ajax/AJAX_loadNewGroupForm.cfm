<cfsetting showdebugoutput="no">
<cfobject component="code/accounts" name="acc">
<cfset callback = true>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
	<div id="newGrpPopup" style="display:none;">
		<script>
			$(document).ready(function(e) {
				$('##newGroupForm').submit(function(event) {
					if ($('input[name="name"]').val().length > 0) {
						$.ajax({
							type: "POST",
							url: "#parm.url#ajax/AJAX_addGroup.cfm",
							data: $(this).serialize(),
							success: function(data) {
								if (data.trim() == "1") {
									$.messageBox("Group added", "success");
									$('##newGroupForm')[0].reset();
									$('input[name="name"]').focus();
									loadLeftIndexes();
									loadAll();
								} else {
									$.messageBox("There is already a group with that name", "error");
									$('input[name="name"]').focus();
								}
							}
						});
					} else {
						$.messageBox("You must enter something", "error");
						$('input[name="name"]').focus();
					}
					event.preventDefault();
				});
			});
		</script>
		<form method="post" enctype="multipart/form-data" id="newGroupForm">
			<input type="text" name="name" maxlength="2" />
			<input type="submit" name="submit" value="Add" />
		</form>
	</div>
</cfoutput>