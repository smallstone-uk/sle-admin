<cfoutput>
    <cfinclude template="bootstrap.cfm">
    <cfinclude template="sleHeader.cfm">

    <script>
        $(document).ready(function(e) {
            $('.form-filter').submit(function(event) {
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "loadTransactions")#',
                    data: $('.form-filter').serialize(),
                    beforeSend: function() {
                        $('.tran-headers .list-group').html('<p>Loading..</p>');
                    },
                    success: function(data) {
                        $('.tran-headers .list-group').html(data);
                    }
                });

                event.preventDefault();
            });

            $('.btn-applyfilter').click(function(event) {
                $('.form-filter').submit();
                event.preventDefault();
            });

            $(document).on("click", ".tran-item", function(event) {
                var child = $(this).find('.list-group');
                $('.tran-item').removeClass("active").find('.list-group').hide();
                $(this).addClass("active");
                child.show();
            });

            $(document).on("click", ".btn-delete-parent", function(event) {
                var caller = $(this);
                var id = caller.data('id');

                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "deleteHeader")#',
                    data: {'id': id},
                    success: function(data) {
                        caller.parents('.tran-item').remove();
                    }
                });

                event.preventDefault();
            });

            $(document).on("click", ".btn-delete-child", function(event) {
                var caller = $(this);
                var id = caller.data('id');

                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "deleteItem")#',
                    data: {'id': id},
                    success: function(data) {
                        caller.parents('.child-item').remove();
                    }
                });

                event.preventDefault();
            });

            $(document).on("click", ".btn-edit-child", function(event) {
                var id = $(this).data('id');
                modal('#route("EPOSController", "editTranItem")#', {'id': id});
                event.preventDefault();
            });
        });
    </script>

    <div class="container">
        <div class="module mt-5">
            <h1>EPOS Transactions</h1>
        </div>

        <div class="module">
            <form method="post" class="form-inline form-filter">
                <div class="form-group">
                    <label class="mr-1">From</label>
                    <input type="date" name="datefrom" class="form-control">
                </div>

                <div class="form-group">
                    <input type="time" name="timefrom" class="form-control">
                </div>

                <div class="form-group">
                    <label class="mr-1 ml-5">To</label>
                    <input type="date" name="dateto" class="form-control">
                </div>

                <div class="form-group">
                    <input type="time" name="timeto" class="form-control">
                </div>

                <a href="javascript:void(0)" class="btn btn-primary pull-right btn-applyfilter">Apply Filter</a>
            </form>
        </div>

        <div class="module tran-headers">
            <ul class="list-group">
                <p>Search for transactions above</p>
            </ul>
        </div>
    </div>

    <cfinclude template="sleFooter.cfm">
</cfoutput>
