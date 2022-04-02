<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Test Button</title>
	<link href="css/main2.css" rel="stylesheet" type="text/css">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<style>
		.activeLink {background:#ff0000}
		.inactiveLink {background:#0000ff}
	</style>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script type="text/javascript">
		function init() {
			$('#btnChargeRound').prop("disabled", false);
			$('#btnChargeRound').css("background","#00f");
		};
		$(document).ready(function() {		
			$('.enable').on('click', function(e) {
				$('#btnChargeRound').prop("disabled", false);
				$('#btnChargeRound').css("background","#0f0");
				$('#msg').html("(enable) button is now enabled");
				e.preventDefault();
			});
			$('.disable').on('click', function(e) {
				$('#btnChargeRound').prop("disabled", true);
				$('#btnChargeRound').css("background","#f00");
				$('#msg').html("(disable) button is now disabled");
				e.preventDefault();
			});
			
			$('#btnChargeRound').click(function(e) {
				if ($('#btnChargeRound').prop("disabled") == false) {
					$('#msg').html("button is still disabled");
				} else {
					$('disable').click();
					$('#msg').html("button is now disabled... running process...");
				}
//				if (confirm("Are you sure you want to run out the rounds now?")) {
//					console.log("running");
//					var status=$(this).attr("data-status");
//					if (status == "enabled") {
//						ChargeRounds();
//					}
//					e.preventDefault();
//				} else {
//					console.log("NOT running");
//					alert("Rounds not run");
//				}
				e.preventDefault();
			});
			init();
		});
	</script>
</head>

<body>
	<div class="rightnav" style="font-family:Arial, Helvetica, sans-serif;">
		<ul>
			<li>
				<a href="#" id="btnChargeRound">
					<b>Charge Rounds</b>
					
				</a>
			</li>
			<li><a href="#" class="print">Quick Print</a></li>
		</ul>
		<div id="msg"></div>
		<div class="clear"></div>
	</div>
	
	<div>
		<button class="enable" id="enable">Enable Button</button>
		<button class="disable" id="disable">Disable Button</button>
	</div>
</body>
</html>