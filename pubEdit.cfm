<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/publications" name="pubs">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.pubID=pubID>
<cfset parm.type="publication">
<cfset load=pubs.LoadPublication(parm)>
<cfset types=pubs.LoadPubTypes(parm)>
<cfset codes=pubs.LoadPubBarcodes(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadEdit(resp,cl,tab) {
			$.ajax({
				type: 'POST',
				url: 'pubEdit.cfm',
				<cfoutput>data : {"pubID":"#parm.pubID#"},</cfoutput>
				beforeSend:function(){
					$("#orderOverlay").css("position", "fixed");
					$("#orderOverlay").fadeIn();
					$("#orderOverlay-ui").fadeIn();
					$('#orderOverlayForm-inner').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					$('#orderOverlayForm').center();
					$('#saveResults').removeClass("success");
					$('#saveResults').removeClass("error");
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
					$("#pubtabs").tabs({ active: tab });
					$('#saveResults').html(resp).fadeIn().addClass(cl);
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 3000 );
				}
			});
		}
		$('#btnSave').click(function(e) {
			$.ajax({
				type: 'POST',
				url: 'pubEditAction.cfm',
				data : $('#editPubForm').serialize(),
				success:function(data){
					LoadEdit('Saved Changes','success',0);
				}
			});
			e.preventDefault();
		});
		$('#btnDelCode').click(function(e) {
			$.ajax({
				type: 'POST',
				url: 'pubEditDelCodeAction.cfm',
				data : $('#editPubForm').serialize(),
				success:function(data){
					LoadEdit('Deleted','success',1);
				}
			});
			e.preventDefault();
		});
		$('#btnAddCode').click(function(e) {
			$.ajax({
				type: 'POST',
				url: 'pubEditAddCodeAction.cfm',
				data : $('#editPubForm').serialize(),
				dataType: "json",
				success:function(data){
					LoadEdit(data.msg,data.status,1);
				}
			});
			e.preventDefault();
		});
		$("#pubtabs").tabs();
	});
</script>

<cfoutput>
	<h1 style="width: 406px;">#load.Title#</h1>
	<form method="post" id="editPubForm">
		<input type="hidden" name="pubID" value="#load.ID#">
		<div id="saveResults" style="display:none;"></div>
		<div id="pubtabs">
			<ul>
				<li><a href="##details">Details</a></li>
				<li><a href="##barcodes">Barcodes</a></li>
			</ul>
			<div id="details">
				<table border="1" class="tableList" width="100%">
					<tr>
						<th align="left" width="90">Full Title</th>
						<td><input type="text" name="pubTitle" value="#load.Title#" style="width: 220px;"></td>
					</tr>
					<tr>
						<th align="left">Supplier Title</th>
						<td><input type="text" name="pubShortTitle" value="#load.ShortTitle#" style="width: 220px;" placeholder="(Optional)"></td>
					</tr>
					<tr>
						<th align="left">Round Title</th>
						<td><input type="text" name="pubRoundTitle" value="#load.RoundTitle#" style="width: 220px;" placeholder="(Optional)"></td>
					</tr>
					<tr>
						<th align="left">Supplier</th>
						<td>
							<select name="pubWholesaler" class="select" data-placeholder="Select...">
								<option value=""></option>
								<option value="WHS"<cfif load.Wholesaler is "WHS"> selected="selected"</cfif>>WHS</option>
								<option value="Dash"<cfif load.Wholesaler is "Dash"> selected="selected"</cfif>>Dash</option>
							</select>
						</td>
					</tr>
					<tr>
						<th align="left">Group</th>
						<td>
							<select name="pubGroup" class="select" data-placeholder="Select...">
								<option value=""></option>
								<option value="News"<cfif load.Group is "News"> selected="selected"</cfif>>News</option>
								<option value="Magazine"<cfif load.Group is "Magazine"> selected="selected"</cfif>>Magazine</option>
							</select>
						</td>
					</tr>
					<tr>
						<th align="left">Type</th>
						<td>
							<select name="pubType" class="select" data-placeholder="Select...">
								<option value=""></option>
								<cfloop array="#types#" index="i">
									<option value="#i.title#"<cfif load.Type is i.title> selected="selected"</cfif> style="text-transform:capitalize;">#LCase(i.title)#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<th align="left">Arrival Day</th>
						<td>
							<select name="pubArrival" class="select" data-placeholder="Select..."<cfif load.type is "morning"> disabled="disabled"</cfif>>
								<option value=""></option>
								<option value="1"<cfif load.Arrival is 1> selected="selected"</cfif>>Monday</option>
								<option value="2"<cfif load.Arrival is 2> selected="selected"</cfif>>Tuesday</option>
								<option value="3"<cfif load.Arrival is 3> selected="selected"</cfif>>Wednesday</option>
								<option value="4"<cfif load.Arrival is 4> selected="selected"</cfif>>Thursday</option>
								<option value="5"<cfif load.Arrival is 5> selected="selected"</cfif>>Friday</option>
								<option value="6"<cfif load.Arrival is 6> selected="selected"</cfif>>Saturday</option>
								<option value="7"<cfif load.Arrival is 7> selected="selected"</cfif>>Sunday</option>
							</select>
						</td>
					</tr>
					<tr>
						<th align="left">Price</th>
						<td><input type="text" name="pubPrice" value="#DecimalFormat(load.Price)#"></td>
					</tr>
					<!---<tr>
						<th align="left">Vat</th>
						<td><input type="text" name="pubVat" value="#DecimalFormat(load.Vat)#"></td>
					</tr>--->
					<tr>
						<th align="left">Vat</th>
						<td>
							<cfset vatKeys=ListSort(StructKeyList(application.site.vat,","),"numeric","asc")>
							<select name="pubVATCode" class="select" data-placeholder="Select...">
								<cfloop list="#vatKeys#" delimiters="," index="key">
									<cfif key gt 0>
										<cfset vatItem=StructFind(application.site.vat,key)>
										<option value="#key#"<cfif key is load.pubVATCode> selected="selected"</cfif>>#vatItem*100#%</option>
									</cfif>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<th align="left">Discount</th>
						<td><input type="text" name="pubDiscount" value="#NumberFormat(load.Discount,'0.0000')#"></td>
					</tr>
					<tr>
						<th align="left">Discount Type</th>
						<td>
							<select name="pubDiscType" class="select" data-placeholder="Select...">
								<option value=""></option>
								<option value="flat"<cfif load.DiscountType is "flat"> selected="selected"</cfif>>Flat amount</option>
								<option value="pc"<cfif load.DiscountType is "pc"> selected="selected"</cfif>>percentage</option>
							</select>
						</td>
					</tr>
					<tr>
						<th align="left">Price (part works)</th>
						<td><input type="text" name="pubPWPrice" value="#DecimalFormat(load.PWPrice)#"></td>
					</tr>
					<tr>
						<th align="left">Vat (part works)</th>
						<td><input type="text" name="pubPWVat" value="#DecimalFormat(load.PWVat)#"></td>
					</tr>
					<tr>
						<th align="left">Days on Sale</th>
						<td>
							<cfif load.group is "news">
								<cfif load.type is "morning">
									<table>
										<tr>
											<td><label><input type="checkbox" name="pubMon" value="1"<cfif load.Mon is 1> checked="checked"</cfif>><br><strong>Mon</strong></label></td>
											<td><label><input type="checkbox" name="pubTue" value="1"<cfif load.Tue is 1> checked="checked"</cfif>><br><strong>Tue</strong></label></td>
											<td><label><input type="checkbox" name="pubWed" value="1"<cfif load.Wed is 1> checked="checked"</cfif>><br><strong>Wed</strong></label></td>
											<td><label><input type="checkbox" name="pubThu" value="1"<cfif load.Thu is 1> checked="checked"</cfif>><br><strong>Thu</strong></label></td>
											<td><label><input type="checkbox" name="pubFri" value="1"<cfif load.Fri is 1> checked="checked"</cfif>><br><strong>Fri</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubSat" value="0" disabled="disabled"><br><strong>Sat</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubSun" value="0" disabled="disabled"><br><strong>Sun</strong></label></td>
										</tr>
									</table>
								<cfelseif (load.type is "saturday" OR load.type is "weekend">
									<table>
										<tr>
											<td><label style="color:##666;"><input type="checkbox" name="pubMon" value="0" disabled="disabled"><br><strong>Mon</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubTue" value="0" disabled="disabled"><br><strong>Tue</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubWed" value="0" disabled="disabled"><br><strong>Wed</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubThu" value="0" disabled="disabled"><br><strong>Thu</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubFri" value="0" disabled="disabled"><br><strong>Fri</strong></label></td>
											<td><label><input type="checkbox" name="pubSat" value="1"<cfif load.Sat is 1> checked="checked"</cfif>><br><strong>Sat</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubSun" value="0" disabled="disabled"><br><strong>Sun</strong></label></td>
										</tr>
									</table>
								<cfelseif load.type is "sunday">
									<table>
										<tr>
											<td><label style="color:##666;"><input type="checkbox" name="pubMon" value="0" disabled="disabled"><br><strong>Mon</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubTue" value="0" disabled="disabled"><br><strong>Tue</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubWed" value="0" disabled="disabled"><br><strong>Wed</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubThu" value="0" disabled="disabled"><br><strong>Thu</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubFri" value="0" disabled="disabled"><br><strong>Fri</strong></label></td>
											<td><label style="color:##666;"><input type="checkbox" name="pubSat" value="0" disabled="disabled"><br><strong>Sat</strong></label></td>
											<td><label><input type="checkbox" name="pubSun" value="1"<cfif load.Sun is 1> checked="checked"</cfif>><br><strong>Sun</strong></label></td>
										</tr>
									</table>
								<cfelse>
									<table>
										<tr>
											<td><label><input type="checkbox" name="pubMon" value="1"<cfif load.Mon is 1> checked="checked"</cfif>><br><strong>Mon</strong></label></td>
											<td><label><input type="checkbox" name="pubTue" value="1"<cfif load.Tue is 1> checked="checked"</cfif>><br><strong>Tue</strong></label></td>
											<td><label><input type="checkbox" name="pubWed" value="1"<cfif load.Wed is 1> checked="checked"</cfif>><br><strong>Wed</strong></label></td>
											<td><label><input type="checkbox" name="pubThu" value="1"<cfif load.Thu is 1> checked="checked"</cfif>><br><strong>Thu</strong></label></td>
											<td><label><input type="checkbox" name="pubFri" value="1"<cfif load.Fri is 1> checked="checked"</cfif>><br><strong>Fri</strong></label></td>
											<td><label><input type="checkbox" name="pubSat" value="1"<cfif load.Sat is 1> checked="checked"</cfif>><br><strong>Sat</strong></label></td>
											<td><label><input type="checkbox" name="pubSun" value="1"<cfif load.Sun is 1> checked="checked"</cfif>><br><strong>Sun</strong></label></td>
										</tr>
									</table>
								</cfif>
							<cfelse>
								<table>
									<tr>
										<td><label><input type="checkbox" name="pubMon" value="1"<cfif load.Mon is 1> checked="checked"</cfif>><br><strong>Mon</strong></label></td>
										<td><label><input type="checkbox" name="pubTue" value="1"<cfif load.Tue is 1> checked="checked"</cfif>><br><strong>Tue</strong></label></td>
										<td><label><input type="checkbox" name="pubWed" value="1"<cfif load.Wed is 1> checked="checked"</cfif>><br><strong>Wed</strong></label></td>
										<td><label><input type="checkbox" name="pubThu" value="1"<cfif load.Thu is 1> checked="checked"</cfif>><br><strong>Thu</strong></label></td>
										<td><label><input type="checkbox" name="pubFri" value="1"<cfif load.Fri is 1> checked="checked"</cfif>><br><strong>Fri</strong></label></td>
										<td><label><input type="checkbox" name="pubSat" value="1"<cfif load.Sat is 1> checked="checked"</cfif>><br><strong>Sat</strong></label></td>
										<td><label><input type="checkbox" name="pubSun" value="1"<cfif load.Sun is 1> checked="checked"</cfif>><br><strong>Sun</strong></label></td>
									</tr>
								</table>
							</cfif>
						</td>
					</tr>
					<tr>
						<th align="left">Sales Type</th>
						<td>
							<select name="pubSaleType" class="select" data-placeholder="Select...">
								<option value=""></option>
								<option value="variable"<cfif load.SaleType is "variable"> selected="selected"</cfif>>Variable</option>
								<option value="firm"<cfif load.SaleType is "firm"> selected="selected"</cfif>>Firm</option>
								<option value="limited"<cfif load.SaleType is "limited"> selected="selected"</cfif>>Limited</option>
							</select>
						</td>
					</tr>
					<tr>
						<th align="left">Active</th>
						<td>
							<select name="pubActive" class="select" data-placeholder="Select...">
								<option value=""></option>
								<option value="1"<cfif load.Active is 1> selected="selected"</cfif>>Yes</option>
								<option value="0"<cfif load.Active is 0> selected="selected"</cfif>>No</option>
							</select>
						</td>
					</tr>
				</table>
				<div class="form-footer" style="margin: 20px -19px -13px -18px;border-radius: 0;">
					<input type="button" id="btnSave" value="Save Changes">
					<div class="clear"></div>
				</div>
			</div>
			<div id="barcodes">
				<table border="1" class="tableList" width="100%">
					<tr>
						<th align="left" width="10"><input type="button" id="btnDelCode" value="X" style="padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
						<th align="left">Barcodes</th>
					</tr>
					<cfif ArrayLen(codes)>
						<cfloop array="#codes#" index="i">
							<tr>
								<td><input type="checkbox" name="selectcode" value="#i.ID#" /></td>
								<td>#i.Code#</td>
							</tr>
						</cfloop>
					<cfelse>
						<tr><td colspan="2">No barcodes found</td></tr>
					</cfif>
					<tr>
						<td colspan="2">
							<input type="text" name="newcode" value="" placeholder="New barcode" style="width: 310px;" />
							<input type="button" id="btnAddCode" value="+" style="padding: 4px 8px;margin: 0px;font-size: 10px;" />
						</td>
					</tr>
				</table>
			</div>
		</div>
	</form>
</cfoutput>
<script type="text/javascript">
	$(".select").chosen({width: "100%"});
</script>


