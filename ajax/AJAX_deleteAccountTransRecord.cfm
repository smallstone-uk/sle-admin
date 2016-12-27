<!---WORKING VERSION AS OF 12/08/2014 18:14--->
<cfobject component="code/accounts" name="acc">
<cfset parm = {}>
<cfset parm.database = application.site.datasource1>
<cfset parm.tranID = tranID>
<cfset parm.accNomAcct = accNomAcct>
<cfset Delete = acc.DeleteAccountTransRecord(parm)>