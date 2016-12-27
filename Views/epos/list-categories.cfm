<cfoutput>
    <script>
        $(document).ready(function(e) {
            $('.cat-item').click(function(event) {
                var child = $(this).find('.list-group');
                $('.cat-item').removeClass("active").find('.list-group').hide();
                $(this).addClass("active");
                child.show();
            });

            $('.btn-remove-child').click(function(event) {
                var child = $(this).parents('.child-item');
                var id = $(this).data('id');
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "removeCategory")#',
                    data: {"id": id},
                    success: function(data) {
                        child.remove();
                        loadCatsList();
                    }
                });
                event.preventDefault();
            });

            $('.btn-delete-child').click(function(event) {
                var child = $(this).parents('.child-item');
                var id = $(this).data('id');
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "deleteCategory")#',
                    data: {"id": id},
                    success: function(data) {
                        child.remove();
                    }
                });
                event.preventDefault();
            });

            $('.btn-edit-child').click(function(event) {
                var id = $(this).data('id');
                modal('#route("EPOSController", "editCategory")#', {'id': id});
                event.preventDefault();
            });

            $('.btn-delete-parent').click(function(event) {
                var parent = $(this).parents('.cat-item');
                var id = $(this).data('id');
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "deleteCategory")#',
                    data: {"id": id},
                    success: function(data) {
                        parent.remove();
                    }
                });
                event.preventDefault();
                event.stopPropagation();
            });

            $('.btn-edit-parent').click(function(event) {
                var id = $(this).data('id');
                modal('#route("EPOSController", "editCategory")#', {'id': id});
                event.preventDefault();
                event.stopPropagation();
            });
        });
    </script>

    <ul class="list-group">
        <cfloop array="#categories#" index="cat">
            <cfset children = cat.getChildren()>
            <li class="list-group-item cat-item">
                <span class="badge ml-2" style="width:50px">#cat.epcID#</span>
                <a href="javascript:void(0)" data-id="#cat.epcID#" class="btn-delete-parent btn btn-danger btn-sm pull-right ml-1">Delete</a>
                <a href="javascript:void(0)" data-id="#cat.epcID#" class="btn-edit-parent btn btn-default btn-sm pull-right">Edit</a>
                <h4 class="list-group-item-heading">
                    #cat.epcTitle#
                </h4>
                <p class="list-group-item-text">
                    <span class="label label-primary">#cat.epcKey#</span>
                    <cfif cat.epcType eq "OUT">
                        <span class="label label-info">#cat.epcType#</span>
                    <cfelse>
                        <span class="label label-warning">#cat.epcType#</span>
                    </cfif>
                    <cfif NOT ArrayIsEmpty(children)>
                        <ul class="list-group mt-3 mb-0" style="display:none;">
                            <cfloop array="#children#" index="child">
                                <li class="list-group-item child-item">
                                    <h4 class="list-group-item-heading">
                                        #child.epcTitle#
                                        <a href="javascript:void(0)" data-id="#child.epcID#" class="btn-remove-child btn btn-default btn-xs pull-right ml-1">Remove</a>
                                        <a href="javascript:void(0)" data-id="#child.epcID#" class="btn-delete-child btn btn-danger btn-xs pull-right ml-1">Delete</a>
                                        <a href="javascript:void(0)" data-id="#child.epcID#" class="btn-edit-child btn btn-default btn-xs pull-right">Edit</a>
                                    </h4>
                                </li>
                            </cfloop>
                        </ul>
                    </cfif>
                </p>
            </li>
        </cfloop>
    </ul>
</cfoutput>
