component
{
    public any function init()
    {
        route()
            .get('/api/payroll/{$employee}/{weekending}', 'PayrollController@show');
    }
}
