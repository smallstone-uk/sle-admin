component extends = "App.Framework.Controller"
{
    /**
     * Shows the index page.
     *
     * @return any
     */
    public any function index(struct args)
    {
        return view('generic.index', args);
    }
}
