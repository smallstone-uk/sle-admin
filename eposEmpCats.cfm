<cftry>

<cfoutput>
    <cfinclude template="bootstrap.cfm">
    <cfinclude template="sleHeader.cfm">

    <script>
        $(document).ready(function(e) {
            employeeReload = function(id) {
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "loadCategoriesForEmployee")#',
                    data: {"empID": id},
                    success: function(data) {
                        $('.cat-list').html(data);
                    }
                });
                
                $.ajax({
                    type: 'POST',
                    url: '#route("EPOSController", "loadUnassignedCategoryOptionsForEmployee")#',
                    data: {"empID": id},
                    success: function(data) {
                        $('##categoryPicker').html(data);
                    }
                });
            }

            $('##employeePicker').change(function(event) {
                var id = $(this).val();

                if (id != 0) {
                    employeeReload(id);
                }
            });

            $('##CategoryPickerForm').submit(function(event) {
                var id = $('##categoryPicker').val();
                var empID = $('##employeePicker').val();

                if (id != 0 && empID != 0) {
                    $.ajax({
                        type: 'POST',
                        url: '#route("EPOSController", "addCategoryToEmployee")#',
                        data: {
                            "empID": empID,
                            "epcID": id
                        },
                        success: function(data) {
                            employeeReload(empID);
                        }
                    });
                }

                event.preventDefault();
            });
        });
    </script>

    <div class="container">
        <div class="module mt-5">
            <h1>EPOS Employee Category Allocation Manager</h1>
        </div>
        <div class="module">
            <form method="post" class="pull-left">
                <select name="empID" id="employeePicker">
                    <option value="0">Select Employee</option>
                    <cfloop array="#new App.Employee().orderBy('empFirstName').getArray()#" index="emp">
                        <option value="#emp.empID#">#emp.empFirstName# #emp.empLastName#</option>
                    </cfloop>
                </select>
            </form>

            <form method="post" class="pull-right" id="CategoryPickerForm">
                <select name="epcID" id="categoryPicker"></select>
                <input type="submit" value="Add" class="btn btn-primary">
            </form>
        </div>
        <div class="module cat-list"></div>
    </div>

    <cfinclude template="sleFooter.cfm">
</cfoutput>

<cfcatch type="any">
    <cfdump var="#cfcatch#" label="cfcatch" expand="false">
</cfcatch>
</cftry>
