<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
	<cfif session.user.id gt 0>
		<cfset parm.userID = session.user.id>
		<cfset userPrefs = epos.LoadUserPreferences(parm)>
		<cfset session.user.prefs = userPrefs>
		<cfif session.epos_frame.mode eq "rfd">
			<cfset userPrefs.empAccent = "##7B693D">
		</cfif>
		<style>
			<!---BACKGROUND ACCENT--->
			.header,
			.productSearch,
			.categories_item:active,
			button,
			button:active,
			.basket_checkout,
			.productSearch:active,
			.big_datepicker_backdrop ul li,
			.openSale,
			.home_list_item,
			.loadHome,
			.r_start,
			.r_tick,
			.archive_item,
			.payment_item,
			.payment_item_special,
			.FCDPPHeader,
			.FCDPPWRIDay_Active,
			.button_select .active_button,
			.option_left:active,
			.option_right:active,
			.products_item,
			.controls button,
			.controls input,
			.continueBtn,
			.previousBtn
			{background:#userPrefs.empAccent#;}
			
			<!---BACKGROUND DARK--->
			.productSearch:active,
			button:active,
			.openSale:active,
			.home_list_item:active,
			.loadHome:active,
			.payment_item:active,
			.payment_item_special:active,
			.products_item:active,
			.continueBtn:active,
			.previousBtn:active
			{background:##222;}
			
			<!---BACKGROUND ACCENT IMPORTANT--->
			.virtual_keyboard span:active,
			.vk_key_active,
			.virtual_numpad span:active,
			.vkn_close:active,
			.user_reminders ul li:active,
			.FCDPPWRIDay_Active,
			.suc_profile,
			.loggedInTile,
			.sectionContinue,
			.sectionBack
			{background:#userPrefs.empAccent# !important;}
			
			<!---BORDER / COLOUR ACCENT IMPORTANT--->
			.searchItem:active,
			.bo_controlList li:active,
			.r_row_completed,
			.reminders ul h1
			{border-color:#userPrefs.empAccent# !important;color:#userPrefs.empAccent# !important;}
			
			<!---BORDER ACCENT IMPORTANT--->
			input[type="text"]:focus,
			.FCDPPHeader,
			.FCDPPWRIDay
			{border-color:#userPrefs.empAccent# !important;}
			
			<!---COLOUR ACCENT IMPORTANT--->
			.touch_menu_active,
			.touch_menu
			.touch_menu_inner li:active,
			.header_note,
			.close-button
			{color: #userPrefs.empAccent# !important;}
			
			<!---SCROLL BAR--->
			::-webkit-scrollbar
			{width: 25px;background:##444;}
			::-webkit-scrollbar-thumb
			{background:#userPrefs.empAccent#;}
		</style>
	</cfif>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>