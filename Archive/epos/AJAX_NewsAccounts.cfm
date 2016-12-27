<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>

<script type="text/javascript">
	$(document).ready(function() {
		$('a.backtobasket').click(function(e) {
			$('#overlay').stop().fadeOut();
			e.preventDefault();
		});
	});
</script>

<cfoutput>
	<div class="list">
		<h1>Not Working</h1>
		<div style="clear:both;"></div>
	</div>
</cfoutput>
