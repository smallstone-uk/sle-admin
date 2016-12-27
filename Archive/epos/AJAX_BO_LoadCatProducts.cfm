<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=epos.LoadCatsProducts(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('.botile').click(function(e) {
			var id=$(this).data("id");
			if (!window.touchhold) {
				//$.LoadProduct(0,id,0,"product",1);
				$(this).removeClass("active");
			}
			e.preventDefault();
		});
		$('.addproduct').click(function(e) {
			var id=$(this).data("catid");
			$('#bocontent').BOAddProductForm(id);
			e.preventDefault();
		});
		$('.botile').touchHold([
			{
				text: "edit title",
				action: function(attrib, elem) {
					$.virtualKeyboard({
						text: attrib.title,
						action: function(title) {
							$.ajax({
								type: "POST",
								url: "AJAX_BO_UpdateProductTitle.cfm",
								data: {
									"prodID": attrib.id,
									"title": title
								},
								success: function(data) {
									$.messageBox(attrib.title + " changed to " + title);
									<cfoutput>$('##bocontent').BOLoadCatProducts("#parm.form.id#");</cfoutput>
								}
							});
						}
					});
				}
			},
			{
				text: "edit price",
				action: function(attrib, elem) {
					$.virtualNumpad({
						action: function(value) {
							$.ajax({
								type: "POST",
								url: "AJAX_BO_UpdateProductPrice.cfm",
								data: {
									"prodID": attrib.id,
									"price": value
								},
								success: function(data) {
									$.messageBox(attrib.title + " price changed to " + nf(value, "str"));
									<cfoutput>$('##bocontent').BOLoadCatProducts("#parm.form.id#");</cfoutput>
								}
							});
						}
					});
				}
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
									$.messageBox(data.title + " deleted", "success");
									<cfoutput>$('##bocontent').BOLoadCatProducts("#parm.form.id#");</cfoutput>
								}
							});
						}
					});
				}
			}
		]);
		$('.botile').click(function(e) {
			e.stopPropagation();
		});
	});
</script>

<cfoutput>
	<div class="list">
		<cfif ArrayLen(load)>
			<cfloop array="#load#" index="i">
				<a href="javascript:void(0)" class="tile botile<cfif ArrayLen(load) gt 12> small</cfif>" data-id="#i.ID#" data-title="#i.title#">
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
	<button class="button addproduct" data-catid="#parm.form.id#">Add</button>
</cfoutput>

