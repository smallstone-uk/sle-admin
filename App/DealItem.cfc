component extends = "Framework.Model"
{
    variables.table = "tblEPOS_DealItems";
    variables.model = "DealItem";

    public model function getHeader()
    {
        return this.hasOne("Deal", "ediParent");
    }
}
