<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset home = epos.LoadHomeFunctions(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.home_list_item').click(function(event) {
				var index = $(this).data("index");
				switch (index)
				{
					case "reminders":
						$.ajax({
							type: "GET",
							url: "ajax/loadReminderFrame.cfm",
							success: function(data) {
								$('.categories_viewer').html(data);
							}
						});
						break;
					case "barcode":
						$.virtualNumpad({
							wholenumber: true,
							callback: function(value) {
								$.searchBarcode(value);
							}
						});
						break;
					case "savebasket":
						$.ajax({
							type: "GET",
							url: "ajax/saveBasketForLater.cfm",
							success: function(data) {
								$.msgBox("Basket Saved");
								$.ajax({
									type: "GET",
									url: "ajax/emptyBasket.cfm",
									success: function(data) {
										$.loadBasket();
										$.ajax({
											type: "GET",
											url: "ajax/loadHeaderNote.cfm",
											success: function(data) {
												$('.header_note_holder').html(data);
											}
										});
									}
								});
							}
						});
						break;
					case "calendar":
						$.calendar(2015, 2, function(data) {
							$.popup(data);
						});
						break;
					case "opentill":
						$.virtualNumpad({
							autolength: 4,
							wholenumber: true,
							callback: function(pin) {
								$.ajax({
									type: "POST",
									url: "ajax/checkPin.cfm",
									data: {"pin": pin},
									success: function(data) {
										var response = data.trim();
										if (response == "true") {
											$.openTill();
										} else {
											$.msgBox("Invalid Login", "error");
										}
									}
								});
							}
						});
						break;
					case "declarecash":
						$.ajax({
							type: "GET",
							url: "ajax/loadDeclareCash.cfm",
							success: function(data) {
								$.fullscreenPopup(data);
							}
						});
						break;
				}
				event.preventDefault();
			});
		});
	</script>
	<ul class="home_list">
		<cfloop array="#home#" index="item">
			<li class="home_list_item" data-index="#item.ehIndex#">#item.ehTitle#</li>
		</cfloop>
	</ul>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>