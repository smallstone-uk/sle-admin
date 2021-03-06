<cftry>
<!DOCTYPE html>
<html>
<head>
<title>Purchase Reports</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
		$(".srchAccount, .srchTranType").chosen({width: "300px"});
	});
</script>
<style type="text/css">
	.header {font-size:16px; font-weight:bold;}
	.amount {text-align:right}
	.amountTotal {text-align:right; font-weight:bold;}
	.tranList {	
		font-family:Arial, Helvetica, sans-serif;
		font-size:13px;
		border-collapse:collapse;
	}
	.tranList th, .tranList td {
		padding:2px 4px; 
		border: solid 1px #ccc;
		background-color:#fff;
	}
	.vatTable {
		border-spacing: 0px;
		border-collapse: collapse;
		border: 1px solid #CCC;
		font-size: 14px;
	}
	.vatTable th {padding: 5px; background:#eee; border-color: #ccc;}
	.vatTable td {padding: 5px; border-color: #ccc;}
</style>

</head>

<cfobject component="code/purchase" name="pur">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfset suppliers=pur.LoadSuppliers(parms)>
<cfset nominals=pur.LoadNominalCodes(parms)>
<cfset diffArray = []>

<cfparam name="srchReport" default="">
<cfparam name="srchAccount" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchMin" default="">
<cfparam name="srchSort" default="">
<cfparam name="srchDept" default="">
<cfparam name="srchLedger" default="">
<cfparam name="srchNom" default="">
<cfparam name="srchTranType" default="">
<cfparam name="srchRange" default="">
<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post">
						<div class="form-header">
							Transaction Reports
							<span><input type="submit" name="btnSearch" value="Search" /></span>
						</div>
						<div class="module">
							<table border="0">
								<tr>
									<td><b>Report</b></td>
									<td>
										<select name="srchReport">
											<option value="">Select...</option>
											<option value="1"<cfif srchReport eq "1"> selected="selected"</cfif>>Transaction List</option>
											<option value="2"<cfif srchReport eq "2"> selected="selected"</cfif>>Transaction Detail</option>
											<option value="3"<cfif srchReport eq "3"> selected="selected"</cfif>>VAT Analysis</option>
											<option value="4"<cfif srchReport eq "4"> selected="selected"</cfif>>Nominal Transactions</option>
											<option value="5"<cfif srchReport eq "5"> selected="selected"</cfif>>Nominal Summary</option>
											<option value="6"<cfif srchReport eq "6"> selected="selected"</cfif>>Report Graphs</option>
											<option value="7"<cfif srchReport eq "7"> selected="selected"</cfif>>NomItem Exceptions</option>
											<option value="8"<cfif srchReport eq "8"> selected="selected"</cfif>>VAT Return</option>
											<option value="9"<cfif srchReport eq "9"> selected="selected"</cfif>>VAT Transactions</option>
											<option value="10"<cfif srchReport eq "10"> selected="selected"</cfif>>Nom Totals Report</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Search by Name</b></td>
									<td>
										<select name="srchAccount">
											<option value="0">Select...</option>
											<option value="-1">Ignore Client Records</option>
											<cfloop array="#suppliers.list#" index="item">
												<option value="#item.accID#"<cfif item.accID eq srchAccount> selected="selected"</cfif>>#item.accName#</option>
											</cfloop>
										</select>									
									</td>
								</tr>
								<tr>
									<td><b>Accounting Year</b></td>
									<td>
										<select name="srchRange" data-placeholder="Select..." id="srchRange" tabindex="3">
											<option value="">Select...</option>
											<cfset dateKeys=ListSort(StructKeyList(application.site.FYDates,","),"text","DESC")>
											<cfloop list="#dateKeys#" index="key">
												<cfset item=StructFind(application.site.FYDates,key)>
												<option value="FY-#item.key#" <cfif srchRange eq "FY-#item.key#"> selected="selected"</cfif>>Year #item.title#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Date From</b></td>
									<td>
										<input type="text" name="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
									</td>
								</tr>
								<tr>
									<td><b>Date To</b></td>
									<td>
										<input type="text" name="srchDateTo" value="#srchDateTo#" class="datepicker" />
									</td>
								</tr>
								<tr>
									<td><b>Minimum Balance</b></td>
									<td><input type="text" name="srchMin" value="#srchMin#" size="5" value="0" /></td>
								</tr>
								<tr>
									<td><b>Ledger</b></td>
									<td>
										<select name="srchLedger">
											<option value="">Select...</option>
											<option value="sales"<cfif srchLedger eq "sales"> selected="selected"</cfif>>Sales</option>
											<option value="purch"<cfif srchLedger eq "purch"> selected="selected"</cfif>>Purchase</option>
											<option value="nom"<cfif srchLedger eq "nom"> selected="selected"</cfif>>Nominal</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Department</b></td>
									<td>
										<select name="srchDept">
											<option value="">Select...</option>
											<option value="shop"<cfif srchDept eq "shop"> selected="selected"</cfif>>Shop</option>
											<option value="news"<cfif srchDept eq "news"> selected="selected"</cfif>>News</option>
											<option value="ext"<cfif srchDept eq "ext"> selected="selected"</cfif>>External</option>
											<option value="other"<cfif srchDept eq "other"> selected="selected"</cfif>>Other</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Transaction Type</b></td>
									<td>
										<select name="srchTranType" class="srchTranType" multiple="multiple" data-placeholder="Select...">
											<option value="inv"<cfif srchTranType eq "inv"> selected="selected"</cfif>>Invoice</option>
											<option value="crn"<cfif srchTranType eq "crn"> selected="selected"</cfif>>Credit</option>
											<option value="pay"<cfif srchTranType eq "pay"> selected="selected"</cfif>>Payment</option>
											<option value="jnl"<cfif srchTranType eq "jnl"> selected="selected"</cfif>>Journal</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Nominal Account</b></td>
									<td>
										<select name="srchNom" class="select">
											<option value="">Select...</option>
											<cfset keys=ListSort(StructKeyList(nominals,","),"text","asc",",")>
											<cfloop list="#keys#" index="key">
												<cfset nom=StructFind(nominals,key)>
												<option value="#nom.nomID#"<cfif nom.nomID is srchNom> selected="selected"</cfif>>
													#nom.nomCode# - #nom.nomTitle#</option>
											</cfloop>
										</select>							
									</td>
								</tr>
								<tr>
									<td><b>Sort By</b></td>
									<td>
										<select name="srchSort">
											<option value="trnAccountID"<cfif srchSort eq "trnAccountID"> selected="selected"</cfif>>Account</option>
											<option value="trnID"<cfif srchSort eq "trnID"> selected="selected"</cfif>>Transaction ID</option>
											<option value="trnDate"<cfif srchSort eq "trnDate"> selected="selected"</cfif>>Transaction Date</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><b>Fix Data</b></td>
									<td><input type="checkbox" name="srchFixData" value="1" /></td>
								</tr>
							</table>
						</div>
					</form>
					<div class="module">
						<cfif StructKeyExists(form,"fieldnames")>
							<cfsetting requesttimeout="900">
							<cfflush interval="200">
							<cfset parms={}>
							<cfset parms.datasource=application.site.datasource1>
							<cfset parms.form=form>
							<cfobject component="code/purchase" name="pur">
							<cfswitch expression="#srchReport#">
								<cfcase value="1">
									<cfset trans=pur.TranList(parms)>
									<cfset accountID=0>
									<table border="1" class="<!---tranList --->tableList" width="100%">
										<cfloop array="#trans.tranArray#" index="tran">
											<cfif accountID neq tran.accID>
												<cfif accountID gt 0>
													<tr>
														<td colspan="4"></td>
														<td class="amountTotal">Totals</td>
														<td class="amountTotal">#DecimalFormat(accNetTotal)#</td>
														<td class="amountTotal">#DecimalFormat(accVATTotal)#</td>
														<td class="amountTotal">#DecimalFormat(accNetTotal+accVATTotal)#</td>
														<td></td>
													</tr>												
												</cfif>
												<cfset accountID=tran.accID>
												<cfset accNetTotal=0>
												<cfset accVATTotal=0>
												<cfset balance=0>
												<tr>
													<th colspan="9"><span class="header">#tran.accName#</span></th>
												</tr>
												<tr>
													<th width="50">ID</th>
													<th width="100">Date</th>
													<th width="50">Type</th>
													<th width="60">Reference</th>
													<th width="150">Description</th>
													<th width="100" class="amount">Net</th>
													<th width="100" class="amount">Vat/Disc</th>
													<th width="100" class="amount">Total</th>
													<th width="100" class="amount">Balance</th>
												</tr>
											</cfif>
											<cfset accNetTotal=accNetTotal+tran.trnAmnt1>
											<cfset accVATTotal=accVATTotal+tran.trnAmnt2>
											<cfset balance=balance+tran.trnTotal>
											<tr>
												<td valign="top">
													<cfif tran.accID eq 3>#tran.trnID#
														<!---<a href="nomTran.cfm?acc=#tran.accID#&tran=#tran.trnID#" target="nomtran">#tran.trnID#</a>--->
													<cfelse>
														<a href="tranMain2.cfm?acc=#tran.accID#&tran=#tran.trnID#" target="acctran">#tran.trnID#</a>
													</cfif>
												</td>
												<td valign="top">#LSDateFormat(tran.trnDate,"dd-mmm-yyyy")#</td>
												<td valign="top">#tran.trnType#</td>
												<td valign="top">#tran.trnRef#</td>
												<td valign="top">#tran.trnDesc#</td>
												<td valign="top" class="amount">#DecimalFormat(tran.trnAmnt1)#</td>
												<td valign="top" class="amount">#DecimalFormat(tran.trnAmnt2)#</td>
												<td valign="top" class="amount">#DecimalFormat(tran.trnTotal)#</td>
												<td valign="top" class="amount"><cfif balance neq 0>#DecimalFormat(balance)#</cfif></td>
											</tr>
										</cfloop>
										<cfif accountID gt 0>
											<tr>
												<td colspan="4"></td>
												<td class="amountTotal">Totals</td>
												<td class="amountTotal">#DecimalFormat(accNetTotal)#</td>
												<td class="amountTotal">#DecimalFormat(accVATTotal)#</td>
												<td class="amountTotal">#DecimalFormat(accNetTotal+accVATTotal)#</td>
												<td></td>
											</tr>												
										</cfif>
										<tr>
											<td colspan="4"></td>
											<td class="amountTotal">Grand Total</td>
											<td class="amountTotal">#DecimalFormat(trans.totAmnt1)#</td>
											<td class="amountTotal">#DecimalFormat(trans.totAmnt2)#</td>
											<td class="amountTotal">#DecimalFormat(trans.totAmnt1+trans.totAmnt2)#</td>
											<td></td>
										</tr>
									</table>			
								</cfcase>
								<cfcase value="2">
									<cfset trans=pur.TranDetail(parms)>					
									<cfset accountID=0>
									<cfset errCount=0>
									<cfset errArray=[]>
									<table border="1" class="tableList">
									<cfloop array="#trans.tranArray#" index="tran">
										<cfif accountID neq tran.accID>
											<cfset accountID=tran.accID>
											<tr>
												<td colspan="7">#tran.accName#</td>
											</tr>
										</cfif>
										<tr>
											<td valign="top"><a href="tranMain2.cfm?acc=#tran.accID#&tran=#tran.trnID#" target="_newtab">#tran.trnID#</a></td>
											<td valign="top">#LSDateFormat(tran.trnDate,"dd-mmm-yyyy")#</td>
											<td valign="top">#tran.trnType#</td>
											<td valign="top">#tran.trnRef#</td>
											<td valign="top" align="right">#DecimalFormat(tran.trnAmnt1)#</td>
											<td valign="top" align="right">#DecimalFormat(tran.trnAmnt2)#</td>
											<td>
												<table border="1" class="tableList">
													<tr>
														<td width="50">Code</td>
														<td width="150">Title</td>
														<td width="70" align="right">DR</td>
														<td width="70" align="right">CR</td>
													</tr>
													<cfset rec={}>
													<cfset rec.penceGross=(tran.trnAmnt1+tran.trnAmnt2)*100>
													<cfset rec.penceSum=0>
													<cfset rec.penceDR=0>
													<cfset rec.penceCR=0>
													<cfset rec.drTotal=0>
													<cfset rec.crTotal=0>
													<cfloop query="tran.items">
														<tr>
															<td>#nomCode#</td>
															<td>#nomTitle#</td>
															<cfset rec.penceSum=rec.penceSum+round(niAmount*100)>
															<cfif niAmount lt 0>
																<cfset rec.crTotal=rec.crTotal+niAmount>
																<cfset rec.penceCR=rec.penceCR+round(niAmount*100)>
																<td></td><td align="right">#DecimalFormat(niAmount)#</td>
															<cfelse>
																<cfset rec.drTotal=rec.drTotal+niAmount>
																<cfset rec.penceDR=rec.penceDR+round(niAmount*100)>
																<td align="right">#DecimalFormat(niAmount)#</td><td></td>
															</cfif>
														</tr>
													</cfloop>
													<tr>
														<td>
															<cfif rec.penceSum eq 0>
																<cfset msg="<strong>Total</strong>">
															<cfelse>
																<cfset errCount++>
																<cfset ArrayAppend(errArray,{"ID"=tran.trnID,"Account"=tran.accName,
																	"trnDate"=LSDateFormat(tran.trnDate,"dd-mmm-yyyy"),"Diff"=rec.penceSum/100})>
																<cfset msg='<span style="color:##FF0000"><strong>Error #rec.penceSum#</strong></span>'>
															</cfif>
															<!---<cfdump var="#rec#" label="rec" expand="no">--->
														</td>
														<td>#msg#</td>
														<td align="right">#DecimalFormat(rec.drTotal)#</td>
														<td align="right">#DecimalFormat(rec.crTotal)#</td>
													</tr>
												</table>
											</td>
										</tr>
									</cfloop>
									</table>			
									<cfif ArrayLen(errArray)>
										<cfset errTotal=0>
										<table>
										<cfloop array="#errArray#" index="item">
											<cfset errTotal=errTotal+item.diff>
											<tr>
												<td width="100"><a href="tranMain2.cfm?acc=#tran.accID#&tran=#tran.trnID#" target="_newtab">#item.ID#</a></td>
												<td width="180">#item.Account#</td>
												<td width="100">#item.trnDate#</td>
												<td width="100" align="right">#DecimalFormat(item.diff)#</td>
											</tr>
										</cfloop>
										</table>
										<p>#errCount# transaction errors found. Error value: #errTotal#</p>
									</cfif>
								</cfcase>
								<cfcase value="3">
									<cfset parms.titleLedger="">
									<cfset trans=pur.VATAnalysis(parms)>
									<cfdump var="#trans#" label="trans" expand="no">
									<cfset codes=ListSort(StructKeyList(trans.analysis,","),"text","asc")>
									<h1>Transaction Analysis</h1>
									<table border="1" class="tableList">
										<tr>
											<td>Code</td>
											<td>Title</td>
											<td width="60" align="right">Rate</td>
										<cfloop from="#trans.firstMonth#" to="#trans.lastMonth#" index="i">
											<cfset key=NumberFormat(i,"00")>
											<td align="center" colspan="2">Month #key#</td>
										</cfloop>
											<td align="center" colspan="2">Total</td>
										</tr>
										<tr>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
										<cfloop from="#trans.firstMonth#" to="#trans.lastMonth#" index="i">
											<td width="60" align="right">Net</td>
											<td width="60" align="right">VAT</td>
										</cfloop>
											<td width="60" align="right">Net</td>
											<td width="60" align="right">VAT</td>
										</tr>
										<cfloop list="#codes#" delimiters="," index="code">
											<cfset item=StructFind(trans.analysis,code)>
											<cfset lineNet=0>
											<cfset lineVAT=0>
											<tr>
												<td>#code#</td>
												<td>#item.title#</td>
												<td align="right">#item.rate#%</td>
												<cfloop from="#trans.firstMonth#" to="#trans.lastMonth#" index="i">
													<cfset key=NumberFormat(i,"00")>
													<cfif StructKeyExists(item,"month#key#")>
														<cfset data=StructFind(item,"month#key#")>
														<cfset lineNet=lineNet+data.net>
														<cfset lineVAT=lineVAT+data.vat>
														<td align="right">#DecimalFormat(data.net)#</td>
														<td align="right">#DecimalFormat(data.vat)#</td>
													<cfelse>
														<td align="right">-</td>
														<td align="right">-</td>
													</cfif>
												</cfloop>
												<td align="right">#DecimalFormat(lineNet)#</td>
												<td align="right">#DecimalFormat(lineVAT)#</td>
											</tr>
										</cfloop>
										<tr>
											<td>&nbsp;</td>
											<td>&nbsp;</td>
											<td>Totals</td>
										<cfloop from="#trans.firstMonth#" to="#trans.lastMonth#" index="i">
											<cfset key=NumberFormat(i,"00")>
											<td align="right">#DecimalFormat(StructFind(trans,"net#key#"))#</td>
											<td align="right">#DecimalFormat(StructFind(trans,"vat#key#"))#</td>
										</cfloop>
											<td align="right">#DecimalFormat(trans.TotalNet)#</td>
											<td align="right">#DecimalFormat(trans.TotalVAT)#</td>
										</tr>
									</table>
									
									<h1>VAT Analysis</h1>
									<cfset codes=ListSort(StructKeyList(trans.VAT,","),"text","asc")>
									<table border="1" class="tableList">
										<tr>
											<td width="60" align="right">RATE</td>
											<td width="60" align="right">NET</td>
											<td width="60" align="right">VAT</td>
											<td width="60" align="right">PROPORTION</td>
										</tr>
										<cfloop list="#codes#" delimiters="," index="code">
											<cfset item=StructFind(trans.VAT,code)>
											<tr>
												<td align="right">#DecimalFormat(item.rate)#</td>
												<td align="right">#DecimalFormat(item.net)#</td>
												<td align="right">#DecimalFormat(item.vat)#</td>
												<td align="right">#DecimalFormat((item.net/trans.TotalNet)*100)#%</td>
											</tr>
										</cfloop>
										<tr>
											<td>Totals</td>
											<td align="right">#DecimalFormat(trans.TotalNet)#</td>
											<td align="right">#DecimalFormat(trans.TotalVAT)#</td>
											<td>&nbsp;</td>
										</tr>
									</table>
									<p>#trans.QTRANSRESULT.sql#</p>
								</cfcase>
								
								<cfcase value="4">
									<cfset trans=pur.NomTrans(parms)>
									<cfdump var="#trans.QTrans_result#" label="QTrans_result" expand="no">				
									<cfset codes=ListSort(StructKeyList(trans.nomAccount,","),"text","asc")>
									<table border="1" class="tableList">
									<cfloop list="#codes#" delimiters="," index="code">
										<cfset item=StructFind(trans.nomAccount,code)>
										<tr>
											<td colspan="7">#code# - #item.Title#</td>
											<tr>
												<td width="50">ID</td>
												<td width="100">DATE</td>
												<td width="70">TYPE</td>
												<td width="70">REF</td>
												<td width="70">CLIENT REF</td>
												<td width="70" align="right">DR</td>
												<td width="70" align="right">CR</td>
											</tr>
										</tr>
										<cfset rec.drTotal=0>
										<cfset rec.crTotal=0>
										<cfloop array="#item.tranArray#" index="tran">
											<cfset diffStruct = {}>
											<tr>
												<td valign="top"><a href="tranMain2.cfm?acc=#tran.accID#&tran=#tran.trnID#" target="_newtab">#tran.trnID#</a></td>
												<td valign="top">#tran.trnDate#</td>
												<td valign="top">#tran.trnType#</td>
												<td valign="top">#tran.trnRef#</td>
												<td valign="top">#tran.trnClientRef#</td>
												<cfif tran.niAmount lt 0>
													<cfset rec.crTotal=rec.crTotal+tran.niAmount><td></td><td align="right">#DecimalFormat(tran.niAmount)#</td>
													<cfelse><cfset rec.drTotal=rec.drTotal+tran.niAmount><td align="right">#DecimalFormat(tran.niAmount)#</td><td></td></cfif>
											</tr>
											<cfset diffStruct.id = tran.trnID>
											<cfset diffStruct.dr = rec.drTotal>
											<cfset diffStruct.cr = rec.crTotal>
											<cfif (diffStruct.dr + diffStruct.cr) gt 0>
												<cfset ArrayAppend(diffArray, diffStruct)>
											</cfif>
										</cfloop>
											<tr>
												<td colspan="5" align="right">Totals</td>
												<td align="right">#DecimalFormat(rec.drTotal)#</td>
												<td align="right">#DecimalFormat(rec.crTotal)#</td>
											</tr>
									</cfloop>
										<tr>
											<td colspan="5">Grand Total</td>
											<td align="right">#DecimalFormat(trans.total)#</td>
										</tr>
									</table>
								</cfcase>
								<cfcase value="5">
									<cfset trans=pur.NomTranSummary(parms)>
									<table border="1" class="tableList">
										<tr>
											<th width="50">Ledger</th>
											<th width="50">CODE</th>
											<th width="150">TITLE</th>
											<th width="70" align="right">DR</th>
											<th width="70" align="right">CR</th>
										</tr>
									<cfset rec.drTotal=0>
									<cfset rec.crTotal=0>
									<cfloop list="#trans.ledgers#" delimiters="," index="key">
										<cfset ledger=StructFind(trans,key)>
										<cfset codes=ListSort(StructKeyList(ledger,","),"text","asc")>
										<cfloop list="#codes#" delimiters="," index="code">
											<cfset item=StructFind(ledger,code)>
											<tr>
												<td>#key#</td>
												<td>#item.nomCode#</td>
												<td>#item.nomTitle#</td>
												<cfif item.nomTotal lt 0>
													<cfset rec.crTotal=rec.crTotal+item.nomTotal>
													<td>&nbsp;</td>
													<td align="right">#DecimalFormat(-item.nomTotal)#</td>
												<cfelseif item.nomTotal gt 0>
													<cfset rec.drTotal=rec.drTotal+item.nomTotal>
													<td align="right">#DecimalFormat(item.nomTotal)#</td>
													<td>&nbsp;</td>
												<cfelse>
													<td>&nbsp;</td>
													<td>&nbsp;</td>
												</cfif>
											</tr>
										</cfloop>
									</cfloop>
									<cfset rec.crTotal=-rec.crTotal>
									<tr>
										<td colspan="3"></td>
										<td align="right">#DecimalFormat(rec.drTotal)#</td>
										<td align="right">#DecimalFormat(rec.crTotal)#</td>
									</tr>
									<tr>
										<td colspan="4"></td>
										<td align="right">#DecimalFormat(rec.crTotal-rec.drTotal)#</td>
									</tr>
									</table>
                                    <p>#trans.QTRANSRESULT.sql#</p>
								</cfcase>
								
								<cfcase value="6">
									<cfset trans=pur.NomTrans(parms)>					
									<cfdump var="#trans#" label="trans" expand="no">
								</cfcase>
								
								<cfcase value="7">
									<cfset count=0>
									<cfset trans=pur.TranList(parms)>
									<table border="1" class="tableList" width="500">
										<tr>
											<td colspan="6">#trans.QResult#</td>
										</tr>
										<cfloop array="#trans.tranArray#" index="item">
											<cfset item.datasource=parms.datasource>
											<cfset data=pur.ValidateTransRecord(parms,item)>
											<tr>
												<td>#data.tran.trnID#</td>
												<td>#LSDateFormat(data.tran.trnDate,"dd-mmm-yyyy")#</td>
												<td>#data.tran.trnType#</td>
												<td>#data.tran.trnMethod#</td>
												<td>#data.tran.trnAmnt1#</td>
												<td>Missing Items: 
													<cfif ArrayLen(data.ItemsMissing) GT 0>
														<table>
															<cfloop array="#data.ItemsMissing#" index="item">
															<tr>
																<td>#item.nomCode#</td>
																<td>#item.niAmount#</td>
															</tr>
															</cfloop>
														</table>
													<cfelse>
														None.											
													</cfif>
												</td>
											</tr>
										</cfloop>
									</table>
								</cfcase>
								
								<cfcase value="8">
									<cfset data=pur.VATReturn(parms)>
									<cfset summary = {
										"box1" = {"title" = "VAT due on sales and other outputs", "value" = 0},
										"box2" = {"title" = "VAT due on acquisitions from other EC States", "value" = 0},
										"box3" = {"title" = "Total VAT due (sum of boxes 1 & 2)", "value" = 0},
										"box4" = {"title" = "VAT reclaimed on purchases", "value" = 0},
										"box5" = {"title" = "Net VAT payable or repayable", "value" = 0},
										"box6" = {"title" = "Total value of sales", "value" = 0},
										"box7" = {"title" = "Total value of purchases", "value" = 0},
										"box8" = {"title" = "Total value of supplies from EC States", "value" = 0},
										"box9" = {"title" = "Total value of acquisitions from EC States", "value" = 0}
									}>
									<cfoutput>
										<table class="tableList" border="1">
										<cfset periodKeys = ListSort(StructKeyList(data.PRD,","),"numeric","asc",",")>
										<cfloop list="#periodKeys#" index="prdKey">
											<cfset period = StructFind(data.PRD,prdKey)>
											<cfset prdDate = CreateDate(mid(prdKey,1,4),mid(prdKey,6,2),1)>
											<tr>
												<td colspan="5"><h1>#LSDateFormat(prdDate,"mmm yyyy")#</h1></td>
											</tr>
											<cfset ledgerKeys = ListSort(StructKeyList(period,","),"text","asc",",")>
											<cfloop list="#ledgerKeys#" index="ledgerKey">
												<cfset ledger = StructFind(period,ledgerKey)>
												<cfif ledgerKey eq "PURCH">
													<cfset summary.box4.value += ledger.zgrand.total.vat>
													<cfset summary.box7.value += ledger.zgrand.total.net>				
												<cfelse>
													<cfset summary.box1.value += ledger.zgrand.total.vat>				
													<cfset summary.box3.value += ledger.zgrand.total.vat>				
													<cfset summary.box6.value += ledger.zgrand.total.net>				
												</cfif>
												<cfset summary.box5.value += ledger.zgrand.total.vat>
												<tr>
													<td colspan="5" class="header">#ledgerKey#</td>
												</tr>
												<tr>
													<th>Rate</th>
													<th>Prop</th>
													<th>Gross</th>
													<th>VAT</th>
													<th>Net</th>
												</tr>
												<cfset deptKeys = ListSort(StructKeyList(ledger,","),"text","asc",",")>
												<cfloop list="#deptKeys#" index="deptKey">
													<cfset dept = StructFind(ledger,deptKey)>
													<cfif deptKey neq "zgrand">
														<tr>
															<td colspan="5" class="header">#deptKey#</td>
														</tr>
													</cfif>
													<cfset vatKeys = ListSort(StructKeyList(dept,","),"text","asc",",")>
													<cfloop list="#vatKeys#" index="vatKey">
														<cfset rec = StructFind(dept,vatKey)>
														<cfif vatKey IS "total"><cfset style = "font-weight:bold;"><cfelse><cfset style = ""></cfif>
														<cfif IsStruct(rec)>
															<tr style="#style#">
																<td align="right">#rec.rate#</td>
																<td align="right">#DecimalFormat(rec.prop)#</td>
																<td align="right">#DecimalFormat(rec.gross)#</td>
																<td align="right">#DecimalFormat(rec.vat)#</td>
																<td align="right">#DecimalFormat(rec.net)#</td>
															</tr>
														<cfelse>
															<tr>
																<td><cfdump var="#rec#" label="rec" expand="no"></td>
															</tr>
														</cfif>
													</cfloop>
												</cfloop>
											</cfloop>
										</cfloop>
										</table>
										<h1>VAT Summary</h1>
										<table class="vatTable" border="1">
											<cfset boxKeys = ListSort(StructKeyList(summary,","),"text","asc",",")>
											<cfloop list="#boxKeys#" index="boxKey">
												<cfset box = StructFind(summary,boxKey)>
												<cfif boxKey eq "box5" and box.value gt 0>
													<cfset style = "color:red;">
													<cfset title = "(refund)">
												<cfelse>
													<cfset style = "">
													<cfset title = "">
												</cfif>
												<tr>
													<td style="#style#">#box.title# #title#</td><td style="#style#" align="right">#DecimalFormat(box.value)#</td>
												</tr>
											</cfloop>
										</table>
										<h1>Sales Analysis Summary</h1>
										<cfset analysis = {}>
										<cfset periodKeys = ListSort(StructKeyList(data.PRD,","),"numeric","asc",",")>
										<cfloop list="#periodKeys#" index="prdKey">
											<cfset period = StructFind(data.PRD,prdKey)>
											<cfset ledgerKeys = ListSort(StructKeyList(period,","),"text","asc",",")>
											<cfloop list="#ledgerKeys#" index="ledgerKey">
												<cfset ledger = StructFind(period,ledgerKey)>
												<cfset deptKeys = ListSort(StructKeyList(ledger,","),"text","asc",",")>
												<cfloop list="#deptKeys#" index="deptKey">
													<cfif deptKey neq "zgrand">
														<cfset dept = StructFind(ledger,deptKey)>
														<cfif NOT StructKeyExists(analysis,ledgerKey)>
															<cfset StructInsert(analysis,ledgerKey,{})>
														</cfif>
														<cfset anLedger = StructFind(analysis,ledgerKey)>
														<cfif NOT StructKeyExists(anLedger,deptKey)>
															<cfset StructInsert(anLedger,deptKey,{})>
														</cfif>
														<cfset anDept = StructFind(anLedger,deptKey)>
														<cfif NOT StructKeyExists(anDept,prdKey)>
															<cfset StructInsert(anDept,prdKey,{})>
														</cfif>
														<cfset anPeriod = StructFind(anDept,prdKey)>
														<cfset tots = dept.total>
														<cfset anPeriod.net = tots.net>
														<cfset anPeriod.vat = tots.vat>
														<cfset anPeriod.gross = tots.gross>
													</cfif>
												</cfloop>
											</cfloop>
										</cfloop>
										<cfset ledgerKeys = ListSort(StructKeyList(analysis,","),"text","asc",",")>
										<table class="vatTable" border="1">
										<cfloop list="#ledgerKeys#" index="ledgerKey">
											<cfset ledger = StructFind(analysis,ledgerKey)>
											<cfset deptKeys = ListSort(StructKeyList(ledger,","),"text","asc",",")>
											<cfloop list="#deptKeys#" index="deptKey">
												<cfset dept = StructFind(ledger,deptKey)>
												<cfset totals = {}>
												<cfset totals.net = 0>
												<cfset totals.vat = 0>
												<cfset totals.gross = 0>
												<cfset periodKeys = ListSort(StructKeyList(dept,","),"numeric","asc",",")>
												<tr>
													<td>#ledgerKey#</td>
													<td>#deptKey#</td>
													<td align="right">Net</td>											
													<td align="right">VAT</td>											
													<td align="right">Gross</td>											
												</tr>
												<cfloop list="#periodKeys#" index="prdKey">
													<cfset period = StructFind(dept,prdKey)>
													<tr>
														<td></td>
														<td>#prdKey#</td>
														<td align="right">#DecimalFormat(period.net)#</td>
														<td align="right">#DecimalFormat(period.vat)#</td>
														<td align="right">#DecimalFormat(period.gross)#</td>
													</tr>
													<cfset totals.net += period.net>
													<cfset totals.vat += period.vat>
													<cfset totals.gross += period.gross>
												</cfloop>
												<tr>
													<th></th>
													<th>#deptKey# total</th>
													<th align="right">#DecimalFormat(totals.net)#</th>
													<th align="right">#DecimalFormat(totals.vat)#</th>
													<th align="right">#DecimalFormat(totals.gross)#</th>
												</tr>
												<tr><td colspan="5">&nbsp;</td></tr>
											</cfloop>
										</cfloop>
										</table>
									</cfoutput>
								</cfcase>
								
								<cfcase value="9">
									<cfset data=pur.VATTransactions(parms)>
									<!---<cfdump var="#data#" label="data" expand="yes">--->
									<cfset analysis = {}>
									<table class="tableList" border="1">
										<cfset nCode = "">
										<cfset nTotal = 0>
										<cfset gTotal = 0>
										<cfset account = {}>
										<cfloop query="data.QSalesTrans">
											<cfif len(nCode) AND nCode neq nomCode>
												<tr>
													<th colspan="6">Total</th>
													<th align="right">#DecimalFormat(nTotal)#</th>
												</tr>
												<cfset nTotal = 0>		
											</cfif>
											<tr>
												<td>#trnID#</td>
												<td>#LSDateFormat(trnDate)#</td>
												<td>#nomType#</td>
												<td>#nomClass#</td>
												<td>#nomCode#</td>
												<td>#nomTitle#</td>
												<td align="right">#DecimalFormat(niAmount)#</td>
											</tr>
											<cfset nCode = nomCode>
											<cfset nTotal += niAmount>
											<cfset gTotal += niAmount>
											<cfif StructKeyExists(analysis,nomCode)>
												<cfset nomAcct = StructFind(analysis,nomCode)>
												<cfset nomAcct.value += niAmount>
											<cfelse>
												<cfset StructInsert(analysis,nomCode,{"title" = nomTitle, "value" = niAmount})>
											</cfif>
											<cfif nomClass eq "ext">
												<cfif StructKeyExists(analysis,"EXT")>
													<cfset nomAcct = StructFind(analysis,"EXT")>
													<cfset nomAcct.value -= niAmount>
												<cfelse>
													<cfset StructInsert(analysis,"EXT",{"title" = "External Suppliers", "value" = -niAmount})>
												</cfif>
												<cfset nTotal -= niAmount>
												<cfset gTotal -= niAmount>
											</cfif>
										</cfloop>
										<tr>
											<th colspan="6">Total</th>
											<th align="right">#DecimalFormat(nTotal)#</th>
										</tr>
										<tr>
											<th colspan="6">Grand Total</th>
											<th align="right">#DecimalFormat(gTotal)#</th>
										</tr>									
									</table>
									<table>
										<cfset account = {}>
										<cfset pCode = "">
										<cfset netTotal = 0>
										<cfset vatTotal = 0>
										<cfset grossTotal = 0>
										<cfset GnetTotal = 0>
										<cfset GvatTotal = 0>
										<cfset GgrossTotal = 0>
										<cfloop query="data.QPurTrans">
											<cfif pCode neq accCode>
												<cfif len(pCode)>
													<tr>
														<th colspan="6">Total</th>
														<th align="right">#DecimalFormat(netTotal)#</th>
														<th align="right">#DecimalFormat(vatTotal)#</th>
														<th align="right">#DecimalFormat(grossTotal)#</th>
													</tr>
													<cfset accKeys = ListSort(StructKeyList(account,","),"text","asc",",")>
													<cfset subTotal = 0>
													<cfloop list="#accKeys#" index="accKey">
														<cfset acc = StructFind(account,accKey)>
														<cfset subTotal += acc.value>
														<tr>
															<td colspan="4"></td>
															<td>#accKey#</td>
															<td>#acc.title#</td>
															<td align="right">#DecimalFormat(acc.value)#</td>
															<td colspan="2"></td>
														</tr>
													</cfloop>
													<tr>
														<td colspan="5"></td>
														<td>Total</td>
														<td align="right">#DecimalFormat(subTotal)#</td>
														<td colspan="2"></td>
													</tr>
													<cfset GnetTotal += netTotal>
													<cfset GvatTotal += vatTotal>
													<cfset GgrossTotal += grossTotal>
													<cfset netTotal = 0>
													<cfset vatTotal = 0>
													<cfset grossTotal = 0>
													<cfset account = {}>
												</cfif>
												<tr>
													<th colspan="9">#accCode# #accName#</th>
												</tr>
											</cfif>
											<tr>
												<td>#trnID#</td>
												<td>#LSDateFormat(trnDate)#</td>
												<td>#nomType#</td>
												<td>#nomClass#</td>
												<td>#nomCode#</td>
												<td>#nomTitle#</td>
												<td align="right">#DecimalFormat(niAmount)#</td>
												<td align="right">#DecimalFormat(vatAmnt)#</td>
												<td align="right">#DecimalFormat(niAmount + vatAmnt)#</td>
											</tr>
											<cfset netTotal += niAmount>
											<cfset vatTotal += vatAmnt>
											<cfset grossTotal += (niAmount + vatAmnt)>
											<cfset pCode = accCode>
											<cfif StructKeyExists(account,nomCode)>
												<cfset nomAcct = StructFind(account,nomCode)>
												<cfset nomAcct.value += niAmount>
											<cfelse>
												<cfset StructInsert(account,nomCode,{"title" = nomTitle, "value" = niAmount})>
											</cfif>
											<cfif StructKeyExists(analysis,nomCode)>
												<cfset nomAcct = StructFind(analysis,nomCode)>
												<cfset nomAcct.value += niAmount>
											<cfelse>
												<cfset StructInsert(analysis,nomCode,{"title" = nomTitle, "value" = niAmount})>
											</cfif>
											<cfif StructKeyExists(analysis,"VAT")>
												<cfset nomAcct = StructFind(analysis,"VAT")>
												<cfset nomAcct.value += vatAmnt>
											<cfelse>
												<cfset StructInsert(analysis,"VAT",{"title" = "Purchase VAT", "value" = vatAmnt})>
											</cfif>
										</cfloop>
										<tr>
											<th colspan="6">Total</th>
											<th align="right">#DecimalFormat(netTotal)#</th>
											<th align="right">#DecimalFormat(vatTotal)#</th>
											<th align="right">#DecimalFormat(grossTotal)#</th>
										</tr>
													<cfset GnetTotal += netTotal>
													<cfset GvatTotal += vatTotal>
													<cfset GgrossTotal += grossTotal>
										<cfset accKeys = ListSort(StructKeyList(account,","),"text","asc",",")>
										<cfset subTotal = 0>
										<cfloop list="#accKeys#" index="accKey">
											<cfset acc = StructFind(account,accKey)>
											<cfset subTotal += acc.value>
											<tr>
												<td colspan="4"></td>
												<td>#accKey#</td>
												<td>#acc.title#</td>
												<td align="right">#DecimalFormat(acc.value)#</td>
												<td colspan="2"></td>
											</tr>
										</cfloop>
										<tr>
											<td colspan="5"></td>
											<td>Total</td>
											<td align="right">#DecimalFormat(subTotal)#</td>
											<td colspan="2"></td>
										</tr>
										<tr>
											<th colspan="6">Grand Total</th>
											<th align="right">#DecimalFormat(GnetTotal)#</th>
											<th align="right">#DecimalFormat(GvatTotal)#</th>
											<th align="right">#DecimalFormat(GgrossTotal)#</th>
										</tr>									
										<cfset accKeys = ListSort(StructKeyList(analysis,","),"text","asc",",")>
										<cfset crTotal = 0>
										<cfset drTotal = 0>
										<cfloop list="#accKeys#" index="accKey">
											<cfset acc = StructFind(analysis,accKey)>
											<cfset subTotal += acc.value>
											<tr>
												<td colspan="4"></td>
												<td>#accKey#</td>
												<td>#acc.title#</td>
												<cfif acc.value gt 0>
													<cfset drTotal += acc.value>
													<td align="right">#DecimalFormat(acc.value)#</td>
													<td></td>
												<cfelse>
													<cfset crTotal += acc.value>
													<td></td>
													<td align="right">#DecimalFormat(acc.value)#</td>
												</cfif>
												<td></td>
											</tr>
										</cfloop>
										<tr>
											<td colspan="5"></td>
											<td>Totals</td>
											<td align="right">#DecimalFormat(drTotal)#</td>
											<td align="right">#DecimalFormat(crTotal)#</td>
											<td></td>
										</tr>
										<tr>
											<td colspan="5"></td>
											<td>Gross Profit</td>
											<td align="right"></td>
											<td align="right">#DecimalFormat(drTotal + crTotal)#</td>
											<td></td>
										</tr>
									</table>
								</cfcase>
								
								<cfcase value="10">
									<cfset data=pur.NomTotalReport(parms)>
									<!---<cfdump var="#data#" label="data" expand="no">--->
									<cfset nomList = ListSort(StructKeyList(data.rows,","),"text","asc")>
									<cfset monthList = ListSort(StructKeyList(data.totals,","),"numeric","asc")>
									<table class="tableList" border="1">
										<tr>
											<th>Code</th>
											<th>Type</th>
											<th>Title</th>
											<cfloop list="#monthList#" delimiters="," index="i">
												<th align="right">#i#</th>
											</cfloop>
											<th>Total</th>
										</tr>
										<cfloop list="#nomList#" delimiters="," index="item">
											<cfset nom = StructFind(data.rows,item)>
											<tr>
												<td>#item#</td>
												<td>#nom.nomType#</td>
												<td>#nom.nomTitle#</td>
												<cfset rowTotal = 0>
												<cfloop list="#monthList#" delimiters="," index="i">
													<td align="right">
														<cfif StructKeyExists(nom.nomBals,i)>
															<cfset value = StructFind(nom.nomBals,i)>
															<cfset rowTotal += value>
															#DecimalFormat(value)#
														</cfif>
													</td>
												</cfloop>
												<td align="right">#DecimalFormat(rowTotal)#</td>
											</tr>
										</cfloop>
										<tr>
											<th></th>
											<th></th>
											<th>Totals</th>
											<cfset rowTotal = 0>
											<cfloop list="#monthList#" delimiters="," index="i">
												<cfset total = StructFind(data.totals,i)>
												<cfset rowTotal += total>
												<th align="right">#DecimalFormat(total)#</th>
											</cfloop>
											<th align="right">#DecimalFormat(rowTotal)#</th>
										</tr>
									</table>
								</cfcase>
							</cfswitch>
						</cfif>
					</div>
				</div>
			</div>
			<!---<cfdump var="#diffArray#" label="diffArray" expand="no">--->
			<div class="clear"></div>
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

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>