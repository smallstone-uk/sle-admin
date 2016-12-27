<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<!---<cfdump var="#form#" label="get pub form" expand="false">--->
<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.pub=psPubID>
<cfset parm.type=psType>
<cfif StructKeyExists(form,"psIssue")><cfset parm.issue=psIssue></cfif>
<cfif StructKeyExists(form,"psSubType")><cfset parm.psSubType=psSubType></cfif>
<cfset parm.delDate=psDate>
<cfset pub=func.GetPub(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function DiscTypeChange() {
			var type=$('#disTypeList').val();
			if (type == "pc") {
				$('#DiscTypeTip').html("%");
			} else {
				$('#DiscTypeTip').html("-");
			}
		};
		$('#disTypeList').change(function() {
			DiscTypeChange();
		});
		$('#psIssue').blur(function() {
			$.ajax({
				type: 'POST',
				url: 'GetPub.cfm',
				data : $('#stockForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#pub').html(data);
					$('#UpdateStock').show();
					$('#loading').fadeOut();
					$('#qty').focus();
				},
				error:function(data){
					$('#pub').html(data);
					$('#UpdateStock').hide();
					$('#loading').fadeOut();
				}		
			});
		});
		DiscTypeChange();
		<!---<cfif pub.group is "news">
			$('#qty').focus();
		<cfelse>
			$('#psIssue').focus();
		</cfif>--->
	});
</script>
<cfoutput>
<input type="hidden" name="mode" value="#pub.mode#">
<input type="hidden" name="psID" value="#pub.stockID#">
<input type="hidden" name="psArrivalDayINT" value="#pub.dayINT#">
<input type="hidden" name="psArrivalDay" value="#pub.thisDay#" class="small" style="width:25px;">
<cfif len(pub.warning)><div class="warning"><b>Warning:</b> #pub.warning#</div></cfif>
<table border="0" cellpadding="2" cellspacing="0">
	<tr>
		<td>Type</td>
		<td>
			<select name="psSubType">
				<option value="normal"<cfif pub.psSubType eq "normal"> selected="selected"</cfif>>Normal</option>
				<option value="recharge"<cfif pub.psSubType eq "recharge"> selected="selected"</cfif>>Recharge</option>
				<option value="misc"<cfif pub.psSubType eq "misc"> selected="selected"</cfif>>Misc</option>
			</select>
		</td>
	</tr>
	<tr>
		<td width="120">Issue</td>
		<td><input type="text" name="psIssue" id="psIssue" value="#pub.issue#" class="small" style="text-transform:uppercase;width:60px;"></td>
	</tr>
	<tr>
		<td>Qty</td>
		<td><input type="text" name="psQty" value="#pub.qty#" class="small" id="qty" style="width:60px;"></td>
	</tr>
	<tr>
		<td>Qty Short</td>
		<td><input type="text" name="psShort" value="#pub.psShort#" class="small" id="psShort" style="width:60px;"></td>
	</tr>
	<tr>
		<td>Retail</td>
		<td><span class="form-tip">&pound;</span><input type="text" name="psRetail" value="#pub.retail#" class="small" style="width:60px;border-radius: 0 3px 3px 0;"></td>
	</tr>
	<tr>
		<td>Discount</td>
		<td><span class="form-tip" id="DiscTypeTip"></span><input type="text" name="psDiscount" value="#pub.discount#" class="small" style="width:60px;border-radius: 0 3px 3px 0;"></td>
	</tr>
	<tr>
		<td>Discount Type</td>
		<td>
			<select name="psDiscountType" id="disTypeList">
				<option value="flat"<cfif pub.discountType eq "flat"> selected="selected"</cfif>>Flat</option>
				<option value="pc"<cfif pub.discountType eq "pc"> selected="selected"</cfif>>Percent</option>
			</select>
		</td>
	</tr>
	<tr>
		<td>Vat</td>
		<td>
			<cfif StructKeyExists(application.site,"VAT")>
				<cfset keys=ListSort(StructKeyList(application.site.VAT,","),"text","asc",",")>
				<select name="psVAT" id="vat">
					<cfloop list="#keys#" index="key">
						<cfset vat=StructFind(application.site.VAT,key)>
						<option value="#key#"<cfif val(pub.pubVATCode) eq key> selected="selected"</cfif>>#DecimalFormat(vat*100)#</option>
					</cfloop>
				</select>
			</cfif>
		</td>
	</tr>
	<tr>
		<th colspan="2" style="padding: 10px 0;text-align: left;border-bottom: 1px solid ##CCC;">Part Works</th>
	</tr>
	<tr><td colspan="2"></td></tr>
	<tr>
		<td>Retail</td>
		<td><span class="form-tip">&pound;</span><input type="text" name="psPWRetail" value="#pub.pwRetail#" class="small" style="width:60px;border-radius: 0 3px 3px 0;"></td>
	</tr>
	<tr>
		<td>Vat Rate</td>
		<td>
			<span class="form-tip">%</span>
			<cfif StructKeyExists(application.site,"VAT")>
				<select name="psPWVat" id="pwvat">
					<cfset keys=ListSort(StructKeyList(application.site.VAT,","),"text","asc",",")>
					<cfloop list="#keys#" index="key">
						<cfset vat=StructFind(application.site.VAT,key)>
						<option value="#vat#"<cfif pub.Vat eq key> selected="selected"</cfif>>#DecimalFormat(vat*100)#</option>
					</cfloop>
				</select>
			</cfif>
		</td>
	</tr>
</table>
</cfoutput>
<script type="text/javascript">
	$("#disTypeList").chosen({width: "120px",disable_search_threshold: 10});
	$("#vat").chosen({width: "120px",disable_search_threshold: 10});
	$("#pwvat").chosen({width: "120px",disable_search_threshold: 10});
</script>
