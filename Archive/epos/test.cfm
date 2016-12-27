<cftry>
<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
<!DOCTYPE html>
<html>
<head>
<title>EPOS | Shortlanesend Store</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<script src="../scripts/jquery-1.11.1.min.js"></script>
<script src="../scripts/jquery-ui.js"></script>
<script src="js/epos.js"></script>
</head>

<body>
	<script>
		$(document).ready(function(e) {
		
			getProduct = function(prodID, barcode) {
				$.ajax({
					type: "POST",
					url: "AJAX_GetProductWithRegExp.cfm",
					data: {
						"prodID": prodID,
						"barcode": barcode
					},
					success: function(data) {
						var result = $.parseReturn(data);
						$('.result').append("<br />Product Title: " + result.title);
						$('.result').append("<br />Product Price: " + nf(result.price, "str"));
					}
				});
			}
		
			getBarcode = function(barcode) {
				$.ajax({
					type: "POST",
					url: "AJAX_GetBarcode.cfm",
					data: {"barcode": barcode},
					success: function(data) {
						var result = $.parseReturn(data);
						$('.result').append("<br />Product ID: " + result.id);
						$('.result').append("<br />Type: " + result.type);
						$('.result').append("<br />Error: " + result.error);
						getProduct(result.id, barcode);
					}
				});
			}
			
			$(document).keypress(function(e){
				if ( !($('input').is(":focus")) ) {
					var code = window.barcode;
					if (e.keyCode == 13) {
						if (code.length >= 8 & code.length <= 14) {
							$('.result').html("Original Barcode: " + window.barcode);
							getBarcode(window.barcode);
							window.barcode = "";
						} else {
							window.barcode = "";
						}
					} else {
						if (code != "") {
							var currentString = code;
							var newString = currentString + String.fromCharCode(e.keyCode);
						} else {
							var newString = String.fromCharCode(e.keyCode);
						}
						window.barcode = newString;
					}
				}
			});
			
		});
	</script>
	<div class="result" style="float:left;margin:50px;"></div>
	
	LOTTERY
		TICKETS
			2083801	2	0200	0	LOTTO					SAT
			2083801	2	0200	0	LOTTO					SAT
			2083801	2	0200	0	LOTTO					SAT
			2083801	2	0200	0	LOTTO					SAT
			2083801	2	0200	0	LOTTO			WED
			2083801	3	0600	5	LOTTO			WED
			2083801	3	0600	5	LOTTO					SAT
			2083801	3	0600	5	LOTTO					SAT
			2083801	3	0600	5	LOTTO			WED
			2083801	4	0400	8	LOTTO					SAT
			2083801	5	0800	3	LOTTO			WED		SAT
			
			2083803	2	0200	8	EUROMILLIONS		FRI
			2083803	3	0600	3	EUROMILLIONS		FRI
			2083803	4	0400	6	EUROMILLIONS		FRI
			
			2083804	6	0100	8	THUNDERBALL				SAT
			2083804	8	1200	8	THUNDERBALL		WED	FRI	SAT
			
			2083805	6	0100	7	HOTPICKS		WED
		SCRATCH CARDS
			5031390	1	0975	7	BINGO
			5031390	1	0984	9	RED ONE
	
	TELEGRAPH
		9925141	39	0005	Mon
		9925141	39	0005	Tue
		9925141	39	0005	Wed
		9925141	39	0005	Thu
		9925141	39	0005	Fri
							
		9925141	40	0001	Sat
							
		9925141	41	0000	Sun
		
	TIMES
		99002609	6	0001	SUN
		99002609	5	0002	SAT
		99002609	4	0003	FRI
		99002609	3	0004	THU
		99002609	2	0005	WED
		99002609	1	0006	TUE
		99002609	0	0007	MON
		
	GUARDIAN / OBSERVER
		99247652	7	0007	WEEKDAY
		99247652	7	0007	WEEKDAY
		99247652	7	0007	WEEKDAY
		99247652	7	0007	WEEKDAY
		99247652	7	0007	WEEKDAY
		99247652	8	0006	SAT
		99247652	9	0005	SUN
		
	FINANCIAL TIMES
		BOLSHAW
			06610006	062043	0000	38	1	2	MON
			06610006	062043	0000	39	1	1	TUE
			06610006	062043	0000	40	1	7	WED
			06610006	062043	0000	41	1	6	THU
			06610006	062043	0000	42	1	5	FRI
			06610006	062043	0000	43	1	4	WEEKEND
			06610006	062043	0000	44	1	3	MON
			06610006	062043	0000	45	1	2	TUE
			06610006	062043	0000	46	1	1	WED
			06610006	062043	0000	47	1	0	THU
			06610006	062043	0000	48	1	9	FRI
			06610006	062043	0000	49	1	8	WEEKEND
			
		WATSON
			06610006	265781	0000	26	1	5	MON
			06610006	265781	0000	27	1	4	TUE
			06610006	265781	0000	28	1	3	WED
			06610006	265781	0000	29	1	2	THU
			06610006	265781	0000	30	1	8	FRI
			06610006	265781	0000	31	1	7	WEEKEND
			06610006	265781	0000	32	1	6	MON
			06610006	265781	0000	33	1	5	TUE
			06610006	265781	0000	34	1	4	WED
			06610006	265781	0000	35	1	3	THU
			06610006	265781	0000	36	1	2	FRI
			06610006	265781	0000	37	1	1	WEEKEND
			
		
	DAILY MAIL
		99066780	20009
		99066780	30008
		99066780	40007
		99066780	50006
		99066780	60005
		99066780	20009
		99066780	30008
		99066780	40007
		99066780	50006
		99066780	60005
</body>
</html>
</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>