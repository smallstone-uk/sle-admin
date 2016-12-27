<cftry>
<cfobject component="code/deals" name="deals">
<cfset parm = {}>
<cfset parm.form = form>
<cfset club = deals.LoadClubByID(parm.form.id)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('##editor_title').html("Edit Retail Club");
			$('*').blur();

			$('.ClubFormHeader').submit(function(event) {
				$.ajax({
					type: "POST",
					url: "ajax/deals/saveClub.cfm",
					data: $('.ClubFormHeader').serialize(),
					success: function(data) {
						$.messageBox("Retail Club Saved");
						load_clubs();
					}
				});
				event.preventDefault();
			});

			$('.ctrlSaveChanges').click(function(event) {
				$('.ClubFormHeader').submit();
				event.preventDefault();
			});
		});
	</script>
	<form method="post" enctype="multipart/form-data" class="ClubFormHeader">
		<input type="hidden" name="erc_id" value="#club.ercID#" />
		<table class="deal_form" width="100%" border="0">
			<tr>
				<td align="left" width="100">Title</td>
				<td><input type="text" name="erc_title" placeholder="Club title" value="#club.ercTitle#"></td>
			</tr>
			<tr>
				<td align="left">Issue Number</td>
				<td><input type="text" name="erc_issue" placeholder="Issue number" value="#club.ercIssue#"></td>
			</tr>
			<tr>
				<td align="left">Starts</td>
				<td><input type="date" name="erc_starts" placeholder="Starting date" value="#LSDateFormat(club.ercStarts, 'yyyy-mm-dd')#"></td>
			</tr>
			<tr>
				<td align="left">Ends</td>
				<td><input type="date" name="erc_ends" placeholder="Ending date" value="#LSDateFormat(club.ercEnds, 'yyyy-mm-dd')#"></td>
			</tr>
		</table>
	</form>
	<a href="javascript:void(0)" class="sleui-button ctrlSaveChanges" style="margin-top:10px;">Save Changes</a>
</cfoutput>

<cfcatch type="any">
	<cf_dumptofile var="#cfcatch#">
</cfcatch>
</cftry>
