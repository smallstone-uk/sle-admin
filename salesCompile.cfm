<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset error="">

<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.set=1>
<cfset parm.tranID=form.transID>
<cfif form.ForceInt eq 0>
	<cfif REReplace(form.total,"£","","all") neq REReplace(form.trnAmnt1,"£","","all")>
		<cfset diff=DecimalFormat(REReplace(form.trnAmnt1,"£","","all")-REReplace(form.total,"£","","all"))>
		<cfset error=error&"<h3>Net amount and item total are not the same.</h3><p><b>Net Amount:</b> #form.trnAmnt1#<br><b>Item Total:</b> #form.total#<br><b>Difference:</b> £#diff#</p>">
	</cfif>
	<cfif REReplace(form.VatTotal,"£","","all") neq REReplace(form.trnAmnt2,"£","","all")>
		<cfset vatdiff=DecimalFormat(REReplace(form.trnAmnt2,"£","","all")-REReplace(form.VatTotal,"£","","all"))>
		<cfset error=error&"<h3>Vat amount and item vat total are not the same.</h3><p><b>VAT Amount:</b> #form.trnAmnt2#<br><b>Item VAT Total:</b> #form.VatTotal#<br><b>Difference:</b> £#vatdiff#</p>">
	</cfif>
</cfif>
<cfif NOT len(error)>
	<cfset activate=supp.ActivateTransaction(parm)>
	<script type="text/javascript">
		$(document).ready(function() {
			$('#loading').fadeOut();
			$('#transItems').html("");
			$('#ItemsList').html("");
			$('#EditID').val("");
			$('#ForceInt').val(0);
			$('#Mode').val(1);
			$('#Ref').val("");
			<cfoutput>$('##Date').val("#DateFormat(Now(),'DD/MM/YYYY')#");</cfoutput>
			$('#Ref').val("");
			$('#NetAmount').val("£0.00");
			$('#VATAmount').val("£0.00");
			$('#GrossTotal').val("£0.00");
			$('#Active').html("");
			$('#EditID').focus();
			$("#orderOverlay").hide();
		});
	</script>
<cfelse>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#orderOverlay").toggle();
			$("#orderOverlay-ui").toggle();
			<cfoutput>$('##orderOverlayForm-inner').html('<h1>Error</h1>#error#<a href="force" id="ForceSave" class="button clear">Continue Anyway</a>').fadeIn();</cfoutput>
			$('#orderOverlayForm').center();
			$('#ForceSave').click(function() {
				$('#ForceInt').val(1);
				$.ajax({
					type: 'POST',
					url: 'salesCompile.cfm',
					data : $('#account-form').serialize(),
					beforeSend:function(){},
					success:function(){
						$('#loading').fadeOut();
						$('#transItems').html("");
						$('#ItemsList').html("");
						$('#EditID').val("");
						$('#ForceInt').val(0);
						$('#Mode').val(1);
						$('#Ref').val("");
						<cfoutput>$('##Date').val("#DateFormat(Now(),'DD/MM/YYYY')#");</cfoutput>
						$('#Ref').val("");
						$('#NetAmount').val("£0.00");
						$('#VATAmount').val("£0.00");
						$('#GrossTotal').val("£0.00");
						$('#Active').html("");
						$('#EditID').focus();
						$("#orderOverlay").hide();
					},
					error:function(){}
				});
				event.preventDefault();
			});
		});
	</script>
</cfif>
