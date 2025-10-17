<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Accounting Reports</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css">	<!--- SLE styles --->
	<link rel="stylesheet" type="text/css" href="css/main4.css">	<!--- SLE styles --->
	<link rel="stylesheet" type="text/css" href="css/accReports.css"><!--- accounting report styles --->
	<link rel="stylesheet" type="text/css" href="css/chosen.css">
	<link rel="stylesheet" type="text/css" href="css/jquery-ui-1.10.3.custom.min.css">
	<script src="scripts/jquery-1.9.1.js"></script>					<!--- core JQuery code --->
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>	<!--- JQuery required for menu code --->
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>		<!--- top menu navigation --->
	<script src="scripts/jquery.hoverIntent.minified.js"></script>	<!--- top menu navigation --->
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<!---<script src="scripts/accReports.js"></script>--->			<!--- accounting report scripts load later --->
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
			$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: false});		<!--- init top menu navigation --->
			$.getScript('scripts/accReports.js',function(){});		<!--- load when DOM ready otherwise code won't run --->

			function Dispatch (e,formData)	{
				var formObj = {};
				$.each(formData, function(_, field) {
					formObj[field.name] = field.value;
				});
				console.log(formObj);
				if (formObj.srchReport = 1)	{
					LoadGroups();
				} else if (formObj.srchReport = 2) {
					
				} else if (formObj.srchReport = 3) {
					
				}
		//		console.log(formObj.srchReport);
				e.preventDefault();
				e.stopPropagation();
			}

			$('#btnRun').click(function(e) {	<!--- run report --->
				Dispatch(e,$('#srchForm').serializeArray());
				LoadGroups();
				e.preventDefault();
				e.stopPropagation();
			});
			
			$(document).on("click", ".openTrans", function() {	<!--- open modal box --->
				$("#overlay").fadeIn(200);
				$("#modal").fadeIn(200);
		
				// Show loading text
				$("#modal-content").html("<p>Loading content...</p>");
				var ref = $(this).data("ref");
				var group = $(this).data("group");
				var title = $(this).data("title");
				var mode = $(this).data("mode");
				var srchDateFrom = $('#srchDateFrom').val();
				var srchDateTo = $('#srchDateTo').val();
				if (mode = "viewTrans") {
					ViewTrans(ref,mode,group,title,srchDateFrom,srchDateTo,"#modal-content");
				}
  			});
			$(document).on("click", ".openModal", function() {	<!--- open modal box --->
				$("#overlay").fadeIn(200);
				$("#modal").fadeIn(200);
		
				// Show loading text
				$("#modal-content").html("<p>Loading content...</p>");
				var ref = $(this).data("ref");
				var group = $(this).data("group");
				var title = $(this).data("title");
				var mode = $(this).data("mode");
				var srchDateFrom = $('#srchDateFrom').val();
				var srchDateTo = $('#srchDateTo').val();
				if (mode = "editGroup") {
					EditGroup(ref,mode,group,title,srchDateFrom,srchDateTo,"#modal-content");
				}
  			});

			$("#closeModal").on("click", function() {	<!--- close modal box --->
				closeModal();
				LoadGroups();
			});
		});
	</script>
</head>

<!--- default parameters --->
<cfparam name="srchReport" default="1">
<cfparam name="srchDateFrom" default="2024-01-01">
<cfparam name="srchDateTo" default="2024-03-31">
<cfparam name="srchSort" default="1">
<cfobject component="code/accReports" name="report">

<cfset init = report.initInterface({})>
<body>
	<cfoutput>
		<div id="wrapper">
			<cfinclude template="sleHeader.cfm">
			<div id="modal">	<!--- modal dialog box --->
			  <div id="modal-content">Loading...</div>
			  <button id="closeModal">Close</button>
			</div>
			<div id="overlay"></div>
			<div id="content">
				<div id="content-inner">
					<div class="form-wrap">
						<form method="post" name="srchForm" id="srchForm">
							<input type="hidden" name="mode" id="mode" value="1" />
							<div class="form-header no-print">
								Accounting Reports
								<span><input type="submit" name="btnRun" id="btnRun" value="Run" /></span>
							</div>
							<div class="module no-print">
								<table class="tableList" border="0">
									<tr>
										<td><b>Select Report</b></td>
										<td>
											<select name="srchReport" id="srchReport">
												<option value="">Select...</option>
												<cfloop array="#init.menu#" index="menu">
													<option id="#menu.id#" value="#menu.value#"<cfif srchReport eq "#menu.value#"> selected="selected"</cfif>>#menu.title#</option>
												</cfloop>
											</select>
										</td>
									</tr>
									<tr>
										<td><b>Date From</b></td>
										<td>
											<input type="text" name="srchDateFrom" id="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
										</td>
									</tr>
									<tr>
										<td><b>Date To</b></td>
										<td>
											<input type="text" name="srchDateTo" id="srchDateTo" value="#srchDateTo#" class="datepicker" />
										</td>
									</tr>
									<tr>
										<td><b>Sort By</b></td>
										<td>
											<select name="srchSort">
												<option value="1"<cfif srchSort eq "1"> selected="selected"</cfif>>Nominal Code</option>
												<option value="2"<cfif srchSort eq "2"> selected="selected"</cfif>>Account Code</option>
											</select>
										</td>
									</tr>
								</table>
							</div>
						</form>	<!--- end form --->
						<div id="loadingDiv" style="width:96%; height:20px;">loadingDiv</div>
						<div style="clear:both"></div>
					</div> <!--- end form-wrap --->
					<div id="resultDiv">resultDiv</div>
				</div> <!--- end content-inner --->
			</div> <!--- end content --->
		</div> <!--- end wrapper --->
	</cfoutput>
</body>
</html>
