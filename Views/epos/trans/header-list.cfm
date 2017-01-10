<cfoutput>
    <cfloop array="#headers#" index="h">
        <cfset children = h.getItems()>

        <li class="list-group-item tran-item">
            <a href="javascript:void(0)" data-id="#h.ehID#" class="btn-delete-parent btn btn-danger btn-sm pull-right">Delete</a>

            <h4 class="list-group-item-heading">
                #h.ehTimestamp#
            </h4>

            <p class="list-group-item-text">
                <span class="label label-success">NET #h.ehNet#</span>
                <span class="label label-warning">VAT #h.ehVAT#</span>

                <cfif NOT ArrayIsEmpty(children)>
                    <ul class="list-group mt-3 mb-0" style="display:none;">
                        <cfloop array="#children#" index="c">
                            <li class="list-group-item child-item">
                                <a href="javascript:void(0)" data-id="#c.eiID#" class="btn-delete-child btn btn-danger btn-sm pull-right ml-1">Delete</a>
                                <a href="javascript:void(0)" data-id="#c.eiID#" class="btn-edit-child btn btn-default btn-sm pull-right">Edit</a>
                                <h4 class="list-group-item-heading">
                                    #c.eiTimestamp#
                                </h4>
                            </li>
                        </cfloop>
                    </ul>
                </cfif>
            </p>
        </li>
    </cfloop>
</cfoutput>
