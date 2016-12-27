<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset cats = epos.LoadCategoriesForEmployee(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('.categories_item').click(function(event) {
				var file = $(this).data("file");
				var id = $(this).data("id");
				var url = (file.length > 0) ? "ajax/" + file : "ajax/productsByCategory.cfm";
				$.ajax({
					type: "POST",
					url: url,
					data: {
						"catID": id,
						"file": file
					},
					success: function(data) {
						$('.categories_viewer').html(data);
					}
				});
			});
			$('.productSearch').click(function(event) {
				$.ajax({
					type: "GET",
					url: "ajax/productSearch.cfm",
					success: function(data) {
						$('.categories_viewer').html(data);
					}
				});
				event.preventDefault();
			});
			$('.openSale').click(function(event) {
				$.virtualNumpad({
					callback: function(value) {
						$.addToBasket({
							id: 0,
							title: "Open Sale",
							type: "product",
							price: value,
							cashonly: 0
						});
					}
				});
				event.preventDefault();
			});
			$('.loadHome').click(function(event) {
				$.ajax({
					type: "GET",
					url: "ajax/loadHome.cfm",
					success: function(data) {
						$('.categories_viewer').html(data);
					}
				});
				event.preventDefault();
			});
		});
	</script>
	<div class="categories_viewer">
		<cfinclude template="ajax/loadHome.cfm">
	</div>
	<div class="categories">
		<ul class="categories_list">
			<li class="loadHome">Home</li>
			<li class="productSearch">Search Products</li>
			<li class="openSale">Open Sale</li>
			<cfloop array="#cats#" index="item">
				<li data-id="#item.epcID#" data-file="#item.epcFile#" class="categories_item">#item.epcTitle#</li>
			</cfloop>
		</ul>
	</div>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>