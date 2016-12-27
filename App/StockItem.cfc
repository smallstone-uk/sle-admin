component extends = "Framework.Model"
{
    variables.table = "tblStockItem";
    variables.model = "StockItem";

    public any function getOrder()
    {
        return this.hasOne("StockOrder", "siOrder");
    }
}
