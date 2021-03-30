<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.clientRef=userID>
<cfset parm.datasource=application.site.datasource1>
<cfset clientData=func.LoadClientByRef(parm)>
<cfset letters=func.LoadLetters(parm)>
<cfset firstDay = CreateDate(Year(Now()),Month(Now()),1)>
<cfset dateFrom = DateAdd("m",-4,firstDay)>
<!---<cfparam name="srchStatementFrom" default="#DateFormat(dateFrom,'yyyy-mm-dd')#">--->

<script type="text/javascript">
	$(document).ready(function() {
		$('#statement').click(function () {
			var allTrans=$('#allTrans').prop("checked");
			var dateFrom=$('#srchDateFrom').val();
			var clientRef="<cfoutput>#parm.clientRef#</cfoutput>";
			window.open("checkClient.cfm?clientRef="+clientRef+'&allTrans='+allTrans+'&dateFrom='+dateFrom+'&print=true', '_blank');
			return false;
		});
		$('#letterMenu').click(function(event) {
			$('#letters').show();
			$('#letters').gravity($(this), false);
			$('#letters').htmlHide();
			event.preventDefault()
		});
		$('.openletter').click(function(e) {
			var id=$(this).attr("data-id");
			var userID=$(this).attr("data-user");
			$.ajax({
				type: 'POST',
				url: 'clientPaymentsLetterSetup.cfm',
				data: {
					"id":id,
					"userID":userID
				},
				success:function(data){
					$("#orderOverlay").fadeIn();
					$("#orderOverlay-ui").fadeIn();
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				}
			});
			e.preventDefault();
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	});
</script>

<cfoutput>
<div style="margin:10px 0;">
	<div id="letters" style="display:none;">
		<div id="letters-inner">
			<ul>
				<cfloop array="#letters#" index="i">
					<li><a href="##" class="openletter" data-id="#i.ID#" data-user="#clientData.ID#">#i.Title#</a></li>
				</cfloop>
			</ul>
		</div>
	</div>
	<a href="##" id="letterMenu" class="button" style="float: left;padding: 0;width: 80px;height: 30px;text-align: center;line-height: 30px;" data-user="#clientData.ID#">Letters</a>
	<a href="##" id="statement" class="button" style="float:left;" data-user="#clientData.ID#">View Statement</a>
	<input value="Export" type="button" onclick="$('##tranTable').table2CSV({header:['icon','ID','Date','Type','PaidIn','Ref','Description','DR','CR','Balance']})">
	<!---&nbsp;Brought Forward from: <input type="text" name="srchStatementFrom" id="srchStatementFrom" value="" size="15" class="datepicker" />#srchDateFrom#--->
	<div class="clear"></div>
</div>
</cfoutput>
