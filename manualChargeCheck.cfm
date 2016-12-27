<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="func">
<cfobject component="code/publications" name="pub">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset pubs=func.LoadPublications(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#btnAdd').click(function() {
			$.ajax({
				type: 'POST',
				url: 'scanPubNewLinkAction.cfm',
				data: $('#newForm').serialize(),
				success:function(data){
					$("#orderOverlay").fadeOut();
					$("#orderOverlay-ui").fadeOut();
					$('#barcode').val("");
				}
			});
		});
		$('#NewBarcode').val($('#barcode').val());
	});
</script>

<cfoutput>
	<h1>Attach Barcode to Publication</h1>
	<form method="post" id="newForm">
		<input type="hidden" name="barcode" id="NewBarcode" value="" autocomplete="off">
		<table border="0" width="500">
			<tr>
				<th width="80">Publication</th>
				<td>
					<cfif ArrayLen(pubs.list)>
						<select name="TitleID" id="pubTitles">
							<cfloop array="#pubs.list#" index="item">
								<option value="#item.ID#" style="text-transform:capitalize;">#LCase(item.Title)#</option>
							</cfloop>
						</select>
					</cfif>
				</td>
			</tr>
			<tr>
				<td colspan="2"><input type="button" id="btnAdd" value="Attach"></td>
			</tr>
		</table>
	</form>
</cfoutput>
<script type="text/javascript">
	$("#pubTitles").chosen({width: "100%",disable_search_threshold: 10});
</script>


