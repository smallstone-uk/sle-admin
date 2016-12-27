<cfoutput>
    <script>
        $(document).ready(function(e) {
            $('.btn-delete-cat').click(function(event) {
                var row = $(this).parents('.list-group-item');
                var epcID = $(this).data("id");

                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "removeCategoryFromEmployee")#',
                    data: {
                        "empID": "#empID#",
                        "epcID": epcID
                    },
                    success: function(data) {
                        employeeReload(Number("#empID#"));
                    }
                });

                event.preventDefault();
            });
        });
    </script>
    <cfif NOT ArrayIsEmpty(categories)>
        <ul class="list-group">
            <cfloop array="#categories#" index="cat">
                <li class="list-group-item">
                    <a
                        href="javascript:void(0)"
                        data-id="#cat.epcID#"
                        class="btn-delete-cat btn btn-danger btn-sm pull-right ml-1"
                    >Remove</a>

                    <span class="badge pull-left mr-2" style="width:50px">#cat.epcID#</span>

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
                    </p>
                </li>
            </cfloop>
        </ul>
    <cfelse>
        <p class="bg bg-warning">No categories assigned.</p>
    </cfif>
</cfoutput>
