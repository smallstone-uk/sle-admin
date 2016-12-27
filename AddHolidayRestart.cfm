<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset count=0>

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.id=id>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadHolidays() {
			$.ajax({
				type: 'POST',
				url: 'LoadHolidayList.cfm',
				data : $('#holidayForm').serialize(),
				success:function(data){
					$('#hol-list').html(data);
				}
			});
		};
		$('#btnRestart').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'AddHolidayRestartAction.cfm',
				data : $('#restartOrderForm').serialize(),
				success:function(data){
					$('#saveResults').html(data).fadeIn();
					LoadHolidays();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000 );
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="restartOrderForm">
		<input type="hidden" name="holID" value="#parm.id#" />
		<input type="text" name="restartDate" value="#LSDateFormat(now(),'dd/mm/yyyy')#" />
		<input type="button" id="btnRestart" value="Ok" />
	</form>
</cfoutput>
