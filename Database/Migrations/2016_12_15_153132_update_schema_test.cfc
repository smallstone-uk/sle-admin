component
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public void function up()
    {
        var table = schema('schema_test');

        table.dropColumn('summary');
        table.string('location').nullable();
        table.foreign('user_id').references('tblEmployee', 'empID').onDelete('set null');

        table.update();
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public void function down()
    {
        var table = schema('schema_test');

        table.longText('summary').nullable();
        table.dropColumn('location');
        table.dropForeign('user_id');

        table.update();
    }
}
