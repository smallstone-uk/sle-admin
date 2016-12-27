<cfoutput>
    <script>
        $(document).ready(function(e) {
            $('.CreateCategoryForm').submit(function(event) {
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "storeCategory")#',
                    data: $(this).serialize(),
                    success: function(data) {
                        closeModal();
                        loadCatsList();
                    }
                });
                event.preventDefault();
            });
        });
    </script>

    <div class="modal-inner">
        <h1>Create/Edit Category</h1>
        <form method="post" class="CreateCategoryForm">
            <input type="hidden" name="epcID" value="#category.epcID#">
            <div class="row">
                <div class="form-group col-md-6">
                    <label>Title</label>
                    <input type="text" name="epcTitle" class="form-control" placeholder="Title" value="#category.epcTitle#">
                </div>
                <div class="form-group col-md-3">
                    <label>Key</label>
                    <input type="text" name="epcKey" class="form-control" placeholder="Key" value="#category.epcKey#">
                </div>
                <div class="form-group col-md-3">
                    <label>Type</label>
                    <cfset selectedType = category.epcType>
                    <select name="epcType" class="form-control">
                        <option value="IN" <cfif selectedType eq 'IN'>selected="true"</cfif>>IN</option>
                        <option value="OUT" <cfif selectedType eq 'OUT'>selected="true"</cfif>>OUT</option>
                    </select>
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-6">
                    <label>File (optional)</label>
                    <input type="text" name="epcFile" class="form-control" placeholder="File" value="#category.epcFile#">
                </div>
                <div class="form-group col-md-6 checkbox">
                    <label>
                        Show in product manager
                        <input type="checkbox" name="epcPMAllow" class="form-control" <cfif category.epcPMAllow>checked="true"</cfif>>
                    </label>
                </div>
            </div>
            <div class="row">
                <div class="form-group col-md-12">
                    <label>Parent</label>
                    <cfset selectedParent = category.epcParent>
                    <select name="epcParent" class="form-control">
                        <option value="0">[0] None</option>
                        <cfloop array="#new App.EPOSCat().getParents()#" index="item">
                            <option value="#item.epcID#" <cfif selectedParent is item.epcID>selected="true"</cfif>>[#item.epcID#] #item.epcTitle#</option>
                        </cfloop>
                    </select>
                </div>
            </div>
        </form>
    </div>

    <div class="modal-controls">
        <a href="javascript:$('.CreateCategoryForm').submit()" class="btn btn-primary pull-right ml-2">Confirm</a>
        <a href="javascript:closeModal()" class="btn btn-default pull-right">Cancel</a>
    </div>
</cfoutput>