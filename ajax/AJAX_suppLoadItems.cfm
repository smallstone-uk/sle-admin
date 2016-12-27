<!---WORKING VERSION AS OF 18/08/2014--->
<cftry>
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	<cfparam name="transID" default="0">
	<cfobject component="code/accounts" name="accts">
	<cfset callback = 1>
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.nomType = accType>
	<cfset loadNoms = accts.LoadNominalCodes(parm)>
	<cfset nominals = loadNoms.codes>
	<cfset parm.isNew = isNew>
	<cfset parm.type = type>
	<cfif NOT parm.isNew>
		<cfset parm.form = form>
		<cfset parm.tranID = transID>
		<cfset parm.load = accts.LoadTransaction(parm)>
	</cfif>
	<cfset parm.url = application.site.normal>
	
	<cfoutput>
		<script>
			$(document).ready(function() {
				var #ToScript(nominals, "nominals")#;
				var parType = "#parm.type#";
				var isNew = "#parm.isNew#";
				$('.aifnewRow').click(function(event) {
					var prevRow = $(this).parent('tr').prev('tr');
					prevRow.after("<tr>" + $('.aifHiddenRow').html() + "</tr>");
					var newRow = prevRow.next();
					var nomCode = newRow.find('.nom').val().toLowerCase();
					newRow.attr({
						"data-static": "false",
						"data-type": "js",
						"data-nomCode": newRow.find('.nom').val()
					});
					newRow.addClass("aifHover");
					newRow.find('.aifHiddenNom').addClass("aifNomTitleCell").removeClass("aifHiddenNom");
					newRow.find('.aifHiddenVATRate').addClass("aifVATRateCell").removeClass("aifHiddenVATRate");
					if ( nomCode in nominals ) {
						newRow.find('##aifVAT').val( nominals[nomCode].nomvatrate + "%" );
						newRow.find('##aifVATAmount').val( vatAmount(newRow.find('.niAmount').val(), nominals[nomCode].nomvatrate) );
						newRow.find('.aifNomTitleCell').attr("data-nomID", nominals[nomCode].nomid);
					}
					vatTotal();
					netTotal();
					netDiff();
					vatDiff();
					event.preventDefault();
				});
				$(document).on("change", ".nom", function(event) {
					var nomCode = $(this).val().toLowerCase();
					var row = $(this).parent('td').parent('tr');
					if ( nomCode in nominals ) {
						row.find('##aifVAT').val( nominals[nomCode].nomvatrate );
						row.find('##aifVATAmount').val( vatAmount(row.find('.niAmount').val(), nominals[nomCode].nomvatrate) );
						vatTotal();
						netTotal();
						netDiff();
						vatDiff();
					}
					event.preventDefault();
				});
				vatAmount = function(net, vat) {
					return (nf(net, "num") * 100) * (nf(vat, "num") / 100) / 100;
				}
				netTotal = function() {
					var cellsTotal = 0;
					$('.aifNetAmountCell').each(function(i, e) {
						var el = $(e);
						var value = nf(el.html(), "num");
						cellsTotal += (!value) ? (el.find('.niAmount').val() >= 0) ? nf(el.find('.niAmount').val(), "num") : 0 : value;
					});
					$('##aifNetTotalHolder').html( nf(cellsTotal, "abs_str") );
					return nf(cellsTotal, "abs_num");
				}
				vatTotal = function() {
					var cellsTotal = 0;
					$('.aifVatAmountCell').each(function(i, e) {
						var el = $(e);
						var value = nf($(e).html(), "num");
						cellsTotal += (!value) ? (el.find('.vatAmountFld').val() >= 0) ? nf(el.find('.vatAmountFld').val(), "num") : 0 : value;
					});
					$('##aifVatTotalHolder').html( nf(cellsTotal, "abs_str") );
					return nf(cellsTotal, "abs_num");
				}
				netDiff = function() {
					var headType = $('##HeaderType').val();
					var parentNet = nf($('##NetAmount').val(), "abs_num"),
						childNet = nf(netTotal(), "abs_num"),
						diff = (parentNet >= childNet) ? nf(parentNet - childNet, "abs_num") : nf(childNet - parentNet, "abs_num"),
						color;
					if (diff > 0) color = "red"; else color = "green";
					$('##Check').html("<strong style='color:" + color + ";'>" + nf(diff, "str") + "</strong>");
					if (diff > 0) {
						if (headType != "jnl" && headType != "pay") {
							disableSave(true);
							$('.aifCompileWrapper').show();
						}
					} else {
						disableSave(false);
						$('.aifCompileWrapper').hide();
					}
					return diff;
				}
				vatDiff = function() {
					var headType = $('##HeaderType').val();
					var parentVat = nf($('##VATAmount').val(), "abs_num"),
						childVat = nf(vatTotal(), "abs_num"),
						diff = (parentVat >= childVat) ? nf(parentVat - childVat, "abs_num") : nf(childVat - parentVat, "abs_num"),
						color;
					if (diff > 0) color = "red"; else color = "green";
					$('##CheckVat').html("<strong style='color:" + color + ";'>" + nf(diff, "str") + "</strong>");
					if (diff > 0.1) {
						if (headType != "jnl" && headType != "pay") {
							disableSave(true);
							$('.aifCompileWrapper').show();
						}
					} else if (nf(netDiff(), "num") <= 0) {
						disableSave(false);
						$('.aifCompileWrapper').hide();
					}
					return diff;
				}
				$(document).on("blur", ".niAmount", function(event) {
					var net = $(this).val();
					var vatRate = $(this).parent("td").parent("tr").find("##aifVAT").val();
					var vatCell = $(this).parent("td").parent("tr").find("##aifVATAmount");
					vatCell.val( nf(vatAmount(net, vatRate), "str") );
					netTotal();
					vatTotal();
					netDiff();
					vatDiff();
				});
				$(document).on("click", ".delRow", function(event) {
					$(this).parent('td').parent('tr').remove();
					vatTotal();
					netTotal();
					netDiff();
					vatDiff();
					event.preventDefault();
				});
				$(document).on("click", "tr[data-static='false']", function(event) {
					var type = $(this).attr("data-type");
					if (type == "cf") {
						$(this).attr("data-static", "edit");
						$(this).attr("data-type", "js");
						
						var row = $(this);
						var nomCode = row.attr("data-nomCode");
						var netAmnt = row.find('.aifNetAmountCell').html();
						var vatRate = row.find('.aifVATRateCell').html();
						var vatAmount = row.find('.aifVatAmountCell').html();
						
						row.find('.aifNomTitleCell').html( $('.aifHiddenRow').find('.aifHiddenNom').html() );
						row.find('.nom option[value="' + nomCode + '"]').attr("selected", "selected");
						
						row.find('.aifVATRateCell').html( $('.aifHiddenRow').find('.aifHiddenVATRate').html() );
						row.find('##aifVAT').val(nf(vatRate, "num"));
						
						row.find('.aifNetAmountCell').html( $('.aifHiddenRow').find('.aifNetAmountCell').html() );
						row.find('.niAmount').val(nf(netAmnt, "num"));
						
						row.find('.aifVatAmountCell').html( $('.aifHiddenRow').find('.aifVatAmountCell').html() );
						row.find('.vatAmountFld').val(nf(vatAmount, "num"));
					}
				});
				
				vatTotal();
				netTotal();
				netDiff();
				vatDiff();
				
				$('##NetAmount, ##VATAmount').blur(function(event) {
					vatTotal();
					netTotal();
					netDiff();
					vatDiff();
				});
				
				$('.niAmount').tab(function() {
					var row = $(this).parent('td').parent('tr').find('.nom').focus();
				});
			});
		</script>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th></th>
				<th align="left">Transaction Analysis</th>
				<th width="100" align="right">VAT Rate</th>
				<th width="100" align="right">Net Amount</th>
				<th width="100" align="right">VAT Amount</th>
			</tr>
			<tr class="aifHiddenRow" style="display:none;" data-static="true" data-type="js">
				<td width="10"><a href="javascript:void(0)" class="delRow" data-itemID="" tabindex="-1"></a></td>
				<td class="aifHiddenNom">
					<select name="nomID" class="nom">
						<option value="" selected="selected">Select...</option>
						<!---<cfset keys = ListSort(StructKeyList(nominals, ","), "text", "asc", ",")>
						<cfloop list="#keys#" index="key">--->
						<cfloop query="loadnoms.QNominal">
							<option value="#nomCode#">#nomGroup# - #nomCode# - #nomTitle#</option>
						</cfloop>
					</select>
				</td>
				<td align="right" class="aifHiddenVATRate"><input type="text" name="vat" id="aifVAT" value="0%" disabled="disabled" style="text-align:right;" tabindex="-1"></td>
				<td align="right" class="aifNetAmountCell"><input type="text" name="niAmount" class="niAmount" value=""></td>
				<td align="right" class="aifVatAmountCell"><input type="text" name="vatAmount" class="vatAmountFld" id="aifVATAmount" value="0" disabled="disabled" tabindex="-1"></td>
			</tr>
			<cfif StructKeyExists(parm, "load")>
				<cfif ArrayLen(parm.load.items) gt 0>
					<cfloop array="#parm.load.items#" index="item">
						<tr class="aifHover" data-static="false" data-type="cf" data-nomCode="#item.nomCode#">
							<td width="75"><a href="javascript:void(0)" class="delRow" data-itemID="#item.niID#" tabindex="-1" style="margin-right:5px;" title="Delete #item.niID#"></a>#item.niID#</td>
							<td class="aifNomTitleCell" data-nomID="#item.niNomID#" data-recID="#item.niID#">#item.nomTitle#</td>
							<td align="right" class="aifVATRateCell">#DecimalFormat(item.nomVATRate)#%</td>
							<td align="right" class="aifNetAmountCell">#DecimalFormat(abs(item.niAmount))#</td>
							<td align="right" class="aifVatAmountCell">#DecimalFormat(abs(item.vat))#</td>
						</tr>
					</cfloop>
				</cfif>
			</cfif>
			<tr>
				<td colspan="5" class="aifnewRow">Click to add a new row</td>
			</tr>
			<tr>
				<th colspan="3" align="right">Total</th>
				<td align="right">
					<strong id="aifNetTotalHolder">
						<cfif StructKeyExists(parm, "load")>
							#DecimalFormat(parm.load.GrandTotal)#
						<cfelse>
							0.00
						</cfif>
					</strong>
				</td>
				<td align="right">
					<strong id="aifVatTotalHolder">
						<cfif StructKeyExists(parm, "load")>
							#DecimalFormat(parm.load.GrandVatTotal)#
						<cfelse>
							0.00
						</cfif>
					</strong>
				</td>
			</tr>
			<tr>
				<th colspan="3" align="right">Difference</th>
				<td id="Check" align="right"></td>
				<td id="CheckVat" align="right"></td>
			</tr>
		</table>
	</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
