
<cfobject component="code/functions" name="settings">
<cfset parms.datasource=application.site.datasource1>
<cfset delCharges=settings.LoadDelCharges(parms)>

<cfset application.site.dir_data="D:\HostingSpaces\SLE\shortlanesendstore.co.uk\data\">
<cfset application.site.url_data="http://lweb.shortlanesendstore.co.uk/data/">
<cfset application.site.dir_invoices="D:\HostingSpaces\SLE\shortlanesendstore.co.uk\data\invoices\">
<cfset application.site.url_invoices="http://lweb.shortlanesendstore.co.uk/data/invoices/">
