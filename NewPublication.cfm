<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>

<cfquery name="QCats" datasource="#parm.datasource#">SELECT pubCategory FROM tblPublication WHERE 1 GROUP BY pubCategory</cfquery>
<cfquery name="QType" datasource="#parm.datasource#">SELECT pubType FROM tblPublication WHERE 1 GROUP BY pubType</cfquery>

<script type="text/javascript">
	$(document).ready(function() {
		<cfif NOT StructKeyExists(form,"manualCharge")>
			function LoadPubs() {
				$.ajax({
					type: 'POST',
					url: 'GetPubs.cfm',
					data : $('#stockForm').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#pubs').html(data);
						$('#loading').fadeOut();
					},
					error:function(data){
						$('#pubs').html(data);
						$('#loading').fadeOut();
					}
				});
			};
		<cfelse>
			function LoadPubs() {
				$.ajax({
					type: 'POST',
					url: 'manualChargeForm.cfm',
					data : $('#chargeForm').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#pubForm').html(data);
						$('#loading').fadeOut();
						LoadList();
					},
					error:function(data){
						$('#pubForm').html(data);
						$('#loading').fadeOut();
					}
				});
				event.preventDefault();
			};
		</cfif>
		$('#btnSavePub').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'NewPublicationSave.cfm',
				data : $('#NewPubForm').serialize(),
				beforeSend:function(){
					$('#miniloading').html("<img src='images/loading_2.gif' class='loadingGif'>").fadeIn();
					$('#btnSavePub').prop("disabled",true);
				},
				success:function(data){
					LoadPubs();
					$("#msg").html(data).fadeIn();
					$('#btnSavePub').prop("disabled",false);
					$('#miniloading').fadeOut();
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<h1>New Publication</h1>
	<div id="msg" class="response"></div>
	<form method="post" enctype="multipart/form-data" id="NewPubForm">
		<table border="0">
			<tr>
				<td colspan="2"><input type="text" name="pubTitle" value="" placeholder="Full Title" style="width:100%;font-size:22px;" /></td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="pubShortTitle" value="" placeholder="WHS Title" style="width:100%;font-size:22px;" /></td>
			</tr>
			<tr>
				<td colspan="2"><input type="text" name="pubRoundTitle" value="" placeholder="Round Title" style="width:100%;font-size:22px;" /></td>
			</tr>
			<tr>
				<td>Supplier</td>
				<td>
					<select name="pubWholesaler">
						<option value="WHS">Smiths</option>
						<option value="Dash">Dash</option>
					</select>
				</td>
			</tr>
			<tr>
				<td>Group</td>
				<td>
					<select name="pubGroup">
						<option value="Magazine">Magazine</option>
						<option value="News">News</option>
					</select>
				</td>
			</tr>
			<tr>
				<td>Type</td>
				<td>
					<select name="pubType" data-placeholder="Select...">
						<option value=""></option>
						<cfloop query="QType">
							<option value="#QType.pubType#">#QType.pubType#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>Category</td>
				<td>
					<select name="pubCategory" data-placeholder="Select...">
						<option value=""></option>
						<cfloop query="QCats">
							<option value="#QCats.pubCategory#">#QCats.pubCategory#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<div class="form-bottom" style="margin: 15px -20px -20px -20px;">
			<input type="button" id="btnSavePub" style="float:right;" value="Save" /><span id="miniloading" style="float:right;margin: 7px 0 0 0;"></span>
			<div class="clear"></div>
		</div>
	</form>
</cfoutput>
<script type="text/javascript">
	$("select").chosen({width: "150px",disable_search_threshold: 10});
</script>

