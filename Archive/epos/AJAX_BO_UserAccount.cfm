<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.userID = val(session.user.id)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			/*$('.bo_ua_changePin').click(function(event) {
				$.messageBox("Enter your current pin number", "success", function() {
					$.virtualNumpad("", function(old_pin) {
						$.messageBox("Enter your new pin number", "success", function() {
							$.virtualNumpad("", function(pin_1) {
								$.messageBox("Re-enter your new pin number", "success", function() {
									$.virtualNumpad("", function(pin_2) {
										if (pin_1 == pin_2) {
											$.ajax({
												type: "POST",
												url: "AJAX_BO_UpdateUserPin.cfm",
												data: {
													"oldpin": old_pin,
													"newpin": pin_1
												},
												success: function(data) {
													var result = $.parseReturn(data);
													var msgType = (Number(result.error) == 1) ? "error" : "success";
													$.messageBox(result.msg, msgType);
												}
											});
										}
									}, false, 4);
								}, 1000);
							}, false, 4);
						}, 1000);
					}, false, 4);
				}, 1000);
				event.preventDefault();
			});*/
			$('.bo_ua_changePin').click(function(event) {
				$.virtualNumpad({
					hint: "Enter your current pin number",
					maxlength: 4,
					decimal: false,
					action: function(old_pin) {
						setTimeout(function() {
							$.virtualNumpad({
								hint: "Enter your new pin number",
								maxlength: 4,
								decimal: false,
								action: function(pin_1) {
									setTimeout(function() {
										$.virtualNumpad({
											hint: "Re-enter your new pin number",
											maxlength: 4,
											decimal: false,
											action: function(pin_2) {
												if (pin_1 == pin_2) {
													$.ajax({
														type: "POST",
														url: "AJAX_BO_UpdateUserPin.cfm",
														data: {
															"oldpin": old_pin,
															"newpin": pin_1
														},
														success: function(data) {
															var result = $.parseReturn(data);
															var msgType = (Number(result.error) == 1) ? "error" : "success";
															$.messageBox(result.msg, msgType);
														}
													});
												}
											}
										});
									}, 1000);
								}
							});
						}, 1000);
					}
				});
				event.preventDefault();
			});
		});
	</script>
	<div class="list">
		<a href="javascript:void(0)" class="tile bo_ua_changePin">
			<div class="inner">
				<div class="title">Change Pin</div>
			</div>
		</a>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>