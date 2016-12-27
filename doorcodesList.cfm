<cfset callback=true>
<cfsetting showdebugoutput="no" requesttimeout="300">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset codes=func.LoadDoorCodes(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadCodes() {
			$.ajax({
				type: 'POST',
				url: 'doorcodesList.cfm',
				success:function(data) {
					$('#print-area').html(data);
				}
			});
		}
		$('.selectitem').click(function(){
			var show=false;
			$('.selectitem').each(function(index) {
				if(this.checked) {
					$('#btnDelete').show();
					show=true;
				} else {
					if(show) {
					} else {
						$('#btnDelete').hide();
						show=false;
					};
				};
			});
		});
		$('#btnDelete').click(function(e){
			var count=0;
			var items="";
			$('.selectitem').each(function() {
				if (this.checked) {
					count=count+1
					if (count != 1) {items=items+",";}
					items=items+$(this).val();
				}
			});
			$.ajax({
				type: 'POST',
				url: 'code/functions.cfc',
				data: {
					"method": "RemoveDoorCodes",
					<cfoutput>"datasource":"#application.site.datasource1#",</cfoutput>
					"items": items
				},
				success:function() {
					LoadCodes();
				}
			});
			e.preventDefault();
		});
		$('.codeChange').dblclick(function(e) {
			var id=$(this).attr("data-ID");
			$(this).hide();
			$('#code'+id).show().focus();
			e.preventDefault();
		});
		$('.codeValue').blur(function() {
			var id=$(this).attr("data-ID");
			var code=$(this).val();
			$.ajax({
				type: 'POST',
				url: 'code/functions.cfc',
				data: {
					"method": "UpdateDoorCode",
					<cfoutput>"datasource":"#application.site.datasource1#",</cfoutput>
					"id": id,
					"code": code
				},
				success:function() {
					LoadCodes();
				}
			});
		});
		$('.addBuilding').blur(function() {
			var save=true;
			$('.addBuilding').each(function() {
				if ($(this).val() == "") {
					save=false;
				}
			});
			if (save) {
				var name=$('#addName').val();
				var code=$('#addCode').val();
				$.ajax({
					type: 'POST',
					url: 'code/functions.cfc',
					data: {
						"method": "AddDoorCode",
						<cfoutput>"datasource":"#application.site.datasource1#",</cfoutput>
						"name": name,
						"code": code
					},
					success:function() {
						LoadCodes();
					}
				});
			}
		});
	});
</script>

<cfoutput>
	<span style="float: right;margin: 0 30px 0 0;line-height: 26px;font-size:16px;font-weight: bold;">Printed: #LSDateFormat(Now(),"DD MMM YY")#</span>
	<h1 style="margin: 0 0 10px 0 !important;">Door Codes</h1>
	<div style="clear:both;"></div>
	<form method="post" id="codeForm">
		<table border="1" class="tableList trhover" style="float:left;font-size:16px;margin:0 10px 0 0;">
			<tr>
				<th width="10" class="no-print" style="padding:10px;"><input type="button" id="btnDelete" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
				<th align="left" width="300" style="padding:10px;">Building</th>
				<th width="160" style="padding:10px;">Code</th>
			</tr>
			<cfloop array="#codes#" index="item">
				<tr>
					<td align="center" class="no-print" style="padding:10px;"><input type="checkbox" name="selectitem" class="selectitem" value="#item.ID#"></td>
					<td align="left" style="padding:10px;">#item.Name#</td>
					<td style="padding:10px;">
						<span class="codeChange" id="codeChange#item.ID#" data-ID="#item.ID#" style="font-weight:bold;">#item.Code#</span>
						<input type="text" id="code#item.ID#" class="codeValue" value="#item.Code#" data-ID="#item.ID#" style="display:none;">
					</td>
				</tr>
			</cfloop>
			<tr class="no-print">
				<th colspan="3" style="padding:10px;">New Building Code</th>
			</tr>
			<tr class="no-print">
				<td align="left" colspan="3" style="padding:10px;">
					<input type="text" id="addName" class="addBuilding" value="" placeholder="New Building" style="width:340px;">
					<input type="text" id="addCode" value="" class="addBuilding" placeholder="Code" style="width:158px;">
				</td>
			</tr>
		</table>
	</form>
</cfoutput>
