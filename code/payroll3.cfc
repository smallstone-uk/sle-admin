<cfcomponent displayname="payroll" extends="core">

	<cffunction name="LoadMinimalPayrollReportByDate" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.headers" datasource="#args.datasource#">
			SELECT tblPayHeader.*,
				SUM(phGross) AS TotalGross,
				SUM(phPAYE) AS TotalPAYE,
				SUM(phNI) AS TotalNI,
				SUM(phEmployerContribution) AS TotalEmployerPension,
				SUM(phMemberContribution) AS TotalMemberPension,
				SUM(phLotterySubs) AS TotalLotto,
				SUM(phAdjustment) AS TotalAdjustment,
				SUM(phNP) AS TotalNP,
				SUM(phTotalHours) AS TotalHours,
				SUM(phWorkHours) AS WorkHours,
				SUM(phHolHours) AS HolHours
			FROM tblPayHeader
			WHERE phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
			GROUP BY phDate
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.headers)>
	</cffunction>
	<cffunction name="LoadPayrollReportByDate" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		<cfset loc.fromDate = args.form.srchDateFrom>
		<cfset loc.toDate = args.form.srchDateTo>
		<cfset loc.currentDate = "">
		
		<cfquery name="loc.weeks" datasource="#args.database#">
			SELECT phWeekNo,phDate
			FROM tblPayHeader
			WHERE phDate BETWEEN '#loc.fromDate#' AND '#loc.toDate#'
			GROUP BY phDate
			ORDER BY phDate ASC
		</cfquery>
		
		<cfloop query="loc.weeks">
			<cfset arrayAppend(loc.result, {
				"weekEnding" = "#DateFormat(phDate, 'yyyy-mm-dd')#",
				"weekNo" =  phWeekNo,
				"items" = []
			})>
		</cfloop>
		<cfloop array="#loc.result#" index="i">
			<cfquery name="loc.headers" datasource="#args.database#">
				SELECT tblPayHeader.*, tblEmployee.*,
					(SELECT SUM(phGross)		FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS GrossSum,
					(SELECT SUM(phPAYE)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS PAYESum,
					(SELECT SUM(phNI)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS NISum,
					(SELECT SUM(phEmployerContribution)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS EmployerPensionSum,
					(SELECT SUM(phMemberContribution)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS MemberPensionSum,
					(SELECT SUM(phLotterySubs)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS LottoSum,
					(SELECT SUM(phAdjustment)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS Adjustment,
					(SELECT SUM(phNP)			FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS NPSum,
					(SELECT SUM(phTotalHours)	FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS HoursSum,
					(SELECT SUM(phWorkHours)	FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS WorkSum,
					(SELECT SUM(phHolHours)		FROM tblPayHeader WHERE phDate = '#i.weekEnding#') AS HolSum
				FROM tblPayHeader, tblEmployee
				WHERE phDate = '#i.weekEnding#'
				AND phEmployee = empID
				<cfif args.currentEmployees>AND empStatus = 'active'</cfif>
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
			<cfset loc.params.currentEmployees = args.currentEmployees>
			<cfset loc.subResult.Employee = LoadEmployee(loc.params)>
			
			<!---GET HEADERS--->
			<cfquery name="loc.headers" datasource="#args.database#" result="loc.subResult.QheaderResult">
				SELECT *,
					(SELECT SUM(phGross) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS GrossSum,
					(SELECT SUM(phPAYE) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS PAYESum,
					(SELECT SUM(phNI) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS NISum,
					(SELECT SUM(phNP) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS NPSum,
					(SELECT SUM(phTotalHours) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS HoursSum,
					(SELECT SUM(phWorkHours) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS WorkSum,
					(SELECT AVG(phWorkHours) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS WorkAvg,
					(SELECT SUM(phHolHours) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS HolSum,
					(SELECT SUM(phEmployerContribution) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS EmployerPensionSum,
					(SELECT SUM(phMemberContribution) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS MemberPensionSum,
					(SELECT SUM(phLotterySubs) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS LottoSum,
					(SELECT SUM(phAdjustment) FROM tblPayHeader WHERE phEmployee = #val(emp)# AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#') AS AdjustmentSum
				FROM tblPayHeader
				INNER JOIN tblEmployee ON empID = phEmployee
				WHERE phEmployee = #val(emp)#
				AND phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
				<cfif args.currentEmployees>AND empStatus = 'active'</cfif>
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
				<cfset loc.item.EmployerPension = phEmployerContribution>
				<cfset loc.item.MemberPension = phMemberContribution>
				<cfset loc.item.Lotto = phLotterySubs>
				<cfset loc.item.Adjustment = phAdjustment>
				<cfset loc.item.Hours = phTotalHours>
				<cfset loc.item.WorkHours = phWorkHours>
				<cfset loc.item.HolHours = phHolHours>
				<cfset loc.item.takeHome = phNP - phLotterySubs>
				<cfset ArrayAppend(loc.subResult.Headers, loc.item)>
			</cfloop>
			
			<cfset loc.subResult.Sums = {}>
			<cfset loc.subResult.Sums.Gross = loc.headers.GrossSum>
			<cfset loc.subResult.Sums.PAYE = loc.headers.PAYESum>
			<cfset loc.subResult.Sums.NI = loc.headers.NISum>
			<cfset loc.subResult.Sums.NP = loc.headers.NPSum>
			<cfset loc.subResult.Sums.EmployerPensionSum = loc.headers.EmployerPensionSum>
			<cfset loc.subResult.Sums.MemberPensionSum = loc.headers.MemberPensionSum>
			<cfset loc.subResult.Sums.LottoSum = loc.headers.LottoSum>
			<cfset loc.subResult.Sums.AdjustmentSum = loc.headers.AdjustmentSum>
			<cfset loc.subResult.Sums.Hours = loc.headers.HoursSum>
			<cfset loc.subResult.Sums.WorkHours = loc.headers.WorkSum>
			<cfset loc.subResult.Sums.HolHours = loc.headers.HolSum>
			<cfset loc.subResult.Sums.takeHome = val(loc.headers.NPSum) - val(loc.headers.LottoSum)>
						
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
	
	<cffunction name="LoadHolidayReportByDate" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QHoliday" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT empID,empFirstName,empLastName,empDOB, AVG(piRate) AS Rate, YEAR(phDate) AS YYYY, SUM( piHours ) AS Work, 
					SUM( piHolHours ) AS Holiday, DATEDIFF(phDate,empDOB) / 365 AS Age,
					SUM(IF(DATEDIFF(phDate,empDOB) < 5840,0,piHours * 0.1207)) AS Entitlement
				FROM tblpayitems
				INNER JOIN tblPayHeader ON piParent = phID
				INNER JOIN tblEmployee ON phEmployee = empID
				WHERE phDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
				<cfif StructKeyExists(args.form,"employee") AND len(args.form.employee)>AND empID IN (#args.form.employee#)</cfif>
				<cfif StructKeyExists(args.form,"active")>AND empStatus = 'active'</cfif>
				AND empRate = 0
				GROUP BY empID, YYYY
				ORDER BY empLastName,empID, YYYY
			</cfquery>
			<cfset loc.result.QHoliday = loc.QHoliday>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
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
			<cfif args.currentEmployees>AND empStatus = 'active'</cfif>
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
			WHERE 1
			<cfif args.currentEmployees>AND empStatus = 'active'</cfif>
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

	<cffunction name="CheckTran" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="data" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.msgs = []>
		<cftry>
			<cfquery name="loc.QCheckTranExists" datasource="#args.database#">
				SELECT trnID
				FROM tblTrans
				WHERE trnRef = '#data.trnRef#'
				AND trnDate = '#data.trnDate#'
				AND trnAccountID = #val(data.trnAccountID)#
			</cfquery>
			<cfif loc.QCheckTranExists.recordcount is 0>
				<cfset loc.tranID = 0>
			<cfelse>
				<cfset loc.tranID = loc.QCheckTranExists.trnID>
			</cfif>
			<cfif loc.tranID is 0>
				<cfquery name="loc.QInsertTran" datasource="#args.database#" result="loc.QInsertTranResult">
					INSERT INTO tblTrans
						(trnRef,trnDate,trnDesc,trnLedger,trnAccountID,trnType,trnAlloc,trnMethod)
					VALUES
						('#data.trnRef#','#data.trnDate#','#data.trnDesc#','#data.trnLedger#',
							#data.trnAccountID#,'#data.trnType#',#data.trnAlloc#,'#data.trnMethod#')
				</cfquery>
				<cfset loc.tranID = loc.QInsertTranResult.generatedkey>
				<cfset ArrayAppend(loc.result.msgs,"Tran inserted #loc.tranID#")>
			<cfelse>
				<cfquery name="loc.QUpdateTran" datasource="#args.database#">
					UPDATE tblTrans
					SET
						trnRef = '#data.trnRef#',
						trnDate = '#data.trnDate#',
						trnDesc = '#data.trnDesc#',
						trnLedger = '#data.trnLedger#',
						trnAccountID = #data.trnAccountID#,
						trnType = '#data.trnType#',
						trnAlloc = #data.trnAlloc#,
						trnMethod = '#data.trnMethod#'
					WHERE trnID = #loc.tranID#
				</cfquery>
				<cfset ArrayAppend(loc.result.msgs,"Tran updated #loc.tranID#")>
			</cfif>
			<cfquery name="loc.QItemsExist" datasource="#args.database#">	<!--- see if any tran items exist --->
				SELECT niID,niNomID,niAmount
				FROM tblNomItems 
				WHERE niTranID = #loc.tranID#
			</cfquery>
			<cfif loc.QItemsExist.recordcount is 0>
				<cfset loc.insertStr = "">
				<cfset loc.itemCount = 0>
				<cfloop array="#data.nomItems#" index="loc.item">
					<cfset loc.itemCount++>
					<cfif loc.item.value neq 0>
						<cfset loc.insertStr = "#loc.insertStr# (#loc.tranID#,#loc.item.nomID#,#loc.item.value#)">
						<cfif loc.itemCount lt ArrayLen(data.nomItems)><cfset loc.insertStr = "#loc.insertStr#,"></cfif>
					</cfif>
				</cfloop>
				<cfset ArrayAppend(loc.result.msgs,loc.insertStr)>
				<cfif Len(loc.insertStr)>
					<cfquery name="loc.QInsertItem" datasource="#args.database#" result="loc.QInsertItemResult">
						INSERT INTO tblNomItems 
							(niTranID,niNomID,niAmount)
						VALUES
							#loc.insertStr#
					</cfquery>
				</cfif>
				<cfset ArrayAppend(loc.result.msgs,"#loc.itemCount# Tran items added to #loc.tranID#")>
			<cfelse>
				<!--- update items --->
				<cfset loc.result.itemStruct = {}>		
				<cfset loc.result.recordStruct = {}>		
				<cfloop array="#data.nomItems#" index="loc.item">
					<cfset StructInsert(loc.result.itemStruct,loc.item.nomID,loc.item.value)>
				</cfloop>
				<cfloop query="loc.QItemsExist">	<!--- loop existing records --->
					<cfset StructInsert(loc.result.recordStruct,niNomID,niAmount)>	<!--- save for later --->
					<cfset loc.itemID = niID>
					<cfset loc.itemNomID = niNomID>
					<cfif StructKeyExists(loc.result.itemStruct,niNomID)>
						<cfset loc.itemValue = StructFind(loc.result.itemStruct,niNomID)>
						<cfif loc.itemValue neq niAmount>	<!--- value changed --->
							<cfquery name="loc.QUpdateItem" datasource="#args.database#">
								UPDATE tblNomItems
								SET niAmount = #loc.itemValue#
								WHERE niID = #loc.itemID#
							</cfquery>
							<cfset ArrayAppend(loc.result.msgs,"Tran item updated #loc.itemID#")>
						<cfelseif loc.itemValue is 0> <!--- empty value saved in earlier version --->
							<cfquery name="loc.QDeleteItem" datasource="#args.database#">
								DELETE FROM tblNomItems WHERE niID = #loc.itemID#
							</cfquery>
							<cfset ArrayAppend(loc.result.msgs,"Zero item deleted #loc.itemID#")>
						</cfif>
					<cfelse>	<!--- item no longer required --->
						<cfquery name="loc.QDeleteItem" datasource="#args.database#">
							DELETE FROM tblNomItems WHERE niID = #loc.itemID#
						</cfquery>
						<cfset ArrayAppend(loc.result.msgs,"Tran item deleted #loc.itemID#")>
					</cfif>
				</cfloop>
				<cfloop array="#data.nomItems#" index="loc.item">	<!--- loop array --->
					<cfif !StructKeyExists(loc.result.recordStruct,loc.item.nomID)>	<!--- new item found --->
						<cfif loc.item.value neq 0>
							<cfquery name="loc.QInsertItem" datasource="#args.database#">
								INSERT INTO tblNomItems
									(niTranID,niNomID,niAmount)
								VALUES
									(#loc.tranID#,#loc.item.nomID#,#loc.item.value#)
							</cfquery>
							<cfset ArrayAppend(loc.result.msgs,"New item added #loc.item.nomID#")>
						</cfif>
					</cfif>
				</cfloop>
				<cfset ArrayAppend(loc.result.msgs,"Tran items updated #loc.tranID#")>
			</cfif>
			<cfset loc.result.trnID = loc.tranID>
			
		<cfcatch type="any">
			<cfdump var="#data.nomItems#" label="nomItems" expand="false">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="ImportPayrollData" access="public" returntype="struct">	<!--- Import data from Payroll to accounts system 27/02/2025 --->
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.trans = []>
		<cfset loc.cashAccount = 181>
		<cfset loc.netPayAccount = 1881>
		<cfset loc.staffWages = 3082>
		<cfset loc.lotteryAccount = 1422>
		<cfset loc.lisaPR = 82>
		<cfset loc.lisaDrawings = 2262>
		<cfset loc.lisaPartner = 3322>
		<cftry>
			<cfquery name="loc.QNomTitles" datasource="#args.database#">
				SELECT nomID, nomTitle
				FROM tblNominal
				WHERE nomID IN(#loc.cashAccount#, #loc.netPayAccount#, #loc.staffWages#, #loc.lisaPartner#, #loc.lisaDrawings#, #loc.lotteryAccount#, 2102, 2182, 2172, 3272, 3282, 2332, 3302)
			</cfquery>
			<cfset loc.result.nomTitles = {}>
			<cfloop query="loc.QNomTitles">
				<cfset StructInsert(loc.result.nomTitles, nomID ,nomTitle)>
			</cfloop>
			<cfquery name="loc.QPayHeaders" datasource="#args.database#">
				SELECT tblpayheader.*, empID,empFirstName,empLastName
				FROM tblpayheader 
				INNER JOIN tblEmployee ON empID = phEmployee
				WHERE phDate BETWEEN '#args.form.srchDateFrom#'
								 AND '#args.form.srchDateTo#'
			</cfquery>

			<cfloop query="loc.QPayHeaders">
				<cfset loc.netpay = 0>
				<cfset loc.lotSub = phLotterySubs>
				<cfif phEmployee NEQ loc.lisaPR>
					<!--- Staff payroll entry --->
					<cfset loc.tran = {}>
					<cfset loc.tran.trnRef = "#NumberFormat(empID,'000')#-#LSDateFormat(phDate,'yymmdd')#">
					<cfset loc.tran.trnDate = LSDateFormat(phDate,'yyyy-mm-dd')>
					<cfset loc.tran.trnDesc = "PR #empFirstName# #empLastName#">
					<cfset loc.tran.trnLedger = 'nom'>
					<cfset loc.tran.trnAccountID = 3>
					<cfset loc.tran.trnMethod = phMethod>
					<cfset loc.tran.trnType = 'nom'>
					<cfset loc.tran.trnAlloc = 1>
					<cfset loc.tran.phID = phID>
					<cfset loc.tran.nomItems = []>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.netPayAccount, status = '', value = phNP})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 2182, status = '', value = phPAYE})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 2172, status = '', value = phNI})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 3282, status = '', value = phMemberContribution})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 3272, status = '', value = phEmployerContribution})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 2102, status = '', value = -(phPAYE + phNI) })>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 2332, status = '', value = -(phMemberContribution + phEmployerContribution) })>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.staffWages, status = '', value = -(phNP) })>
					<cfset loc.tran.test = CheckTran(args,loc.tran)>
					<cfset loc.tran.trnID = loc.tran.test.trnID>
					<cfset ArrayAppend(loc.result.trans,loc.tran)>
					<cfif phMethod eq 'cash'>
						<cfset loc.tran = {}>
						<cfset loc.tran.trnRef = "PAY #NumberFormat(empID,'000')#-#LSDateFormat(phDate,'yymmdd')#">
						<cfset loc.tran.trnDate = LSDateFormat(DateAdd("d",5,phDate),'yyyy-mm-dd')>
						<cfset loc.tran.trnDesc = "CASH Payment #empFirstName# #empLastName#">
						<cfset loc.tran.trnLedger = 'nom'>
						<cfset loc.tran.trnAccountID = 3>
						<cfset loc.tran.trnMethod = phMethod>
						<cfset loc.tran.trnType = 'nom'>
						<cfset loc.tran.trnAlloc = 1>
						<cfset loc.tran.phID = phID>
						<cfset loc.tran.nomItems = []>
						<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.staffWages, status = '', value = phNP - loc.lotSub})>
						<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.cashAccount, status = '', value = -phNP})>
						<cfset loc.tran.test = CheckTran(args,loc.tran)>
						<cfset loc.tran.trnID = loc.tran.test.trnID>
						<cfset ArrayAppend(loc.result.trans,loc.tran)>
					</cfif>
				<cfelse>
					<!--- Lisa payroll entry --->
					<cfset loc.tran = {}>
					<cfset loc.tran.trnRef = "#NumberFormat(empID,'000')#-#LSDateFormat(phDate,'yymmdd')#">
					<cfset loc.tran.trnDate = LSDateFormat(phDate,'yyyy-mm-dd')>
					<cfset loc.tran.trnDesc = "LK #empFirstName# #empLastName#">
					<cfset loc.tran.trnLedger = 'nom'>
					<cfset loc.tran.trnAccountID = 3>
					<cfset loc.tran.trnMethod = phMethod>
					<cfset loc.tran.trnType = 'nom'>
					<cfset loc.tran.trnAlloc = 1>
					<cfset loc.tran.phID = phID>
					<cfset loc.tran.nomItems = []>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.lisaPartner, status = '', value = phNP})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.lisaDrawings, status = '', value = -phNP})>
					<cfset loc.tran.test = CheckTran(args,loc.tran)>
					<cfset loc.tran.trnID = loc.tran.test.trnID>
					<cfset ArrayAppend(loc.result.trans,loc.tran)>
					<cfif phMethod eq 'cash'>
						<cfset loc.tran = {}>
						<cfset loc.tran.trnRef = "PAY #NumberFormat(empID,'000')#-#LSDateFormat(phDate,'yymmdd')#">
						<cfset loc.tran.trnDate = LSDateFormat(DateAdd("d",5,phDate),'yyyy-mm-dd')>
						<cfset loc.tran.trnDesc = "CASH Payment #empFirstName# #empLastName#">
						<cfset loc.tran.trnLedger = 'nom'>
						<cfset loc.tran.trnAccountID = 3>
						<cfset loc.tran.trnMethod = phMethod>
						<cfset loc.tran.trnType = 'nom'>
						<cfset loc.tran.trnAlloc = 1>
						<cfset loc.tran.phID = phID>
						<cfset loc.tran.nomItems = []>
						<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.lisaDrawings, status = '', value = phNP})>
						<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.cashAccount, status = '', value = -phNP})>
						<cfset loc.tran.test = CheckTran(args,loc.tran)>
						<cfset loc.tran.trnID = loc.tran.test.trnID>
						<cfset ArrayAppend(loc.result.trans,loc.tran)>
					</cfif>
				</cfif>
				<cfif phLotterySubs neq 0>	<!--- lottery played --->
					<cfset loc.tran = {}>
					<cfset loc.tran.trnRef = "LOT #NumberFormat(empID,'000')#-#LSDateFormat(phDate,'yymmdd')#">
					<cfset loc.tran.trnDate = LSDateFormat(phDate,'yyyy-mm-dd')>
					<cfset loc.tran.trnDesc = "Lottery Sub #empFirstName# #empLastName#">
					<cfset loc.tran.trnLedger = 'nom'>
					<cfset loc.tran.trnAccountID = 3>
					<cfset loc.tran.trnMethod = phMethod>
					<cfset loc.tran.trnType = 'nom'>
					<cfset loc.tran.trnAlloc = 1>
					<cfset loc.tran.phID = phID>
					<cfset loc.tran.nomItems = []>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.staffWages, status = '', value = loc.lotSub})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.lotteryAccount, status = '', value = -loc.lotSub})>
					<cfset loc.tran.test = CheckTran(args,loc.tran)>
					<cfset loc.tran.trnID = loc.tran.test.trnID>
					<cfset ArrayAppend(loc.result.trans,loc.tran)>
					
					<cfset loc.tran = {}>
					<cfset loc.tran.trnRef = "LOTPAY #NumberFormat(empID,'000')#-#LSDateFormat(phDate,'yymmdd')#">
					<cfset loc.tran.trnDate = LSDateFormat(phDate,'yyyy-mm-dd')>
					<cfset loc.tran.trnDesc = "Lottery Payment #empFirstName# #empLastName#">
					<cfset loc.tran.trnLedger = 'nom'>
					<cfset loc.tran.trnAccountID = 3>
					<cfset loc.tran.trnMethod = phMethod>
					<cfset loc.tran.trnType = 'nom'>
					<cfset loc.tran.trnAlloc = 1>
					<cfset loc.tran.phID = phID>
					<cfset loc.tran.nomItems = []>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.lotteryAccount, status = '', value = loc.lotSub})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.cashAccount, status = '', value = -loc.lotSub})>
					<cfset loc.tran.test = CheckTran(args,loc.tran)>
					<cfset loc.tran.trnID = loc.tran.test.trnID>
					<cfset ArrayAppend(loc.result.trans,loc.tran)>
				</cfif>
			</cfloop>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="ImportPayrollDataOld" access="public" returntype="struct">	<!--- Import data from Payroll to accounts system 27/02/2025 --->
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.trans = []>
		<cfset loc.result.paytrans = []>
		<cfset loc.result.lotTrans = []>
		<cfset loc.result.lisaTrans = []>
		<cfset loc.cashAccount = 181>
		<cfset loc.netPayAccount = 1881>
		<cfset loc.staffWages = 3082>
		<cfset loc.lotteryAccount = 1422>
		<cfset loc.lisaPR = 82>
		<cfset loc.lisaDrawings = 2262>
		<cfset loc.lisaPartner = 3322>
		
		<cftry>
			<cfquery name="loc.QNomTitles" datasource="#args.database#">
				SELECT nomID, nomTitle
				FROM tblNominal
				WHERE nomID IN(#loc.cashAccount#, #loc.netPayAccount#, #loc.staffWages#, 1422, 2102, 2182, 2172, 3272, 3282, 2332, 3302, 2262)
			</cfquery>
			<cfset loc.result.nomTitles = {}>
			<cfloop query="loc.QNomTitles">
				<cfset StructInsert(loc.result.nomTitles, nomID ,nomTitle)>
			</cfloop>
			<cfquery name="loc.QPayHeaders" datasource="#args.database#">
				SELECT tblpayheader.*, empID,empFirstName,empLastName
				FROM tblpayheader 
				INNER JOIN tblEmployee ON empID = phEmployee
				WHERE phDate BETWEEN '#args.form.srchDateFrom#'
								AND  '#args.form.srchDateTo#'
			</cfquery>
			<cfloop query="loc.QPayHeaders">
				<cfif phEmployee NEQ loc.lisaPR>
					<cfset loc.netpay = 0>
					<cfset loc.lotSub = phLotterySubs>
					<cfset loc.tran = {}>
					<cfset loc.paytran = {}>
					<cfset loc.tran.trnRef = "#NumberFormat(empID,'000')#-#LSDateFormat(phDate,'yymmdd')#">
					<cfset loc.tran.trnDate = LSDateFormat(phDate,'yyyy-mm-dd')>
					<cfset loc.tran.trnPayDate = LSDateFormat(DateAdd("d",5,phDate),'yyyy-mm-dd')>
					<cfset loc.tran.trnDesc = "PR #empFirstName# #empLastName#">
					<cfset loc.tran.trnLedger = 'nom'>
					<cfset loc.tran.trnAccountID = 3>
					<cfset loc.tran.trnMethod = phMethod>
					<cfset loc.tran.trnType = 'nom'>
					<cfset loc.tran.trnAlloc = 1>
					<cfset loc.tran.phID = phID>
					<cfset loc.tran.nomItems = []>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.netPayAccount, status = '', value = phNP})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 2182, status = '', value = phPAYE})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 2172, status = '', value = phNI})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 3282, status = '', value = phMemberContribution})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 3272, status = '', value = phEmployerContribution})>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 2102, status = '', value = -(phPAYE + phNI) })>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = 2332, status = '', value = -(phMemberContribution + phEmployerContribution) })>
					<cfset ArrayAppend(loc.tran.nomItems, {"nomID" = loc.staffWages, status = '', value = -(phNP) })>	<!--- + phLotterySubs--->
					<!--- Payroll transaction --->
					<cfquery name="loc.QTranExists" datasource="#args.database#">
						SELECT trnID
						FROM tblTrans
						WHERE trnRef = '#loc.tran.trnRef#'
						AND trnDate = '#loc.tran.trnDate#'
						AND trnAccountID = #loc.tran.trnAccountID#
					</cfquery>
					<cfif loc.QTranExists.recordcount is 0>
						<cfset loc.tran.trnID = 0>
					<cfelse>
						<cfset loc.tran.trnID = loc.QTranExists.trnID>
					</cfif>
					<cfif args.importdata>
						<cfif loc.tran.trnID is 0>
							<cfquery name="loc.QInsertTran" datasource="#args.database#" result="loc.QInsertTranResult">
								INSERT INTO tblTrans
									(trnRef,trnDate,trnDesc,trnLedger,trnAccountID,trnType,trnAlloc)
								VALUES
									('#loc.tran.trnRef#','#loc.tran.trnDate#','#loc.tran.trnDesc#','#loc.tran.trnLedger#',
										#loc.tran.trnAccountID#,'#loc.tran.trnType#',#loc.tran.trnAlloc#)
							</cfquery>
							<cfset loc.tran.trnID = loc.QInsertTranResult.generatedkey>
							<cfset loc.tran.msg = "tran added #loc.tran.trnID#">
						<cfelse>
							<cfquery name="loc.QUpdateTran" datasource="#args.database#">
								UPDATE tblTrans
								SET
									trnRef = '#loc.tran.trnRef#',
									trnDate = '#loc.tran.trnDate#',
									trnDesc = '#loc.tran.trnDesc#',
									trnLedger = '#loc.tran.trnLedger#',
									trnAccountID = #loc.tran.trnAccountID#,
									trnType = '#loc.tran.trnType#',
									trnAlloc = #loc.tran.trnAlloc#
								WHERE trnID = #loc.tran.trnID#
							</cfquery>
							<cfset loc.tran.msg = "tran updated #loc.tran.trnID#">
						</cfif>
						<cfset loc.tran.checkSum = 0>
						<cfloop array="#loc.tran.nomItems#" index="loc.item">
							<cfset loc.tran.checkSum += loc.item.value>
							<cfif loc.item.nomID eq loc.netPayAccount><cfset loc.paytran.netpay = loc.item.value></cfif>		<!--- save net pay for later --->
							<!---<cfif loc.item.nomID eq loc.lotteryAccount><cfset loc.lotSub = loc.item.value></cfif>--->
							<cfquery name="loc.QItemExists" datasource="#args.database#">
								SELECT niID 
								FROM tblNomItems 
								WHERE niTranID = #loc.tran.trnID#
								AND niNomID = #loc.item.nomID#
							</cfquery>
							<cfif loc.QItemExists.recordcount is 0>
								<cfif loc.item.value neq 0>
									<cfquery name="loc.QInsertItem" datasource="#args.database#" result="loc.QInsertItemResult">
										INSERT INTO tblNomItems
											(niTranID,niNomID,niAmount)
										VALUES
											(#loc.tran.trnID#,#loc.item.nomID#,#loc.item.value#)
									</cfquery>
									<cfset loc.item.status = 'tran item added #loc.QInsertItemResult.generatedkey#'>
								<cfelse>
									<cfset loc.item.status = 'item ignored'>
								</cfif>
							<cfelse>
								<cfquery name="loc.QUpdateItem" datasource="#args.database#">
									UPDATE tblNomItems
									SET niAmount = #loc.item.value#
									WHERE niTranID = #loc.tran.trnID#
									AND niNomID = #loc.item.nomID#
								</cfquery>
								<cfset loc.item.status = 'tran item updated #loc.tran.trnID#'>
							</cfif>
						</cfloop>
						<!--- Cash Payment transaction --->
						<cfif loc.tran.trnMethod eq 'cash'>
							<cfset loc.tran.test = CheckTran(args,loc.tran)>
							<cfquery name="loc.QPayTranExists" datasource="#args.database#">
								SELECT trnID
								FROM tblTrans
								WHERE trnRef = 'PAY #loc.tran.trnRef#'
								AND trnDate = '#loc.tran.trnPayDate#'
								AND trnAccountID = #loc.tran.trnAccountID#
							</cfquery>
							<cfif loc.QPayTranExists.recordcount is 0>
								<cfset loc.paytran.trnID = 0>
							<cfelse>
								<cfset loc.paytran.trnID = loc.QPayTranExists.trnID>
							</cfif>
							<cfif loc.paytran.trnID is 0>
								<cfquery name="loc.QInsertPayTran" datasource="#args.database#" result="loc.QInsertPayTranResult">
									INSERT INTO tblTrans
										(trnRef,trnDate,trnDesc,trnLedger,trnAccountID,trnType,trnAlloc,trnMethod)
									VALUES
										('PAY #loc.tran.trnRef#','#loc.tran.trnPayDate#','cash payment','#loc.tran.trnLedger#',
											#loc.tran.trnAccountID#,'#loc.tran.trnType#',#loc.tran.trnAlloc#,'#loc.tran.trnMethod#')
								</cfquery>
								<cfset loc.paytran.trnID = loc.QInsertPayTranResult.generatedkey>
								<cfset loc.paytran.msg = "paytran added #loc.paytran.trnID#">
							<cfelse>
								<cfquery name="loc.QUpdatePayTran" datasource="#args.database#">
									UPDATE tblTrans
									SET
										trnRef = 'PAY #loc.tran.trnRef#',
										trnDate = '#loc.tran.trnPayDate#',
										trnDesc = 'cash payment',
										trnLedger = '#loc.tran.trnLedger#',
										trnAccountID = #loc.tran.trnAccountID#,
										trnType = '#loc.tran.trnType#',
										trnAlloc = #loc.tran.trnAlloc#
									WHERE trnID = #loc.paytran.trnID#
								</cfquery>
								<cfset loc.paytran.msg = "paytran updated #loc.paytran.trnID#">
							</cfif>
							<cfset loc.paytran.ref = loc.tran.trnRef>
							<cfif phEmployee eq loc.lisaPR>
								<cfset loc.paytran.accDR = loc.lisaDrawings>
							<cfelse>
								<cfset loc.paytran.accDR = loc.staffWages>
							</cfif>
							<cfquery name="loc.QPayItemExists" datasource="#args.database#">	<!--- see if cash payment items exist --->
								SELECT niID 
								FROM tblNomItems 
								WHERE niTranID = #loc.paytran.trnID#
								AND niNomID = #loc.cashAccount#
							</cfquery>
							<cfif loc.QPayItemExists.recordcount is 0>
								<cfquery name="loc.QInsertPayItem" datasource="#args.database#" result="loc.QInsertPayItemResult">
									INSERT INTO tblNomItems
										(niTranID,niNomID,niAmount)
									VALUES
										(#loc.paytran.trnID#,#loc.paytran.accDR#,#loc.paytran.netpay - loc.lotSub#),
										(#loc.paytran.trnID#,#loc.cashAccount#,#-(loc.paytran.netpay - loc.lotSub)#)
								</cfquery>
								<cfset loc.paytran.trnID = loc.QInsertPayItemResult.generatedkey>
							<cfelse>
								<cfquery name="loc.QUpdateItemCR" datasource="#args.database#">
									UPDATE tblNomItems
									SET niAmount = #-(loc.paytran.netpay - loc.lotSub)#
									WHERE niTranID = #loc.paytran.trnID#
									AND niNomID = #loc.cashAccount#
								</cfquery>
								<cfquery name="loc.QUpdateItemDR" datasource="#args.database#">
									UPDATE tblNomItems
									SET niAmount = #loc.paytran.netpay - loc.lotSub#
									WHERE niTranID = #loc.paytran.trnID#
									AND niNomID = #loc.staffWages#
								</cfquery>
							</cfif>
							<cfset loc.paytran.msg = 'paytran items updated #loc.paytran.trnID#'>
							<cfset ArrayAppend(loc.result.paytrans,loc.paytran)>
						</cfif> <!--- end cash tran --->
						<cfif phLotterySubs neq 0>	<!--- lottery played --->
							<cfquery name="loc.QLotTranExists" datasource="#args.database#">
								SELECT trnID
								FROM tblTrans
								WHERE trnRef = 'LOT #loc.tran.trnRef#'
								AND trnDate = '#loc.tran.trnPayDate#'
								AND trnAccountID = #loc.tran.trnAccountID#
							</cfquery>
							<cfif loc.QLotTranExists.recordcount is 0>
								<cfset loc.lotTran.trnID = 0>
							<cfelse>
								<cfset loc.lotTran.trnID = loc.QLotTranExists.trnID>
							</cfif>
							<cfif loc.lotTran.trnID is 0>
								<cfquery name="loc.QInsertLotTran" datasource="#args.database#" result="loc.QInsertLotTranResult">
									INSERT INTO tblTrans
										(trnRef,trnDate,trnDesc,trnLedger,trnAccountID,trnType,trnAlloc,trnMethod)
									VALUES
										('LOT #loc.tran.trnRef#','#loc.tran.trnPayDate#','Lottery sub','#loc.tran.trnLedger#',
											#loc.tran.trnAccountID#,'#loc.tran.trnType#',#loc.tran.trnAlloc#,'#loc.tran.trnMethod#')
								</cfquery>
								<cfset loc.lotTran.trnID = loc.QInsertLotTranResult.generatedkey>
								<cfset loc.lotTran.msg = "lotTran added #loc.lotTran.trnID#">
							<cfelse>
								<!--- update lottery tran here if ness --->
							</cfif>
							<cfquery name="loc.QLotItemExists" datasource="#args.database#">	<!--- see if lottery subs items exist --->
								SELECT niID 
								FROM tblNomItems 
								WHERE niTranID = #loc.lotTran.trnID#
								AND niNomID = #loc.lotteryAccount#
							</cfquery>
							<cfif loc.QLotItemExists.recordcount is 0>
								<cfquery name="loc.QInsertLotItem" datasource="#args.database#" result="loc.QInsertLotItemResult">
									INSERT INTO tblNomItems
										(niTranID,niNomID,niAmount)
									VALUES
										(#loc.lotTran.trnID#,#loc.lotteryAccount#,-#loc.lotSub#),
										(#loc.lotTran.trnID#,#loc.staffWages#,#loc.lotSub#)
								</cfquery>
								<cfset loc.lotTran.trnID = loc.QInsertLotItemResult.generatedkey>
								<cfset loc.lotTran.msg = "lottery items added #loc.lotTran.trnID#">
							<cfelse>
								<!--- update lottery items --->						
								<cfquery name="loc.QUpdateLotItemCR" datasource="#args.database#">
									UPDATE tblNomItems
									SET niAmount = -#loc.lotSub#
									WHERE niTranID = #loc.lotTran.trnID#
									AND niNomID = #loc.lotteryAccount#
								</cfquery>
								<cfquery name="loc.QUpdateLotItemDR" datasource="#args.database#">
									UPDATE tblNomItems
									SET niAmount = #loc.lotSub#
									WHERE niTranID = #loc.lotTran.trnID#
									AND niNomID = #loc.staffWages#
								</cfquery>
								<cfset loc.lotTran.msg = 'lottery items updated #loc.lotTran.trnID#'>
							</cfif>
							<cfset ArrayAppend(loc.result.lotTrans,loc.lotTran)>
						</cfif> <!--- end lottery subs --->
					</cfif>
					<cfset ArrayAppend(loc.result.trans,loc.tran)>
				<cfelse>
					<!--- Lisa payment --->
					<cfset loc.lisaTran = {}>
					<cfset loc.lisaTran.trnRef = "#NumberFormat(empID,'000')#-#LSDateFormat(phDate,'yymmdd')#">
					<cfset loc.lisaTran.trnDate = LSDateFormat(phDate,'yyyy-mm-dd')>
					<cfset loc.lisaTran.trnPayDate = LSDateFormat(DateAdd("d",5,phDate),'yyyy-mm-dd')>
					<cfset loc.lisaTran.trnDesc = "LK #empFirstName# #empLastName#">
					<cfset loc.lisaTran.trnLedger = 'nom'>
					<cfset loc.lisaTran.trnAccountID = 3>
					<cfset loc.lisaTran.trnMethod = phMethod>
					<cfset loc.lisaTran.trnType = 'nom'>
					<cfset loc.lisaTran.trnAlloc = 1>
					<cfset loc.lisaTran.phID = phID>
					
					<cfset loc.lisaTran.test = CheckTran(args,loc.tran)>
					
					<cfquery name="loc.QLisaTranExists" datasource="#args.database#">
						SELECT trnID
						FROM tblTrans
						WHERE trnRef = 'LK #loc.lisaTran.trnRef#'
						AND trnDate = '#loc.lisaTran.trnDate#'
						AND trnAccountID = #loc.lisaTran.trnAccountID#
					</cfquery>
					<cfif loc.QLisaTranExists.recordcount is 0>
						<cfset loc.lisaTran.trnID = 0>
					<cfelse>
						<cfset loc.lisaTran.trnID = loc.QLisaTranExists.trnID>
					</cfif>
					<cfif loc.lisaTran.trnID is 0>
						<cfquery name="loc.QInsertLisaTran" datasource="#args.database#" result="loc.QInsertLisaTranResult">
							INSERT INTO tblTrans
								(trnRef,trnDate,trnDesc,trnLedger,trnAccountID,trnType,trnAlloc,trnMethod)
							VALUES
								('LK #loc.lisaTran.trnRef#','#loc.lisaTran.trnDate#','Lisa Drawings','#loc.lisaTran.trnLedger#',
									#loc.lisaTran.trnAccountID#,'#loc.lisaTran.trnType#',#loc.lisaTran.trnAlloc#,'#loc.lisaTran.trnMethod#')
						</cfquery>
						<cfset loc.lisaTran.trnID = loc.QInsertLisaTranResult.generatedkey>
						<cfset loc.lisaTran.msg = "lisaTran added #loc.lisaTran.trnID#">
					<cfelse>
						<!--- update Lisa tran here if ness --->
					</cfif>
					<cfquery name="loc.QLisaItemExists" datasource="#args.database#">	<!--- see if Lisa items exist --->
						SELECT niID 
						FROM tblNomItems 
						WHERE niTranID = #loc.lisaTran.trnID#
						<!---AND niNomID = #loc.lisaDrawings#--->
					</cfquery>
					<cfif loc.QLisaItemExists.recordcount is 0>
						<cfquery name="loc.QInsertLisaItem" datasource="#args.database#" result="loc.QInsertLisaItemResult">
							INSERT INTO tblNomItems
								(niTranID,niNomID,niAmount)
							VALUES
								(#loc.lisaTran.trnID#,#loc.lisaDrawings#,-#phNP#),
								(#loc.lisaTran.trnID#,#loc.lisaPartner#,#phNP#)
						</cfquery>
						<cfset loc.lisaTran.trnID = loc.QInsertLisaItemResult.generatedkey>
						<cfset loc.lisaTran.msg = "Lisa items added #loc.lisaTran.trnID#">
					<cfelse>
						<!--- update Lisa items here --->
						<cfquery name="loc.QUpdateLisaItemCR" datasource="#args.database#">
							UPDATE tblNomItems
							SET niAmount = -#phNP#
							WHERE niTranID = #loc.lisaTran.trnID#
							AND niNomID = #loc.lisaDrawings#
						</cfquery>
						<cfquery name="loc.QUpdateLisaItemDR" datasource="#args.database#">
							UPDATE tblNomItems
							SET niAmount = #phNP#
							WHERE niTranID = #loc.lisaTran.trnID#
							AND niNomID = #loc.lisaPartner#
						</cfquery>
						<cfset loc.lisaTran.msg = 'Lisa items updated #loc.lisaTran.trnID#'>
					</cfif>
					<cfif loc.lisaTran.trnMethod eq 'cash'>
						<cfquery name="loc.QLisaCashPayTranExists" datasource="#args.database#">
							SELECT trnID
							FROM tblTrans
							WHERE trnRef = 'PAY #loc.lisaTran.trnRef#'
							AND trnDate = '#loc.lisaTran.trnDate#'
							AND trnAccountID = #loc.lisaTran.trnAccountID#
						</cfquery>
						<cfif loc.QLisaCashPayTranExists.recordcount is 0>
							<cfset loc.lisaTran.trnID = 0>
						<cfelse>
							<cfset loc.lisaTran.trnID = loc.QLisaCashPayTranExists.trnID>
						</cfif>
						<cfif loc.lisaTran.trnID is 0>
							<cfquery name="loc.QInsertLisaPayTran" datasource="#args.database#" result="loc.QInsertLisaPayTranResult">
								INSERT INTO tblTrans
									(trnRef,trnDate,trnDesc,trnLedger,trnAccountID,trnType,trnAlloc,trnMethod)
								VALUES
									('PAY #loc.lisaTran.trnRef#','#loc.lisaTran.trnPayDate#','cash payment','#loc.lisaTran.trnLedger#',
										#loc.lisaTran.trnAccountID#,'#loc.lisaTran.trnType#',#loc.lisaTran.trnAlloc#,'#loc.lisaTran.trnMethod#')
							</cfquery>
							<cfset loc.lisaPayTran.trnID = loc.QInsertLisaPayTranResult.generatedkey>
							<cfset loc.lisaPayTran.msg = "lisaPayTran added #loc.lisaPayTran.trnID#">
						<cfelse>
							<!--- edit lisa cash pay tran --->
						</cfif>
						<cfquery name="loc.QLisaPayItemExists" datasource="#args.database#">	<!--- see if cash payment items exist --->
							SELECT niID 
							FROM tblNomItems 
							WHERE niTranID = #loc.lisaPayTran.trnID#
							AND niNomID = #loc.cashAccount#
						</cfquery>
						<cfif loc.QLisaPayItemExists.recordcount is 0>
							<cfquery name="loc.QInsertLisaPayItem" datasource="#args.database#" result="loc.QInsertLisaPayItemResult">
								INSERT INTO tblNomItems
									(niTranID,niNomID,niAmount)
								VALUES
									(#loc.lisaPayTran.trnID#,#loc.cashAccount#,-#phNP#),
									(#loc.lisaPayTran.trnID#,#loc.lisaDrawings#,#phNP#)
							</cfquery>
							<cfset loc.lisaPayTran.trnID = loc.QInsertLisaPayItemResult.generatedkey>
							<cfset loc.lisaPayTran.msg = "Lisa pay items added #loc.lisaPayTran.trnID#">
						<cfelse>
							<!--- update Lisa pay items here --->
							<cfquery name="loc.QUpdateLisaPayItemCR" datasource="#args.database#">
								UPDATE tblNomItems
								SET niAmount = -#phNP#
								WHERE niTranID = #loc.lisaPayTran.trnID#
								AND niNomID = #loc.cashAccount#
							</cfquery>
							<cfquery name="loc.QUpdateLisaPayItemDR" datasource="#args.database#">
								UPDATE tblNomItems
								SET niAmount = #phNP#
								WHERE niTranID = #loc.lisaPayTran.trnID#
								AND niNomID = #loc.lisaDrawings#
							</cfquery>
							<cfset loc.lisaPayTran.msg = 'Lisa pay items updated #loc.lisaPayTran.trnID#'>
						</cfif>
					</cfif>
					<cfset ArrayAppend(loc.result.lisaTrans,loc.lisaTran)>
				</cfif>
			</cfloop>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>
