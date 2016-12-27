<cftry>
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset stocklist = pstock.LoadSavedStockList(parm)>
	<cfoutput>
		<script>
			$(document).ready(function(e) {
				$('##btnPrintList').click(function(e) {
					$('##header').addClass("noPrint");
					$('##footer').addClass("noPrint");
					$('.form-wrap').addClass("noPrint");
					$('.listcontrols').addClass("noPrint");
					$('##print-area').addClass("noPrint");
					$('##wrapper').removeClass("noPrint");
					$('.stock-wrapper').removeClass("noPrint");
					window.print();
					e.preventDefault();
				});
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
		<div class="module noprint">
			<strong>#stocklist.records# products</strong>
			<a href="##" id="btnPrintList" class="button">Print List</a>
			<a href="##" id="btnPrintLabels" class="button">Print Labels</a>
			<a href="##" id="btnSaveList" class="button">Update List</a>
		</div>
		<div class="module">
			<form method="post" id="listForm">
				<table class="tableList" border="1">
					<tr>
						<th class="noprint" width="10">
							<input type="checkbox" name="selectAllOnList" class="selectAllOnList" checked="checked" style="width:20px; height:20px;"></th>
						<th>Reference</th>
						<th width="250">Description</th>
						<th width="100">Unit Size</th>
						<th>Our Price</th>
						<th class="noprint">Pack Qty</th>
						<th class="noprint">Last Purchased</th>
						<th class="noprint">Valid To</th>
					</tr>
					<cfif stocklist.records gt 0>
						<cfloop query="stocklist.stockItems">
							<tr class="searchrow" data-title="#prodTitle#" data-prodID="#prodID#">
								<td class="noprint">
									<input type="checkbox" name="selectitem" class="selectitem item#prodCatID# searchrowselect#prodID#" value="#prodID#" checked="checked"></td>
								<td><a href="stockItems.cfm?ref=#prodID#">#prodRef#</a></td>
								<td class="sod_title" data-id="#prodID#">#prodTitle#</td>
								<td>#siUnitSize#</td>
								<td>&pound;#siOurPrice# #GetToken(" ,PM",prodPriceMarked+1,",")#</td>
								<td class="noprint">#siPackQty#</td>
								<td class="noprint">#LSDateFormat(prodLastBought,"ddd dd-mmm yy")#</td>
								<td class="noprint">#LSDateFormat(prodValidTo,"ddd dd-mmm")#</td>
							</tr>
						</cfloop>
					</cfif>
				</table>
			</form>
		</div>
	</cfoutput>
	<div id="print-area"><div id="LoadPrint"></div></div>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

