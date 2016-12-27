<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset employees = epos.LoadEmployees(parm)>
<cfdump var="#employees#" label="employees" expand="no">

<cfoutput>
	<script>
		$(document).ready(function(e) {
			/*$.virtualKeyboard(function(text) {
				console.log(text);
			});*/
		
			$('.login').center();
		    $('.pin').center("left");
			
			var user = 0;
			var pin = "";
			
			$('.user').click(function(event) {
				user = $(this).data("id");
				$('.user').fadeTo(100, 0.5);
				$(this).fadeTo(100, 1);
				$('.login').animate({
					"top": "50px"
				}, 250, function() {
					$('.pin').fadeIn(250);
				});
			});
			
			$('.pin span').click(function(event) {
				pin += $(this).html();
				$('.pin_val').html( $('.pin_val').html() + "&##9679;" );
				if (pin.length == 4) {
					$.ajax({
						type: "POST",
						url: "AJAX_verifyPin.cfm",
						data: {
							"user": user,
							"pin": pin
						},
						success: function(data) {
							var userStruct = $.parseReturn(data);
							console.log(userStruct);
							if (Number(userStruct.id) > 0) {
								// User login valid
								$('.username').html(userStruct.firstname + " " + userStruct.lastname);
								$('.splash').fadeOut(250);
								$.messageBox("Logged in as " + userStruct.firstname + " " + userStruct.lastname, "success");
								$('##basket').ClearBasket();
								
								user = 0;
								pin = "";
								
								$('.user').fadeTo(0, 1);
								$('.login').css("top", Math.max(0, (($(window).height() - $('.login').outerHeight()) / 2) + $(window).scrollTop()) + "px");
								$('.pin').hide();
							} else {
								$.messageBox("Pin number invalid", "error");
								$('.pin_val').html("&nbsp;");
								pin = "";
							}
						}
					});
				}
			});
		});
	</script>
	<div class="splash"<cfif session.user.loggedIn> style="display:none;"</cfif>>
		<div class="login">
			<ul>
				<cfloop array="#employees#" index="i">
					<li class="user" data-id="#i.id#">#i.firstName# #Left(i.lastname, 1)#</li>
				</cfloop>
			</ul>
		</div>
		<div class="pin" style="display:none;">
			<div class="pin_val">&nbsp;</div>
			<span>7</span>
			<span>8</span>
			<span>9</span>
			<span>4</span>
			<span>5</span>
			<span>6</span>
			<span>1</span>
			<span>2</span>
			<span>3</span>
			<span style="margin-left:106px;">0</span>
		</div>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>