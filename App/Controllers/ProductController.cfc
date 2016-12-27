component extends = "App.Framework.Controller"
{
    public any function loadBrokenPromoProducts(any args)
    {
        var products = new App.Product()
            .orderBy("prodID", "desc")
            .take(args.take)
            .skip(args.skip)
            .getArray();

        return view('products.broken-promo', {'products' = products});
    }
}
