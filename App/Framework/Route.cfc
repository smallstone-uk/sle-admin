component
{
    public any function init(string controller = "", string method = "")
    {
        if (controller == "" && method == "") {
            return this;
        }

        if (findNoCase("@", controller) > 0) {
            // Found @ - find method in controller
            var identifiers = listToArray(controller, "@");
            controller = identifiers[1];
            method = identifiers[2];
        }

        return getUrl('App/Framework/Request.cfm?controller=#controller#&method=#method#');
    }

    public route function handle()
    {
        if (structKeyExists(url, "controller") && structKeyExists(url, "method")) {
            var component = createObject("component", "App.Controllers.#url.controller#");
            var method = component.getMethod(url.method);
            method(form);
        }

        return this;
    }
}
