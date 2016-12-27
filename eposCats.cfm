<cftry>

<cfoutput>
    <cfinclude template="bootstrap.cfm">
    <cfinclude template="sleHeader.cfm">

    <script>
        $(document).ready(function(e) {
            $('.btn-add').click(function(event) {
                modal('#route("EPOSController", "createCategory")#');
                event.preventDefault();
            });

            loadCatsList = function() {
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "listCategories")#',
                    data: {},
                    success: function(data) {
                        $('.cat-list').html(data);
                    }
                });
            }

            loadCatsList();
        });
    </script>

    <div class="container">
        <div class="module mt-5">
            <h1>EPOS Category Manager</h1>
        </div>
        <div class="module">
            <a href="javascript:void(0)" class="btn btn-primary btn-add pull-right">Add Category</a>
        </div>
        <div class="module cat-list"></div>
    </div>

    <cfinclude template="sleFooter.cfm">
</cfoutput>

<cfcatch type="any">
    <cfdump var="#cfcatch#" label="cfcatch" expand="false">
</cfcatch>
</cftry>
