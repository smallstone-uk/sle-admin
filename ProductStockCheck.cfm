<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset check=product.CheckProductStock(parm)>
<cfset cats=product.LoadProductCats(parm)>

<style type="text/css">
	.red {border:1px solid #F00 !important;}
</style>

<script type="text/javascript">
	$(document).ready(function() { 
		$('#openCalc').click(function(event) {
			var loadingText="<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...";
			$('#orderOverlay').toggle();
			$.ajax({
				type: 'POST',
				url: 'ProductPriceCalc.cfm',
				data : $('#stockForm').serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText);
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		function LoadCache() {
			$.ajax({
				type: 'POST',
				url: 'ProductStockLoadCache.cfm',
				data : $('#stockForm').serialize(),
				success:function(data){
					$('#cacheList').html(data);
				}
			});
		};
		$('.orderOverlayClose').click(function(event) {
			$("#orderOverlay").fadeOut();
$("#orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
		$('#AddStock').click(function(event) {
			var loadingText="<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...";
			var title=$('#title').val();
			if (title != 0) {
				$.ajax({
					type: 'POST',
					url: 'ProductStockSave.cfm',
					data : $('#stockForm').serialize(),
					beforeSend:function(){
						$('#checkResult').html(loadingText).fadeIn();
					},
					success:function(data){
						$('#checkResult').html(data);
						$('#barcodeCheck').val("");
						$('#barcodeCheck').focus();
						LoadCache();
					},
					error:function(data){
						$('#checkResult').html(data);
					}
				});
			} else {
				$('#title').addClass("red");
			};
			event.preventDefault();
		});
		$('#AddCat').click(function(event) {
			$('#orderOverlay').toggle();
			$.ajax({
				type: 'POST',
				url: 'ProductAddCat.cfm',
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<input type="hidden" name="mode" value="#val(check.mode)#">
	<input type="hidden" name="prodID" value="#val(check.ID)#">
	<input type="hidden" name="stockID" value="#val(check.StockID)#">
	<div class="clear" style="padding:5px 0;"></div>
	<table border="1" class="tableList" width="100%">
		<tr>
			<th>Title</th>
			<th>Category</th>
			<th width="40">Pack</th>
			<th width="60">Size</th>
			<th width="40">Pack Price</th>
			<th width="40">Shelf Price</th>
			<th width="40">Vat Rate</th>
			<th width=""></th>
		</tr>
		<tr>
			<td><input type="text" id="title" name="prodTitle" value="#check.title#" style="width:95%;"></td>
			<td id="catList" width="150">
				<select name="catID" class="type">
					<option value="0"<cfif check.CatID eq 0> selected="selected"</cfif> style="text-transform:capitalize;">Select...</option>
					<cfloop array="#cats#" index="i">
						<option value="#i.ID#"<cfif check.CatID eq i.ID> selected="selected"</cfif> style="text-transform:capitalize;">#i.Title#</option>
					</cfloop>
				</select>
			</td>
			<td><input type="text" name="pskPack" value="#check.Pack#" style="width:60px;"></td>
			<td><input type="text" name="prodSize" value="#check.Size#" style="width:80px;"></td>
			<td><input type="text" name="pskPackPrice" value="#check.PackPrice#" style="width:60px;"></td>
			<td><input type="text" name="pskShelfPrice" id="ShelfPrice" value="#check.Price#" style="width:60px;"></td>
			<td>
				<select name="pskVatRate">
					<cfset vatKeys=ListSort(StructKeyList(application.site.vat,","),"numeric","asc")>
					<cfloop list="#vatKeys#" delimiters="," index="key">
						<cfif key gt 0>
							<cfset vatItem=StructFind(application.site.vat,key)>
							<option value="#vatItem#"<cfif check.VatRate eq vatItem> selected="selected"</cfif>>#vatItem*100#%</option>
						</cfif>
					</cfloop>
				</select>
			</td>
			<td><input type="button" id="AddStock" value="Save" style="float:left;padding:10px 20px;"></td>
		</tr>
		<tr>
			<th colspan="8">
				<a href="##" id="openCalc" class="button" style="float:left;color:##fff;">Price Calculator</a>
				<a href="##" id="AddCat" class="button" style="float:left;color:##fff;">Add Category</a>
			</th>
		</tr>
	</table>
</cfoutput>
<script type="text/javascript">
	$(".type").chosen({width: "150px"});
</script>

