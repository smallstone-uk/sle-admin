<cfoutput>
    <script>
        $(document).ready(function(e) {
            $('.EditItemForm').submit(function(event) {
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "saveTranItem")#',
                    data: $(this).serialize(),
                    success: function(data) {
                        closeModal();
                        $('.btn-applyfilter').click();
                    }
                });

                event.preventDefault();
            });
        });
    </script>

    <div class="modal-inner">
        <h1>Edit Item</h1>
        <form method="post" class="EditItemForm">
            <input type="hidden" name="eiID" value="#item.eiID#">
            <div class="row">
                <div class="form-group col-md-4">
                    <label>Class</label>
                    <input type="text" name="eiClass" class="form-control" placeholder="Class" value="#item.eiClass#">
                </div>
                <div class="form-group col-md-4">
                    <label>Type</label>
                    <input type="text" name="eiType" class="form-control" placeholder="Type" value="#item.eiType#">
                </div>
                <div class="form-group col-md-4">
                    <label>Pay Type</label>
                    <input type="text" name="eiPayType" class="form-control" placeholder="Pay Type" value="#item.eiPayType#">
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-12">
                    <label>Product</label>
                    <input type="text" name="eiProdID" class="form-control" placeholder="Product" value="#item.eiProdID#">
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-12">
                    <label>Publication</label>
                    <input type="text" name="eiPubID" class="form-control" placeholder="Publication" value="#item.eiPubID#">
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-12">
                    <label>Payment</label>
                    <input type="text" name="eiPayID" class="form-control" placeholder="Payment" value="#item.eiPayID#">
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-12">
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
        <a href="javascript:$('.EditItemForm').submit()" class="btn btn-primary pull-right ml-2">Save</a>
        <a href="javascript:closeModal()" class="btn btn-default pull-right">Cancel</a>
    </div>
</cfoutput>
