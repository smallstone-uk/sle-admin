<cfoutput>
<div class="no-print" id="footer">
	<div id="footer-inner">
		<div id="nav">
			<ul>
				<li>
					<!--- Mike this is what's breaking the pubSearch - can you make this do an AJAX post instead 22/09/2013 --->
					<form name="settings" method="post" action="#script_name#">
						<input type="hidden" name="options" value="1" />
						<label><input type="checkbox" name="debug"<cfif application.site.debug> checked="checked"</cfif> onchange="doSubmit('settings')" /> Show debug &nbsp;</label>
						<label><input type="checkbox" name="showdumps"<cfif application.site.showdumps> checked="checked"</cfif> onchange="doSubmit('settings')" /> Show dumps</label>
					</form>	
					#GetLocale()#			
				</li>
			</ul>
		</div>
		<div id="contact">
			<span><b></b></span>
		</div>
		<div class="clear"></div>
	</div>
</div>
</cfoutput>