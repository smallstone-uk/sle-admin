<!DOCTYPE html>
<html>
<head>
<title>Nominal Accounts</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/tabs.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/jquery.numeric.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/checkDates.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('#Supplier').change(function(event) {
			$.ajax({
				type: 'POST',
				url: 'nomGetForm.cfm',
			//	data : $('#Supplier').serialize(),
				data : $('#Supplier').serialize()+'&accType='+$('#accType').val(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#supplier-form').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#supplier-form').html(data);
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		});
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").fadeOut();
			event.preventDefault();
		});
		
		$('.drValue').keypress(function(event) {
			var key=String.fromCharCode(event.which);
			var rowID=this.id.replace('drValue','');;
		//	console.log(event.which+" = "+key);
			if (key.match(/[\d\.]/)) {
				var crfld="#crValue"+rowID;
				//console.log($(crfld).val());
				if ($(crfld).val() != "") {
					alert('values cannot be entered in both DR & CR columns in the same row');
					this.value="";
					event.preventDefault();
				}
			} else if (key.match(/[a-zA-Z]/)) { // alpha char
				event.preventDefault();
			} else {
				var total=0;
				var thisAmount=0;
				$('.drValue').each(function() {
					thisAmount=Number($(this).val(),10);
					total=total+thisAmount;
				});				
				$('#drTotal').val(total.toFixed(2));
				return true
			}
		});
		
		$('.crValue').keypress(function(event) {
			var key=String.fromCharCode(event.which);
			var rowID=this.id.replace('crValue','');;
		//	console.log(event.which+" = "+key);
			if (key.match(/[\d\.]/)) {
				var drfld="#drValue"+rowID;
				//console.log($(drfld).val());
				if ($(drfld).val() != "") {
					alert('values cannot be entered in both DR & CR columns in the same row');
					this.value="";
					event.preventDefault();
				}
			} else if (key.match(/[a-zA-Z]/)) { // alpha char
				event.preventDefault();
			} else {
				var total=0;
				var thisAmount=0;
				$('.crValue').each(function() {
					thisAmount=Number($(this).val(),10);
					total=total+thisAmount;
				});				
				$('#crTotal').val(total.toFixed(2));
				return true
			}
		});
		$('#trnDate').blur(function(event) {
			var dateChecked=checkDate($('#trnDate').val());
			if (!dateChecked) {
				alert('Date is out of range')
				setTimeout(function() {
					$('#trnDate').focus();
				}, 0);
			} else {
				$('#trnDate').val(dateChecked)			
			}
		});
	});
</script>
</head>

	<cffunction name="FieldValue" access="public" returntype="string">
		<cfargument name="key" type="string" required="yes">
		<cfif StructKeyExists(form,key)>
			<cfreturn StructFind(form,key)>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

<cfparam name="ledger" default="nom">
<cfparam name="accountID" default="3">
<cfparam name="tranType" default="nom">
<cfparam name="tranID" default="0">
<cfparam name="maxRows" default="10">
<cfobject component="code/accounts" name="noms">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset nominals=noms.LoadNominalCodes(parm)>
<cfif StructKeyExists(form,"fieldnames")>
	<cfif form.tranID is 0>
		<cfset parm.form=form>
		<cfset nomTran=noms.AddTran(parm)>
	</cfif>
<cfelse>
	<cfset nomTran=noms.LoadBlank(parm)>	
</cfif>
<cfdump var="#nomTran#" label="nomTran" expand="no">
<cfoutput query="nomTran.QTran">
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfif StructKeyExists(nomTran,"msg")>
					#nomTran.msg#
				</cfif>
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data" id="account-form">
						<input type="hidden" name="ledger" value="#ledger#" />
						<input type="hidden" name="accountID" value="#accountID#" />
						<input type="hidden" name="tranType" value="#tranType#" />
						<input type="hidden" name="tranID" value="#tranID#" />
						<input type="hidden" name="maxRows" value="#maxRows#" />
						<div id="orderOverlay">
							<div id="orderOverlayForm">
								<a href="##" class="orderOverlayClose">X</a>
								<div id="orderOverlayForm-inner"></div>
							</div>
						</div>
						<div class="form-header">
							Nominal Transactions
							<span><div id="loading"></div></span>
						</div>
						<div class="nav">
							<a href="#script_name#">Find</a>
							<a href="#script_name#">Next</a>
							<a href="#script_name#">Back</a>
							<a href="#script_name#">Last</a>
							<a href="#script_name#">Add</a>
							<a href="#script_name#">Delete</a>
						</div>
						<table border="1" cellpadding="2" cellspacing="0">
							<tr>
								<th width="100" align="left">Trans ID</th>
								<td width="170"><input type="text" name="trnID" value="#trnID#" id="EditID" tabindex="1"></td>
								<th width="100" align="left">Net Amount</th>
								<td width="100"><input type="text" name="trnAmnt1" style="text-align:right" size="10" value="#trnAmnt1#" id="NetAmount" tabindex="5"></td>
							</tr>
							<tr>
								<th align="left">Trans Date</th>
								<td><input type="text" name="trnDate" value="#LSDateFormat(trnDate,'dd/mm/yyyy')#" id="trnDate" tabindex="2"></td>
								<th align="left">VAT Amount</th>
								<td><input type="text" name="trnAmnt2" style="text-align:right" size="10" value="#trnAmnt2#" id="VATAmount" tabindex="6"></td>
							</tr>
							<tr>
								<th align="left">Trans Ref</th>
								<td><input type="text" name="trnRef" value="#trnRef#" tabindex="3" id="Ref"></td>
								<th align="left">Gross Total</th>
								<td><input type="text" name="trnTotal" style="text-align:right" size="10" value="#trnTotal#" id="GrossTotal" tabindex="7"></td>
							</tr>
							<tr>
								<th align="left">Description</th>
								<td colspan="3"><input type="text" name="trnDesc" value="#trnDesc#" tabindex="4" size="60" id="desc"></td>
							</tr>
							<tr>
								<td colspan="4">
									<table border="0">
										<tr>
											<td>Select Nominal Account...</td>
											<td align="right">DR</td>
											<td align="right">CR</td>
										</tr>
										<cfset startTab=16>
										<cfset maxCols=3>
										<cfset rowNo=1>
										<cfif StructKeyExists(nomTran,"QTranItems")>
											<cfloop query="nomTran.QTranItems">
												<cfset crValue="">
												<cfset drValue="">
												<cfset tabID=startTab+maxCols*rowNo>
												<cfif niAmount lt 0>
													<cfset crValue=DecimalFormat(abs(niAmount))>
												<cfelse><cfset drValue=DecimalFormat(niAmount)></cfif>
												<tr>
													<td>
														<select name="nomID#rowNo#" class="nom" tabindex="#tabID+1#">
															<option value=""></option>
															<cfset keys=ListSort(StructKeyList(nominals,","),"text","asc",",")>
															<cfloop list="#keys#" index="key">
																<cfset nom=StructFind(nominals,key)>
																<option value="#nom.nomID#"<cfif nom.nomID eq niNomID> selected="selected"</cfif>>#nom.nomCode# - #nom.nomTitle#</option>
															</cfloop>
														</select>							
													</td>
													<td><input type="text" name="drValue#rowNo#" value="#drValue#" id="drValue#rowNo#" style="text-align:right" 
														class="drValue" size="10" tabindex="#tabID+2#" /></td>
													<td><input type="text" name="crValue#rowNo#" value="#crValue#" id="crValue#rowNo#" style="text-align:right" 
														class="crValue" size="10" tabindex="#tabID+3#" /></td>
												</tr>											
												<cfset rowNo++>
											</cfloop>
										</cfif>
										<cfloop from="#rowNo#" to="#maxRows#" index="i">
											<cfset tabID=startTab+maxCols*i>
											<cfset drFld=FieldValue('drValue#i#')>
											<cfset crFld=FieldValue('crValue#i#')>
											<tr>
												<td>
													<cfif StructKeyExists(form,"nomID#i#")>
														<cfset thisKey=StructFind(form,"nomID#i#")>
													<cfelse><cfset thisKey=0></cfif>
													<cfset keys=ListSort(StructKeyList(nominals,","),"text","asc",",")>
													<select name="nomID#i#" class="nom" tabindex="#tabID+1#">
														<option value=""></option>
														<cfloop list="#keys#" index="key">
															<cfset nom=StructFind(nominals,key)>
															<option value="#nom.nomID#"<cfif nom.nomID eq thisKey> selected="selected"</cfif>>#nom.nomCode# - #nom.nomTitle#</option>
														</cfloop>
													</select>	#thisKey#						
												</td>
												<td><input type="text" name="drValue#i#" value="#drFld#" id="drValue#i#" 
													class="drValue" style="text-align:right" size="10" tabindex="#tabID+2#" /></td>
												<td><input type="text" name="crValue#i#" value="#crFld#" id="crValue#i#" 
													class="crValue" style="text-align:right" size="10" tabindex="#tabID+3#" /></td>
											</tr>
										</cfloop>
										<tr>
											<td>Totals</td>
											<td><input type="text" name="drTotal" id="drTotal" size="10" /></td>
											<td><input type="text" name="crTotal" id="crTotal" size="10" /></td>
										</tr>										
									</table>
								</td>
							</tr>
							<tr>
								<td colspan="3">&nbsp;</td>
								<td><input type="submit" name="btnSend" value="Save" /></td>
							</tr>
						</table>
						<div id="supplier-form"></div>
						<div class="clear"></div>
					</form>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
</html>
