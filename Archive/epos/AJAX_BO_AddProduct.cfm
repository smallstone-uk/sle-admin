<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>

<cfoutput>
	<script type="text/javascript">
		$(document).ready(function() {
			$('##btnAdd').click(function(e) {
				if ($('input[name="title"]').val().length > 0) {
					$.BOAddProduct("#parm.form.catID#",$('##AddProdForm'));
				}
				e.preventDefault();
			});
			$('input[name="title"]').focus(function(event) {
				$.virtualKeyboard({
					text: $(this).val(),
					action: function(text) {
						$('input[name="title"]').val(text);
					}
				});
			});
			$('input[name="price"]').focus(function(event) {
				$.virtualNumpad({
					text: $(this).val(),
					action: function(text) {
						$('input[name="price"]').val(nf(text, "str"));
					}
				});
			});
		});
	</script>
	<div class="list">
		<h1>Add Product</h1>
		<form method="post" id="AddProdForm">
			<input type="hidden" name="catID" value="#parm.form.catID#">
			<input type="text" name="title" value="" placeholder="Product Title">
			<input type="number" name="price" value="" placeholder="Price">
			<div style="clear:both;"></div>
			<label style="float:left;display: block;line-height: 66px;color: ##000;margin:0 0 0 5px;"><input type="checkbox" name="cashonly" value="1">&nbsp;Cash Only</label>
			<div style="clear:both;"></div>
			<input type="button" id="btnAdd" value="Add">
		</form>
	</div>
</cfoutput>