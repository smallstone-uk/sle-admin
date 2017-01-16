<cfoutput>
    <cfinclude template="bootstrap_m.cfm">
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
                el.parents('.header-panel').remove();
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

    <div class="navbar navbar-default">
        <div class="container">
            <div class="navbar-header">
                <a class="navbar-brand" href="#getUrl('/eposTrans.cfm')#">EPOS Transactions</a>
            </div>
        </div>
    </div>

    <div class="container">
        <div class="panel panel-default">
            <div class="panel-body">
                <form class="form-filter form-inline text-center">
                    <div class="form-group label-floating mr-5" style="width:20%">
                        <label class="control-label" for="timeframeFrom">From</label>
                        <input type="text" id="timeframeFrom" name="timeframeFrom" class="form-control" value="#day(now())-7#/#month(now())#/#year(now())#">
                    </div>

                    <div class="form-group label-floating mr-5" style="width:20%">
                        <label class="control-label" for="timeframeTo">To</label>
                        <input type="text" id="timeframeTo" name="timeframeTo" class="form-control" value="#day(now())#/#month(now())#/#year(now())#">
                    </div>

                    <div class="form-group">
                        <a href="javascript:void(0)" class="btn btn-primary btn-raised btn-applyfilter pull-right">Search</a>
                    </div>
                </form>
            </div>
        </div>

        <div class="panel panel-default tran-headers">
            <div class="panel-body">
                <ul class="list-group">
                    <p>Search for transactions above</p>
                </ul>
            </div>
        </div>
    </div>

    <cfinclude template="sleFooter.cfm">
</cfoutput>
