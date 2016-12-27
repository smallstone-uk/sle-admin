<cftry>
<!DOCTYPE html>
<html>
<head>
<title>JS Sandbox</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/virtualInput.css" rel="stylesheet" type="text/css">
<script src="../scripts/jquery-1.11.1.min.js"></script>
<script src="../scripts/jquery-ui.js"></script>
<script src="js/sandbox.js"></script>
</head>

<cfoutput>
	<body id="content">
		<script>
			$(document).ready(function(e) {
				$('.mySelectBox').touchSelect();
			});
		</script>
		<select class="mySelectBox">
			<option value="red">Red</option>
			<option value="blue">Blue</option>
			<option value="green">Green</option>
			<option value="black">Black</option>
		</select>
	</body>
</cfoutput>
</html>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>