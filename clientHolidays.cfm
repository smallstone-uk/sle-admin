<!DOCTYPE html>
<html>
<head>
	<title>Customer Holidays</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<cfobject component="code/functions" name="cust">

<cfif StructKeyExists(form,"btnSave")>
	<cfset parms.datasource=application.site.datasource1>
	<cfset parms.form=form>
	<cfset holidays=cust.SaveHoliday(parms)>
	<cflocation url="#script_name#?row=#row#&clientRef=#url.clientRef#" addtoken="no">
</cfif>

<cfoutput>
<body>
	<p><a href="clientDetails.cfm?row=#row#">Back</a></p>
	<cfif StructKeyExists(url,"clientRef")>
		<cfset parms.datasource=application.site.datasource1>
		<cfset parms.clientRef=url.clientRef>
		<cfset holidays=cust.LoadHolidays(parms)>
			<table border="1" class="tableList">
				<tr class="clienthead">
					<th>&nbsp;</th>
					<th width="80" class="centre">ID</th>
					<th width="80" class="centre">Reference</th>
					<th width="300" class="centre">Name</th>
				</tr>
				<tr class="client">
					<td><strong>Customer</strong></td>
					<td class="centre">#holidays.customer.ID#</td>
					<td class="centre">#holidays.customer.Ref#</td>
					<td class="centre">#holidays.customer.Name#</td>
				</tr>
				<cfloop collection="#holidays.orders#" item="key">
					<cfset order=StructFind(holidays.orders,key)>
					<tr>
						<td><strong>Order</strong></td>
						<td>#key#</td>
						<td>#order.date#</td>
						<td>#order.active#</td>
					</tr>
					<tr>
						<th colspan="2">Holidays</th>
						<th>Stop Date</th>
						<th>Start Date</th>
					</tr>
					<form name="holidayForm" id="holidayForm" method="post">
						<input type="hidden" name="orderRef" value="#key#" />
						<input type="hidden" name="row" value="#row#" />
						<tr>
							<td colspan="2">New Holiday</td>
							<td><input type="text" class="inputfield" name="hoStop" id="hoStop" value="#DateFormat(Now(),"dd/mm/yyyy")#" 
								size="20" maxlength="20" placeholder="DD/MM/YYYY" /></td>
							<td>
								<input type="text" class="inputfield" name="hoStart" id="hoStart" value="" size="20" maxlength="20" placeholder="DD/MM/YYYY" />
								<input type="submit" name="btnSave" value="Save Holiday" />
							</td>
						</tr>
					</form>
					<cfloop array="#order.holidays#" index="item">
						<tr>
							<td>#item.ID#</td>
							<td>#item.orderID#</td>
							<td>#item.stop#</td>
							<td>#item.start#</td>
						</tr>
					</cfloop>
				</cfloop>
			</table>
	<cfelse>
		<p>No client reference was specified.</p>
	</cfif>
</body>
</cfoutput>
</html>