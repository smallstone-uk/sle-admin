<cfoutput>
    <script>
        $(document).ready(function(e) {
            new Model('EPOSItem').bindSave('.EditItemForm', 'submit', function() {
                closeModal();
                $('.btn-applyfilter').click();
            });
        });
    </script>

    <div class="modal-inner">
        <h1>Edit Item</h1>

        <form method="post" class="EditItemForm" data-id="#item.eiID#">
            <input type="hidden" name="eiID" value="#item.eiID#">

            <div class="row">
                <div class="form-group col-md-4">
                    <label>Class</label>
                    <select class="form-control" name="eiClass">
                        <cfloop list="sale|supp|disc|item|lot|pay" delimiters="|" index="c">
                            <option value="#c#" <cfif item.eiClass eq c>selected="true"</cfif>>#uCase(c)#</option>
                        </cfloop>
                    </select>
                </div>

                <div class="form-group col-md-4">
                    <label>Type</label>
                    <select class="form-control" name="eiType">
                        <cfloop array="#new App.EPOSCat().where('epcType', 'IN')#" index="t">
                            <option value="#t.epcKey#" <cfif item.eiType eq t.epcKey>selected="true"</cfif>>#t.epcKey#</option>
                        </cfloop>
                    </select>
                </div>

                <div class="form-group col-md-4">
                    <label>Pay Type</label>
                    <select class="form-control" name="eiPayType">
                        <cfloop list="cash|credit" delimiters="|" index="pt">
                            <option value="#pt#" <cfif item.eiPayType eq pt>selected="true"</cfif>>#uCase(pt)#</option>
                        </cfloop>
                    </select>
                </div>
            </div>

            <div class="row">
                <div class="form-group col-md-3">
                    <label>Product</label>
                    <input type="text" name="eiProdID" class="form-control" placeholder="Product" value="#item.eiProdID#">
                </div>

                <div class="form-group col-md-3">
                    <label>Publication</label>
                    <input type="text" name="eiPubID" class="form-control" placeholder="Publication" value="#item.eiPubID#">
                </div>

                <div class="form-group col-md-3">
                    <label>Payment</label>
                    <select class="form-control" name="eiPayID">
                        <cfloop array="#new App.EPOSAccount().all()#" index="p">
                            <option value="#p.eaID#" <cfif item.eiPayID is p.eaID>selected="true"</cfif>>#p.eaTitle#</option>
                        </cfloop>
                    </select>
                </div>

                <div class="form-group col-md-3">
                    <label>Account</label>
                    <input type="text" name="eiAccID" class="form-control" placeholder="Account" value="#item.eiAccID#">
                </div>
            </div>

            <div class="row">
                <div class="form-group col-md-3">
                    <label>Quantity</label>
                    <input type="text" name="eiQty" class="form-control" placeholder="Quantity" value="#item.eiQty#">
                </div>

                <div class="form-group col-md-3">
                    <label>Retail</label>
                    <input type="text" name="eiRetail" class="form-control" placeholder="Retail" value="#item.eiRetail#">
                </div>

                <div class="form-group col-md-3">
                    <label>Net</label>
                    <input type="text" name="eiNet" class="form-control" placeholder="Net" value="#item.eiNet#">
                </div>

                <div class="form-group col-md-3">
                    <label>VAT</label>
                    <input type="text" name="eiVAT" class="form-control" placeholder="VAT" value="#item.eiVAT#">
                </div>
            </div>
        </form>
    </div>

    <div class="modal-controls">
        <a href="javascript:$('.EditItemForm').submit()" class="btn btn-primary btn-raised pull-right ml-2">Save</a>
        <a href="javascript:closeModal()" class="btn btn-default pull-right">Cancel</a>
    </div>
</cfoutput>
