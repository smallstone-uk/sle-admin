component
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public void function up()
    {
        var table = schema('tblPayHeader');

        table.decimal('phEmployerContribution', 10, 2).nullable();
        table.decimal('phMemberContribution', 10, 2).nullable();
        table.decimal('phAdjustment', 10, 2).nullable();

        table.update();
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public void function down()
    {
        var table = schema('tblPayHeader');

        table.dropColumn('phEmployerContribution');
        table.dropColumn('phMemberContribution');
        table.dropColumn('phAdjustment');
    }
}
