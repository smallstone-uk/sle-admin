<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/messages" name="msg">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.msgID=id>
<cfset comments=msg.LoadMessageComments(parm)>

<cfoutput>
	<cfloop array="#comments#" index="com">
		<div class="comment-wrap">
			<div class="comment-timestamp">#DateFormat(com.Timestamp,"dd-mmm-yy")# #TimeFormat(com.Timestamp,"HH:MM")#</div>
			<div class="comment-text">#com.Comment#</div>
		</div>
	</cfloop>
</cfoutput>