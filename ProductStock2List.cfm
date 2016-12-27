<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=prod.LoadStockByDate(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#btnPrintLabels').click(function(e) {
			PrintLabels("#listForm","#print-area");
			e.preventDefault();
		});
		$('#btnDeals').click(function(e) {
			DealsManager("#listForm");
			e.preventDefault();
		});
		$('#showAllStock').click(function(e) {
			LoadStockByDate("#listForm");
		});
		$('#selectAll').click(function(e) {   
			if(this.checked) {
				$('.selectitem').prop({checked: true});
			} else {
				$('.selectitem').prop({checked: false});
			};
		});
		$('.showlink').click(function(e) {
			var id=$(this).attr("data-ID");
			$('.deallist').hide();
			$('.barcodelist').hide();
			$('.showlink').css("font-weight","normal");
			$(id).show();
			$(this).css("font-weight","bold");
			e.preventDefault();
		});
	});
</script>

<cfoutput>
	<form method="post" id="listForm">
		<input type="hidden" name="supp" value="#parm.form.supp#">
		<input type="hidden" name="pskDate" value="#LSDateFormat(parm.form.pskDate,'yyyy-mm-dd')#">
		<table border="1" class="tableList" width="100%">
			<tr>
				<th colspan="8">
					<label style="float:left;"><input type="checkbox" name="showAllStock" id="showAllStock" value="1"<cfif StructKeyExists(parm.form,"showAllStock")> checked="checked"</cfif> />&nbsp;Show stock from all suppliers</label>
					<input type="button" id="btnPrintLabels" value="Print Labels" />
					<input type="button" id="btnDeals" value="Deals" />
				</th>
			</td>
			<tr>
				<th width="10"><input type="checkbox" id="selectAll" value="1" /></th>
				<th align="left">Title</th>
				<th width="60">Pack Qty</th>
				<th width="60">Pack Price</th>
				<th width="60">Lastest Price</th>
				<th width="60">Vat Rate</th>
				<th width="60">POR</th>
			</td>
			<cfif ArrayLen(load)>
				<cfloop array="#load#" index="i">
					<tr>
						<td><input type="checkbox" name="selectitem" class="selectitem" value="#i.prodID#" /></td>
						<td>
							#i.Title#
							<a href="##" class="showlink" data-ID="##barcodes#i.ID#" style="float: right;margin: 0 0 0 10px;">Barcodes</a>
							<a href="##" class="showlink" data-ID="##deals#i.ID#" style="float: right;margin: 0 0 0 10px;">Deals</a>
						</td>
						<td align="center">#i.Pack#</td>
						<td align="right">&pound;#DecimalFormat(i.PackPrice)#</td>
						<td align="right">&pound;#DecimalFormat(i.ShelfPrice)#</td>
						<td align="right">#i.VatRate*100#%</td>
						<td align="right">#DecimalFormat(i.POR)#%</td>
					</tr>
					<tr id="deals#i.ID#" class="deallist" style="display:none;">
						<td colspan="2">
							<table border="1" class="tableList" width="100%">
								<tr>
									<th align="left">Title</th>
									<th align="right" width="60">Price</th>
								</tr>
								<cfif Arraylen(i.deals)>
									<cfloop array="#i.deals#" index="d">
										<tr>
											<td>#d.Title#</td>
											<td align="right">#d.Price#</td>
										</tr>
									</cfloop>
								<cfelse>
									<tr><td colspan="2">No deals assigned to this product</td></tr>
								</cfif>
							</table>
						</td>
						<td colspan="5"></td>
					</tr>
					<tr id="barcodes#i.ID#" class="barcodelist" style="display:none;">
						<td colspan="2">
							<table border="1" class="tableList" width="100%">
								<tr>
									<th align="left">Barcode</th>
									<th align="right" width="60">Price</th>
								</tr>
								<cfif Arraylen(i.barcodes)>
									<cfloop array="#i.barcodes#" index="b">
										<tr>
											<td>#b.Code#</td>
											<td align="right">#b.Price#</td>
										</tr>
									</cfloop>
								<cfelse>
									<tr><td colspan="2">No barcodes assigned to this product</td></tr>
								</cfif>
							</table>
						</td>
						<td colspan="5"></td>
					</tr>
				</cfloop>
			<cfelse>
				<tr>
					<td colspan="8">No stock has been input today</td>
				</tr>
			</cfif>
		</table>
	</form>
</cfoutput>