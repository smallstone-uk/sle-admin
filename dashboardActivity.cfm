<link href="css/activity.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="scripts/activity.js"></script>

<script type="text/javascript">
	$(document).ready(function() {
		//setInterval(function(){LoadActivity(0);}, 10000);
		LoadActivity(0);
	});
</script>

<cfoutput>	
	<div style="float:left;width: 390px;margin:0 0 0 10px;">
		<h1>Recent Activity</h1>
		<h3>Today</h3>
		<div id="ActivityResults"></div>
	</div>
</cfoutput>


