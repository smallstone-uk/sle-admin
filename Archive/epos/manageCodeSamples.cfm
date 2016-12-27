<script src="../scripts/jquery-1.11.1.min.js"></script>
<script src="../scripts/jquery-ui.js"></script>

<style>
	body {font-family:Sans-Serif;}
	table {border-spacing: 0px;border-collapse: collapse;border: 1px solid #BBB;font-size: 16px;font-weight: normal;}
	table th {padding: 6px 10px;color: #000;font-weight: bold;background-color:#DDD;}
	table td {padding: 6px 10px;border-color: #BBB;color: #000;}
	table[border="0"] {border:none;}
</style>

<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset samples = epos.LoadCodeSamples(parm)>

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$(document).on("click", ".edit", function(event) {
				$('input[name="id"]').val( $(this).data("id") );
				$('input[name="code"]').val( $(this).data("code") );
				$('input[name="item"]').val( $(this).data("item") );
				$('input[name="type"]').val( $(this).data("type") );
				$('input[name="title"]').val( $(this).data("title") );
				$('input[name="regexp"]').val( $(this).data("regexp") );
				$('input[name="extract"]').val( $(this).data("extract") );
				$('input[name="operator"]').val( $(this).data("operator") );
				$('input[name="modifier"]').val( $(this).data("modifier") );
				event.preventDefault();
			});
			$(document).on("click", ".del", function(event) {
				$.ajax({
					type: "POST",
					url: "AJAX_deleteSample.cfm",
					data: {"id": $(this).data("id")},
					success: function(data) {
						loadSamples();
					}
				});
				event.preventDefault();
			});
			loadSamples = function() {
				$.ajax({
					type: "GET",
					url: "AJAX_loadCodeSamples.cfm",
					success: function(data) {
						$('.items').html(data);
					}
				});
			}
			$('##SaveSampleForm').submit(function(event) {
				$.ajax({
					type: "POST",
					url: "AJAX_saveSample.cfm",
					data: $(this).serialize(),
					success: function(data) {
						loadSamples();
					}
				});
				event.preventDefault();
			});
			loadSamples();
		});
	</script>
	<form method="post" enctype="multipart/form-data" id="SaveSampleForm">
		<table width="25%" border="0">
			<tr>
				<td>ID</td>
				<td><input type="text" name="id" placeholder="ID" style="width:100%;" readonly="true"></td>
			</tr>
			<tr>
				<td>Barcode</td>
				<td><input type="text" name="code" placeholder="Barcode part" style="width:100%;"></td>
			</tr>
			<tr>
				<td>Item ID</td>
				<td><input type="text" name="item" placeholder="Item ID" style="width:100%;"></td>
			</tr>
			<tr>
				<td>Type</td>
				<td><input type="text" name="type" placeholder="Type of item" style="width:100%;"></td>
			</tr>
			<tr>
				<td>Title</td>
				<td><input type="text" name="title" placeholder="Title of item" style="width:100%;"></td>
			</tr>
			<tr>
				<td>RegExp</td>
				<td><input type="text" name="regexp" placeholder="Reg Expression"></td>
			</tr>
			<tr>
				<td>Extract</td>
				<td><input type="text" name="extract" placeholder="Title of the extracted value" style="width:100%;"></td>
			</tr>
			<tr>
				<td>Operator</td>
				<td>
					<select name="operator" style="width:100%;">
						<option value="+">+</option>
						<option value="-">-</option>
						<option value="*">*</option>
						<option value="/">/</option>
					</select>
				</td>
			</tr>
			<tr>
				<td>Modifier</td>
				<td><input type="text" name="modifier" placeholder="Modifier for the operator" style="width:100%;"></td>
			</tr>
			<tr>
				<td><input type="button" name="clear" value="Clear Form" style="width:100%;" onClick="javascript:$('##SaveSampleForm')[0].reset();"></td>
				<td><input type="submit" name="submit" value="Save Sample" style="width:100%;"></td>
			</tr>
		</table>
	</form>
	<table width="100%" style="margin:0 auto;" border="1">
		<tr>
			<th align="center">&nbsp;</th>
			<th align="center">ID</th>
			<th align="center">Code</th>
			<th align="center">Item ID</th>
			<th align="center">Type</th>
			<th align="left">Title</th>
			<th align="left">RegExp</th>
			<th align="center">Extract</th>
			<th align="center">Operator</th>
			<th align="right">Modifier</th>
		</tr>
		<tbody class="items"></tbody>
	</table>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>