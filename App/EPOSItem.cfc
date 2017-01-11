component extends = "Framework.Model"
{
    variables.table = "tblEPOS_Items";
    variables.model = "EPOSItem";

    public any function product()
    {
        return this.hasOne('Product', 'eiProdID');
    }

    public any function publication()
    {
        return this.hasOne('Publication', 'eiPubID');
    }

    public any function payment()
    {
        return this.hasOne('EPOSAccount', 'eiPayID');
    }

    public any function account()
    {
        return this.hasOne('EPOSAccount', 'eiAccID');
    }

    public string function title()
    {
        if (this.eiProdID != 1) {
            return this.product().prodTitle;
        }

        if (this.eiPubID != 1) {
            return this.publication().pubTitle;
        }

        if (this.eiPayID != 1) {
            return this.payment().eaTitle;
        }

        if (this.eiAccID != 1) {
            return this.account().eaTitle;
        }

        return '';
    }
}
