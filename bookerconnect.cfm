<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Interface</title>
</head>

<body>
<!---http://www.booker.co.uk/account/orders/orders.aspx
http://www.booker.co.uk/catalog/print.aspx?printType=Order&trackingNumber=35541107&returnUrl=http%3a%2f%2fwww.booker.co.uk%2faccount%2forders%2forder.aspx%3ftrackingNumber%3d35541107
?ReturnUrl=http%3a%2f%2fwww.booker.co.uk%2faccount%2forders%2forders.aspx
http://www.booker.co.uk/account/loginregister/userlogin.aspx?ReturnUrl=http%3a%2f%2fwww.booker.co.uk%2fcatalog%2fyourbooker.aspx
--->
<cftry>
<!---	<cfhttp url="http://www.booker.co.uk/account/loginregister/userlogin.aspx" method="post" useragent="#CGI.http_user_agent#">
		<cfhttpparam name="LoginControl$EmailSingle" type="formfield" value="steven@shortlanesendstore.co.uk">
		<cfhttpparam name="LoginControl$PasswordSingle" type="formfield" value="buzzy67">
	</cfhttp> http://lweb.shortlanesendstore.co.uk/
--->
<cfset strURL="http://www.bbc.co.uk">
<!---<cfset strURL="https://www.militaryfilmservices.com/index.cfm">--->
<cfhttp method="get" url="#strURL#" useragent="#CGI.http_user_agent#">
	<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
	<cfhttpparam type="Header" name="TE" value="deflate;q=0">
	<cfhttpparam type="header" name="mimetype" value="text/html">
<!---	<cfhttpparam type="url" name="access_token" value="eC05hdmlnYXRlVXJsBRcvaGVscC9icmFuY2hmaW5k">
	<cfhttpparam type="formfield" name="LoginControl$EmailSingle" value="steven@shortlanesendstore.co.uk">
	<cfhttpparam type="formfield" name="LoginControl$PasswordSingle" value="buzzy67">--->
</cfhttp>
	<cfdump var="#cfhttp#" label="cfhttp" expand="true">

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</body>
</html>
<!---
LoginControl$EmailSingle=steven@shortlanesendstore.co.uk
LoginControl$EnterEmailPasswordSubmit.x=33
LoginControl$EnterEmailPasswordSubmit.y=5
LoginControl$PasswordSingle=buzzy67
__EVENTARGUMENT=
__EVENTTARGET=
__VIEWSTATE=/wEPDwULLTE3NzkyODYyNTAPZBYCAgMPZBYEAgMPZBYGAgEPZBYIZg8PFgIeC05hdmlnYXRlVXJsBRcvaGVscC9icmFuY2hmaW5kZXIuYXNweGRkAgEPZBYEAgEPZBYCZg8PFgIfAAXbAWh0dHBzOi8vd3d3LmJvb2tlci5jby51azo0NDMvYWNjb3VudC9sb2dpbnJlZ2lzdGVyL3VzZXJsb2dpbi5hc3B4P1JldHVyblVybD1odHRwcyUzYSUyZiUyZnd3dy5ib29rZXIuY28udWslMmZhY2NvdW50JTJmbG9naW5yZWdpc3RlciUyZnVzZXJsb2dpbi5hc3B4JTNmUmV0dXJuVXJsJTNkaHR0cHMlM2ElMmYlMmZ3d3cuYm9va2VyLmNvLnVrJTJmYWNjb3VudCUyZmFjY291bnQuYXNweGRkAgIPFgIeB1Zpc2libGVoFgJmDw8WAh8ABcoBaHR0cHM6Ly93d3cuYm9va2VyLmNvLnVrOjQ0My9hY2NvdW50L2xvZ291dC5hc3B4P1JldHVyblVybD1odHRwcyUzYSUyZiUyZnd3dy5ib29rZXIuY28udWslMmZhY2NvdW50JTJmbG9naW5yZWdpc3RlciUyZnVzZXJsb2dpbi5hc3B4JTNmUmV0dXJuVXJsJTNkaHR0cHMlM2ElMmYlMmZ3d3cuYm9va2VyLmNvLnVrJTJmYWNjb3VudCUyZmFjY291bnQuYXNweGRkAgMPDxYCHwAFuAEvaGVscC9jb250YWN0dXMuYXNweD9yZXR1cm5Vcmw9aHR0cHMlM2ElMmYlMmZ3d3cuYm9va2VyLmNvLnVrJTJmYWNjb3VudCUyZmxvZ2lucmVnaXN0ZXIlMmZ1c2VybG9naW4uYXNweCUzZlJldHVyblVybCUzZGh0dHBzJTI1M2ElMjUyZiUyNTJmd3d3LmJvb2tlci5jby51ayUyNTJmYWNjb3VudCUyNTJmYWNjb3VudC5hc3B4ZGQCBA8PFgIfAAW+AS9oZWxwL2V4cG9ydGVucXVpcmllcy5hc3B4P3JldHVyblVybD1odHRwcyUzYSUyZiUyZnd3dy5ib29rZXIuY28udWslMmZhY2NvdW50JTJmbG9naW5yZWdpc3RlciUyZnVzZXJsb2dpbi5hc3B4JTNmUmV0dXJuVXJsJTNkaHR0cHMlMjUzYSUyNTJmJTI1MmZ3d3cuYm9va2VyLmNvLnVrJTI1MmZhY2NvdW50JTI1MmZhY2NvdW50LmFzcHhkZAIFDw8WAh4eQnJvd3NlQ2F0ZWdvcnlQYWdlRm9ybWF0U3RyaW5nBScvY2F0YWxvZy9wcm9kdWN0cy5hc3B4P2NhdGVnb3J5TmFtZT17MH1kZAIHD2QWBGYPDxYCHwFoZBYCAgMPDxYCHwAFKS9hY2NvdW50L2xvZ2lucmVnaXN0ZXIvRGVzdHJveUNvb2tpZS5hc3B4ZGQCAg9kFgQCAQ8PFgIeBFRleHQFBlN0ZXZlbmRkAgMPDxYCHwAFKS9hY2NvdW50L2xvZ2lucmVnaXN0ZXIvRGVzdHJveUNvb2tpZS5hc3B4ZGQCBw9kFgICAQ9kFgZmD2QWAgIBD2QWBmYPZBYEAgEPDxYCHwMFHkNvbmZpcm0gQm9va2VyIEN1c3RvbWVyIE51bWJlcmRkAgMPDxYCHwNlZGQCAQ9kFgQCBw9kFgICAQ8PFgIfAAUXL2hlbHAvYnJhbmNoZmluZGVyLmFzcHhkZAILDw8WAh4VU3VibWl0QnV0dG9uQ29udHJvbElEBSZMb2dpbkNvbnRyb2xfRW50ZXJDdXN0b21lck51bWJlclN1Ym1pdGRkAgIPZBYCAgEPDxYCHwAFGC9jYXRhbG9nL3lvdXJib29rZXIuYXNweGRkAgEPZBYCAgEPZBYCAgIPZBYGAgEPDxYCHwAFGC9jYXRhbG9nL3lvdXJib29rZXIuYXNweGRkAgMPDxYCHwAFDy9oZWxwL2hlbHAuYXNweGRkAgUPDxYCHwAFHC9hY2NvdW50L2ZvcmdvdHBhc3N3b3JkLmFzcHhkZAICD2QWAgIBD2QWBAIBD2QWAgIRDw8WAh8EBTNMb2dpbkNvbnRyb2xfRW50ZXJDdXN0b21lck51bWJlckVtYWlsUGFzc3dvcmRTdWJtaXRkZAICD2QWAgIBDw8WAh8ABRgvY2F0YWxvZy95b3VyYm9va2VyLmFzcHhkZBgDBR5fX0NvbnRyb2xzUmVxdWlyZVBvc3RCYWNrS2V5X18WAwUlTG9naW5Db250cm9sJEVudGVyRW1haWxQYXNzd29yZFN1Ym1pdAURRkMkT0VDJHNvQ29udGludWUFIHBvcHVwUGFzc3dvcmRDaGFuZ2VQcm9jZWVkQnV0dG9uBRNGQyRPRUMkc29wTXVsdGlWaWV3Dw9kAgJkBRZMb2dpbkNvbnRyb2wkTG9naW5WaWV3Dw9kAgFkt48Cm+hm4d3eovd89yNsF9ZHTPg=
passwordChangePopupTarget=
txtNewPassword=
txtPasswordConfirm=--->