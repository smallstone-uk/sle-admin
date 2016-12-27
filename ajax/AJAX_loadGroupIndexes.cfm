<cftry>
	<cfobject component="code/accounts" name="acc">
	<cfsetting showdebugoutput="no">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset nominals = acc.LoadNominalGroupsWithItems(parm)>
	
	<cfoutput>
		<script>
			$(document).ready(function(e) {
				$('.nomManControl').click(function(event) {
					var value = $(this).html().trim();
					$('.nomManControl').removeClass("nomManControl_Active");
					$(this).addClass("nomManControl_Active");
					$('.nomMan-groupTitleStr').removeClass("nomMan-groupTitleStr_active");
					$('.hr-left').removeClass("hr-left-active");
					$('.hr-right').removeClass("hr-right-active");
					if (value.length > 0) {
						$('body').scrollTo('.nomMan-groupTitle[data-group="' + value + '"]', 1000, {
							easing: "easeInOutCubic",
							offset: {left: 0, top: -50},
							onAfter: function() {
								$('.nomMan-groupTitle[data-group="' + value + '"]').find('.nomMan-groupTitleStr').addClass("nomMan-groupTitleStr_active");
								$('.nomMan-groupTitle[data-group="' + value + '"]').find('.hr-left').addClass("hr-left-active");
								$('.nomMan-groupTitle[data-group="' + value + '"]').find('.hr-right').addClass("hr-right-active");
							}
						});
					} else {
						$('body').scrollTo(0, 1000, {
							easing: "easeInOutCubic"
						});
					}
					event.preventDefault();
				});
			});
		</script>
		<ul>
			<li class="nomManControl nomManControl-Top nomManControl_Active"></li>
			<cfloop array="#nominals#" index="item">
				<li class="nomManControl">#item.group.name#</li>
			</cfloop>
		</ul>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

