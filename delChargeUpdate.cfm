<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Change Delivery Charges</title>
</head>

<body>
	<h1>Change Delivery Charges</h1>
	<p>This routine will update all the non-zero delivery charges by the amount specified.</p>
	<p>A negative amount will reduce the charge. These rates are used everytime the rounds are run-out and charged.</p>
	<h2 style="color:#F00">USE CAREFULLY</h2>
	<cfif StructKeyExists(form,"delIncrease")>
		<cfset adjustment=val(form.delIncrease)>
		<cfquery name="QUpdateDelCharges" datasource="#application.site.datasource1#">
			UPDATE tblDelCharges
			SET 
				delPrice1 = IF (delPrice1 > 0,delPrice1+#adjustment#,0),
				delPrice2 = IF (delPrice2 > 0,delPrice2+#adjustment#,0),
				delPrice3 = IF (delPrice3 > 0,delPrice3+#adjustment#,0)
			WHERE 1
		</cfquery>
		<cfquery name="QDelCharges" datasource="#application.site.datasource1#">
			SELECT *
			FROM tblDelCharges
		</cfquery>
		<cfoutput>
			<h1>Rates Updated by #adjustment#p</h1>
			<table width="500">
				<cfloop query="QDelCharges">
					<tr>
						<td>#delID#</td>
						<td>#delCode#</td>
						<td>#delPrice1#</td>
						<td>#delPrice2#</td>
						<td>#delPrice3#</td>
						<td>#delType#</td>
					</tr>
				</cfloop>
			</table>
		</cfoutput>
	</cfif>
	<form method="post">
		Increase each non-zero rate by: <input type="text" size="5" name="delIncrease" value="0.05" />
		<input type="submit" name="btnSubmit" value="Update Rates" />
	</form>
</body>
</html>