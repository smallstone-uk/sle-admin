<cfoutput>
    <cfinclude template="bootstrap.cfm">
    <cfinclude template="sleHeader.cfm">

    <script>
        $(document).ready(function(e) {
            loadProducts = function(take, skip) {
                $.ajax({
                    type: 'POST',
                    url: "#route('ProductController', 'loadBrokenPromoProducts')#",
                    data: {
                        "take": take,
                        "skip": skip
                    },
                    success: function(data) {
                        $('.product-array').append(data);
                        loadProducts(take, skip + take);
                    }
                });
            }

            loadProducts(10, 0);
        });
    </script>

    <div class="container">
        <div class="module">
            <table class="table table-striped table-condensed table-bordered">
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Deal</th>
                    <th>Stock</th>
                    <th>Barcode</th>
                </tr>
                <tbody class="product-array"></tbody>
            </table>
        </div>
    </div>

    <cfinclude template="sleFooter.cfm">
</cfoutput>
