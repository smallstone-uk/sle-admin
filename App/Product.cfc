component extends = "Framework.Model"
{
    variables.table = "tblProducts";
    variables.model = "Product";

    public model function getCategory()
    {
        return this.hasOne("ProductCat", "prodCatID", "pcatID");
    }

    public model function getEPOSCategory()
    {
        return this.hasOne("EPOSCat", "prodEposCatID");
    }

    public array function getBarcodes()
    {
        return this.hasMany("Barcode", "prodID", "barProdID");
    }

    public array function getCodeSamples()
    {
        return this.hasMany("CodeSample", "prodID", "csItemID");
    }

    public array function getDeals()
    {
        return this.hasMany("DealItem", "prodID", "ediProduct");
    }

    public array function getStockItems()
    {
        return this.hasMany("StockItem", "prodID", "siProduct");
    }

    public array function getPromoStockItems()
    {
        var result = [];

        for (item in this.getStockItems()) {
            if (item.getOrder().isPromotion()) {
                arrayAppend(result, item);
            }
        }

        return result;
    }
}
