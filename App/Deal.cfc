component extends = "Framework.Model"
{
    variables.table = "tblEPOS_Deals";
    variables.model = "Deal";

    public boolean function hasExpired()
    {
        return this.edEnds <= Now();
    }
}
