<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=epos.LoadCatsProducts(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('.tile').click(function(e) {
			var id=$(this).data("id");
			if (!window.touchhold) {
				$.LoadProduct(0,id,0,"product",1);
			}
			e.preventDefault();
		});
		$('.backtobasket').click(function(e) {
			$.CloseOverlay();
			e.preventDefault();
		});
		$('.addproduct').click(function(e) {
			var id=$(this).data("catid");
			var file=$(this).data("file");
			$('#overlay').AddProductForm(id,file);
			e.preventDefault();
		});
		$('.tile').touchHold([
			{
				text: "edit",
				action: function(attrib) {console.log("edit");}
			},
			{
				text: "remove",
				action: function(data, obj) {
					$.confirmation({
						message: "<h1>Confirm</h1>Are you sure you want to delete this product?",
						action: function() {
							$.ajax({
								type: "POST",
								url: "AJAX_deleteCatProduct.cfm",
								data: {"catProdID": data.id},
								success: function(a) {
									obj.remove();
									$.messageBox(data.title + " deleted", "success");
								}
							});
						}
					});
				}
			}
		]);
		$('.tile').click(function(e) {
			e.stopPropagation();
		});
	});
</script>

<cfoutput>
	<div class="list">
		<cfif ArrayLen(load)>
			<cfloop array="#load#" index="i">
				<a href="javascript:void(0)" class="tile" data-id="#i.ID#" data-title="#i.title#">
					<div class="inner">
						<div class="title">#i.title#</div>
						<cfif i.price neq 0><div class="price">&pound;#DecimalFormat(i.price)#</div></cfif>
						<cfif i.cashonly is 1><div class="cashonly">(Cash Only)</div></cfif>
					</div>
				</a>
			</cfloop>
		<cfelse>
			<p>No products found in this category (#parm.form.id#)</p>
		</cfif>
		<div style="clear:both;"></div>
	</div>
	<button class="button addproduct" data-catid="#parm.form.id#" data-file="#parm.form.file#">Add</button>
</cfoutput>

