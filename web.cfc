component
{
    public any function init()
    {
        var mappings = [
            { 'uri' = 'payroll', 'file' = 'payroll2' },
            { 'uri' = 'transactions', 'file' = 'tranMain2' }
        ];

        for (var item in mappings) {
            route().get(item.uri, 'PageController@index', {
                'fileToInclude' = item.file
            });
        }
    }
}
