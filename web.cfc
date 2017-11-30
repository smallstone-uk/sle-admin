component
{
    public any function init()
    {
        route()
            .get('/api/payroll', 'PayrollController@index');
    }
}
