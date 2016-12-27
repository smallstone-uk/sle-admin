<cfcomponent displayname="payroll" extends="core">

	<cffunction name="LoadMinimalPayrollReportByDate" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.headers" datasource="#args.datasource#">
			SELECT tblPayHeader.*,
				SUM(phGross) AS TotalGross,
				SUM(phPAYE) AS TotalPAYE,
				SUM(phNI) AS TotalNI,
				SUM(phNP) AS TotalNP,
				SUM(phTotalHours) AS TotalHours,
				SUM(phWorkHours) AS WorkHours,
				SUM(phHolHours) AS HolHours
			FROM tblPayHeader
			WHERE phDate BETWEEN '#args.form.From#' AND '#args.form.To#'
			GROUP BY phDate
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.headers)>
	</cffunction>
	<cffunction name="LoadPayrollReportByDate" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		<cfset loc.fromDate = args.form.From>
		<cfset loc.toDate = args.form.To>
		<cfset loc.currentDate = "">
		
		<cfquery name="loc.weeks" datasource="#args.database#">
			SELECT phDate, phWeekNo
			FROM tblPayHeader
			WHERE phDate BETWEEN '#loc.fromDate#' AND '#loc.toDate#'
			GROUP BY phDate
			ORDER BY phDate ASC
		</cfquery>
		
		<cfloop query="loc.weeks">
			<cfset arrayAppend(loc.result, {
				"weekEnding" = "#DateFormat(phDate, 'yyyy-mm-dd')#",
				"weekNo" = phWeekNo,
				"items" = []
			})>
		</cfloop>
		
		<cfloop array="#loc.result#" index="i">
			<cfquery name="loc.headers" datasource="#args.database#">
				SELECT tblPayHeader.*, tblEmployee.*,
					(SELECT SUM(phGross)		FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS GrossSum,
					(SELECT SUM(phPAYE)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS PAYESum,
					(SELECT SUM(phNI)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS NISum,
					(SELECT SUM(phNP)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS NPSum,
					(SELECT SUM(phTotalHours)	FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS HoursSum,
					(SELECT SUM(phWorkHours)	FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS WorkSum,
					(SELECT SUM(phHolHours)		FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS HolSum
				FROM tblPayHeader, tblEmployee
				WHERE phDate = '#i.weekEnding#'
				AND phEmployee = empID
				ORDER BY empFirstName ASC
			</cfquery>
			<cfset i.items = QueryToArrayOfStruct(loc.headers)>
		</cfloop>
				
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="LoadEmployeeReport" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		<cfif StructKeyExists(args.form, "employee")>
			<cfset loc.empArr = ListToArray(args.form.employee, ",")>
		<cfelse>
			<cfset loc.empArr = LoadEmployeesByID(args)>
		</cfif>
		
		<cfloop array="#loc.empArr#" index="emp">
			<cfset loc.subResult = {}>
			<cfset loc.subResult.Headers = []>
			
			<!---GET EMPLOYEE DETAILS--->
			<cfset loc.params = {}>
			<cfset loc.params.employee = val(emp)>
			<cfset loc.params.database = args.database>
			<cfset loc.subResult.Employee = LoadEmployee(loc.params)>
			
			<!---GET HEADERS--->
			<cfquery name="loc.headers" datasource="#args.database#" result="loc.subResult.QheaderResult">
				SELECT *,
					(SELECT SUM(phGross) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#') AS GrossSum,
					(SELECT SUM(phPAYE) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#') AS PAYESum,
					(SELECT SUM(phNI) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#') AS NISum,
					(SELECT SUM(phNP) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#') AS NPSum,
					(SELECT SUM(phTotalHours) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#') AS HoursSum,
					(SELECT SUM(phWorkHours) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#') AS WorkSum,
					(SELECT AVG(phWorkHours) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#') AS WorkAvg,
					(SELECT SUM(phHolHours) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#') AS HolSum
				FROM tblPayHeader
				WHERE phEmployee = #val(emp)#
				AND phDate BETWEEN '#args.form.From#' AND '#args.form.To#'
				ORDER BY phDate
			</cfquery>
			
			<cfloop query="loc.headers">
				<cfset loc.item = {}>
				<cfset loc.item.ID = phID>
				<cfset loc.item.EmpID = phEmployee>
				<cfset loc.item.WeekEnding = phDate>
				<cfset loc.item.WeekNo = phWeekNo>
				<cfset loc.item.Gross = phGross>
				<cfset loc.item.PAYE = phPAYE>
				<cfset loc.item.NI = phNI>
				<cfset loc.item.NP = phNP>
				<cfset loc.item.Hours = phTotalHours>
				<cfset loc.item.WorkHours = phWorkHours>
				<cfset loc.item.HolHours = phHolHours>
				<cfset ArrayAppend(loc.subResult.Headers, loc.item)>
			</cfloop>
			
			<cfset loc.subResult.Sums = {}>
			<cfset loc.subResult.Sums.Gross = loc.headers.GrossSum>
			<cfset loc.subResult.Sums.PAYE = loc.headers.PAYESum>
			<cfset loc.subResult.Sums.NI = loc.headers.NISum>
			<cfset loc.subResult.Sums.NP = loc.headers.NPSum>
			<cfset loc.subResult.Sums.Hours = loc.headers.HoursSum>
			<cfset loc.subResult.Sums.WorkHours = loc.headers.WorkSum>
			<cfset loc.subResult.Sums.HolHours = loc.headers.HolSum>
						
			<cfset loc.subResult.hols = {}>
			<cfset loc.subResult.hols.recs = loc.headers.recordcount>
			<cfset loc.subResult.hols.WorkAvg = loc.headers.WorkAvg>
			<cfset loc.subResult.Sums.taken = val(loc.headers.HolSum)>
			<cfif loc.subResult.Employee.ServicePrd GT 11>
				<cfset loc.subResult.hols.annual = val(loc.headers.WorkAvg) * 5.6>
				<cfset loc.subResult.hols.accrued = 0>
				<cfset loc.subResult.hols.remain = loc.subResult.hols.annual - loc.subResult.Sums.taken>
			<cfelse>
				<cfset loc.subResult.hols.annual = 0>
				<cfset loc.subResult.hols.accrued = val(loc.subResult.Sums.WorkHours) * 0.1207>
				<cfset loc.subResult.hols.remain = loc.subResult.hols.accrued - loc.subResult.Sums.taken>
			</cfif>
			
			<cfset ArrayAppend(loc.result, loc.subResult)>
		</cfloop>
		

		<cfreturn loc.result>
	</cffunction>
	<cffunction name="LoadReport" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cftry>
		<cfset loc.weekNoStart = "#Year(Now())#-#DateFormat(application.controls.weekNoStartDate, 'mm-dd')#">
		
		<cfquery name="loc.headers" datasource="#args.database#">
			SELECT *
			FROM tblPayHeader
			WHERE phDate = '#args.weekEnding#'
		</cfquery>
		
		<cfloop query="loc.headers">
			<cfset loc.item = {}>
			<cfset loc.item.header = {}>
			<cfset loc.item.header.ID = phID>
			<cfset loc.item.header.EmpID = phEmployee>
			<cfset loc.item.header.WeekEnding = DateDiff("ww", loc.weekNoStart, phDate)>
			<cfset loc.item.header.WeekNo = phWeekNo>
			<cfset loc.item.header.Gross = phGross>
			<cfset loc.item.header.PAYE = phPAYE>
			<cfset loc.item.header.NI = phNI>
			<cfset loc.item.header.NP = phNP>
			<cfset loc.item.header.THours = phTotalHours>
			<cfset loc.item.WeekDays = {}>
			<cfset loc.item.Employee = {}>
			
			<cfquery name="loc.employee" datasource="#args.database#">
				SELECT *,
					(SELECT ctlEmployer FROM tblControl WHERE ctlID = 1) AS Employer,
					(SELECT ctlEmployerRef FROM tblControl WHERE ctlID = 1) AS EmployerRef
				FROM tblEmployee
				WHERE empID = #val(loc.item.header.EmpID)#
			</cfquery>
			
			<cfloop query="loc.employee">
				<cfset loc.item.Employee.ID = empID>
				<cfset loc.item.Employee.FirstName = empFirstName>
				<cfset loc.item.Employee.LastName = empLastName>
				<cfset loc.item.Employee.DOB = empDOB>
				<cfset loc.item.Employee.Start = empStart>
				<cfset loc.item.Employee.Rate = empRate>
				<cfset loc.item.Employee.Rate2 = empRate2>
				<cfset loc.item.Employee.Rate3 = empRate3>
				<cfset loc.item.Employee.Status = empStatus>
				<cfset loc.item.Employee.TaxCode = empTaxCode>
				<cfset loc.item.Employee.Employer = Employer>
				<cfset loc.item.Employee.EmployerRef = EmployerRef>
			</cfloop>
			
			<cfquery name="loc.getEmployeeItems" datasource="#args.database#">
				SELECT *
				FROM tblPayItems, tblPayHeader, tblPayDepartment
				WHERE piParent = phID
				AND piParent = #val(loc.item.header.ID)#
				AND piDept = depID
				ORDER BY phEmployee, phDate
			</cfquery>
			
			<cfloop query="loc.getEmployeeItems">
				<cfset loc.type = {}>
				<cfset loc.type.ID = piID>
				<cfset loc.type.WHeadID = piParent>
				<cfset loc.type.Gross = piGross>
				<cfset loc.type.Type = depName>
				<cfset loc.type.DayStr = piDay>
				<cfif loc.type.Gross gt 0>
					<cfset StructInsert(loc.item.WeekDays, "#loc.type.Type#", loc.type)>
				</cfif>
			</cfloop>
			<cfset ArrayAppend(loc.result, loc.item)>
		</cfloop>
		
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="LoadTypes" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.types" datasource="#args.database#">
			SELECT *
			FROM tblEmpWorkType
		</cfquery>
		
		<cfloop query="loc.types">
			<cfset loc.item = {}>
			<cfset loc.item.ID = ewtID>
			<cfset loc.item.String = ewtVar>
			<cfset loc.item.Title = ewtTitle>
			<cfset ArrayAppend(loc.result, loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="SavePayrollRecord" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		<cfif Len(args.form.recID)>
			<cfset loc.recID = args.form.recID>
		<cfelse>
			<cfset loc.recID = 0>
		</cfif>
		
		<cfquery name="loc.checkHeader" datasource="#args.database#">
			SELECT *
			FROM tblEmpWorkHeader
			WHERE whEmpID = #val(args.form.empID)#
			AND whWeekEnding = '#args.form.prWeek#'
		</cfquery>
		
		<cfif loc.checkHeader.recordcount is 0>
			<cfquery name="loc.newHeader" datasource="#args.database#" result="loc.newHeaderResult">
				INSERT INTO tblEmpWorkHeader (
					whEmpID,
					whWeekEnding,
					whWeekNo,
					whGross,
					whPAYE,
					whNI,
					whNP,
					whHours
				) VALUES (
					#val(args.form.empID)#,
					'#args.form.prWeek#',
					#Week(args.form.prWeek)-14#,
					#val(args.form.grossTotal)#,
					#val(args.form.paye)#,
					#val(args.form.ni)#,
					#val(args.form.np)#,
					#val(args.form.totalHours)#
				)
			</cfquery>
			<cfset loc.wHeadID = loc.newHeaderResult.GeneratedKey>
		<cfelse>
			<cfquery name="loc.newHeader" datasource="#args.database#" result="loc.newHeaderResult">
				UPDATE tblEmpWorkHeader
				SET whEmpID = #val(args.form.empID)#,
					whWeekEnding = '#args.form.prWeek#',
					whWeekNo = #Week(args.form.prWeek)-14#,
					whGross = #val(args.form.grossTotal)#,
					whPAYE = #val(args.form.paye)#,
					whNI = #val(args.form.ni)#,
					whNP = #val(args.form.np)#,
					whHours = #val(args.form.totalHours)#
				WHERE whID = #val(loc.recID)#
			</cfquery>
			<cfset loc.wHeadID = val(loc.recID)>
		</cfif>
		
		<cfloop array="#args.form.headers#" index="item">
			<cfquery name="loc.checkItem" datasource="#args.database#">
				SELECT *
				FROM tblEmpWorkItem
				WHERE etWHeadID = #val(loc.wHeadID)#
				AND etType = '#item.type#'
			</cfquery>
			<cfdump var="#item#" label="item" expand="no">
			<cfif loc.checkItem.recordcount is 0>
				<cfquery name="loc.newItem" datasource="#args.database#">
					INSERT INTO tblEmpWorkItem (
						etWHeadID,
						etGross,
						etRate,
						etType,
						etSun,
						etMon,
						etTue,
						etWed,
						etThu,
						etFri,
						etSat
					) VALUES (
						#val(loc.wHeadID)#,
						#val(item.gross)#,
						#val(item.cells[1].rate)#,
						'#item.type#',
						#val(item.cells[1].hours)#,
						#val(item.cells[2].hours)#,
						#val(item.cells[3].hours)#,
						#val(item.cells[4].hours)#,
						#val(item.cells[5].hours)#,
						#val(item.cells[6].hours)#,
						#val(item.cells[7].hours)#
					)
				</cfquery>
			<cfelse>
				<cfquery name="loc.newItem" datasource="#args.database#" result="loc.newItemResult">
					UPDATE tblEmpWorkItem
					SET etGross = #val(item.gross)#,
						etRate = #val(item.cells[1].rate)#,
						etType = '#item.type#',
						etSun = #val(item.cells[1].hours)#,
						etMon = #val(item.cells[2].hours)#,
						etTue = #val(item.cells[3].hours)#,
						etWed = #val(item.cells[4].hours)#,
						etThu = #val(item.cells[5].hours)#,
						etFri = #val(item.cells[6].hours)#,
						etSat = #val(item.cells[7].hours)#
					WHERE etWHeadID = #val(loc.wHeadID)#
					AND etType = '#item.type#'
				</cfquery>
				<cfdump var="#loc.newItemResult#" label="newItemResult" expand="no">
			</cfif>
		</cfloop>
		
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</cfcatch>
		</cftry>
		
	</cffunction>
	<cffunction name="LoadPayrollRecord" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.getEmployeeHeader" datasource="#args.database#">
			SELECT *
			FROM tblEmpWorkHeader
			WHERE whEmpID = #val(args.employee)#
			AND whWeekEnding = '#args.prWeek#'
		</cfquery>
		
		<cfset loc.result.ID = loc.getEmployeeHeader.whID>
		<cfset loc.result.EmpID = loc.getEmployeeHeader.whEmpID>
		<cfset loc.result.WeekEnding = loc.getEmployeeHeader.whWeekEnding>
		<cfset loc.result.WeekNo = loc.getEmployeeHeader.whWeekNo>
		<cfset loc.result.Gross = loc.getEmployeeHeader.whGross>
		<cfset loc.result.PAYE = loc.getEmployeeHeader.whPAYE>
		<cfset loc.result.NI = loc.getEmployeeHeader.whNI>
		<cfset loc.result.NP = loc.getEmployeeHeader.whNP>
		<cfset loc.result.WeekDays = {}>
		
		<cfquery name="loc.getEmployeeItems" datasource="#args.database#">
			SELECT *
			FROM tblEmpWorkItem
			WHERE etWHeadID = #val(loc.result.ID)#
		</cfquery>
		
		<cfloop query="loc.getEmployeeItems">
			<cfset loc.result.Item = {}>
			<cfset loc.result.Item.ID = etID>
			<cfset loc.result.Item.WHeadID = etWHeadID>
			<cfset loc.result.Item.Gross = etGross>
			<cfset loc.result.Item.Rate = etRate>
			<cfset loc.result.Item.Type = etType>
			<cfset loc.result.Item.Mon = etMon>
			<cfset loc.result.Item.Tue = etTue>
			<cfset loc.result.Item.Wed = etWed>
			<cfset loc.result.Item.Thu = etThu>
			<cfset loc.result.Item.Fri = etFri>
			<cfset loc.result.Item.Sat = etSat>
			<cfset loc.result.Item.Sun = etSun>
			<cfset StructInsert(loc.result.WeekDays, "#loc.result.Item.Type#", loc.result.Item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="LoadEmployee" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.employees" datasource="#args.database#">
			SELECT *,
				(SELECT ctlEmployer FROM tblControl WHERE ctlID = 1) AS Employer,
				(SELECT ctlEmployerRef FROM tblControl WHERE ctlID = 1) AS EmployerRef
			FROM tblEmployee
			WHERE empID = #val(args.employee)#
			ORDER BY empLastName
		</cfquery>
		
		<cfset loc.result = {}>
		<cfset loc.result.ID = loc.employees.empID>
		<cfset loc.result.FirstName = loc.employees.empFirstName>
		<cfset loc.result.LastName = loc.employees.empLastName>
		<cfset loc.result.DOB = loc.employees.empDOB>
		<cfset loc.result.Start = loc.employees.empStart>
		<cfif IsDate(loc.result.Start)>
			<cfset loc.result.ServicePrd = DateDiff("m",loc.result.Start,Now())>
		<cfelse>
			<cfset loc.result.ServicePrd = 0>
		</cfif>
		<cfset loc.result.Rate = loc.employees.empRate>
		<cfset loc.result.Rate2 = loc.employees.empRate2>
		<cfset loc.result.Rate3 = loc.employees.empRate3>
		<cfset loc.result.Status = loc.employees.empStatus>
		<cfset loc.result.TaxCode = loc.employees.empTaxCode>
		<cfset loc.result.Employer = loc.employees.Employer>
		<cfset loc.result.EmployerRef = loc.employees.EmployerRef>
		<cfset loc.result.NI = loc.employees.empNI>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="LoadEmployeesByID" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.employees" datasource="#args.database#">
			SELECT empID
			FROM tblEmployee
		</cfquery>
		
		<cfloop query="loc.employees">
			<cfset ArrayAppend(loc.result, empID)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="LoadEmployees" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.employees" datasource="#args.database#">
			SELECT *
			FROM tblEmployee
			WHERE empStatus='active'
			ORDER BY empFirstName ASC
		</cfquery>
		
		<cfloop query="loc.employees">
			<cfset loc.item = {}>
			<cfset loc.item.ID = empID>
			<cfset loc.item.FirstName = empFirstName>
			<cfset loc.item.LastName = empLastName>
			<cfset loc.item.DOB = empDOB>
			<cfset loc.item.Start = empStart>
			<cfset loc.item.Rate = empRate>
			<cfset loc.item.Status = empStatus>
			<cfset ArrayAppend(loc.result, loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
</cfcomponent>