<cftry>
<cfobject component="code/deals" name="deals">
<cfset parm = {}>
<cfset parm.form = DeserializeJSON(form.params)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('*').blur();

			$('.PSSearchForm').submit(function(event) {
				$.ajax({
					type: "POST",
					url: "ajax/deals/searchProduct.cfm",
					data: $('.PSSearchForm').serialize(),
					success: function(data) {
						$('.ps_content').html(data);
						$('.product_selector').center("both", "fixed");
						setTimeout(function() {
							$('.product_selector').center("both", "fixed");
						}, 100);
					}
				});

				event.preventDefault();
			});
		});
	</script>
	<div class="ps_controls">
		<span>Scan a barcode</span>
		<span id="psSearchForm">
			<form method="post" enctype="multipart/form-data" class="PSSearchForm">
				<input type="text" name="ps_search_fld" placeholder="Search for a product">
			</form>
		</span>
	</div>
	<div class="ps_content"></div>
</cfoutput>

<cfcatch type="any">
	<cf_dumptofile var="#cfcatch#">
</cfcatch>
</cftry>
