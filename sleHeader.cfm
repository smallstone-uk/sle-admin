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

<cfif cgi.REMOTE_ADDR eq "127.0.0.1">
	<style>
		#header {
			background: #108873 !important;
		}

		#header #nav {
			background: #085044 !important;
		}
	</style>
</cfif>

<div id="header">
	<div id="header-inner">
		<div id="logo">
			<span>
				<cfif cgi.REMOTE_ADDR eq "127.0.0.1">
					<strong>LOCAL - </strong>
				</cfif>
				Shortlanesend Store | Admin
			</span>
		</div>
		<div id="contact">
			<span><b>Tel</b>: 01872 275102</span>
			<span><b>Post Office</b>: 01872 223670</span>
			<span><b>Email</b>: news@shortlanesendstore.co.uk</span>
		</div>
		<div class="clear"></div>
	</div>
	<div id="nav">
		<div id="nav-inner">
			<div id="nav-quickfind">
				<div id="quickfind-loading" style="display:none;"><img src='images/loading_2.gif' class='loadingGif'></div>
				<!---<div class="calendar">
					<input type="text" name="psDate" id="Date" class="datepicker" value="" placeholder="date" style="width:26px;" tabindex="-1" />
				</div>--->
				<input type="text" name="quickfind" id="quickfind" value="" placeholder="Search client user account number, name or address...." tabindex="-1" />
				<div id="quickfind-list"></div>
			</div>
			<div class="nav-branch">
				<!--- <span>branch: deal-manager</span> --->
			</div>
			<ul id="menu" class="mega-menu">
				<li><a href="index.cfm" tabindex="-1">Home</a></li>
				<li><a href="##" tabindex="-1">News Management</a>
					<ul>
						<li><a href="clientAdd.cfm">New Customer</a></li>
						<li class="spacer"></li>
						<li><a href="clientSearch.cfm">Customer Search</a></li>
						<li><a href="clientPayments.cfm">Customer Payments</a></li>
						<li><a href="manualCharge.cfm">Manual Charging</a></li>
						<li class="spacer"></li>
						<li><a href="pubStock2.cfm">Publication Stock</a></li>
						<li><a href="voucherMain.cfm">Voucher Returns</a></li>
						<li class="spacer"></li>
						<li><a href="rounds5.cfm">Rounds</a></li>
						<li><a href="Invoicing.cfm">Invoicing</a></li>
						<li><a href="https://mapsengine.google.com/map/edit?mid=zePprILBGHcg.k1zT53hH1b0M" target="_blank">Rounds Map</a></li>
						<li class="spacer"></li>
						<li><a href="pubStockReport.cfm">Publication Report</a></li>
						<li><a href="forecast.cfm" target="_blank">Publication Forecast</a></li>
						<li><a href="pubChart.cfm" target="_blank">Publication Chart</a></li>
						<li class="spacer"></li>
						<li><a href="doorcodes.cfm" target="_blank">Door Codes</a></li>
						<li><a href="VoucherReport.cfm">Voucher Report</a></li>
						<li><a href="shopSaveAccount.cfm" target="_blank">Shop News Account Sheet</a></li>
						<li><a href="forecastMagazineOrders.cfm" target="_blank">Magazine Distribution Sheet</a></li>
						<li class="spacer"></li>
						<li><a href="pubNewsRetail.cfm" target="_blank">Newspaper Retail Price List</a></li>
						<li><a href="pubNewsPrices.cfm" target="_blank">Newspaper Stock Movement</a></li>
					</ul>
				</li>
				<li><a href="##" tabindex="-1">Shop Management</a>
					<ul>
						<li><a href="till.cfm">Till</a>
						<li class="spacer"></li>
						<li><a href="ProductStock3.cfm">Booker Stock</a></li>
						<li><a href="ProductStock2.cfm">Other Product Stock</a></li>
						<li><a href="PriceLabels.cfm">Price Labels</a></li>
						<li><a href="dealManager.cfm">Deal Manager</a></li>
						<li><a href="dealChecker.cfm">Deal Checker</a></li>
						<li class="spacer"></li>
						<li><a href="stockSearch.cfm">Stock Search</a></li>
						<li><a href="ProductStock6.cfm">Stock Management</a></li>
						<li class="spacer"></li>
						<li><a href="eposCats.cfm">EPOS Categories</a></li>
						<li><a href="eposEmpCats.cfm">EPOS Employee Categories</a></li>
						<li><a href="eposTrans.cfm">EPOS Transactions</a></li>
						<li><a href="missingDealChecker.cfm">Product Deal Checker</a></li>
						<li class="spacer"></li>
						<li><a href="bookerProcess.cfm">Import Booker Stock</a></li>
					</ul>
				</li>
				<li><a href="##" tabindex="-1">Accounting</a>
					<ul>
						<li><a href="salesMain.cfm">Sales</a></li>
						<li><a href="tranMain2.cfm">Supplier Transactions</a></li>
						<li><a href="nomTran.cfm">Nominal Ledger</a></li>
						<li><a href="nomManager.cfm">Nominal Manager</a></li>
						<li class="spacer"></li>
						<li><a href="nomReports.cfm">Sales Graphs</a></li>
						<li><a href="purReports.cfm">Transaction Reports</a></li>
						<li><a href="paymentBankSheet.cfm" target="_blank">Banking Sheet</a></li>
						<li class="spacer"></li>
						<li><a href="Payroll2.cfm">PayRoll</a></li>
						<li><a href="PayrollReport.cfm">PayRoll Reports</a></li>						
						<li class="spacer"></li>
						<li><a href="debtors.cfm">Aged Debtors List</a></li>
						<li><a href="sales.cfm">Sales Report</a></li>
						<li><a href="weekly.cfm">Weekly Report</a></li>
					</ul>
				</li>
				<li><a href="stockGetList.cfm" tabindex="-1">Stock List</a></li>
				<li><a href="logs.cfm" tabindex="-1">Logs</a></li>
			</ul>
		</div>
	</div>
</div>
