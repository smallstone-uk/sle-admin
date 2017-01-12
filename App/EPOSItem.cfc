component extends = "Framework.Model"
{
    variables.table = "tblEPOS_Items";
    variables.model = "EPOSItem";

    /**
     * Called when the item is updated.
     *
     * @return any
     */
    public any function onUpdated()
    {
        // Update header record totals
        var header = this.header();
        var items = new App.EPOSItem().where('eiParent', header.ehID).getArray();
        var totalNet = 0;
        var totalVAT = 0;

        for (item in items) {
            if (lCase(item.eiClass) != 'pay') {
                writeDumpToFile(item);
                totalNet += item.eiNet;
                totalVAT += item.eiVAT;
            }
        }

        header.ehNet = totalNet;
        header.ehVAT = totalVAT;
        writeDumpToFile(header);
        header.save();
    }

    /**
     * Gets this item's header record.
     *
     * @return any
     */
    public any function header()
    {
        return this.belongsToOne('EPOSHeader', 'eiParent');
    }

    /**
     * Gets this item's product record.
     *
     * @return any
     */
    public any function product()
    {
        return this.hasOne('Product', 'eiProdID');
    }

    /**
     * Gets this item's publication record.
     *
     * @return any
     */
    public any function publication()
    {
        return this.hasOne('Publication', 'eiPubID');
    }

    /**
     * Gets this item's payment record.
     *
     * @return any
     */
    public any function payment()
    {
        return this.hasOne('EPOSAccount', 'eiPayID');
    }

    /**
     * Gets this item's account record.
     *
     * @return any
     */
    public any function account()
    {
        return this.hasOne('EPOSAccount', 'eiAccID');
    }

    /**
     * Gets this item's title.
     *
     * @return any
     */
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
