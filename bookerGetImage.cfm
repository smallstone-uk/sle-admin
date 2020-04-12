<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Image Fetch</title>
</head>
<cfset bookerURL = "https://www.booker.co.uk">
<cfset localURL = "C:\xampp\htdocs\data\images\">	<!--- where to store the images --->
<cfquery name="QProducts" datasource="#application.site.datasource1#">	<!--- get sample products for testing --->
	SELECT prodID,prodRef,prodTitle
	FROM `tblproducts` 
	WHERE `prodRef` != ''
	AND length(prodRef)=6
	LIMIT 30
</cfquery>
<body>
<cftry>
	<table>
		<cfloop query="QProducts">
			<cfset strURL="#bookerURL#/catalog/displayimage.aspx?vid=#prodRef#">
			<cfset productID = prodID>
			<cfhttp method="get" url="#strURL#" useragent="#CGI.http_user_agent#">
				<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
				<cfhttpparam type="Header" name="TE" value="deflate;q=0">
				<cfhttpparam type="header" name="mimetype" value="text/html">
			</cfhttp>
			<cfoutput>
				<cfset htmlText = cfhttp.FileContent>
				<cfset imgTag = ReMatch("<img[^>]+>",htmlText)>
				<cfif ArrayLen(imgTag) gt 0>
					<cfset imgTagAttr = ReMatch('(\w+(?:\(\d+\))?)\s*=\s*(.*?)(?=(!|$|\w+(\(\d+\))?\s*=))',imgTag[1])>	<!--- return an array of tag attributes --->
					<cfif ArrayLen(imgTagAttr) gt 0>
						<cfset attributes = {}>
						<cfset StructInsert(attributes,prodRef,{})>
						<cfset attrArray = StructFind(attributes,prodRef)>
						<cfloop array="#imgTagAttr#" index="item"> 	<!--- convert into struct of name/value pairs --->
							<cfset name = ListFirst(item,"=")>
							<cfset value = Trim(Replace(ListLast(item,"="),'"','',"all"))>
							<cfset StructInsert(attrArray,name,value)>
						</cfloop>
						<!---<cfdump var="#attributes#" label="attributes" expand="false">--->
					</cfif>
					<cfif !StructIsEmpty(attributes)>
						<cfset attrArray = StructFind(attributes,prodRef)>
						<cfset filename = ListLast(attrArray.src,'/')>	<!--- get image file name --->
						<cfset filepath = "C:\xampp\htdocs\data\images\#filename#"> <!--- path to store image --->
						<cffile action="readbinary" file="#bookerURL##attrArray.src#" variable="piccy"> <!--- read source image into variable object --->
						<cffile action="write" file="#filepath#" output="#toBinary(piccy)#">	<!--- write the file locally (doesn't check if already exists) --->
						<cfquery name="QSaveProduct" datasource="#application.site.datasource1#">	<!--- update product record with image file name and product description --->
							UPDATE tblProducts
							SET prodImg = '#filename#',
							prodDesc = '#attrArray.alt#'
							WHERE prodID = #productID#
						</cfquery>
						<tr>
							<td>#filename#</td>
							<td>#attrArray.alt#</td>
							<td></td>
						</tr>
					</cfif>
				</cfif>
			</cfoutput>
		</cfloop>
	</table>
	<cfcatch type="any">
		<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
	</cfcatch>
</cftry>
</body>
</html>
