<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset employees = epos.LoadEmployees(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.login').center("left");
			
			var user = 0;
			var pin = "";
			
			$('.user').click(function(event) {
				$('.user').removeClass("user_active");
				$('.user').addClass("user_inactive");
				
				$(this).removeClass("user_inactive");
				$(this).addClass("user_active");
				
				user = $(this).data("id");
				
				$('.user_inactive').fadeTo(100, 0.5);
				$('.user_active').fadeTo(100, 1);
				
				$('.user_inactive').css("top", "0");
				$('.user_active').css({
					"position": "relative",
					"top": "70px"
				});
				
				$('.pin').css("right", "100px");
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
							if (Number(userStruct.id) > 0) {
								// User login valid
								$('.username').html(userStruct.firstname + " " + userStruct.lastname);
								$('.splash, .login_time, .login_date').css("top", "-1000px");
								$.messageBox("Logged in as " + userStruct.firstname + " " + userStruct.lastname, "success");
								$('##basket').ClearBasket();
								
								user = 0;
								pin = "";
								
								$('.user').fadeTo(0, 1).css("top", "0");
								$('.pin').css("right", "-1000px");
							} else {
								$.messageBox("Pin number invalid", "error");
								$('.pin_val').html("&nbsp;");
								pin = "";
							}
						}
					});
				}
			});
			
			$('.login_time').currentTime();
			
			setInterval(function() {
				var hue = 'rgb(' + (Math.floor(Math.random() * 128)) + ',' + (Math.floor(Math.random() * 128)) + ',' + (Math.floor(Math.random() * 128)) + ')';
				$('.splash').css("background", hue);
				$('.user').css("border", "5px solid " + hue);
			}, 4000);
			
			//$('.user').float(1000);
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
		<div class="pin">
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
			<span style="margin-left:115px;">0</span>
		</div>
		<h1 class="login_time">#LSTimeFormat(Now(), "HH:mm")#</h1>
		<h2 class="login_date">#LSDateFormat(Now(), "dddd dd mmmm")#</h2>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>