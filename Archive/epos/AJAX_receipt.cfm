
<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset trans=epos.LoadTransaction(parm)>

<style type="text/css">
	@page  
	{   size:portrait;
		margin-top:0px;
		margin-left:10px;
		margin-right:10px;
		margin-bottom:0px;
		
	}
	@media print {	
		h1 {font-size:15px;}
		div {font-size:9px;font-family: Arial, sans-serif;}
		div span {display:inline-block;}
	}
</style>

<!--- Receipt Width: 165px appox. --->

<cfoutput>
	<!---<cfdump var="#trans#" label="trans" expand="yes">--->
	<h1>Shortlanesend Store</h1>
	<cfloop array="#trans.list#" index="i">
		<div>
			<span style="width:134px;">#i.prodTitle#</span>
			<cfif i.qty gt 1>
				<div>
					<span style="width:40px;">&nbsp;</span>
					<span style="width:91px;">#i.qty# @ &pound;#DecimalFormat(i.price)#</span>
					<span style="width:20px;text-align:right;">&pound;#DecimalFormat(i.price*i.qty)#</span>
				</div>
			<cfelse>
				<span style="width:20px;text-align:right;">&pound;#DecimalFormat(i.price)#</span>
			</cfif>
		</div>
	</cfloop>
	<div style="font-size:14px;padding:10px 0;"><span style="width:110px;">Total</span><span style="width:50px;text-align:right;">&pound;#DecimalFormat(trans.gross)#</span></div>
</cfoutput>
