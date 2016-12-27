<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset pubs=cust.LoadPublications(parm)>
<cfset client=man.LoadCustomOrder(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadList2() {
			$.ajax({
				type: 'POST',
				url: 'manualChargeList.cfm',
				data : $('#chargeForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#result').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#result').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		$(document).keypress(function(e) {
			var bcode = "";
			if ($('input[type="text"]').is(":focus")) {
			} else {
				bcode = newscanner(e);
				if (bcode) {
					SendBarcode(bcode,"code");
				}
			}
		});
		$('#pubList').change(function(event) {
			$('#qty').focus();
			event.preventDefault();
		});
		$('#btnAdd').click(function(event) {
			var id=$('#pubList').val();
			AddCharge(id);
			event.preventDefault();
		});
		$('#pubList').focus();
	});
</script>

<cfoutput>
	<input type="hidden" name="delCharge" id="delCharge" value="#client.charge#" />
	<input type="hidden" name="cltID" id="cltID" value="#client.cltID#" />
	<input type="hidden" name="roundID" id="roundID" value="#client.roundID#" />
	<table border="1" class="tableList">
		<tr>
			<th width="300">Publication cc</th>
			<th width="80">Qty</th>
			<th></th>
		</tr>
		<tr>
			<td width="300">
				<select name="PubID" data-placeholder="Choose a publication..." id="pubList">
					<option value=""></option>
					<cfloop array="#pubs.list#" index="item">
						<option value="#item.ID#" style="text-transform:capitalize;">#LCase(item.Title)#</option>
					</cfloop>
				</select>
			</td>
			<td><input type="number" name="qty" id="qty" min="1" max="20" value="1" size="5" style="text-align:center;" /></td>
			<td><input type="button" id="btnAdd" value="+" /></td>
		</tr>
	</table>
</cfoutput>
<script type="text/javascript">
	$("#pubList").chosen({width: "100%",disable_search_threshold: 5,enable_split_word_search:false});
</script>

