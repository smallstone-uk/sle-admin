<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfparam name="roundsTicked" default="">
<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset roundList=rnd.LoadRoundList(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadRoundRoute() {
			$.ajax({
				type: 'POST',
				url: 'RoundLoadRoute.cfm',
				data : $('#roundForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Building round sheets...").fadeIn();
				},
				success:function(data){
					$('#loading').fadeOut();
					$('#RoundResult').html(data);
				},
				error:function(data){
					$('#loading').fadeOut();
					$('#RoundResult').html(data);
				}
			});
		};
		LoadRoundRoute();
	});
</script>

<cfoutput>
	<cfloop array="#roundList.rounds#" index="item">
		<label><input type="checkbox" name="roundsTicked" value="#item.ID#" class="checkbox" checked="checked" />#item.Ref# #item.Title#</label>
	</cfloop>
	<div class="clear" style="padding:5px 0;"></div>
</cfoutput>
