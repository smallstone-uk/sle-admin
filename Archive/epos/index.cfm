<cfset randNum=RandRange(1024,1220120,'SHA1PRNG')>
<!DOCTYPE html>
<html>
<head>
<title>EPOS | Shortlanesend Store</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<cfoutput>
	<link href="../css/chosen.css?#randNum#" rel="stylesheet" type="text/css">
	<link href="css/epos_black.css?#randNum#" rel="stylesheet" type="text/css">
	<!---<link href="css/epos_white.css?#randNum#" rel="stylesheet" type="text/css">--->
	<script src="../scripts/jquery-1.11.1.min.js?#randNum#"></script>
	<script src="../scripts/jquery-ui.js?#randNum#"></script>
	<script src="../scripts/chosen.jquery.js?#randNum#" type="text/javascript"></script>
	<script src="js/epos.js?#randNum#" type="text/javascript"></script>
	<script src="js/jquery.kinetic.min.js?#randNum#" type="text/javascript"></script>
</cfoutput>
<script type="text/javascript">
	$(document).ready(function() {
		/*setInterval(function() {
			$('*').removeClass("disable-select");
			$('*').addClass("disable-select");
		}, 1000);*/
		//$('#overlay').kinetic();
		$('#basket').LoadBasket();
		$('#leftcontrols').LoadCats();
		$('#keypadwrap').LoadKeypad();
		$(document).keypress(function(e){
			if ($('input').is(":focus")) {
				//console.log("focused");
			} else {
				$.Scanner(e);
			}
		});
		
		$('.clearbasket').click(function(e) {
			$('#basket').ClearBasket();
			e.preventDefault();
		});
		
		$('.datetime_time').currentTime(1);
		
		$('.switchUser').click(function(event) {
			$('.splash').css("top", "0");
			$('.login_time').css("top", "630px");
			$('.login_date').css("top", "770px");
			$('.pin_val').html("&nbsp;");
			$('.login').center("left");
			$.logout();
			event.preventDefault();
		});
		$('#commands .payment').click(function(e) {
			var fastcash=$(this).data("fastcash");
			var type=$(this).data("type");
			var subtype=$(this).data("subtype");
			var amount=window.keypadDecimal;
			var subtotal=nf($('.total .totalamount').html(),"num");
			var cashOnlyTotal = window.cashOnlyTotal;
			var basketTotal = window.basketTotal;
			
			if (type == "supplier") {
				$.PaymentSupplier(amount,subtotal,type,subtype)
			} else {
				if (Math.abs(Number(subtotal)) > 0) {
					switch (type)
					{
						case "card":
							$.PaymentCard({
								amount: amount,
								subtotal: subtotal,
								type: type,
								subtype: subtype,
								cashOnlyTotal: cashOnlyTotal,
								basketTotal: basketTotal
							});
							break;
						case "cash":
							$.PaymentCash(amount,subtotal,type,subtype);
							break;
						case "cheque":
							$.PaymentCheque(amount,subtotal,type,subtype);
							break;
						case "voucher":
							$.PaymentNewsVoucher(amount,subtotal,type,subtype);
							break;
						case "coupon":
							$.PaymentCoupon(amount,subtotal,type,subtype);
							break;
						default:
							$.messageBox("Payment method not complete","error");
							$.KeypadClear();
							$.CloseOverlay();
							break;
					}
				} else {
					if (type == "prize") {
						$.AddPrize(type, subtype);
					} else {
						$.messageBox("Please add items to the basket before adding payments","error");
						$.KeypadClear();
						$.CloseOverlay();
					}
				}
			}
			e.preventDefault();
		});
		$('#GetPrevTrans').click(function(e) {
			$('#basket').ClearBasket();
			$('#basket').LoadPrevTrans(function(){
				$('#basket').LoadBasket();
				$.messageBox("Editing Transaction","success");
			});
			e.preventDefault();
		});
		$('.receipt').click(function(e) {
			$.PrintReceipt();
			e.preventDefault();
		});
		$('.backoffice').click(function(e) {
			$.OpenBackoffice();
			e.preventDefault();
		});
		$('.opentill').click(function(e) {
			$.OpenTill();
			e.preventDefault();
		});
		
		$('.refund').click(function(e) {
			window.refundMode = true;
			$.ajax({
				type: "GET",
				url: "AJAX_SwitchTillToRefundMode.cfm",
				success: function(data) {
					$.messageBox("YOU ARE NOW IN REFUND MODE!", "success");
				}
			});
			e.preventDefault();
		});
	});
</script>
</head>

<cfif NOT StructKeyExists(session,"epos") OR NOT StructKeyExists(session,"eposdeals") OR NOT StructKeyExists(session,"epospayments")>
	<cfset session.epos = {}>
	<cfset session.eposeditID = 0>
	<cfset session.eposlasttransID = 0>
	<cfset session.eposrows = 0>
	<cfset session.eposCashonlyTotal=0>
	<cfset session.eposBasketTotal=0>
	<cfset session.eposdeals = {}>
	<cfset session.epospayments = {}>
	<cfset session.eposmode = "reg">
</cfif>

<cfoutput>
<body>
	<div style="position:fixed;top:0;left:0;z-index:9999999999999;">
		<!---<cfdump var="#session#" label="session" expand="no">--->
	</div>
	<div id="receiptresult" class="noscreen"></div>
	<div id="bodyroot" class="noprint">
		<cfinclude template="backoffice.cfm">
		<cfinclude template="login.cfm">
		<cfinclude template="numpad.cfm">
		<cfinclude template="keyboard.cfm">
		<div id="header">
			<div id="datetime">
				<span class="company">Shortlanesend Store <em>EPOS</em></span>
				<br />
				#LSDateFormat(Now(),"(dd/mm/yyyy) ddd dd mmm yyyy")#
				<span class="datetime_time"></span>
			</div>
			<div id="user">
				<span class="username"><cfif StructKeyExists(session.user,"firstname")>#session.user.firstname#</cfif>&nbsp;<cfif StructKeyExists(session.user,"lastname")>#session.user.lastname#</cfif></span>
				<a href="javascript:void(0)" class="switchUser">Switch User</a>
			</div>
		</div>
		<div id="leftcontrols"></div>
		<div id="overlay" style="display:none;" class="custom-scrollbar"></div>
		<div id="basket"></div>
		<div id="rightcontrols">
			<div id="commands">
				<ul>
					<li><span class="payment cash" data-type="cash" data-subtype="cash" data-fastcash="yes">Cash</span></li>
					<li><span class="payment card" data-type="card" data-subtype="card" data-fastcash="yes">Card</span></li>
					<li><span class="payment cheque" data-type="cheque" data-subtype="chq" data-fastcash="no">Cheque</span></li>
					<li><span class="payment voucher" data-type="voucher" data-subtype="vch" data-fastcash="no">Newspaper Voucher</span></li>
					<li><span class="payment prize" data-type="prize" data-subtype="cash" data-fastcash="no">Prize</span></li>
					<li><span class="payment coupon" data-type="coupon" data-subtype="vch" data-fastcash="no">Coupon</span></li>
					<li><span class="payment owners" data-type="owners" data-subtype="cash" data-fastcash="no">Owners Account</span></li>
					<li><span class="payment supplier" data-type="supplier" data-subtype="cash" data-fastcash="no">Supplier</span></li>
					<li><span class="payment refund" data-type="refund" data-subtype="cash" data-fastcash="no">Refund</span></li>
					<li><span class="backoffice">Back Office</span></li>
					<li><span class="prevtrans" id="GetPrevTrans">Previous Transaction</span></li>
					<li><span class="clearbasket">Clear Basket</span></li>
					<li><span class="receipt">Receipt</span></li>
					<li><span class="opentill">Open Till</span></li>
				</ul>
			</div>
			<div id="keypadwrap"></div>
		</div>
	</div>
</body>
</cfoutput>
</html>




