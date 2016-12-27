<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset roundsFileList=rnd.LoadRoundFiles(parm)>

<cfoutput>
	<div class="round-charged" style="margin:10px 0 0 0;font-family: Arial, Helvetica, sans-serif;">
		<b style="line-height:30px;font-size:13px;padding:0 25px;">Latest Charged Rounds</b>
		<cfif ArrayLen(roundsFileList)>
			<ul>
				<cfloop array="#roundsFileList#" index="i">
					<li style="padding:4px 25px;margin:0 0 4px 0;border-bottom:1px solid ##ccc;">
						<cfif FileExists("#application.site.dir_data#rounds/#LSDateFormat(i.Ref,'YY-MM')#/#LSDateFormat(i.Ref,'yyyy-mm-dd')#.pdf")>
							<a href="#application.site.url_data#rounds/#LSDateFormat(i.Ref,'YY-MM')#/#LSDateFormat(i.Ref,'yyyy-mm-dd')#.pdf" target="_blank">#LSDateFormat(i.Ref,"DD/MM/YYYY (DDD)")#</a>
						<cfelse>
							#LSDateFormat(i.Ref,"DD/MM/YYYY (DDD)")#
						</cfif>
						<cfif len(i.Time)><span style="float:right;color:##999;" title="#i.Date#">#i.Time#</span></cfif>
					</li>
				</cfloop>
			</ul>
		</cfif>
	</div>
</cfoutput>