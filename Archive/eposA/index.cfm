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
		setInterval(function() {
			$('*').removeClass("disable-select");
			$('*').addClass("disable-select");
		}, 1000);
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
		
		var d = new Date();
		$('.datetime_time').html( ('0' + d.getHours()).slice(-2) + ":" + ('0' + d.getMinutes()).slice(-2) + ":" + ('0' + d.getSeconds()).slice(-2) );
		setInterval(function() {
			var d = new Date();
			$('.datetime_time').html( ('0' + d.getHours()).slice(-2) + ":" + ('0' + d.getMinutes()).slice(-2) + ":" + ('0' + d.getSeconds()).slice(-2) );
		}, 1000);
		
		$('.switchUser').click(function(event) {
			$('.splash').fadeIn(250);
			$('.pin_val').html("&nbsp;");
			$('.login').center();
		    $('.pin').center("left");
			$.logout();
			event.preventDefault();
		});
		$('#commands .payment').click(function(e) {
			var fastcash=$(this).data("fastcash");
			var type=$(this).data("type");
			var subtype=$(this).data("subtype");
			var amount=window.keypadDecimal;
			var subtotal=nf($('.total .totalamount').html(),"num");
			if (subtype == "card" && Number(amount) === 0) {
				$.keypadFocus("Card", "Please enter the amount shown on the <b>PayPoint receipt.</b>", true);
				$('#btnEnter').css("background","#0D58A1");
				$('#btnEnter').bind("click", function(e) {
					$.keypadFocus("Card", "You need to do something", false, function() {
						$.TransPayment(type,subtype,window.keypadDecimal);
						$.KeypadClear();
						$.CloseOverlay();
						$('#btnEnter').unbind("click");
					});
					e.preventDefault();
				});
			} else {
				if (subtype == "cash" && window.cashonlyError) {
					$.confirmation({
						message: "<h1>Confirm</h1>Are you sure you have recieved cash for the CASH ONLY item(s)?",
						action: function() {
							$.TransPayment(type,subtype,subtotal);
						}
					});
				} else {
					if (amount > 0) { 
						$.TransPayment(type,subtype,amount);
					} else if (subtotal > 0 && fastcash == "yes")  {
						$.TransPayment(type,subtype,subtotal);
					}
				}
			}
			e.preventDefault();
		});
		$('#GetPrevTrans').click(function(e) {
			$('#basket').ClearBasket();
			$('#basket').LoadPrevTrans(function(){
				$('#basket').LoadBasket();
			});
			e.preventDefault();
		});
	});
</script>
</head>

<cfif NOT StructKeyExists(session,"epos") OR NOT StructKeyExists(session,"eposdeals") OR NOT StructKeyExists(session,"epospayments")>
	<cfset session.epos = {}>
	<cfset session.eposeditID = 0>
	<cfset session.eposdeals = {}>
	<cfset session.epospayments = []>
</cfif>

<cfoutput>
<body>
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
				<li><span class="payment voucher" data-type="voucher" data-subtype="vch" data-fastcash="no">News Voucher</span></li>
				<li><span class="payment coupon" data-type="coupon" data-subtype="vch" data-fastcash="no">Coupon</span></li>
				<li><span class="payment refund" data-type="refund" data-subtype="cash" data-fastcash="no">Refund</span></li>
				<li><span class="clearbasket">Clear Basket</span></li>
				<li><span class="payment owners" data-type="owners" data-subtype="cash" data-fastcash="no">Owners Account</span></li>
				<li><span class="backoffice">Back Office</span></li>
				<li><span id="GetPrevTrans">Prev Transaction</span></li>
			</ul>
		</div>
		<div id="keypadwrap"></div>
	</div>
</body>
</cfoutput>
</html>




