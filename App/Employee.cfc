component extends = "Framework.Model"
{
    variables.table = "tblEmployee";
    variables.model = "Employee";

    public array function getEPOSCategories()
    {
        return this.hasManyToOne(
            // The many
            'EPOSEmpCat', 'empID', 'eecEmployee',

            // The one
            'EPOSCat', 'eecCategory', 'epcID',

            // Order by clause
            'eecOrder', 'asc'
        );
    }

    public array function getUnassignedEPOSCategories()
    {
        var allCats = new App.EPOSCat().all();
        var myCats = this.getEPOSCategories();
        var unassigned = [];

        for (cat in allCats) {
            var canAdd = true;

            for (empCat in myCats) {
                if (empCat.epcID == cat.epcID) {
                    canAdd = false;
                }
            }

            if (canAdd) {
                arrayAppend(unassigned, cat);
            }
        }

        return unassigned;
    }
}
