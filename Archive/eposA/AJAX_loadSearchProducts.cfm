<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.sf_title').focus(function(event) {
				$.virtualKeyboard($(this).val(), function(text) {
					$('.sf_title').val(text);
					$.ajax({
						type: "POST",
						url: "AJAX_searchProductsResults.cfm",
						data: {"title": text},
						success: function(data) {
							$('.sf_results').html(data);
						}
					});
				});
				event.preventDefault();
			});
		});
	</script>
	<h1>Search Products</h1>
	<form method="post" enctype="multipart/form-data" id="SearchForm">
		<input type="text" name="title" placeholder="Product title" class="sf_title" />
	</form>
	<div class="sf_results"></div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>