<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<script type="text/javascript">
	$(document).ready(function() {
		function Invoice() {
			$('#type').val(2);
			$('#createPDF').val(1);
			$.ajax({
				type: 'POST',
				url: 'InvoicingList.cfm',
				data : $('#invForm').serialize(),
				beforeSend:function(){
					$('#InvoiceList').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Invoicing Clients, please wait...");
				},
				success:function(data){
					$('#InvoiceList').html(data);
				}
			});
		}
		$('#btnYes').click(function(event) {   
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			Invoice();
			event.preventDefault();
		});
		$('#btnNo').click(function(event) {   
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<h1>Create Invoices</h1>
	<p>Are you sure you want to create invoices for these customers?</p>
	<div align="center">
		<a href="##" id="btnYes" class="button" style="float:none;display:inline-block;">Yes</a>
		<a href="##" id="btnNo" class="button" style="float:none;display:inline-block;">No</a>
	</div>
</cfoutput>
