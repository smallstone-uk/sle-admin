<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfobject component="code/labels" name="labs">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset labels=labs.LoadPriceLabelsFromList(parm)>
<cfset count=0>

<cfoutput>
	<div class="spacer" style="padding:25px 0;"></div>
	<div class="label-wrap">
		<cfif ArrayLen(labels.list)>
			<cfset count=0>
			<cfloop array="#labels.list#" index="i">
				<cfset count=count+1>
				<div class="label" id="label#i.ID#">
					<div class="label-inner">
						<div id="barcodeTarget#i.ID#" class="barcode"><span style="float: left;font-size:12px;margin: -12px 0 0 -20px;">#i.Barcode#</span></div>
						<label for="box#i.ID#"></label>
						<div class="tick noPrint">
							<input type="checkbox" class="labelbox" id="box#i.ID#" value="#i.ID#" checked="checked">
						</div>
						<div class="title">#i.title#</div>
						<div class="info">#i.UnitSize#</div>
						<div class="price">#i.price#</div>
						<div style="clear:both;"></div>
					</div>
				</div>
				<cfif count eq 21>
					<cfset count=0>
					<div style="page-break-after:always;clear:both;"></div>
					<div class="spacer" style="padding:30px 0;"></div>
				</cfif>
				<!---<script type="text/javascript">
					$("##barcodeTarget#i.ID#").barcode('#i.Barcode#', '#i.BarcodeType#');
				</script>--->
			</cfloop>
		<cfelse>
			No Products Found
		</cfif>
		
		<cfif count gte 19><div style="page-break-after:always;clear:both;"></div></cfif>
		
		<cfset count=0>
		<cfloop collection="#labels.deals#" item="deal">
			<cfset i=StructFind(labels.deals,deal)>
			<cfset count=count+1>
			<div class="label deal" id="label#i.ID#">
				<label for="box#i.ID#"></label>
				<div class="tick noPrint">
					<input type="checkbox" class="labelbox" id="box#i.ID#" value="#i.ID#" checked="checked">
				</div>
				<div class="price">#i.Deal#</div>
				<div class="title">#i.title#</div>
			</div>
			<cfif count eq 8>
				<cfset count=0>
				<div style="page-break-after:always;clear:both;"></div>
				<div class="spacer" style="padding:30px 0;"></div>
			</cfif>
		</cfloop>
	</div>
</cfoutput>
<script type="text/javascript">
	$('#print-area').printArea();
</script>

