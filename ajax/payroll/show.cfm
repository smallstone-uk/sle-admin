<cfscript>
    record = new code.payroll2().LoadPayrollRecord({
        "url" = url,
        "datasource" = getDatasource(),
        "form" = {
            "employee" = url.employee,
            "weekending" = url.weekending
        }
    });

    outputJson(record);
</cfscript>
