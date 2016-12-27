<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset load=epos.LoadCats(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('.backtobasket').click(function(e) {
			$.CloseOverlay();
			e.preventDefault();
		});
		$('.function').click(function(e) {
			var id=$(this).attr("data-id");
			var file=$(this).attr("data-file");
			$('#overlay').LoadCatProducts(id,file);
			$('.function').removeClass("active");
			$(this).addClass("active");
			e.preventDefault();
		});
		$('.keyboard').click(function(e) {
			$.virtualKeyboard("This is some sample text.", function(text) {
				$.messageBox(text, "success");
			});
			e.preventDefault();
		});
		$('.searchproducts').click(function(e) {
			$.ajax({
				type: "GET",
				url: "AJAX_loadSearchProducts.cfm",
				success: function(data) {
					$('#overlay').html(data).fadeIn();
				}
			});
			e.preventDefault();
		});
	});
</script>

<cfoutput>
	<ul>
		<!---<li><button class="lc-button keyboard">Virtual Keyboard</button></li>--->
		<li><button class="lc-button backtobasket" style="background:##455288;">Back to Basket</button></li>
		<li><button class="lc-button searchproducts">Search Products</button></li>
		<cfloop array="#load#" index="i">
			<li><button class="lc-button function" data-id="#i.ID#" data-file="#i.file#">#i.title#</button></li>
		</cfloop>
	</ul>
</cfoutput>
