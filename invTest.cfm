<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfsetting requesttimeout="1200">
<cfset error="">
<cfset headerHeight=70>
<cfset titleHeight=80>
<cfset rowHeight=15>
<cfset totalTableHeight=110>
<cfset footerHeight=190>
<cfset HeightTotal=footerHeight>
<cfset HeightLimit=800>

<cfobject component="code/Invoicing" name="inv">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.testmode=testmode>
<cfset parm.InvID=InvID>
<cfset parm.InvRef=InvRef>
<cfset parm.clientID=clientID>
<cfset parm.fromDate=fromDate>
<cfset parm.toDate=toDate>
<cfset parm.delDate=delDate>
<cfset parm.TransType=TransType>
<cfset invoice=inv.LoadInvoice(parm)>
<cfset parm.cltID=invoice.ID>
<cfset parm.cltRef=invoice.Ref>
<cfset parm.ordRef=invoice.ordRef>
<cfset parm.Total=invoice.total>
<cfset bal=inv.LoadBalance(parm)>
<cfdump var="#invoice#" label="invoice" expand="false">
<cfdump var="#bal#" label="balance" expand="false">
