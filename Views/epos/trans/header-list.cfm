<cfoutput>
    <cfloop array="#headers#" index="h">
        <cfset children = h.getItems()>

        <div class="panel panel-default">
            <div class="panel-heading">
                <strong>#humanTimestamp(h.ehTimestamp)#</strong>
                <a href="javascript:void(0)" data-id="#h.ehID#" class="btn-delete-parent pull-right">Delete</a>
            </div>

            <cfif NOT ArrayIsEmpty(children)>
                <table class="table">
                    <cfloop array="#children#" index="c">
                        <tr class="child-item">
                            <td align="left">#c.getTitle()#</td>
                            <td align="right" width="25">#c.eiQty#</td>
                            <td align="right" width="100">&pound;#c.eiRetail#</td>
                            <td align="right" width="50">
                                <a href="javascript:void(0)" data-id="#c.eiID#" class="btn-edit-child btn btn-default btn-sm pull-right">Edit</a>
                            </td>
                            <td align="right" width="50">
                                <a href="javascript:void(0)" data-id="#c.eiID#" class="btn-delete-child btn btn-danger btn-sm pull-right ml-1">Delete</a>
                            </td>
                        </tr>
                    </cfloop>
                </table>
            </cfif>
        </div>
    </cfloop>
</cfoutput>
