<!DOCTYPE html>
<html>
<head>
<title>Round Priority Ordering</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		function SaveOrder() {
			$.ajax({
				type: 'POST',
				url: 'rounds5PriorityOrderingAction.cfm',
				data: $('#orderingForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#loading').html(data);
				},
				error:function(data){
					$('#loading').html(data);
				}
			});
		}
		$(".roundTable").tableDnD({
			onDrop: function() {
				$('.orderItem').each(function(index) {
					$(this).val(index+1);
				});
				setTimeout(function(){SaveOrder();},1000);
			},
			scrollAmount:50
		});
		$('#btnSave').click(function(e) {
			SaveOrder();
			e.preventDefault();
		});
	});
</script>
</head>

<cftry>
	<cfsetting showdebugoutput="no" requesttimeout="300">
	<cfobject component="code/rounds5" name="rounds">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset orders=rounds.PriorityOrdering(parm)>
	<cfset total=0>
	
	<cfoutput>
	<body>
		<div id="wrapper">
			<cfinclude template="sleHeader.cfm">
			<div id="content">
				<div id="content-inner">
					<div class="form-wrap no-print">
						<form method="post" id="orderingForm">
							<div class="form-header">
								Priority Ordering<input type="button" id="btnSave" value="Save" style="float:right;">
								<span><div id="loading" class="loading" style="float: right;margin: 11px 19px 0px 0px;"></div></span>
							</div>
							<table border="1" class="tableList trhover roundTable" width="100%">
								<tr class="nodrop nodrag">
									<th>Address</th>
								</tr>
								<cfif ArrayLen(orders)>
									<cfloop array="#orders#" index="i">
										<tr class="row#i.ID#">
											<td>
												<input type="text" name="item" value="#i.id#" style="display:none;">
												<input type="text" name="order#i.ID#" class="orderItem" value="#i.Priority#" style="display:none;">
												#i.name# #i.street#
											</td>
										</tr>
									</cfloop>
								</cfif>
							</table>
						</form>
					</div>
					<div class="clear"></div>
				</div>
			</div>
			<cfinclude template="sleFooter.cfm">
		</div>
		<cfif application.site.showdumps>
			<cfdump var="#session#" label="session" expand="no">
			<cfdump var="#application#" label="application" expand="no">
			<cfdump var="#variables#" label="variables" expand="no">
		</cfif>
	</body>
	</cfoutput>

	<cfcatch type="any">
		<cfdump var="#cfcatch#" label="cfcatch" expand="no">
	</cfcatch>
</cftry>
</html>
