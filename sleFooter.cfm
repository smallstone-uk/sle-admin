<cfoutput>
<div class="no-print" id="footer">
	<div id="footer-inner">
		<div id="foot-nav">
			<ul>
				<li>
					<!--- Mike this is what's breaking the pubSearch - can you make this do an AJAX post instead 22/09/2013 --->
					<form name="settings" method="post" action="#script_name#">
						<input type="hidden" name="options" value="1" />
						<label><input type="checkbox" tabindex="-1" name="debug"<cfif application.site.debug> checked="checked"</cfif> 
                        	onchange="doSubmit('settings')" /> Show debug &nbsp;</label>
						<label><input type="checkbox" tabindex="-1" name="showdumps"<cfif application.site.showdumps> checked="checked"</cfif> 
                        	onchange="doSubmit('settings')" /> Show dumps &nbsp;</label>
                        <label>#GetLocale()#</label>
					</form>	
				</li>
			</ul>
		</div>
		<div class="clear"></div>
	</div>
</div>
</cfoutput>