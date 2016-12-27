<!DOCTYPE html>
<html>
<head>
<title>Colour Wheel Test</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/colourWheel.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.11.1.min.js"></script>
<script src="scripts/ui/1.10.3/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/main.js" type="text/javascript"></script>
</head>

<cfoutput>
<body>
	<script>
		$(document).ready(function(e) {
			//	R	G	B	A
			
			writeBlock = function(a) {
				$('.wheel').append("<div class='block' style='background:" + a + "'></div>");
			}
			
			getStyle = function(a, b, c) {
				return "rgba(" + a + "," + b + "," + c + ",1);";
			}
			
			// Colours
			
			for (var i = 0; i < 6; i++) {
				for (var x = 0; x < 255; x++) {
					writeBlock(getStyle(x, 0, 0));
				}
				for (var x = 0; x < 255; x++) {
					writeBlock(getStyle(0, x, 0));
				}
				for (var x = 0; x < 255; x++) {
					writeBlock(getStyle(0, 0, x));
				}
				for (var x = 0; x < 255; x++) {
					writeBlock(getStyle(x, 0, x));
				}
				for (var x = 0; x < 255; x++) {
					writeBlock(getStyle(x, x, x));
				}
				for (var x = 0; x < 255; x++) {
					writeBlock(getStyle(x, x, 0));
				}
				for (var x = 0; x < 255; x++) {
					writeBlock(getStyle(0, x, x));
				}
			}
		});
	</script>
	
	<div class="wheel">
		
	</div>
	
</body>
</cfoutput>

</html>