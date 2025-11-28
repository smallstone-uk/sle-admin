<!DOCTYPE HTML>
<html>
<head>
	<meta charset="utf-8">
	<title>Import Square EPOS Data</title>
	<link rel="stylesheet" type="text/css" href="css/main.css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 0, 1)});
			$(".srchAccount, .srchHintFields").chosen({width: "300px"});
			
			function Dispatch (e,formData)	{
				console.log(formData);
				e.preventDefault();
				e.stopPropagation();

				const data = {};
				formData.forEach(field => {
				  if (data[field.name]) {
					// Handle multiple fields with same name (e.g. checkboxes)
					if (!Array.isArray(data[field.name])) {
					  data[field.name] = [data[field.name]];
					}
					data[field.name].push(field.value);
				  } else {
					data[field.name] = field.value;
				  }
				});
				var process = data.srchProcess;
				console.log('process ' + process);
				if (process == 1)	{
					//	preview selected file
					$.ajax({
						type: 'POST',
						url: 'importControl.cfm',
						data : formData,
						beforeSend:function(){
							$('#previewDiv').empty();
							$('#previewDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Previewing file...").fadeIn();
						},
						success:function(data){
							$('#previewDiv').html(data);
							$('#loading').fadeOut();
						},
						error:function(data){
							alert("error loading items");
							$('#resultDiv').html(data);
							$('#loading').fadeOut();
						}
					});
				} else if (process == 2) {
					console.log("process2 to run");
					$.ajax({
						type: 'POST',
						url: 'importControl.cfm',
						data : formData,
						beforeSend:function(){
							$('#previewDiv').empty();
							$('#resultDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Processing file...").fadeIn();
						},
						success:function(data){
							$('#resultDiv').html(data);
							$('#loading').fadeOut();
						},
						error:function(data){
							alert("error loading items");
							$('#resultDiv').html(data);
							$('#loading').fadeOut();
						}
					});
				} else if (process == 3) {
					console.log("process3 to run");
					$.ajax({
						type: 'POST',
						url: 'importControl.cfm',
						data : formData,
						beforeSend:function(){
							$('#previewDiv').empty();
							$('#resultDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Processing file...").fadeIn();
						},
						success:function(data){
							$('#resultDiv').html(data);
							$('#loading').fadeOut();
						},
						error:function(data){
							alert("error loading items");
							$('#resultDiv').html(data);
							$('#loading').fadeOut();
						}
					});
					
				}
			}

			$('#btnPreview').click(function(e) {	<!--- run preview --->
				e.preventDefault();
				e.stopPropagation();
				$('#srchProcess').prop("value", 1);
				Dispatch(e,$('#importForm').serializeArray());
			});

			$('#btnProcess').click(function(e) {	<!--- run process --->
				e.preventDefault();
				e.stopPropagation();
				$('#srchProcess').prop("value", 2);
				Dispatch(e,$('#importForm').serializeArray());
			});

			$('#btnImport').click(function(e) {	<!--- run import --->
				e.preventDefault();
				e.stopPropagation();
				$('#srchProcess').prop("value", 3);
				Dispatch(e,$('#importForm').serializeArray());
			});
			
			$(document).on("click", "#tickAll", function() {
				console.log('tickle toggle');
				if ($('#tickAll').prop('checked')) {
					$('.fields').prop('checked', true);
				} else {
					$('.fields').prop('checked', false);
				}
			});
		});
	</script>
	<style type="text/css">
		.title {font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:bold;}
		.tableStyle {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border-collapse:collapse;
		}
		.tableFiles {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border-collapse:collapse;
		}
		.tableStyle th, .tableStyle td {
			border: 1px solid #ccc;
			padding: 2px 4px;
		}
		.blue {background-color:#0000FF; color:#FFFFFF}
		.green {background-color:#0F0;}
		.red {background-color:#FF0000;}
		.fuschia {background-color:#FF33FF;}
		.insert {font-weight:bold; color:#FF00FF;}
	</style>
</head>

<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchFile" default="">
<cfparam name="srchSuppliers" default="on">
<cfparam name="srchNominal" default="on">
<cfparam name="srchCustomers" default="on">
<cfparam name="srchUnknown" default="">
<cfparam name="srchFilter" default="">
<cfparam name="srchColName" default="">
<cfparam name="srchField" default="">
<cfparam name="srchRef" default="">
<cfparam name="srchSheet" default="">
<cfparam name="srchHint" default="">
<cfparam name="srchDebit" default="">
<cfparam name="srchCredit" default="">
<cfparam name="srchSupplier" default="">
<cfparam name="srchHintFields" default="">

<cfobject component="code/purchase" name="pur">
<cfobject component="code/accounts" name="acc">
<cfobject component="code/import3" name="import">
<cfset parms={}>
<cfset parms.datasource = application.site.datasource1>
<cfset nominals = acc.LoadNominalCodes(parms)>
<cfset accounts = import.LoadAccountCodes(parms)>
<!---<cfset loadKeys = import.LoadKeys(parms)>--->
<!---<cfset HintKeys = import.HintKeys()>--->
<!---<cfdump var="#HintKeys#" label="HintKeys" expand="false">--->

<cfset insertCount = 0>
<cfset recordCount = 0>
<cfset colNames = "">

<body>
<cftry>
	<cfflush interval="200">
	<cfsetting requesttimeout="900">
	<cfset dataDir = "#application.site.dir_data#spreadsheets\">
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

<cfdirectory directory="#dataDir#" action="list" name="QDir">
<h2><a href="importExcel.cfm">Import Square EPOS Data</a></h2>
<cfoutput>
<form name="importForm" id="importForm" method="post" enctype="multipart/form-data">
	<input type="text" name="srchProcess" id="srchProcess" size="5" />
	<table class="tableStyle" border="1" width="800">
		<tr>
			<th colspan="2" align="left">Import Settings</th>
		</tr>
		<tr>
			<td>Reference</td>
			<td><input type="text" name="srchRef" value="#srchRef#" size="15" /></td>
		</tr>
		<tr>
			<td>Worksheet Name</td>
			<td><input type="text" name="srchSheet" value="#srchSheet#" size="30" /></td>
		</tr>
		<tr>
			<td>Transaction Dates From</td>
			<td><input type="text" name="srchDateFrom" value="#srchDateFrom#" size="15" class="datepicker" /></td>
		</tr>
		<tr>
			<td>Transaction Dates To</td>
			<td><input type="text" name="srchDateTo" value="#srchDateTo#" size="15" class="datepicker" /></td>
		</tr>
		<tr>
			<td>Using Column Name:</td>
			<td>
            	<select name="srchColName" class="select">
                	<cfloop list="#colNames#" index="fld">
                    	<option value="#fld#"<cfif fld is srchColName> selected="selected"</cfif>>#fld#</option>
                    </cfloop>
            	</select>
                Find This: <input type="text" name="srchFilter" value="#srchFilter#" size="15" />
            </td>
		</tr>
		<tr>
			<td>Debit Account</td>
			<td>
				<select name="srchDebit" class="select">
					<option value="">Select...</option>
					<cfloop array="#nominals.nomArray#" index="nom">
						<option value="#nom.nomID#"<cfif nom.nomID is srchDebit> selected="selected"</cfif>>
							#nom.nomTitle# - #nom.nomGroup# - #nom.nomCode# - #NumberFormat(nom.nomID,'0000')#</option>
					</cfloop>
				</select>
			</td>					
		</tr>
		<tr>
			<td>Credit Account</td>
			<td>
				<select name="srchCredit" class="select">
					<option value="">Select...</option>
					<cfloop array="#nominals.nomArray#" index="nom">
						<option value="#nom.nomID#"<cfif nom.nomID is srchCredit> selected="selected"</cfif>>
							#nom.nomTitle# - #nom.nomGroup# - #nom.nomCode# - #NumberFormat(nom.nomID,'0000')#</option>
					</cfloop>
				</select>
			</td>					
		</tr>
		<tr>
			<td>Supplier Account</td>
			<td>
				<select name="srchSupplier" class="select">
					<option value="">Select...</option>
					<cfloop query="accounts.QAccounts">
						<option value="#accID#"<cfif accID is srchSupplier> selected="selected"</cfif>>
							#accName# - #accCode# - #NumberFormat(accID,'0000')#</option>
					</cfloop>
				</select>
			</td>					
		</tr>
		<tr>
			<td>Processing Mode</td>
			<td>
				<input type="radio" name="srchMode" value="1" checked="checked" /> View Only
				<input type="radio" name="srchMode" value="2" /> Import Data
			</td>
		</tr>
		<tr>
			<td>Options:</td>
			<td>
				<input type="checkbox" name="srchUnknown"<cfif srchUnknown eq "on"> checked="checked"</cfif> /> Ignore Unknown Trans?
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<table width="100%" class="tableFiles">
					<tr>
						<th align="left">##</th>
						<th align="left">Select</th>
						<th align="left">File</th>
						<th align="left">Date Modified</th>
						<th align="right">Size</th>
					</tr>
					<cfloop query="QDir">
						<cfif type eq "file">
							<tr>
								<td>#currentrow#</td>
								<td><input type="radio" name="srchFile" value="#name#" <cfif ListFind(srchFile,name,",")> checked</cfif> /></td>
								<td><a href="#application.site.url_data#spreadsheets/#name#" title="click to download this file">#name#</a></td>
								<td>#acc.FormatDate(datelastmodified,"dd-mmm-yyyy")#</td>
								<td align="right">#acc.FormatBytes(size)#</td>
							</tr>
						</cfif>
					</cfloop>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<div id="previewDiv"></div>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<input type="submit" name="btnProcess" id="btnProcess" value="Process Selected File" />
				<input type="submit" name="btnPreview" id="btnPreview" value="Preview File" />
				<input type="submit" name="btnImport" id="btnImport" value="Import File" />
			</td>
		</tr>
	</table>
</form>
</cfoutput>
<div id="resultDiv"></div>
</body>
</html>

