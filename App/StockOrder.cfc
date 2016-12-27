component extends = "Framework.Model"
{
    variables.table = "tblStockOrder";
    variables.model = "StockOrder";

    public boolean function isPromotion()
    {
        return findNoCase("prom", this.soRef) > 0;
    }
}
