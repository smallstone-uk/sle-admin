<cfoutput>
    <option value="0">Select Category</option>

    <cfloop array="#categories#" index="cat">
        <cfif cat.epcParent is 0 AND cat.epcType eq "OUT">
            <option value="#cat.epcID#">#cat.epcTitle#</option>
        </cfif>

        <!--- <cfloop array="#categories#" index="child">
            <cfif child.epcParent is cat.epcID>
                <option value="#child.epcID#">&mdash; #child.epcTitle#</option>
            </cfif>
        </cfloop> --->
    </cfloop>
</cfoutput>
