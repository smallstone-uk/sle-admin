<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=epos.LoadProduct(parm)>

<cfoutput>
	<cfif load.price neq 0>
		<script type="text/javascript">
			$(document).ready(function(e) {
				$.messageBox("#load.prodtitle# added to basket","success");
			});
		</script>
		<cfset add=epos.AddToBasket(load)>
	<cfelse>
		<div id="tempscript">
			<script>
				$(document).ready(function(e) {
					$('##keypad').eyeFocus({
						position: "fixed",
						on: true,
						popup: true,
						popupTitle: "#load.prodtitle#",
						popupMessage: "Please enter an amount for the selected product.",
						cancel: function() {
							$('##btnEnter').unbind("click");
						}
					});
					$('##btnEnter').bind("click", function(e) {
						$('##keypad').eyeFocus({
							position: "fixed",
							on: false,
							popup: true,
							success: function() {
								$.LoadProduct(0,"#load.prodID#",window.keypadDecimal,"product",1);
								$.KeypadClear();
								$.CloseOverlay();
								$('##btnEnter').unbind("click");
							}
						});
						e.preventDefault();
					});
				});
			</script>
		</div>
	</cfif>
</cfoutput>