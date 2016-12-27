<cftry>
<script src="../scripts/jquery-1.11.1.min.js"></script>
<script src="../scripts/jquery-ui.js"></script>
<script src="js/epos.js"></script>

<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.code = (StructKeyExists(url, "code")) ? url.code : 0>
<cfset output = epos.InterrogateBarcode(parm.code)>

<cfdump var="#output#" label="output" expand="yes">

<cfoutput>
	<script>
		$(document).ready(function(e) {
			$(document).keypress(function(e){
				if ( !($('input').is(":focus")) ) {
					var code = window.barcode;
					if (e.keyCode == 13) {
						if (code.length >= 8 & code.length <= 14) {
							window.location = "barcodeTest.cfm?code=" + window.barcode;
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
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>