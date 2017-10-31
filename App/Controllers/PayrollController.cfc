component extends = "App.Framework.Controller"
{
    /**
     * Shows the given employee payroll data.
     *
     * @return string
     */
    public any function show(required struct employee, required string weekEnding)
    {
        outputJson(
            new code.payroll2().LoadPayrollRecord({
                'url' = url,
                'datasource' = getDatasource(),
                'form' = {
                    'employee' = employee.empID,
                    'weekending' = weekEnding
                }
            })
        );
    }
}
