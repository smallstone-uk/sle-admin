<!---WORKING VERSION AS OF 18/08/2014--->
<!DOCTYPE html>
<html>
<head>
<title>Accounts (V2)</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<link href="css/accounts.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/tabs.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/accounts.js" type="text/javascript"></script>
<script src="scripts/checkDates.js"></script>
<script src="scripts/main.js"></script>
<style type="text/css">
	#wrapper {font-family:Arial, Helvetica, sans-serif; font-size:11px;border:solid 1px #ccc; padding:4px; width:100%;}
	.element {float:left; padding:2px; min-height:56px;}
	.clear {clear:both;}
	select {margin:2px;}
	@media print {
		.noPrint {display:none;}
	}
</style>
</head>

<cfobject component="code/accounts" name="accts">
<cfset parm = {}>
<cfset parm.nomType = "">
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset acctsList = accts.LoadAccounts(parm)>
<!---<cfset nominals = accts.LoadNominalCodes(parm)>--->
<cfset loadNoms = accts.LoadNominalCodes(parm)>
<cfset nominals = loadNoms.codes>
<cfparam name="srchAccount" default="">
<cfparam name="srchRange" default="">

<cfset parm.select.account = 0>
<cfset parm.select.transaction = 0>
<cfif StructKeyExists(url, "acc")>
	<cfset parm.select.account = val(url.acc)>
	<cfif StructKeyExists(url, "tran")><cfset parm.select.transaction = val(url.tran)></cfif>
</cfif>

<cfoutput>
	<script>
		$(document).ready(function() {
			var selectAccount = parseInt("#parm.select.account#");
			var selectTran = parseInt("#parm.select.transaction#");
			
			if (selectAccount > 0) {
				$('##account').find('option').each(function(i, e) { $(e).removeAttr("selected"); });
				$('##account').find('option[value="' + selectAccount + '"]').prop("selected", true);
			//	$('##srchRange').find('option[value="2"]').prop("selected", true);
				$('##srchAllocChk').prop("checked", false);
				setTimeout(function() {
					$('##account-form').submit();
					setTimeout(function() {
						$('.trnIDLink[data-id="' + selectTran + '"]').click();
					//	toggleTranList();
					}, 250);
				}, 250);
			}
			
			var shouldClear = true;
			var #ToScript(nominals, "nominals")#;
			$('##account').chosen({
				width: "220px",
				disable_search_threshold: 10
			});
			$('##account-form').submit(function(event) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_tranGetList.cfm",
					headers: {'Content-Type': 'application/x-www-form-urlencoded'},
					data: $('##account-form').serialize(),
					beforeSend:function(){
						$('##loading').loading(true);
					},
					success:function(data){
						$('##tran-list').html(data).show();
						if (shouldClear) $('##tran-form, ##tran-items').html("").hide();
						$('##loading').loading(false);
						shouldClear = true;
						allowNewTran = true;
					},
					error:function(data){
						$('##tran-list').html(data);
						$('##loading').loading(false);
						$('##tran-list-toggle').show();
					}
				});
				event.preventDefault();
			});
			$('##btnSave').click(function(event) {
				event.preventDefault();
			});
			$('.overlayClose').click(function(event) {   
				$("##overlay").fadeOut();
				$("##overlay-ui").fadeOut();
				event.preventDefault();
			});
			
			$('##btnNewAccount').click(function(event) {
				$.popupDialog({
					file: "AJAX_loadNewAccountForm",
					width: 350
				});
				event.preventDefault();
			});
			$('##btnNewNominal').click(function(event) {
				$.popupDialog({
					file: "AJAX_loadNewNominalForm",
					width: 350
				});
				event.preventDefault();
			});
			$('.orderOverlayClose').click(function(event) {
				$("##orderOverlay").hide();
				$("##orderOverlay-ui").hide();
				event.preventDefault();
			});
			$('##btnNewAccTrans').click(function(event) {
				if (allowNewTran) {
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_loadEmptyTransHeaderForm.cfm",
						data: {
							"accID": $('##account').val()
						},
						beforeSend: function() {
							$('##loading').loading(true);
							$('##tran-form').html("");
							$('##tran-items').html("").hide();
						},
						success: function(data) {
							$('##tran-form').html(data).show();
							$('##loading').loading(false);
							$('##tran-list-toggle').show();
						}
					});
				} else {
					$.confirmation({
						accept: function() {
							$.ajax({
								type: "POST",
								url: "#parm.url#ajax/AJAX_loadEmptyTransHeaderForm.cfm",
								data: {
									"accID": $('##account').val()
								},
								beforeSend: function() {
									$('##loading').loading(true);
									$('##tran-form').html("");
									$('##tran-items').html("").hide();
								},
								success: function(data) {
									$('##tran-form').html(data).show();
									$('##loading').loading(false);
									$('##tran-list-toggle').show();
									allowNewTran = true;
								}
							});
						}
					});
				}
				event.preventDefault();
			});
			$("##Compile").click(function(event) {
				disableSave(true);
				if (validateTran()) {
					var cells = [];
					$('tr[data-static="edit"]').each(function(i, e) {
						$(e).attr("data-static", "false");
					});
					$('tr[data-static="false"]').each(function(i, e) {
						var rowType = $(e).attr("data-type");
						$(e).attr("data-static", "false");
						switch (rowType)
						{
							case "cf":
								var nomTitle = $(e).find('.aifNomTitleCell').html(),
									nomID = $(e).find('.aifNomTitleCell').attr("data-nomID"),
									recID = $(e).find('.aifNomTitleCell').attr("data-recID"),
									vatRate = $(e).find('.aifVATRateCell').html(),
									netAmount = $(e).find('.aifNetAmountCell').html(),
									vatAmount = $(e).find('.aifVatAmountCell').html();
								break;
							case "js":
								var nomCode = $(e).find('.nom').val().toLowerCase();
								var nomTitle = nominals[nomCode].nomtitle,
									nomID = nominals[nomCode].nomid,
									recID = 0,
									vatRate = $(e).find('##aifVAT').val(),
									netAmount = $(e).find('.niAmount').val(),
									vatAmount = $(e).find('##aifVATAmount').val();
								$(e).find('.nom').parent('td').html(nomTitle);
								$(e).find('##aifVAT').parent('td').html(nf(vatRate, "abs_str") + "%");
								$(e).find('.niAmount').parent('td').html(nf(netAmount, "num"));
								$(e).find('##aifVATAmount').parent('td').html(nf(vatAmount, "num"));
								$(e).attr("data-type", "cf");
								break;
						}
						cells.push({
							nomTitle: nomTitle,
							nomID: nomID,
							recID: recID,
							vatRate: nf(vatRate, "num"),
							netAmount: nf(netAmount, "num"),
							vatAmount: nf(vatAmount, "num")
						});
					});
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_saveSuppItems.cfm",
						data: {
							"items": JSON.stringify(cells),
							"header": JSON.stringify(serializeRecordEditForm()),
						},
						success: function(data) {
							shouldClear = false;
							var tData = data.trim();
							$.messageBox("Saved Successfully", "success");
							$('##EditID').val(tData);
							$('##account-form').submit();
							disableSave(false);
							switchHeaderType($('##HeaderType').val(), false);
						},
						error: function(error) {
							$.messageBox("An error occurred", "error");
						}
					});
				} else {
					$.messageBox("You cannot save right now", "error");
				}
				event.preventDefault();
			});
			getRandomColor = function() {
				var letters = '0123456789ABCDEF'.split('');
				var color = '##';
				for (var i = 0; i < 6; i++ ) {
					color += letters[Math.floor(Math.random() * 16)];
				}
				return color;
			}
			hexToRgb = function(hex) {
				var result = /^##?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
				return result ? {
					r: parseInt(result[1], 16),
					g: parseInt(result[2], 16),
					b: parseInt(result[3], 16)
				} : null;
			}
			rainbowMode = function() {
				$.confirmation({
					accept: function() {
						$('*').each(function(i, e) {
							setInterval(function() {
								var colour = getRandomColor();
								var rgb = hexToRgb(colour);
								var op = Math.random().toFixed(1);
								$(e).css({
									"background": "rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + "," + op + ")",
									"background-color": "rgba(" + rgb.r + "," + rgb.g + "," + rgb.b + "," + op + ")",
									"color": getRandomColor()
								});
							}, 250);
						});
					}
				});
			}
			allowNewTran = true;
		});
	</script>
	<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<div id="orderOverlay-ui"></div>
						<div id="orderOverlay">
						<div id="orderOverlayForm">
							<a href="##" class="orderOverlayClose">X</a>
							<div id="orderOverlayForm-inner"></div>
						</div>
					</div>
					
	<div id="wrapper" class="noPrint">
		<form method="post" enctype="multipart/form-data" id="account-form">
		<div class="element">
			Account: 
			<select name="accountID" data-placeholder="Select..." id="account" tabindex="1">
				<option value="">Select...</option>
				<cfloop array="#acctsList.accounts#" index="item">
					<option value="#item.accID#" <cfif item.accName eq srchAccount>selected="selected"</cfif>>#item.accName#</option>
				</cfloop>
			</select>
			<br />
			Reference: <input type="text" size="25" name="tranRef" value="" tabindex="2" />
		</div>
		<div class="element">
			Date Range:
			<select name="srchRange" data-placeholder="Select..." id="srchRange" tabindex="3">
				#accts.DateRangeOptions()#
			</select>
			<br />
			Tran Types:
			<select name="srchType" data-placeholder="Select..." id="srchType" tabindex="4">
				<option value="">All Types</option>
				<option value="inv">Invoices</option>
				<option value="crn">Credit Notes</option>
				<option value="ic">Invoices &amp; Credit Notes</option>
				<option value="pay">Payments</option>											
				<option value="rfd">Refunds</option>											
				<option value="jnl">Journals</option>
				<option value="pj">Payments, Journals &amp; Refunds</option>											
			</select>
		</div>
		<div class="element">
			Sort Order: 
			<select name="sortOrder" data-placeholder="Select..." id="sortOrder" tabindex="5">
				<option value="date" selected="selected">Transaction Date</option>
				<option value="id">Transaction ID</option>
				<option value="ref">Transaction Ref</option>
			</select>
			<br />
			<input type="checkbox" name="srchAllocated" value="1" id="srchAllocChk" tabindex="6"> Show Allocated
		</div>
		<div class="element">
			<input type="submit" value="Search" id="btnSearch" tabindex="-1" />
		</div>
		<div class="clear"></div>
		</form>
	</div>
<!---	<cfoutput>
		<select name="test">
			#accts.DateRangeOptions()#
		</select>
	</cfoutput>

					<form method="post" enctype="multipart/form-data" id="account-form">
						<div class="form-header" id="tranMainHeader">
							Account Transactions
							<span><div id="loading"></div></span>
						</div>
						<div class="module" id="tranMainFilters">
							<table border="1" cellpadding="2" cellspacing="0" width="100%">
								<tr>
									<td align="right">Account</td>
									<td>
										<select name="accountID" data-placeholder="Select..." id="account" tabindex="1">
											<option value="">Select...</option>
											<cfloop array="#acctsList.accounts#" index="item">
												<option value="#item.accID#" <cfif item.accName eq srchAccount>selected="selected"</cfif>>#item.accName#</option>
											</cfloop>
										</select>
									</td>
									<td align="right">Ref</td>
									<td><input type="text" size="10" name="tranRef" value="" tabindex="2" /></td>
									<td align="right">Sort Order</td>
									<td>
										<select name="sortOrder" data-placeholder="Select..." id="sortOrder" tabindex="3">
											<option value="date" selected="selected">Transaction Date</option>
											<option value="id">Transaction ID</option>
											<option value="ref">Transaction Ref</option>
										</select>
									</td>
									<td align="right">Records</td>
									<td>
										<select name="srchRange" data-placeholder="Select..." id="srchRange" tabindex="4">
											<option value="0">All Records</option>
											<option value="1">Last 7 Days</option>
											<option value="2">This Month</option>
											<option value="3">From Last Month</option>
											<option value="4">From Previous Month</option>
											<cfset dateKeys=ListSort(StructKeyList(application.site.FYDates,","),"text","ASC")>
											<cfloop list="#dateKeys#" index="key">
												<cfset item=StructFind(application.site.FYDates,key)>
												<option value="FY-#item.key#">Year #item.title#</option>
											</cfloop>
											<cfloop from="2013" to="#year(Now())#" index="yearNum">
												<option disabled>#yearNum#</option>
												<cfloop from="1" to="12" index="i">
													<option value="#yearNum#-#i#">#yearNum#-#NumberFormat(i,"00")#</option>
												</cfloop>
											</cfloop>
										</select>
										<br>
										<select name="srchType" data-placeholder="Select..." id="srchType" tabindex="5">
											<option value="">All Types</option>
											<option value="inv">Invoices</option>
											<option value="crn">Credit Notes</option>
											<option value="ic">Invoices &amp; Credit Notes</option>
											<option value="pay">Payments</option>											
											<option value="jnl">Journals</option>
											<option value="pj">Payments &amp; Journals</option>											
										</select>
									</td>
									<td>
										<label>
											<input type="checkbox" name="srchAllocated" value="1" id="srchAllocChk">
											Show Allocated
										</label>
									</td>
									<td><input type="submit" value="Search" id="btnSearch" tabindex="5" /></td>
								</tr>
							</table>
						</div>
					</form>
					
--->
					<div id="tran-list" class="module" style="display:none;"></div>
					<div id="tran-list-toggle" class="module noPrint"><a href="javascript:toggleTranList();" tabindex="-1">Toggle Transactions List</a></div>
					<div id="tran-form" class="module" style="display:none;"></div>
					<div id="tran-items" class="module" style="display:none;"></div>
					<div class="tran-controls module noPrint">
						<a href="javascript:void(0)" class="button button_white" id="btnNewAccount" style="float:left;font-size: 14px;margin-left:0;" tabindex="-1">New Account</a>
						<a href="javascript:void(0)" class="button button_white" id="btnNewNominal" style="float:left;font-size: 14px;" tabindex="-1">New Nominal</a>
						<a href="javascript:void(0)" class="button button_white" style="float:left;font-size: 14px;" tabindex="-1" onClick="javascript:rainbowMode();">Rainbow Mode</a>
						<button id="Compile" style="float:right;">Save Transaction</button>
						<button id="btnNewAccTrans" style="float:right;" tabindex="-1">New Transaction</button>
					</div>
					<div class="module" id="dump"></div>
					<div class="clear"></div>
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
</html>
