<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Credit Round</title>
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script type="text/javascript">
	function LoadRoundItems() {
		$.ajax({
			type: 'POST',
			url: 'rounds6LoadCredits.cfm',
			data : $('#roundForm').serialize(),
			beforeSend:function(){
				$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Building round sheet...").fadeIn();
			},
			success:function(data){
				$('#loading').fadeOut();
				$('#RoundResult').html(data).fadeIn();
				$('#processCredits').prop("checked",false);
			}
		});
	}
	$(document).ready(function() {
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1),onClose: function() {}});
		$('#btnRun').click(function(e) {
			LoadRoundItems();
			e.preventDefault();
		});
		$('.selectAllOnList').click(function(event) {
			if (this.checked) {
				$('.roundstick').prop({checked: true});
				$('.selectAllOnList').prop({checked: true});
			} else {
				$('.roundstick').prop({checked: false});
				$('.selectAllOnList').prop({checked: false});
			}
		})
		$('#showRoundOrder').click(function(e) {
			if (this.checked) {
				$('#priorityLink').hide();
				$('.dispatchtick').prop("checked",true);
				$('#showSummaries').prop("checked",true);
			} else {
				$('#priorityLink').show();
				$('.dispatchtick').prop("checked",false);
				$('#showSummaries').prop("checked",false);
			}
		});
		$('#btnRun').show();
	});
</script>
</head>

<cfobject component="code/rounds6" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.roundDate=DateFormat(DateAdd('d',1,Now()),'yyyy-mm-dd')>
<cfset parm.pubGroup='news'>
<cfset roundList = rnd.LoadRoundList(parm)>

<cfoutput>
<body>
	<h1>Credit Round</h1>
	<form method="post" id="roundForm">
	<table>
		<tr>
			<td><b>Day</b></td>
			<td><input type="text" name="roundDate" class="datepicker" value="#parm.roundDate#"></td>
		</tr>
		<tr>
			<td></td>
			<td id="roundList" valign="top">
				<input type="checkbox" name="selectAllOnList" class="selectAllOnList" checked="checked" />
				<cfloop array="#roundList.rounds#" index="item">
					<label><input type="checkbox" name="roundsTicked" value="#item.ID#" class="checkbox roundstick" checked="checked" />#item.Title#</label>
				</cfloop>
			</td>
		</tr>
		<tr>
			<td><b>Process Credits</b></td>
			<td><label><input type="checkbox" name="processCredits" id="processCredits" value="0" class="checkbox" />&nbsp;Process Credits</label></td>
		</tr>
		<tr>
			<td></td>
			<td colspan="3"><input type="button" id="btnRun" value="Go" style="float:left;display:none;" /></td>
		</tr>
	</table>
	</form>
	<div id="RoundResult" class="module"></div>
</body>
</cfoutput>
</html>