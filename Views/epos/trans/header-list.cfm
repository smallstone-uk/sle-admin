<cfoutput>
    <cfloop array="#headers#" index="h">
        <cfset children = h.getItems()>

        <div class="panel panel-primary header-panel">
            <div class="panel-heading">
                <strong title="#h.ehTimestamp#">
                    NET #DecimalFormat(h.ehNet)# /
                    VAT #DecimalFormat(h.ehVAT)# /
                    #humanTimeDiff(h.ehTimestamp)#
                </strong>
                <a href="javascript:void(0)" data-id="#h.ehID#" class="btn-delete-parent pull-right" style="color:white">Delete</a>
            </div>

            <cfif NOT ArrayIsEmpty(children)>
                <table class="table">
                    <cfloop array="#children#" index="c">
                        <tr class="child-item">
                            <td align="left">#c.title()#</td>
                            <td align="right" width="25">#c.eiQty#</td>
                            <td align="right" width="100">&pound;#c.eiRetail#</td>
                            <td align="right" width="50">
                                <a href="javascript:void(0)" data-id="#c.eiID#" class="btn-edit-child btn btn-primary btn-raised btn-sm pull-right">Edit</a>
                            </td>
                            <td align="right" width="50">
                                <a href="javascript:void(0)" data-id="#c.eiID#" class="btn-delete-child btn btn-danger btn-raised btn-sm pull-right">Delete</a>
                            </td>
                        </tr>
                    </cfloop>
                </table>
            </cfif>
        </div>
    </cfloop>
</cfoutput>
