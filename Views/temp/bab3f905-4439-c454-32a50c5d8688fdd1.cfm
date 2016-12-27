<cfoutput>
    <cfif NOT ArrayIsEmpty()>
        <ul class="list-group">
            <cfloop array="#categories#" index="cat">
                <li class="list-group-item">
                <a href="javascript:void(0)" data-id="#cat.epcID#" class="btn-delete-parent btn btn-danger btn-sm pull-right ml-1">Remove</a>
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
        <p>No categories assigned.</p>
    </cfif>
</cfoutput>
