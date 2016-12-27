<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>
<cfset pubs=cust.LoadPublications(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#selectAll').click(function(event) {   
			if(this.checked) {
				$('input.selectPub').each(function() {this.checked = true;});
			} else {
				$('input.selectPub').each(function() {this.checked = false;});
			}
		});
		$('#pubList').change(function() {
			$.ajax({
				type: 'POST',
				url: 'checkPublications.cfm',
				data : $(this).serialize(),
				beforeSend:function(){
					$('#pubResults').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#pubResults').html(data);
					$('#orderOverlayForm').center();
					$('#addbtn').show();
					$('#editPub').fadeIn();
				}
			});
			event.preventDefault();
		});
		function GetOrders() {
			var id=$('#OrderID').val();
			$.ajax({
				type: 'POST',
				url: 'LoadClientOrder.cfm',
				data : $('#AddPubForm').serialize(),
				beforeSend:function(){},
				success:function(data){$('#OrderList'+id).html(data);}
			});
		};
		$('#addbtn').click(function(event) { 
			$.ajax({
				type: 'POST',
				url: 'AddPubAction.cfm',
				data : $('#AddPubForm').serialize(),
				beforeSend:function(){
					$('#saveResults').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...").fadeIn();
				},
				success:function(data){
					$('#saveResults').html(data);
					$('#saveResults').show();
					GetOrders();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000 );
				}
			});
			event.preventDefault();
		});
		$('#editPub').click(function(e) { 
			var id=$('#pubList').val();
			OpenEdit(id);
			e.preventDefault();
		});
		$('#pubList').focus();
	});
</script>

<cfoutput>
<form method="post" enctype="multipart/form-data" id="AddPubForm">
	<h1>
		Add Publication
	</h1>
	<div id="saveResults" style="display:none;"></div>
	<input type="hidden" name="oiOrderID" id="OrderID" value="#parm.form.orderID#" />
	<input type="hidden" name="cltID" value="#parm.form.cltID#" />
	<input type="hidden" name="cltRef" value="#parm.form.cltRef#" />
	<table border="0" width="100%">
		<tr>
			<td width="300">
				<select name="oiPubID" data-placeholder="Choose a publication..." id="pubList" class="select">
					<option value=""></option>
					<cfloop array="#pubs.list#" index="item">
						<option value="#item.ID#" style="text-transform:capitalize;">#LCase(item.Title)#</option>
					</cfloop>
				</select>
				<a href="##" id="editPub" style="display:none;">Edit</a>
			</td>
		</tr>
	</table>
	<div id="pubResults"></div>
	<div class="form-footer">
		<input type="button" id="addbtn" value="Add" style="float:right;" />
		<div class="clear"></div>
	</div>
</form>
</cfoutput>
<script type="text/javascript">
	$(".select").chosen({width: "85%"});
</script>

