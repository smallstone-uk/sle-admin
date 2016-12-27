<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ProductStock3" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset deals=pstock.LoadDealList(parm)>

<script type="text/javascript">
	$(document).ready(function() { 
		$('.editDeal').click(function(e) {
			var id=$(this).attr("data-ID");
			EditDeal(id);
			e.preventDefault();
		});
		$('#btnDelete').click(function(e) {
			DeleteDeal('#listForm');
			e.preventDefault();
		});
		$('#btnPrint').click(function(e) {
			$('#order-list').addClass("noPrint");
			$('#wrapper').addClass("noPrint");
			$('#print-area').removeClass("noPrint");
			PrintDeals("#listForm","#LoadPrint");
			e.preventDefault();
		});
		$('.selectAll').click(function(e) {
			var id=$(this).val();
			if(this.checked) {
				$('.selectitem'+id).prop({checked: true});
				$('#controls').show();
			} else {
				$('.selectitem'+id).prop({checked: false});
				$('#controls').hide();
			};
		});
		$('.item').click(function(e) {
			var show=false;
			$('.item').each(function() {
				if(this.checked) {
					show=true;
				};
			});
			if (show) {
				$('#controls').show();
			} else {
				$('#controls').hide();
			}
		});
	});
</script>

<cfoutput>
	<div style="width:100%;height:550px;overflow-y:scroll;">
		<form method="post" id="listForm">
			<input type="hidden" name="dealLabels" value="true" />
			<table border="1" class="tableList" width="100%">
				<tr>
					<th width="10"></th>
					<th align="left">Record Title</th>
					<th width="10%" align="right">Amount</th>
					<th width="10%">Qty</th>
					<th width="15%">Starts</th>
					<th width="15%">Ends</th>
				</tr>
				<cfset group="">
				<cfloop array="#deals#" index="i">
					<cfif group neq "#i.starts##i.ends#">
						<cfset group="#i.starts##i.ends#">
						<tr>
							<th><input type="checkbox" class="selectAll" value="#group#" /></th>
							<th colspan="5" align="left">#LSDateFormat(i.starts,"dd mmm yy")# - #LSDateFormat(i.ends,"dd mmm yy")#</th>
						</tr>
					</cfif>
					<tr>
						<td><input type="checkbox" name="selectitem" class="item selectitem#group#" value="#i.ID#" /></td>
						<td><a href="##" class="editDeal" title="Edit Deal" data-ID="#i.ID#">#i.recordtitle#</a></td>
						<td align="right">&pound;#DecimalFormat(i.amount)#</td>
						<td align="center">#i.qty#</td>
						<td align="center">#LSDateFormat(i.starts,"dd mmm yy")#</td>
						<td align="center">#LSDateFormat(i.ends,"dd mmm yy")#</td>
					</tr>
				</cfloop>
			</table>
		</form>
	</div>
	<div class="clear" style="padding:10px 0;"></div>
	<div id="controls" style="display:none;">
		<a href="##" class="button red" id="btnDelete">Delete</a>
		<a href="##" class="button" id="btnPrint">Print Labels</a>
	</div>
</cfoutput>



