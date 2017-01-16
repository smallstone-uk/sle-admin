<cfoutput>
    <script>
        $(document).ready(function(e) {
            new Model('EPOSItem').bindSave('.edit-item-form', 'submit', function() {
                $('##edit-item-modal').modal('hide');
                $('.btn-applyfilter').click();
            });

            $('##create-item-modal').on('show.bs.modal', function(event) {
                var button = $(event.relatedTarget);
                $(this).find('input[name="eiID"]').val(button.data('id'));
            });
        });
    </script>

    <div class="modal fade" id="edit-item-modal" tabindex="-1" role="dialog" aria-labelledby="edit-item-modal">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>

                    <h4 class="modal-title">Edit Item</h4>
                </div>

                <div class="modal-body">
                    <form class="form edit-item-form" method="post">
                        <input type="hidden" name="eiID" value="">

                        <div class="row">
                            <div class="form-group col-md-4 label-floating">
                                <label class="control-label">Class</label>
                                <input type="text" name="eiClass" class="form-control" placeholder="Class" value="#item.eiClass#">
                            </div>
                            <div class="form-group col-md-4 label-floating">
                                <label class="control-label">Type</label>
                                <input type="text" name="eiType" class="form-control" placeholder="Type" value="#item.eiType#">
                            </div>
                            <div class="form-group col-md-4 label-floating">
                                <label class="control-label">Pay Type</label>
                                <input type="text" name="eiPayType" class="form-control" placeholder="Pay Type" value="#item.eiPayType#">
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-md-12 label-floating">
                                <label class="control-label">Product</label>
                                <input type="text" name="eiProdID" class="form-control" placeholder="Product" value="#item.eiProdID#">
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-md-12 label-floating">
                                <label class="control-label">Publication</label>
                                <input type="text" name="eiPubID" class="form-control" placeholder="Publication" value="#item.eiPubID#">
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-md-12 label-floating">
                                <label class="control-label">Payment</label>
                                <input type="text" name="eiPayID" class="form-control" placeholder="Payment" value="#item.eiPayID#">
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-md-12 label-floating">
                                <label class="control-label">Account</label>
                                <input type="text" name="eiAccID" class="form-control" placeholder="Account" value="#item.eiAccID#">
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-md-3 label-floating">
                                <label class="control-label">Quantity</label>
                                <input type="text" name="eiQty" class="form-control" placeholder="Quantity" value="#item.eiQty#">
                            </div>
                            <div class="form-group col-md-3 label-floating">
                                <label class="control-label">Retail</label>
                                <input type="text" name="eiRetail" class="form-control" placeholder="Retail" value="#item.eiRetail#">
                            </div>
                            <div class="form-group col-md-3 label-floating">
                                <label class="control-label">Net</label>
                                <input type="text" name="eiNet" class="form-control" placeholder="Net" value="#item.eiNet#">
                            </div>
                            <div class="form-group col-md-3 label-floating">
                                <label class="control-label">VAT</label>
                                <input type="text" name="eiVAT" class="form-control" placeholder="VAT" value="#item.eiVAT#">
                            </div>
                        </div>
                    </form>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" onclick="$('.edit-item-form').submit()">Save changes</button>
                </div>
            </div>
        </div>
    </div>
</cfoutput>
