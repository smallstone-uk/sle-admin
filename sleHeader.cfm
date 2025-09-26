<script type="text/javascript">
	$(document).ready(function() {
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: false});
		$(document).click(function(event) {
			$('#quickfind-list').slideUp(function() {
				$('#quickfind').val("").animate({"width":"150px"}, 500);
			});
		});
		$('#nav-quickfind').click(function(event) {
			event.stopPropagation();
		});
		$('#quickfind').click(function(event) {
			$('#quickfind').animate({"width":"350px"}, 500);
		});
		$('#quickfind').on("keyup",function(e) {
			var x=$('#quickfind').val();
			if (x != "") {
				$('#quickfind-loading').fadeIn();
				$.ajax({
					type: 'POST',
					url: 'sleHeaderQuickFindList.cfm',
					data: {"search":x},
					success:function(data){
						$('#quickfind-list').html(data).slideDown(function() {
							$('#quickfind-loading').fadeOut();
						});
					}
				});
			} else {
				$('#quickfind-list').slideUp();
				$('#quickfind-loading').fadeOut();
			}
		});
	});
</script>
<cfoutput>
	<cfset minAgeDate = DateAdd("yyyy",-18,Now())>
<div id="header">
	<div id="header-inner">
		<div id="logo"><a href="index.cfm" tabindex="-1"><span>#application.company.name#</span></a></div>
		<div id="contact">
			<span><b>Age Check: #DateFormat(minAgeDate,'yyyy mm dd')# &nbsp; <b>Tel</b>: 01872 275102</span>
			<span><b>Post Office</b>: 01872 223670</span>
			<span><b>Email</b>: #application.company.email_news#</span>
		</div>
		<div class="clear"></div>
	</div>
	<div id="nav">
		<div id="nav-inner">
			<div id="nav-quickfind">
				<div id="quickfind-loading" style="display:none;"><img src='images/loading_2.gif' class='loadingGif'></div>
				<input type="text" name="quickfind" id="quickfind" value="" placeholder="Search client user account number, name or address...." tabindex="-1" />
				<div id="quickfind-list"></div>
			</div>
			<div class="nav-branch">
				<!--- <span>branch: deal-manager</span> --->
			</div>
			<ul id="menu" class="mega-menu">
				<li><a href="##" tabindex="-1">News Management</a>
					<ul>
						<li><a href="rounds6.cfm">Run Out Rounds</a></li>
						<li><a href="pubStock2.cfm">Publication Stock</a></li>
						<li class="spacer"></li>
						<li><a href="voucherMain.cfm">Voucher Returns</a></li>
						<li><a href="VoucherReport.cfm">Voucher Report</a></li>
						<li class="spacer"></li>
						<li><a href="Invoicing.cfm">News Invoicing</a></li>
						<li><a href="clientemail.cfm">Email News Invoices</a></li>
						<li><a href="paymentBankSheet.cfm" target="_blank">News Cheques Banking</a></li>
						<li class="spacer"></li>
						<li><a href="debtors.cfm">Aged News Debtors List</a></li>
						<li><a href="sales.cfm">News Sales Report</a></li>
						<li><a href="rounds6income3.cfm">Rounds Income</a></li>
						<li class="spacer"></li>
						<li><a href="clientAdd.cfm">Add News Customer</a></li>
						<li><a href="clientSearch.cfm">News Customer Search</a></li>
						<li><a href="clientPayments.cfm">News Customer Payments</a></li>
						<li><a href="doorcodes.cfm" target="_blank">Door Codes</a></li>
						<li class="spacer"></li>
						<li><a href="pubStockReport.cfm">Publication Report</a></li>
						<li><a href="forecast.cfm" target="_blank">Publication Forecast</a></li>
						<li><a href="pubChart.cfm" target="_blank">Publication Chart</a></li>
						<li class="spacer"></li>
						<li><a href="forecastMagazineOrders.cfm" target="_blank">Magazine Distribution Sheet</a></li>
						<li><a href="pubNewsRetail.cfm" target="_blank">Newspaper Retail Price List</a></li>
						<!---<li><a href="https://mapsengine.google.com/map/edit?mid=zePprILBGHcg.k1zT53hH1b0M" target="_blank">Rounds Map</a></li>--->
					</ul>
				</li>
				<li><a href="##" tabindex="-1">Shop Management</a>
					<ul>
						<li><a href="stockSearch.cfm">Stock Search</a></li>
						<li><a href="ProductStock6.cfm">Stock Management</a></li>
						<li><a href="stockGetList.cfm">Stock List</a></li>
						<li class="spacer"></li>
						<li><a href="dealManager.cfm">Deal Manager</a></li>
						<li><a href="dealChecker.cfm">Deal Checker</a></li>
						<li class="spacer"></li>
						<li><a href="ProductStock3.cfm">Booker Stock</a></li>
						<li><a href="bookerProcess.cfm">Import Booker Stock</a></li>
						<li class="spacer"></li>
						<li><a href="#application.site.url2#">EPOS Till</a>
						<li><a href="eposCats.cfm">EPOS Categories</a></li>
						<li><a href="eposEmpCats.cfm">EPOS Employee Categories</a></li>
						<li class="spacer"></li>
						<li><a href="#application.site.url2#reportdaysheet.cfm" target="_blank">EPOS Day Report</a></li>
						<li><a href="#application.site.url2#reportaccounts.cfm" target="_blank">EPOS Accounts</a></li>
						<li><a href="#application.site.url2#reportAnalysis.cfm" target="_blank">EPOS Analysis</a></li>
						<li><a href="#application.site.url2#reportAnalysis2.cfm" target="_blank">EPOS Analysis by Hour</a></li>
					</ul>
				</li>
				<li><a href="##" tabindex="-1">Accounting</a>
					<ul>
						<li><a href="salesMain3.cfm">Sales Transactions</a></li>
						<li><a href="tranMain2.cfm">Supplier Transactions</a></li>
						<li><a href="nomTran.cfm">Nominal Transactions</a></li>
						<li class="spacer"></li>
						<li><a href="#application.site.url2#reportdaysheet3.cfm" target="_blank">Import Till Data</a></li>
						<li><a href="spread2.cfm">Import Bank Statement</a></li>
						<li><a href="spreadloan.cfm">Import Bank Loan Statement</a></li>
						<li><a href="importnominal.cfm">Import Nominal Transactions</a></li>
						<li class="spacer"></li>
						<li><a href="nomManager.cfm">Nominal Manager</a></li>
						<li><a href="nomReports.cfm">Nominal Graphs</a></li>
						<li class="spacer"></li>
						<li><a href="Payroll2.cfm">Staff PayRoll</a></li>
						<li><a href="importDelWages.cfm">Import Drivers Wages</a></li>
						<li><a href="PayrollReport.cfm">PayRoll Reports</a></li>						
						<li class="spacer"></li>
						<li><a href="salesgraph.cfm">Sales Graphs</a></li>
						<li><a href="bunperformance.cfm">Bunnery Performance</a></li>
						<li><a href="salesreports.cfm">Stock Movement Report</a></li>
					</ul>
				</li>
				<li><a href="##" tabindex="-1">Reports</a>
					<ul>
						<li><a href="purReports.cfm">Transaction Reports</a></li>
						<li><a href="suppliers.cfm">Supplier Reports</a></li>
						<li class="spacer"></li>
						<li><a href="vatReport.cfm">VAT Reports</a></li>
						<li><a href="accReports.cfm">Accounting Reports</a></li>
						<li class="spacer"></li>
						<li><a href="birthday.cfm">Staff Birthdays</a></li>
					</ul>
				</li>
			</ul>
		</div>
	</div>
</div>
</cfoutput>