<link href="css/messages.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="scripts/messages.js"></script>

<script type="text/javascript">
	$(document).ready(function() {
		LoadMessages(7);
		$('.orderOverlayClose').click(function(event) {
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
		$('#showMore').click(function(event) {
			var days=$(this).attr("href");
			var newDays=parseInt(days)+7;
			$(this).attr("href",newDays);
			$('#days').html(newDays);
			//console.log(newDays);
			LoadMessages(newDays);
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<div style="float:left;">
		<h1>Recent Messages</h1>
		<h3>Last <b id="days">7</b> Days</h3>
		<div id="orderOverlay-ui"></div>
			<div id="orderOverlay" style="position: fixed;">
			<div id="orderOverlayForm">
				<a href="##" class="orderOverlayClose">X</a>
				<div id="orderOverlayForm-inner"></div>
			</div>
		</div>
		<div id="msg-outer"></div>
		<div class="clear"></div>
		<a href="7" id="showMore">Older</a>
	</div>
</cfoutput>