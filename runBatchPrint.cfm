<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1> <!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">

<cfobject component="code/functions" name="fnc">
<cfset parm={}>
<cfset parm.client=val(url.client)>
<cfset parm.datasource=application.site.datasource1>
<cfset print=fnc.PrintStatments(parm)>

<cfoutput>
	<cfif StructKeyExists(url,"client")>
		<h1>In Progress</h1>
		<div id="progress">
			<cfif url.total neq url.row>
				<img src='images/loading_2.gif' class='loadingGif'>&nbsp;#url.row# of #url.total#
				<div style="padding:10px 0;">
					<b>#print.Name#</b><br>
					Status: #print.Status#<br>
				</div>
			<cfelse>
				Completed
			</cfif>
		</div>
	</cfif>
</cfoutput>