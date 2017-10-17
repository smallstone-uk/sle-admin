<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.ID=id>
<cfset parm.clientID=userID>

<script type="text/javascript">
	$(document).ready(function() {
		$('.printLetter').click(function(e) {
			<cfoutput>
				var id="#parm.ID#";
				var userID="#parm.clientID#";
			</cfoutput>
			var preview=$(this).attr("data-preview");
			$.ajax({
				type: 'POST',
				url: 'clientPaymentsLetter.cfm',
				data: {
					"id":id,
					"userID":userID,
					"preview":preview
				},
				success: function(data){
					$("#orderOverlay").fadeOut();
					$("#orderOverlay-ui").fadeOut();
					$('#LoadPrint').html(data).fadeIn(function() {
						$('#wrapper').addClass("noPrint");
						$('.form-wrap').addClass("noPrint");
						$('#print-area').removeClass("noPrint");
						//window.print();
	
							$('#print-area').printArea({extraHead:"<style type='text/css'>@media print {#LoadPrint {position:relative !important;left:0 !important;}}</style>"});
						$('#print-area').html(data);
					});
				}
			});
			e.preventDefault();
		});
	});
</script>

<cfoutput>
	<h1>Print Letter</h1>
	<div style="float:left;width:200px;">
		<p>Click 'Preview' to see a quick preview of the letter.</p>
		<a href="##" data-preview="1" class="printLetter button" style="float:left;">Preview</a>
	</div>
	<div style="float:left;width:200px;">
		<p>Click Print to commit to the chasing process.</p>
		<a href="##" data-preview="0" class="printLetter button">Print</a>
	</div>
</cfoutput>