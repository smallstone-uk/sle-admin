<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<script type="text/javascript">
	$(document).ready(function() {
		function ReloadRoundItems() {
			$.ajax({
				type: 'POST',
				url: 'RoundItemList.cfm',
				data : $('#RoundForm').serialize(),
				beforeSend:function(){
					$('#loading .loading-box').html("<div class='loading-box'><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...</div>").fadeIn();
				},
				success:function(data){
					$('#roundlist').html(data);
					$('#loading').fadeOut();
					ReloadTable();
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#roundlist').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		function ReloadTable() {
			$.ajax({
				type: 'POST',
				url: 'clientAddOrderToRoundTable.cfm',
				data : $('#RoundForm').serialize(),
				success:function(data){
					$('#roundTable').html(data);
					$('#loading').fadeOut();
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#roundTable').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		$('#DeleteSingleDrop').click(function(event) {
			$('#all').val("false");
			$.ajax({
				type: 'POST',
				url: 'RemoveOrderFromRoundAction.cfm',
				data : $('#RoundForm').serialize(),
				beforeSend:function(){
					$('#confirm').html("<div class='loading-box'><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...</div>");
				},
				success:function(data){
					$('#confirm').html(data);
					//ReloadRoundItems();
				}
			});
			event.preventDefault();
		});
		$('#DeleteAll').click(function(event) {
			$('#all').val("true");
			$.ajax({
				type: 'POST',
				url: 'RemoveOrderFromRoundAction.cfm',
				data : $('#RoundForm').serialize(),
				beforeSend:function(){
					$('#confirm').html("<div class='loading-box'><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...</div>");
				},
				success:function(data){
					$('#confirm').html(data);
					//ReloadRoundItems();
				}
			});
			event.preventDefault();
		});
		$('.removeOrderLinkClose').click(function(event) {   
			$("#confirm").fadeOut();
			event.preventDefault();
		});
	});
</script>
<h2>Delete</h2>
<p>Would you like to delete just this item or all items for this order?</p>
<a href="##" id="DeleteSingleDrop">Delete</a>&nbsp;|&nbsp;<a href="##" id="DeleteAll">Delete All</a>&nbsp;|&nbsp;<a href="##" class="removeOrderLinkClose">Cancel</a>

