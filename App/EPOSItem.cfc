component extends = "Framework.Model"
{
    variables.table = "tblEPOS_Items";
    variables.model = "EPOSItem";

    public any function getProduct()
    {
        return new App.Product(this.eiProdID);
    }

    public any function getPublication()
    {
        return new App.Publication(this.eiPubID);
    }

    public any function getPayment()
    {
        return new App.EPOSAccount(this.eiPayID);
    }

    public any function getAccount()
    {
        return new App.EPOSAccount(this.eiAccID);
    }

    public string function getTitle()
    {
        if (this.eiProdID != 1) {
            return this.getProduct().prodTitle;
        }

        if (this.eiPubID != 1) {
            return this.getPublication().pubTitle;
        }

        if (this.eiPayID != 1) {
            return this.getPayment().eaTitle;
        }

        if (this.eiAccID != 1) {
            return this.getAccount().eaTitle;
        }

        return '';
    }
}
