<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Accounting Reports</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="common/scripts/common.js"></script>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
			$(".srchAccount, .srchTranType").chosen({width: "300px"});
			$(document).on("click", ".openModal", function() {
				$("#overlay").fadeIn(200);
				$("#modal").fadeIn(200);
		
				// Show loading text
				$("#modal-content").html("<p>Loading content...</p>");
  			});
			function closeModal() {
				$("#overlay, #modal").fadeOut(150, function () {
					$("#modal-content").empty(); // clear out old stuff
					$("body").removeClass("modal-open");
				});
			}
	
			$("#closeModal").on("click", closeModal);
			
			function LoadSales(ref,mode,group,srchDateFrom,srchDateTo,result) {
				$.ajax({
					type: 'POST',
					url: 'ajax/AJAX_vatDetail.cfm',
					data: {"ref":ref,"mode":mode,"group":group,"srchDateFrom":srchDateFrom,"srchDateTo":srchDateTo},
					beforeSend:function(){
						$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading sales...");
					},
					success:function(data){
						$(result).html(data);
					}
				});
			}
			$('#btnRun').click(function(e) {
				$.ajax({
					type: 'POST',
					url: 'ajax/AJAX_accNomGroups.cfm',
					data: $('#srchForm').serialize(),
					beforeSend:function(){
						$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#loadingDiv').fadeOut();
						$('#resultDiv').html(data).show();
					},
					error:function(data){
						$('#resultDiv').html(data);
						$('#loadingDiv').loading(false);
					}
				});
				e.preventDefault();
			})
		});
	</script>
	<style type="text/css">
		.header {font-size:16px; font-weight:bold;}
		.amount {text-align:right}
		.amountTotal {text-align:right; font-weight:bold;}
		.tranList {	
			font-family:Arial, Helvetica, sans-serif;
			font-size:12px;
			border-collapse:collapse;
		}
		.tranList th, .tranList td {
			padding:2px 4px; 
			border: solid 1px #ccc;
			background-color:#fff;
		}
		.vatTable {
			margin:10px;
			border-spacing: 0px;
			border-collapse: collapse;
			border: 1px solid #CCC;
			font-size: 16px;
		}
		.vatTable th {padding: 5px; background:#eee; border-color: #ccc;}
		.vatTable td {padding: 5px; border-color: #ccc;}
		.err {background-color:#FF0000}
		.ok {background-color:#00DF00}
		.summary {font-size:11px; color:#0033FF;}
		.salesHeader { background-color:#0F3;}
		.purchHeader { background-color:#09F;}
		.nomHeader { background-color:#FF3;}
		.vatHeader {background-color:#FC9;}
		.reg {background-color:#FFFFFF;}
		.rfd {background-color:#FFCCFF;}
		.wst {background-color:#FFFF99;}
		/* Overlay */
		#overlay {
		  display: none;
		  position: fixed;
		  top: 0; left: 0;
		  width: 100%; height: 100%;
		  background: rgba(0,0,0,0.5);
		  z-index: 1000;
		}
		/* Modal */
		#modal {
		  display: none;
		  position: fixed;
		  top: 50%; left: 50%;
		  transform: translate(-50%, -50%);
		  background: #fff;
		  padding: 20px;
		  border-radius: 8px;
		  z-index: 1001;
		  min-width: 300px;
		  box-shadow: 0 0 15px rgba(0,0,0,0.3);
		}
		#modal h2 {
		  margin-top: 0;
		}	
		#modal-content {
		  margin: 15px 0;
		  max-height: 80vh; 
		  overflow-y: auto;
		  border: solid 1px #CCCCCC;
		}
		#loadingDiv {width:100%;}
	</style>
</head>
<cfsetting requesttimeout="900">
<cfparam name="srchReport" default="1">
<cfparam name="srchAccount" default="">
<cfparam name="srchExclude" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchSort" default="1">
<cfparam name="srchUpdate" default="">

<cfobject component="code/vatReport" name="report">
<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>


<cfquery name="QAccounts" datasource="#parms.datasource#">
	SELECT eaID, eaTitle
	FROM tblepos_account
	WHERE 1
	ORDER BY eaTitle
</cfquery>
<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<!-- Modal -->
		<div id="modal">
		  <div id="modal-content">Loading…</div>
		  <button id="closeModal">Close</button>
		</div>
		<div id="overlay"></div>
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" name="srchForm" id="srchForm">
						<div class="form-header no-print">
							Accounting Reports
							<span><input type="submit" name="btnRun" id="btnRun" value="Run" /></span>
						</div>
						<div class="module no-print">
							<table border="0">
								<tr>
									<td><b>Report</b></td>
									<td>
										<select name="srchReport">
											<option value="">Select...</option>
											<option value="1"<cfif srchReport eq "1"> selected="selected"</cfif> >Nominal Group Headings</option>
											<option value="2"<cfif srchReport eq "2"> selected="selected"</cfif> >Monthly Stock Valuation</option>
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
					</form>
				</div> <!--- end form-wrap --->
				<div id="loadingDiv"></div>
				<div id="resultDiv"></div>
			</div> <!--- end content-inner --->
		</div> <!--- end content --->
	</div> <!--- end wrapper --->
</body>
</cfoutput>
</html>
