<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.userLevel = session.user.eposLevel>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.header_logout').click(function(event) {
				$.confirmation("Are you sure you want to exit to the home screen?", function() {
					/*$.ajax({
						type: "GET",
						url: "ajax/logout.cfm",
						success: function(data) {*/
							$('.content').fadeOut(500, function() {
								$('.content').html("");
							});
							$.get("ajax/loadHomeScreen.cfm", function(data) {
								$('.home_screen_content').html(data);
							});
						/*}
					});*/
				});
				event.preventDefault();
			});
			
			activeTab = function(a) {
				$('.header_tabs li').removeClass("active");
				$(a).addClass("active");
			}
			
			$('.header_tabs li').click(function(event) {
				var obj = $(this);
				var page = obj.data("page");
				
				switch (page)
				{
					case "refund":
						$.confirmation("Are you sure you want to enter refund mode?", function() {
							$.ajax({
								type: "POST",
								url: "ajax/switchMode.cfm",
								data: {"mode": "rfd"},
								success: function(data) {
									if (data.trim() == "true") {
										$('.backoffice').hide();
										$.loadBasket();
										$.msgBox("You are now in refund mode!");
										activeTab(obj);
										$.ajax({
											type: "GET",
											url: "ajax/getStyleOveride.cfm",
											success: function(data) {
												$('.style_overide').html(data);
											}
										});
									}
								}
							});
						});
						break;
					case "register":
						$.ajax({
							type: "POST",
							url: "ajax/switchMode.cfm",
							data: {"mode": "reg"},
							success: function(data) {
								if (data.trim() == "true") {
									$('.backoffice').hide();
									$.loadBasket();
									$.msgBox("You are now in register mode!");
									activeTab(obj);
									$.ajax({
										type: "GET",
										url: "ajax/getStyleOveride.cfm",
										success: function(data) {
											$('.style_overide').html(data);
										}
									});
								}
							}
						});
						break;
					case "backoffice":
						$.ajax({
							type: "POST",
							url: "ajax/switchMode.cfm",
							data: {"mode": "office"},
							success: function(data) {
								if (data.trim() == "true") {
									if ($.contains(document, $('.backoffice')[0])) {
										$('.backoffice').show();
										activeTab(obj);
									} else {
										$.ajax({
											type: "GET",
											url: "ajax/loadBackOffice.cfm",
											success: function(data) {
												$('body').prepend(data);
												activeTab(obj);
												$.ajax({
													type: "GET",
													url: "ajax/getStyleOveride.cfm",
													success: function(data) {
														$('.style_overide').html(data);
													}
												});
											}
										});
									}
								}
							}
						});
						break;
				}
			});
			
			$('.header_time').currentTime();
			
			$('.header_user').click(function(event) {
				var obj = $(this);
				var offsetRight = $(window).innerWidth() - (obj.offset().left + obj.outerWidth());
				$.ajax({
					type: "GET",
					url: "ajax/loadUserPrefs.cfm",
					success: function(data) {
						$('.content').prepend(data);
						
						$('.user_prefs').css({
							"right": offsetRight,
							"top": "75px"
						});
						
						obj.css("background-color", "##444 !important");
					}
				});
				event.preventDefault();
			});
		});
	</script>
	<cfif session.user.loggedin>
		<div class="header_brand">
			<strong>#application.company.name#</strong>
			<br />
			<span class="header_date">#LSDateFormat(Now(), "ddd dd mmmm yyyy")#&nbsp;&nbsp;&nbsp;</span><span class="header_time">#LSTimeFormat(Now(), "HH:mm")#</span>
		</div>
		<ul class="header_tabs">
			<li <cfif session.epos_frame.mode eq "reg">class="active"</cfif> data-page="register">Register</li>
			<li <cfif session.epos_frame.mode eq "rfd">class="active"</cfif> data-page="refund">Refund</li>
			<li data-page="backoffice">Back Office</li>
			<li data-page="help">Help</li>
		</ul>
		<div class="header_note_holder">
			<cfinclude template="ajax/loadHeaderNote.cfm">
		</div>
		<a href="javascript:void(0)" class="header_logout">Exit</a>
		<div class="header_user">
			#session.user.firstName# #Left(session.user.lastName, 1)#
			<div class="cog"></div>
		</div>
	</cfif>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>