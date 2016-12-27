<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/till" name="till">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>

<script type="text/javascript">
	$(document).ready(function() { 
		$('#accountRef').blur(function() {   
			var loadingText="<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading account information...</div>";
			$.ajax({
				type: 'POST',
				url: 'LoadNewsAccountInfo.cfm',
				data : $(this).serialize(),
				beforeSend:function(){
					$('#loading').html(loadingText).fadeIn();
				},
				success:function(data){
					$('#loading').html(loadingText).fadeOut();
					$('#info').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(){
					$('#loading').html("Client not found");
					$('#info').html("");
				}
			});
		});
		$('#accountRef').focus();
	});
</script>

<cfoutput>
	<h1 style="width:500px;">News Account Payment</h1>
	<table border="1" class="tableList" width="100%">
		<tr>
			<th width="120">Account Ref:</th>
			<td>
				<input type="text" name="accountRef" id="accountRef" class="NewsAccountItem" value="" style="float:left;">
				<span id="loading" style="float:left;font-size:12px;margin:5px 0 0 5px;"></span>
			</td>
		</tr>
	</table>
	<div id="info"></div>
</cfoutput>
