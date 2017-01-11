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

            new Model('EPOSHeader').bindDelete('.btn-delete-parent', 'click', function(el) {
                el.parents('.panel').remove();
            });

            new Model('EPOSItem').bindDelete('.btn-delete-child', 'click', function(el) {
                el.parents('.child-item').remove();
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
