
<cfcomponent displayname="application" extends="CMSCode/CoreFunctions">

	<cfscript>
		this.name="slecfc";
		this.clientStorage="kcc_cf_sle";
		this.clientManagement=true;
		this.sessionManagement=true;
		this.applicationTimeout=createTimeSpan(2,0,0,0);	// 2 days
		this.sessionTimeout=createTimeSpan(0,0,60,0);		// 60 mins
		this.setClientCookies=true;

	</cfscript>

	<!--- Boot Framework --->
	<cfset new App.Framework.Application.Boot()>

	<cffunction name="onApplicationStart" output="true" returntype="boolean">
		<cfset var serverHost=ListFirst(CGI.HTTP_HOST,".")>
		<cfset var useCustom=false>
		<cfset var SettingsXml="">
		<cfset var SettingsXmlObject="">
		<cfset var globalSettings="">
		<cfset var group="">
		<cfset var SettingGroup="">
		<cfset var settingName="">
		<cfset var SettingNode="">
		<cfset var srvFactory="">
		<cfset var debugService="">
		<cfset var IPList="">

		<!--- Load variables from appSettings.xml based on server address --->
		<cfset useCustom=FileExists(ExpandPath('/custom/config/#serverHost#-Settings.xml'))>
		<cfif useCustom>
			<cffile action="read" variable="SettingsXml" file="#expandPath('/custom/config/#serverHost#-Settings.xml')#">
		<cfelse>
			<cffile action="read" variable="SettingsXml" file="#expandPath('/core/config/#serverHost#-Settings.xml')#">
		</cfif>	
		<cfset SettingsXmlObject=xmlParse(SettingsXml)>	
		<cfset globalSettings=xmlSearch(SettingsXmlObject,"/appsettings")>		
		<cfloop array="#globalSettings[1].XmlChildren#" index="group">					
			<cfset SettingGroup=group.XmlName />
			<cfloop array="#group.XmlChildren#" index="settingName">
				<cfset SettingNode=settingName.XmlName>
				<cfset "application.#SettingGroup#.#SettingNode#"=settingName.XmlText>
			</cfloop>
		</cfloop>
		<cfset application.sessionCount=0>
		<cfset application.site.start=Now()>
		<cfset application.site.basedir="#ExpandPath(".")#\">
		<cfset application.site.fileDir="#ExpandPath(".")#\source\">
		<cfset application.site.normal="http://#application.site.host#.#application.site.domain#/">		<!--- used to force normal if page requests it --->
		<cfset application.site.secure="https://#application.site.host#.#application.site.domain#/">	<!--- used to force secure if page requests it --->
		<cfset application.site.days=["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]>
		<cfset application.site.VAT={0=0,1=0,2=0.20,3=0.05}>	<!--- quick fix  needs maintaining in a table --->
		<cfset application.site.clientID=143>	<!--- cms client record ID --->
		<cfset application.site.sourceDir="source">
		<cfset application.site.url_data="#application.site.normal#data/">
		<cfset application.site.url_invoices="#application.site.normal#data/invoices/">

		<cfset application.mvc = {
            'datasource' = application.site.datasource1,
            'migrationDatasource' = application.site.datasource2,
            'dataDirectory' = (getDirectoryFromPath(getCurrentTemplatePath()) & "..\data\"),
            'baseDirectory' = getDirectoryFromPath(getCurrentTemplatePath()),
            'migrationTableName' = 'migrations'
        }>

<!--- move to session--->
		<cfset application.site.debug=false>
		<cfset application.site.showdumps=false>
		
		<cfset onSessionStart() />
<!---
		<cfset application.site={}>
		<cfset application.site.datasource0="kcc_cms">
		<cfset application.site.datasource1="kcc_sle">
		<cfset application.site.dir_logs="D:\HostingSpaces\SLE\shortlanesendstore.co.uk\data\logs\">
--->
		
		<cfinclude template="appSite.cfm">
		<cfreturn true>
	</cffunction>
	
	<cffunction name="onApplicationEnd" output="true" returnType="void">
		<cfargument name="applicationScope" required="true" />
		<cfdump var="#applicationScope#" format="html" output="#application.site.dir_logs#endapp.htm">
	</cffunction>
	
	<cffunction name="onRequestStart" output="true" returnType="void">
		<!---PREVENT ERROR FOR EPOS--->
		<cfif NOT DirectoryExists("#application.site.dir_logs#epos")><cfdirectory action="create" directory="#application.site.dir_logs#epos"></cfif>
		<cfif NOT DirectoryExists("#application.site.dir_data#epos")><cfdirectory action="create" directory="#application.site.dir_data#epos"></cfif>
		<cfif NOT DirectoryExists("#application.site.dir_data#epos\misc")><cfdirectory action="create" directory="#application.site.dir_data#epos\misc"></cfif>
		<cfif NOT DirectoryExists("#application.site.dir_data#epos\receipts")><cfdirectory action="create" directory="#application.site.dir_data#epos\receipts"></cfif>
		<!---PREVENT ERROR FOR EPOS--->
		
		<cfif StructKeyExists(URL,"restart")>
			<cfset onApplicationStart()>
		</cfif>
		<cfif StructKeyExists(form,"options")>
			<cfset application.site.debug=StructKeyExists(form,"debug")> 
			<cfset application.site.showdumps=StructKeyExists(form,"showdumps")> 
		</cfif>
		<cfset request.building={}>
		<cfset request.building.start=Now()>
		<cfset request.oldLocale=SetLocale("English (UK)")>
	</cffunction>
	
	<cffunction name="onSessionStart">
		<cfscript>
			session.started=now();
			session.currDate="";
			session.user = {};
			session.user.id = 0;
			session.user.loggedIn = false;
			session.user.firstname = "";
			session.user.lastname = "";
			session.user.eposLevel = 6;
			session.epos_frame = {};
			session.epos_frame.mode = "reg";
		</cfscript>
		<cflock scope="Application" timeout="5" type="Exclusive">
			<cfset application.sessionCount=application.sessionCount + 1>
		</cflock>
	</cffunction>
	
	<cffunction name="onSessionEnd">
		<cfargument name = "SessionScope" required=true/>
		<cfargument name = "AppScope" required=true/>
		<cfset var sessionLength = TimeFormat(Now() - SessionScope.started,"H:mm:ss")>
		<cflock name="AppLock" timeout="5" type="Exclusive">
			<cfset Arguments.AppScope.sessionCount = Arguments.AppScope.sessionCount - 1>
		</cflock>
		<cflog file="#This.Name#" type="Information" 
			text="Session #Arguments.SessionScope.sessionid# ended. Length: #sessionLength# Active sessions: #Arguments.AppScope.sessionCount#">
	</cffunction>

	<cffunction name="onRequest" returnType="void">
		<cfargument name="thePage" type="string" required="true" />
		<cfinclude template="#arguments.thePage#">
		<cfif NOT StructKeyExists(variables,"callback")><cfsetting showdebugoutput="#application.site.debug#"></cfif>
	</cffunction>
</cfcomponent>
