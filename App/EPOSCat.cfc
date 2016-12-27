component extends = "Framework.Model"
{
    variables.table = "tblEPOS_Cats";
    variables.model = "EPOSCat";

    public array function getParents()
    {
        return this.where("epcParent", 0).orderBy("epcOrder", "asc").getArray();
    }

    public array function getChildren()
    {
        return this.where("epcParent", this.epcID).orderBy("epcOrder", "asc").getArray();
    }
}
