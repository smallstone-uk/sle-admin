<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset employees = epos.LoadEmployees()>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$.tiles();
			
			userLogin = function(employee) {
				$.virtualNumpad({
					autolength: 4,
					wholenumber: true,
					callback: function(pin, methods) {
						$.ajax({
							type: "POST",
							url: "ajax/login.cfm",
							data: {
								"employee": employee,
								"pin": pin
							},
							success: function(data) {
								var response = data.trim();
								if (response == "true") {
									$.get("ajax/loadHomeScreen.cfm", function(data) {
										$('.home_screen_content').html(data);
									});
								}
							}
						});
					}
				});
			}
			
			$('.suc_settings').click(function(event) {
				var obj = $(this);
				$.ajax({
					type: "GET",
					url: "ajax/loadUserPrefs.cfm",
					success: function(data) {
						obj.after(data);
						$('.user_prefs').hide().slideDown(250);
						$('.user_prefs').css({
							"right": "32px",
							"top": "78px"
						});
					}
				});
				event.preventDefault();
			});
			
			$('.suc_profile').click(function(event) {
				var obj = $(this);
				$.ajax({
					type: "GET",
					url: "ajax/loadUserProfile.cfm",
					success: function(data) {
						obj.after(data);
						$('.user_profile').show();
					}
				});
				event.preventDefault();
			});
			
			launchTill = function() {
				fadeDashBoard();
				$('.epos-till-page').addClass('slidePageInFromLeft').removeClass('slidePageBackLeft');
				$.get("till.cfm", function(data) {
					$('.content').html(data);
					//setTimeout(function() {
						$('.content').fadeIn(500);
					//}, 2000);
				});
			}
			
			//$('.newsTile').newsStories();
			//$('.grocerTile').grocerStories();
		});
	</script>
	<div class="style_overide"><cfinclude template="getStyleOveride.cfm"></div>
	<div class="content" style="display:none;"></div>
	<div class="demo-wrapper">
		<div class="s-page epos-main-page"></div>
		<div class="s-page epos-till-page" style="background-color:##3EC7F3 !important;color:##444 !important;">
			<div class="icon-cart"></div>
		</div>
		<div class="s-page product-manager-page">
			<h2 class="page-title">Product Manager</h2>
			<div class="close-button s-close-button">x</div>
			<cfinclude template="office/addProduct.cfm">
		</div>
		<div class="s-page end-of-day-page">
			<cfinclude template="office/declareCash.cfm">
		</div>
		<div class="s-page reminders-page">
			<h2 class="page-title">Reminders</h2>
			<div class="close-button s-close-button">x</div>
		</div>
		<div class="dashboard clearfix">
			<ul class="tiles">
				<div class="startheader">Home</div>
				<div class="startusercontrols">
					<cfif session.user.loggedin>
						<span class="suc_profile">#session.user.firstname# #left(session.user.lastname, 1)#</span>
						<span class="suc_settings icon-cog"></span>
					<cfelse>
						No one's logged in
					</cfif>
				</div>
				<div class="col3 clearfix">
					<div class="colheader">Users</div>
					<cfloop array="#employees#" index="item">
						<li
							class="tile tile-small last tile-5 <cfif item.empID is session.user.id>loggedInTile</cfif>"
							onClick="userLogin(#item.empID#);"
							data-page-type="s-page"
							data-page-name="epos-main-page"
							style="background-color:#item.empAccent#;color:##FFF;<cfif item.empID is session.user.id>border: 5px solid white;</cfif>">
							<div><p><span class="icon-user"></span>#item.empFirstName# #Left(item.empLastName, 1)#</p></div>
						</li>
					</cfloop>
				</div>
				<cfif session.user.loggedin>
					<div class="spacer"></div>
					<div class="col3 clearfix">
						<div class="colheader">Apps</div>
						<li class="tile tile-big tile-6 slideTextLeft" data-page-type="s-page" data-page-name="epos-till-page" onClick="launchTill();">
							<div><p><span class="icon-cart"></span>Till</p></div>
							<div><p>Launch</p></div>
						</li>
						<li class="tile tile-small tile-1 last slideTextUp" data-page-type="s-page" data-page-name="end-of-day-page">
							<div><p>End of Day</p></div>
							<div><p>Launch</p></div>
						</li>
						<li class="tile tile-small tile-1 last slideTextUp" data-page-type="s-page" data-page-name="product-manager-page">
							<div><p>Product Manager</p></div>
							<div><p>Launch</p></div>
						</li>
					</div>
				</cfif>
				<!---<div class="spacer"></div>
				<div class="col3 clearfix">
					<div class="colheader">News</div>
					<li class="tile tile-big tile-6 newsTile" style="background-color:##BE2323;" data-page-type="s-page" data-page-name="news-page" onClick="javascript:void(0);"></li>
					<li class="tile tile-big tile-6 grocerTile" style="background-color:##37BE34;" data-page-type="s-page" data-page-name="grocer-page" onClick="javascript:void(0);"></li>
				</div>--->
			</ul>
		</div>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>