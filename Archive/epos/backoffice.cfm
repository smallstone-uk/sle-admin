<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>

<script>
	$(document).ready(function(e) {
		$('.closebackoffice').click(function(e) {
			$.OpenBackoffice();
			e.preventDefault();
		});
		$('.bofunction').click(function(e) {
			var id=$(this).data("id");
			var file=$(this).data("file");
			$('.bofunction').removeClass("active");
			$(this).addClass("active");
			$.LoadBOFunctions(id,file);
			e.preventDefault();
		});
	});
</script>

<cfoutput>
	<div class="backoffice-overlay">
		<div id="boleftcontrols">
			<ul>
				<li><button class="lc-button bofunction" data-id="0" data-file="AJAX_BO_UserAccount.cfm">User Account</button></li>
				<li><button class="lc-button bofunction" data-id="0" data-file="AJAX_BO_Categories.cfm">Categories</button></li>
			</ul>
		</div>
		<div id="bocontent"></div>
		<div id="borightcontrols">
			<div id="commands">
				<ul>
					<li><span class="closebackoffice">Close Back Office</span></li>
				</ul>
			</div>
		</div>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>