<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<script type="text/javascript">
	$(document).ready(function() {
		$('#btnPrintReturnsSheet').click(function(e) {
			PrintReturnSheet();
			e.preventDefault();
		});
		$('#printOptionsForm').submit(function(e) {
			PrintReturnSheet();
			e.preventDefault();
		});
		$('#returnBarcode').focus();
	});
</script>

<cfoutput>
	<h1>Print</h1>
	<form method="post" id="printOptionsForm">
		<input type="hidden" name="psDate" value="#LSDateFormat(form.date,'yyyy-mm-dd')#" />
		<select name="printType">
			<option value="Magazine">Magazines</option>
			<option value="News">Newspapers</option>
		</select>
		<input type="button" id="btnPrintReturnsSheet" value="Print" />
	</form>
</cfoutput>
