<cfsetting showdebugoutput="no">
<cfobject component="code/stock" name="stock">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfquery name="getStockListFromDB" datasource="#parm.datasource#">
	SELECT ctlStockList
	FROM tblControl
	WHERE ctlID = 1
</cfquery>
<cfset parm.stocklist = getStockListFromDB.ctlStockList>
<cfif Len(parm.stocklist)>
	<cfset stocklist = stock.LoadStockListFromArray(parm)>
<cfelse>
	<strong>Your list is empty.</strong>
	<cfabort>
</cfif>
				
<cfoutput>
	<script>
		$(document).ready(function(e) {
			$('##btnPrintLabels').click(function(event) {
				$('##wrapper').addClass("noPrint");
				$('##print-area').removeClass("noPrint");
				PrintLabels("##listForm","##LoadPrint");
				event.preventDefault();
			});
			$('##btnSaveList').click(function(event) {
				var list = [];
				$('.selectitem').each(function(i, e) {
					if ($(e).prop("checked")) {
						list.push($(e).val());
					}
				});
				$.ajax({
					type: "POST",
					url: "stockSaveList.cfm",
					data: {"list": JSON.stringify(list)},
					success: function(data) {
						$.messageBox("List Saved", "success");
						$.ajax({
							type: "GET",
							url: "stockGetListRaw.cfm",
							success: function(data) {
								$('.stock-wrapper').html(data);
							}
						});
					}
				});
				event.preventDefault();
			});
			$('.selectAllOnList').click(function(event) {
				if (this.checked) {
					$('.selectitem').prop({checked: true});
					$('.selectAllOnList').prop({checked: true});
				} else {
					$('.selectitem').prop({checked: false});
					$('.selectAllOnList').prop({checked: false});
				}
			});
			$('.selectitem').click(function(event) {
				$('.selectAllOnList').prop({checked: true});
				$('.selectitem').each(function(i, e) {
					if (!$(e).prop("checked")) {
						$('.selectAllOnList').prop({checked: false});
					}
				});
			});
		var isEditingTitle = false;
		$('.sod_title').click(function(event) {
			if (!isEditingTitle) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var htmlStr = "<input type='text' size='40' value='" + value + "' class='sod_title_input' data-id='" + prodID + "'>";
				$(this).html(htmlStr);
				$(this).find('.sod_title_input').focus();
			}
			isEditingTitle = true;
		});
		$(document).on("blur", ".sod_title_input", function(event) {
			var value = $(this).val();
			var prodID = $(this).attr("data-id");
			var cell = $(this).parent('.sod_title');
			$.ajax({
				type: "POST",
				url: "saveProductTitle.cfm",
				data: {"title": value, "prodID": prodID},
				success: function(data) {
					cell.html(data.trim());
					isEditingTitle = false;
				}
			});
		});
		});
	</script>
	<div class="module">
		<strong>#stocklist.recordcount# products</strong>
		<a href="##" id="btnPrintLabels" class="button">Print Labels</a>
		<a href="##" id="btnSaveList" class="button">Update List</a>
	</div>
	<div class="module">
		<form method="post" id="listForm">
			<table width="100%" class="tableList" border="1">
				<tr>
					<th width="10"><input type="checkbox" name="selectAllOnList" class="selectAllOnList" checked="checked" style="width:20px; height:20px;"></th>
					<th>Reference</th>
					<th></th>
					<th>Unit Size</th>
					<th>Our Price</th>
					<th>Pack Qty</th>
					<th>Last Purchased</th>
					<th>Valid To</th>
				</tr>
				<cfloop query="stocklist.stockItems">
					<tr class="searchrow" data-title="#prodTitle#" data-prodID="#prodID#">
						<td><input type="checkbox" name="selectitem" class="selectitem item#prodCatID# searchrowselect#prodID#" value="#prodID#" checked="checked"></td>
						<td><a href="stockItems.cfm?ref=#prodRef#">#prodRef#</a></td>
						<td class="sod_title" data-id="#prodID#">#prodTitle#</td>
						<td>#prodUnitSize#</td>
						<td>&pound;#prodOurPrice# #GetToken(" ,PM",prodPriceMarked+1,",")#</td>
						<td>#prodPackQty#</td>
						<td>#LSDateFormat(prodLastBought,"ddd dd-mmm yy")#</td>
						<td>#LSDateFormat(prodValidTo,"ddd dd-mmm")#</td>
					</tr>
				</cfloop>
			</table>
		</form>
	</div>
</cfoutput>