<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>

<cfoutput>
	<script type="text/javascript">
		$(document).ready(function() {
			$('##btnAdd').click(function(e) {
				if ($('input[name="title"]').val().length > 0) {
					$.AddProduct("#parm.form.catID#","#parm.form.file#",$('##AddProdForm'));
				}
				e.preventDefault();
			});
			$('input[name="title"]').focus(function(event) {
				$.virtualKeyboard($(this).val(), function(text) {
					$('input[name="title"]').val(text);
				});
			});
			$('input[name="price"]').focus(function(event) {
				$.virtualNumpad($(this).val(), function(text) {
					$('input[name="price"]').val(nf(text, "str"));
				});
			});
		});
	</script>
	<div class="list">
		<h1>Add Product</h1>
		<form method="post" id="AddProdForm">
			<input type="hidden" name="catID" value="#parm.form.catID#">
			<input type="hidden" name="file" value="#parm.form.file#">
			<input type="text" name="title" value="" placeholder="Product Title">
			<input type="number" name="price" value="" placeholder="Price">
			<label style="display: block;line-height: 66px;color: ##fff;margin:0 0 0 5px;"><input type="checkbox" name="cashonly" value="1">&nbsp;Cash Only</label>
			<div style="clear:both;"></div>
			<input type="button" id="btnAdd" value="Add">
		</form>
	</div>
</cfoutput>