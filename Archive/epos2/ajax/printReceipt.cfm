<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.tranID = tranID>
<cfset parm.randNum = RandRange(1024, 1220120, 'SHA1PRNG')>
<cfset basket = StructCopy(session.epos_frame.basket)>
<cfset sign = (2 * int(session.epos_frame.mode eq "reg")) - 1>
<cfset session.epos_frame.result.balanceDue = 0>
<cfset session.epos_frame.result.totalGiven = 0>
<cfset session.epos_frame.result.changeDue = 0>
<cfset session.epos_frame.result.youSaved = 0>
<cfif NOT StructKeyExists(session.epos_frame.result, "discount")>
	<cfset session.epos_frame.result.discount = 0>
</cfif>
<cfset epos.ProcessDeals()>
<cfset discountMessage = epos.ProcessDiscounts()>
<cfset basketIsEmpty = (epos.BasketItemCount() is 0) ? true : false>

<cfset dateNow = LSDateFormat(Now(), "dd/mm/yyyy")>
<cfset timeNow = LSTimeFormat(Now(), "HH:mm")>

<cfoutput>
	<cfscript>
		function bold(str) {
			return "#Chr(27)##Chr(14)##str##Chr(27)##Chr(20)#";
		};
		function rightAlign(str) {
			var spaces = ceiling(32 - len(str));
			var spacesStr = left("                                      ", abs(spaces));
			return "#spacesStr##str#";
		};
		function centerAlign(str) {
			var spaces = ceiling((32 - len(str)) / 2);
			var spacesStr = left("                                      ", abs(spaces));
			return "#spacesStr##str#";
		};
		function centerAlignBold(str) {
			var spaces = ceiling((16 - len(str)) / 2);
			var spacesStr = left("                                      ", abs(spaces));
			return "#Chr(27)##Chr(14)##spacesStr##str##Chr(27)##Chr(20)#";
		};
		function alignLeftRight(str1, str2) {
			var spaces = ceiling(31 - (len(str1) + len(str2)));
			var spacesStr = left("                                      ", abs(spaces));
			return "#str1##spacesStr##str2#";
		};
		function alignRightLeftRight(str1, str2, str3) {
			if (len(str1) lt 3 && str1 neq "-") {
				var pad = 3 - len(str1);
				var padSpaces = left("          ", abs(pad));
				str1 = "#padSpaces##str1#";
			}
			
			var spaces = ceiling(31 - (5 + len(str2) + len(str3)));
			var spacesStr = left("                                      ", abs(spaces));
			
			if (str1 eq "-") {
				str1 = "   ";
			}
			
			if (str3 eq "-") {
				str3 = "  ";
			}
			
			return "#str1#  #str2##spacesStr##str3#";
		};
	</cfscript>
	
	<cfsavecontent variable="txtContent">
		<cfoutput>
			#Chr(27)##Chr(112)#011
			#Chr(27)##Chr(64)#
			#Chr(27)##Chr(50)#
			#Chr(27)#6
			#Chr(10)##Chr(10)#
			#centerAlignBold("Shortlanesend")#
			#Chr(10)#
			#centerAlignBold("Store")#
			#Chr(10)##Chr(10)#
			#centerAlign(application.company.telephone)#
			#Chr(10)#
			#centerAlign("VAT No. 152 5803 21")#
			#Chr(10)##Chr(10)#
			<cfif session.epos_frame.mode eq "rfd">
				Refund
				#Chr(10)##Chr(10)#
			</cfif>
			#Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)##Chr(156)#
			#alignLeftRight("Served By: #session.user.firstName# #Left(session.user.lastName, 1)#", "Ref: #parm.tranID#")#
			#alignLeftRight("#dateNow#", "#timeNow#")#
			#Chr(10)##Chr(10)#
			#alignRightLeftRight("QTY", "DESCRIPTION", "AMOUNT")#
			<cfloop collection="#basket.product#" item="key">
				<cfset item = StructFind(basket.product, key)>
				<cfset item.lineTotal = val(item.qty) * val(item.price)>
				<cfset session.epos_frame.result.balanceDue += item.lineTotal>
				<cfset item.lenSpace = 32 - (10 + len(DecimalFormat(-item.lineTotal)))>
				<cfset item.titleArr = ListToArray(item.title, " ")>
				<cfset curLen = 0>
				<cfset item.title1 = "">
				<cfset item.title2 = "">
				<cfloop array="#item.titleArr#" index="i">
					<cfset curLen += len(i)>
					<cfif curLen lt item.lenSpace>
						<cfset item.title1 = item.title1 & "#i# ">
					<cfelse>
						<cfset item.title2 = item.title2 & "#i# ">
					</cfif>
				</cfloop>
				<cfif len(item.title1)>
					#alignRightLeftRight("#item.qty#", "#item.title1#", "#DecimalFormat(-item.lineTotal)#")#
				</cfif>
				<cfif len(item.title2)>
					#alignRightLeftRight("-", "#item.title2#", "-")#
				</cfif>
			</cfloop>
			<cfloop collection="#basket.publication#" item="key">
				<cfset item = StructFind(basket.publication, key)>
				<cfset item.lineTotal = val(item.qty) * val(item.price)>
				<cfset session.epos_frame.result.balanceDue += item.lineTotal>
				#alignRightLeftRight("#item.qty#", "#item.title#", "#DecimalFormat(-item.lineTotal)#")#
			</cfloop>
			<cfloop collection="#basket.paypoint#" item="key">
				<cfset item = StructFind(basket.paypoint, key)>
				<cfset item.lineTotal = val(item.qty) * val(item.price)>
				<cfset session.epos_frame.result.balanceDue += item.lineTotal>
				#alignRightLeftRight("#item.qty#", "#item.title#", "#DecimalFormat(-item.lineTotal)#")#
			</cfloop>
			<cfloop collection="#basket.deal#" item="key">
				<cfset item = StructFind(basket.deal, key)>
				<cfset item.lineTotal = val(item.qty) * val(item.price)>
				<cfset session.epos_frame.result.youSaved += item.lineTotal>
				<cfset session.epos_frame.result.balanceDue += item.lineTotal>
				#alignRightLeftRight("#item.qty#", "#item.title#", "#DecimalFormat(-item.lineTotal)#")#
			</cfloop>
			<cfset session.epos_frame.result.balanceDue -= session.epos_frame.result.discount>
			<cfloop collection="#basket.discount#" item="key">
				<cfset item = StructFind(basket.discount, key)>
				<cfset session.epos_frame.result.totalGiven += item.amount>
				<cfset session.epos_frame.result.youSaved += item.amount>
				#alignRightLeftRight("", "#item.title#", "#DecimalFormat(item.amount)#")#
			</cfloop>
			<cfif session.epos_frame.mode eq "reg">
				#Chr(10)##Chr(10)#
				#alignLeftRight("Balance Due", "#DecimalFormat(-session.epos_frame.result.balanceDue)#")#
				<cfloop collection="#basket.payment#" item="key">
					<cfset item = StructFind(basket.payment, key)>
					<cfset session.epos_frame.result.totalGiven += item.value>
					#alignLeftRight("#item.title#", "#DecimalFormat(item.value)#")#
				</cfloop>
				<cfset session.epos_frame.result.changeDue = (session.epos_frame.result.balanceDue + session.epos_frame.result.totalGiven) * sign>
				<cfset session.epos_frame.result.changeDue -= session.epos_frame.result.discount>
				<cfif StructKeyExists(session.epos_frame.basket, "payment")>
					<cfif StructCount(session.epos_frame.basket.payment) gt 0>
						<cfif session.epos_frame.result.changeDue lt 0>
							#alignLeftRight("Balance Now Due", "#DecimalFormat(-session.epos_frame.result.changeDue)#")#
						<cfelse>
							#alignLeftRight("Change Due", "#DecimalFormat(session.epos_frame.result.changeDue)#")#
						</cfif>
					</cfif>
				</cfif>
			<cfelse>
				#Chr(10)#
				#alignLeftRight("Refund Due", "#DecimalFormat(session.epos_frame.result.balanceDue)#")#
			</cfif>
			<cfif val(session.epos_frame.result.youSaved) gt 0>
				#Chr(10)##Chr(10)#
				#centerAlign("You have saved #DecimalFormat(session.epos_frame.result.youSaved)# today")#
			</cfif>
			#Chr(10)##Chr(10)##Chr(10)##Chr(10)##Chr(10)##Chr(10)#
			#Chr(27)##Chr(64)#
		</cfoutput>
	</cfsavecontent>
	
	<cffile action="write" file="#application.site.dir_data#epos\receipts\#parm.tranID##parm.randNum#.txt" addnewline="no" output="#txtContent#">
	
	<script>
		$(document).ready(function(e) {
			printFile('#application.site.url_data#epos/receipts/#parm.tranID##parm.randNum#.txt');
			/*$.ajax({
				type: "GET",
				url: "ajax/emptyBasket.cfm",
				success: function(data) {
					$.loadBasket();
				}
			});*/
		});
	</script>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>