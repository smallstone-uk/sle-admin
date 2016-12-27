<cfcomponent displayname="messages" extends="core">

	<cffunction name="LoadMessages" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QMsgs="">
		<cfset var QComments="">
		<cfset startDate=DateAdd("d",-args.days,Now())>
		
		<cfquery name="QMsgs" datasource="#args.datasource#">
			SELECT *, tblClients.cltRef,tblClients.cltName,tblClients.cltCompanyName,tblClients.cltDelTel
			FROM tblNotification, tblClients
			WHERE notClientID=cltID
			AND (notStatus<>'archived')
			AND (notUrgent OR notEntered >= '#LSDateFormat(startDate,"yyyy-mm-dd")#')
			ORDER BY notUrgent desc, notImportant desc, notEntered desc, notStatus asc
		</cfquery>
		
		<cfloop query="QMsgs">
			<cfquery name="QComments" datasource="#args.datasource#">
				SELECT COUNT(ncID) AS Total
				FROM tblNotificationComments
				WHERE ncNotID=#notID#
				ORDER BY ncTimestamp desc
			</cfquery>
			<cfset item={}>
			<cfset item.ID=notID>
			<cfset item.ClientID=notClientID>
			<cfset item.ClientRef=cltRef>
			<cfif len(cltName) AND len(cltCompanyName)>
				<cfset item.ClientName="#cltName# #cltCompanyName#">
			<cfelse>
				<cfset item.ClientName="#cltName##cltCompanyName#">
			</cfif>
			<cfset item.ClientTel=cltDelTel>
			<cfset item.Timestamp="#LSDateFormat(notEntered,'DD/MMM/YY')# #TimeFormat(notEntered,'HH:mm')#">
			<cfset item.Type=notType>
			<cfset item.Text=notText>
			<cfset item.Status=notStatus>
			<cfset item.Urgent=notUrgent>
			<cfset item.Important=notImportant>
			<cfset item.Comments=val(QComments.Total)>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadMessageComments" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QComments="">
		
		<cfquery name="QComments" datasource="#args.datasource#">
			SELECT *
			FROM tblNotificationComments
			WHERE ncNotID=#val(args.msgID)#
			ORDER BY ncTimestamp desc
		</cfquery>
		<cfloop query="QComments">
			<cfset item={}>
			<cfset item.ID=ncID>
			<cfset item.Timestamp="#LSDateFormat(ncTimestamp,'DD/MMM/YY')# #TimeFormat(ncTimestamp,'HH:mm')#">
			<cfset item.Comment=ncComment>
			<cfset ArrayAppend(result,item)>
		</cfloop>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="AddComment" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QAdd="">
		
		<cfif StructKeyExists(args.form,"msgID")>
			<cfquery name="QAdd" datasource="#args.datasource#">
				INSERT INTO tblNotificationComments (
					ncNotID,
					ncComment
				) VALUES (
					#args.form.msgID#,
					'#args.form.comment#'
				)
			</cfquery>
		</cfif>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateStatus" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdate="">

		<cfquery name="QUpdate" datasource="#args.datasource#">
			UPDATE tblNotification
			SET 
			<cfif StructKeyExists(args.form,"urgent")>notUrgent=1,<cfelse>notUrgent=0,</cfif>
			notStatus='#args.form.status#'
			WHERE notID=#args.form.msgID#
		</cfquery>

		<cfreturn result>
	</cffunction>

</cfcomponent>




