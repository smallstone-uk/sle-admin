<cfcomponent displayname="payroll2" extends="core">
	<cffunction name="LoadEmployeeDepartments" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>

		<cfquery name="loc.deps" datasource="#args.datasource#">
			SELECT *
			FROM tblPayDepartment, tblPayRates
			WHERE rtEmployee = #val(args.form.employee)#
			AND rtDepartment = depID
		</cfquery>

		<cfreturn QueryToArrayOfStruct(loc.deps)>
	</cffunction>
	<cffunction name="SwitchDept" access="public" returntype="numeric">
		<cfargument name="args" type="string" required="yes">
		<cfswitch expression="#args#">
			<cfcase value="shop"><cfreturn 2></cfcase>
			<cfcase value="po"><cfreturn 12></cfcase>
			<cfcase value="admin"><cfreturn 22></cfcase>
			<cfcase value="web"><cfreturn 32></cfcase>
			<cfcase value="delivery"><cfreturn 42></cfcase>
			<cfdefaultcase><cfreturn 2></cfdefaultcase>
		</cfswitch>
	</cffunction>
	<cffunction name="ImportPayroll" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>

		<cfquery name="loc.wipe" datasource="#args.datasource#">
			DELETE FROM tblPayHeader
		</cfquery>

		<cfquery name="loc.header" datasource="#args.datasource#">
			SELECT *
			FROM tblEmpWorkHeader
		</cfquery>

		<cfset loc.headers = QueryToArrayOfStruct(loc.header)>

		<cfloop array="#loc.headers#" index="loc.i">
			<cfquery name="loc.addHeader" datasource="#args.datasource#" result="loc.addHeader_result">
				INSERT INTO tblPayHeader (
					phDate,
					phEmployee,
					phWeekNo,
					phGross,
					phPAYE,
					phNI,
					phNP,
					phTotalHours,
					phWorkHours,
					phHolHours
				) VALUES (
					#loc.i.whWeekEnding#,
					#val(loc.i.whEmpID)#,
					#val(loc.i.whWeekNo)#,
					#val(loc.i.whGross)#,
					#val(loc.i.whPAYE)#,
					#val(loc.i.whNI)#,
					#val(loc.i.whNP)#,
					#val(loc.i.whHours)#,
					#val(loc.i.whHours)#,
					0
				)
			</cfquery>

			<cfquery name="loc.items" datasource="#args.datasource#" result="loc.items_result">
				SELECT *
				FROM tblEmpWorkItem
				WHERE etWHeadID = #val(loc.i.whID)#
			</cfquery>

			<cfloop query="loc.items">
				<cfset loc.prep = []>

				<cfset ArrayAppend(loc.prep, {
					parent = val(loc.addHeader_result.generatedKey),
					dept = val(SwitchDept(etType)),
					rate = val(etRate),
					daystr = "Monday",
					gross = val(etMon) * val(etRate),
					hours = val(etMon),
					holiday = "No"
				})>

				<cfset ArrayAppend(loc.prep, {
					parent = val(loc.addHeader_result.generatedKey),
					dept = val(SwitchDept(etType)),
					rate = val(etRate),
					daystr = "Tuesday",
					gross = val(etTue) * val(etRate),
					hours = val(etTue),
					holiday = "No"
				})>

				<cfset ArrayAppend(loc.prep, {
					parent = val(loc.addHeader_result.generatedKey),
					dept = val(SwitchDept(etType)),
					rate = val(etRate),
					daystr = "Wednesday",
					gross = val(etWed) * val(etRate),
					hours = val(etWed),
					holiday = "No"
				})>

				<cfset ArrayAppend(loc.prep, {
					parent = val(loc.addHeader_result.generatedKey),
					dept = val(SwitchDept(etType)),
					rate = val(etRate),
					daystr = "Thursday",
					gross = val(etThu) * val(etRate),
					hours = val(etThu),
					holiday = "No"
				})>

				<cfset ArrayAppend(loc.prep, {
					parent = val(loc.addHeader_result.generatedKey),
					dept = val(SwitchDept(etType)),
					rate = val(etRate),
					daystr = "Friday",
					gross = val(etFri) * val(etRate),
					hours = val(etFri),
					holiday = "No"
				})>

				<cfset ArrayAppend(loc.prep, {
					parent = val(loc.addHeader_result.generatedKey),
					dept = val(SwitchDept(etType)),
					rate = val(etRate),
					daystr = "Saturday",
					gross = val(etSat) * val(etRate),
					hours = val(etSat),
					holiday = "No"
				})>

				<cfset ArrayAppend(loc.prep, {
					parent = val(loc.addHeader_result.generatedKey),
					dept = val(SwitchDept(etType)),
					rate = val(etRate),
					daystr = "Sunday",
					gross = val(etSun) * val(etRate),
					hours = val(etSun),
					holiday = "No"
				})>

				<cfquery name="loc.addItem" datasource="#args.datasource#">
					INSERT INTO tblPayItems (
						piParent,
						piDept,
						piRate,
						piDay,
						piGross,
						piHours,
						piHoliday
					) VALUES
						<cfset loc.itemCounter = 0>
						<cfloop array="#loc.prep#" index="loc.prepItem">
							<cfset loc.itemCounter++>
							(
								#loc.prepItem.parent#,
								#loc.prepItem.dept#,
								#loc.prepItem.rate#,
								'#loc.prepItem.daystr#',
								#loc.prepItem.gross#,
								#loc.prepItem.hours#,
								'#loc.prepItem.holiday#'
							)<cfif loc.itemCounter neq ArrayLen(loc.prep)>,</cfif>
						</cfloop>
				</cfquery>

				<!---<cfloop list="etMon,etTue,etWed,etThu,etFri,etSat,etSun" delimiters="," index="loc.daystr">
					<cfset loc.findDayInItem = {}>
					<cfif StructKeyExists(loc.item, "#loc.daystr#")>
						<cfset loc.findDayInItem = StructFind(loc.item, "#loc.daystr#")>
						<cfif val(loc.findDayInItem) gt 0>
							<cfquery name="loc.addItem" datasource="#args.datasource#">
								INSERT INTO tblPayItems (
									piParent,
									piDept,
									piRate,
									piDay,
									piGross,
									piHours,
									piHoliday
								) VALUES (
									#val(loc.addHeader_result.generatedKey)#,
									#val(SwitchDept(loc.item.etType))#,
									#val(loc.item.etRate)#,
									<cfswitch expression="#loc.daystr#">
										<cfcase value="etMon">'Monday'</cfcase>
										<cfcase value="etTue">'Tuesday'</cfcase>
										<cfcase value="etWed">'Wednesday'</cfcase>
										<cfcase value="etThu">'Thursday'</cfcase>
										<cfcase value="etFri">'Friday'</cfcase>
										<cfcase value="etSat">'Saturday'</cfcase>
										<cfcase value="etSun">'Sunday'</cfcase>
									</cfswitch>,
									#val(loc.findDayInItem) * val(loc.item.etRate)#,
									#val(loc.findDayInItem)#,
									'No'
								)
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>--->
			</cfloop>
		</cfloop>

		<cfquery name="loc.delEmpty" datasource="#args.datasource#">
			DELETE FROM tblPayItems
			WHERE piHours <= 0
		</cfquery>

	</cffunction>
	<cffunction name="SavePayrollRecord" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>

		<cfset loc.headerID = 0>

		<cfquery name="loc.checkHeader" datasource="#args.datasource#">
			SELECT phID
			FROM tblPayHeader
			WHERE phEmployee = #val(args.form.header.employee)#
			AND phDate = '#args.form.header.weekending#'
		</cfquery>

		<cfif loc.checkHeader.recordcount is 0>
			<cfquery name="loc.newHeader" datasource="#args.datasource#" result="loc.newHeader_result">
				INSERT INTO tblPayHeader (
					phDate,
					phEmployee,
					phWeekNo,
					phMethod,
					phGross,
					phPAYE,
					phNI,
					phNP,
					phTotalHours,
					phWorkHours,
					phHolHours,
					phEmployerContribution,
					phMemberContribution,
					phLotterySubs,
					phAdjustment
				) VALUES (
					'#args.form.header.weekending#',
					#val(args.form.header.employee)#,
					#val(args.form.header.weekno)#,
					'#args.form.header.method#',
					#val(args.form.header.gross)#,
					#val(args.form.header.paye)#,
					#val(args.form.header.ni)#,
					#val(args.form.header.np)#,
					#val(args.form.header.total_hours)#,
					#val(args.form.header.work_hours)#,
					#val(args.form.header.hol_hours)#,
					#val(args.form.header.pension_employer)#,
					#val(args.form.header.pension_member)#,
					#val(args.form.header.lottery_subs)#,
					#val(args.form.header.adjustment)#
				)
			</cfquery>

			<cfset loc.headerID = val(loc.newHeader_result.generatedKey)>
		<cfelse>
			<cfquery name="loc.updateHeader" datasource="#args.datasource#">
				UPDATE tblPayHeader
				SET phDate = '#args.form.header.weekending#',
					phEmployee = #val(args.form.header.employee)#,
					phWeekNo = #val(args.form.header.weekno)#,
					phMethod = '#args.form.header.method#',
					phGross = #val(args.form.header.gross)#,
					phPAYE = #val(args.form.header.paye)#,
					phNI = #val(args.form.header.ni)#,
					phNP = #val(args.form.header.np)#,
					phTotalHours = #val(args.form.header.total_hours)#,
					phWorkHours = #val(args.form.header.work_hours)#,
					phHolHours = #val(args.form.header.hol_hours)#,
					phEmployerContribution = #val(args.form.header.pension_employer)#,
					phMemberContribution = #val(args.form.header.pension_member)#,
					phLotterySubs = #val(args.form.header.lottery_subs)#,
					phAdjustment = #val(args.form.header.adjustment)#
				WHERE phID = #val(loc.checkHeader.phID)#
			</cfquery>

			<cfset loc.headerID = val(loc.checkHeader.phID)>
		</cfif>

		<cfquery name="loc.clearItems" datasource="#args.datasource#">
			DELETE FROM tblPayItems
			WHERE piParent = #val(loc.headerID)#
		</cfquery>

		<cfif !ArrayIsEmpty(args.form.items)>
			<cfquery name="loc.newItem" datasource="#args.datasource#">
				INSERT INTO tblPayItems (
					piParent,
					piDept,
					piRate,
					piDay,
					piGross,
					piHours,
					piHolHours,
					piHoliday
				) VALUES
				<cfset loc.counter = 0>
				<cfloop array="#args.form.items#" index="loc.item">
					<cfset loc.counter++>
					(
						#val(loc.headerID)#,
						#val(loc.item.dept)#,
						#val(loc.item.rate)#,
						'#loc.item.weekday#',
						#val(loc.item.gross)#,
						<cfif !loc.item.holiday>#val(loc.item.hours)#<cfelse>0</cfif>,
						<cfif loc.item.holiday>#val(loc.item.hours)#<cfelse>0</cfif>,
						'#loc.item.holiday#'
					)<cfif loc.counter neq ArrayLen(args.form.items)>,</cfif>
				</cfloop>
			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="GetPayrollWeekNumber" access="public" returntype="numeric">
		<cfargument name="dateStr" type="string" required="yes">
		<cfset var loc = {}>
		<cfif len(dateStr)>
			<cfset loc.passedDate = LSParseDateTime(dateStr)>
			<cfset loc.controlMonth = DateFormat(application.controls.weekNoStartDate, 'mm')>
			<cfset loc.controlDay = DateFormat(application.controls.weekNoStartDate, 'dd')>
			<cfset loc.newDate = CreateDate(Year(Now()), loc.controlMonth, loc.controlDay)>
			<cfset loc.comparison = DateCompare(loc.newDate, loc.passedDate, "d")>
			<cfif loc.comparison is 1><cfset loc.newDate = CreateDate( ( Year(Now()) - 1 ), loc.controlMonth, loc.controlDay )></cfif>
			<cfset loc.weekNo = val(DateDiff("ww", loc.newDate, loc.passedDate))>
			<cfset loc.weekNo = (loc.weekNo IS 0) ? 1 : loc.weekNo>
			<cfreturn loc.weekNo>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>

	<cffunction name="LoadEmployeeDetails" access="public" returntype="struct">
		<cfargument name="empID" type="numeric" required="yes">
		<cfset var loc = {}>

		<cfquery name="loc.employee" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEmployee
			WHERE empID = #val(empID)#
		</cfquery>

		<cfreturn QueryToStruct(loc.employee)>
	</cffunction>

	<cffunction name="LoadWeeklyPayrollRecords" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>

		<cfquery name="loc.control" datasource="#args.datasource#">
			SELECT *
			FROM tblControl
			WHERE ctlID = 1
		</cfquery>

		<cfquery name="loc.employee" datasource="#args.datasource#">
			SELECT *
			FROM tblEmployee
			WHERE empStatus='active'
		</cfquery>

		<cfloop query="loc.employee">
			<cfset loc.item = {}>
			<cfset loc.item.employee = LoadEmployee({"employee"=val(empID),"database"=args.datasource})>
			<cfset loc.item.items = {}>

			<cfquery name="loc.depts" datasource="#args.datasource#">
				SELECT *
				FROM tblPayDepartment, tblPayRates
				WHERE rtDepartment = depID
				AND rtEmployee = #val(loc.item.employee.ID)#
			</cfquery>

			<cfset loc.item.employee.depts = QueryToArrayOfStruct(loc.depts)>

			<cfquery name="loc.header" datasource="#args.datasource#">
				SELECT *
				FROM tblPayHeader
				WHERE phDate = '#args.weekending#'
				AND phEmployee = #val(loc.item.employee.ID)#
			</cfquery>

			<cfset loc.item.header = (loc.header.recordcount is 0) ? {} : QueryToStruct(loc.header)>

			<cfif NOT StructIsEmpty(loc.item.header)>
				<cfloop query="loc.depts">
					<cfset StructInsert(loc.item.items, "#depName#", {})>
					<cfset depStruct = StructFind(loc.item.items, "#depName#")>

					<cfset loc.WeekStartDate = LSDateFormat(loc.control.ctlWeekNoStartDate,"yyyy-mm-dd")>
					<cfset loc.HolStartDate = LSDateFormat(loc.control.ctlHolidayStart,"yyyy-mm-dd")>
					<cfquery name="loc.ytd" datasource="#args.datasource#">
						SELECT Count(phID) as recs,
							(SELECT SUM(phGross) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.WeekStartDate#' AND '#args.weekending#') AS GrossSum,
							(SELECT SUM(phPAYE) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.WeekStartDate#' AND '#args.weekending#') AS PAYESum,
							(SELECT SUM(phNI) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.WeekStartDate#' AND '#args.weekending#') AS NISum,
							(SELECT SUM(phNP) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.WeekStartDate#' AND '#args.weekending#') AS NPSum,
							(SELECT SUM(phTotalHours) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.weekending#') AS HoursSum,
							(SELECT SUM(phWorkHours) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.weekending#') AS WorkSum,
							(SELECT AVG(phWorkHours) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.weekending#') AS WorkAvg,
							(SELECT SUM(phHolHours) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.weekending#') AS HolSum,
							(SELECT SUM(phMemberContribution) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.weekending#') AS PensionSum,
							(SELECT SUM(phLotterySubs) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.weekending#') AS LotterySum,
							(SELECT SUM(phAdjustment) FROM tblPayHeader
								WHERE phEmployee = #val(loc.item.employee.ID)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.weekending#') AS AdjustmentSum
						FROM tblPayHeader
						WHERE phEmployee = #val(loc.item.employee.ID)#
						AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.weekending#'
						ORDER BY phDate
					</cfquery>
					<cfset loc.item.totals = QueryToStruct(loc.ytd)>

					<cfif loc.item.employee.ServicePrd GT 11>
						<cfset loc.item.totals.annual = val(loc.item.totals.WorkAvg) * 52 * 0.1207>
						<cfset loc.item.totals.accrued = 0>
						<cfset loc.item.totals.remain = val(loc.item.totals.annual) - val(loc.item.totals.HolSum)>
					<cfelse>
						<cfset loc.item.totals.annual = 0>
						<cfset loc.item.totals.accrued = val(loc.item.totals.WorkSum) * 0.1207>
						<cfset loc.item.totals.remain = val(loc.item.totals.accrued) - val(loc.item.totals.HolSum)>
					</cfif>

					<cfquery name="loc.items" datasource="#args.datasource#">
						SELECT *
						FROM tblPayItems
						WHERE piParent = #val(loc.item.header.phID)#
						AND piDept = #val(depID)#
					</cfquery>
					<cfset loc.itemArr = QueryToArrayOfStruct(loc.items)>

					<cfloop array="#loc.itemArr#" index="loc.itemArrItem">
						<cfset StructInsert(depStruct, "#loc.itemArrItem.piDay#", loc.itemArrItem)>
					</cfloop>
				</cfloop>
			<cfelse>
				<cfset loc.item.items = {}>
			</cfif>
			<cfset ArrayAppend(loc.result, loc.item)>
		</cfloop>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadEmployee" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>

		<cfquery name="loc.employee" datasource="#args.database#">
			SELECT *,
				(SELECT ctlEmployer FROM tblControl WHERE ctlID = 1) AS Employer,
				(SELECT ctlEmployerRef FROM tblControl WHERE ctlID = 1) AS EmployerRef
			FROM tblEmployee
			WHERE empID = #val(args.employee)#
			ORDER BY empLastName
		</cfquery>

		<cfset loc.result = {}>
		<cfset loc.result.ID = loc.employee.empID>
		<cfset loc.result.FirstName = loc.employee.empFirstName>
		<cfset loc.result.LastName = loc.employee.empLastName>
		<cfif StructKeyExists(loc.employee,"empEmail")><cfset loc.result.empEmail = loc.employee.empEmail></cfif>
		<cfset loc.result.DOB = loc.employee.empDOB>
		<cfset loc.result.Start = loc.employee.empStart>
		<cfif IsDate(loc.result.Start)>
			<cfset loc.result.ServicePrd = DateDiff("m",loc.result.Start,Now())>
		<cfelse>
			<cfset loc.result.ServicePrd = 0>
		</cfif>
		<cfset loc.result.Rate = loc.employee.empRate>
		<cfset loc.result.Rate2 = loc.employee.empRate2>
		<cfset loc.result.Rate3 = loc.employee.empRate3>
		<cfset loc.result.Status = loc.employee.empStatus>
		<cfset loc.result.TaxCode = loc.employee.empTaxCode>
		<cfset loc.result.Employer = loc.employee.Employer>
		<cfset loc.result.EmployerRef = loc.employee.EmployerRef>
		<cfset loc.result.NI = loc.employee.empNI>
		<cfset loc.result.empPaySlip = loc.employee.empPaySlip>
		<cfset loc.result.Method = loc.employee.empMethod>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadPayrollRecord" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.items = {}>

		<cftry>
			<cfquery name="loc.control" datasource="#args.datasource#">
				SELECT *
				FROM tblControl
				WHERE ctlID = 1
			</cfquery>
			<cfset loc.result.employee = LoadEmployee({"employee"=val(args.form.employee),"database"=args.datasource})>

			<cfquery name="loc.depts" datasource="#args.datasource#">
				SELECT *
				FROM tblPayDepartment, tblPayRates
				WHERE rtDepartment = depID
				AND rtEmployee = #val(args.form.employee)#
			</cfquery>
			<cfset loc.result.employee.depts = QueryToArrayOfStruct(loc.depts)>

			<cfquery name="loc.header" datasource="#args.datasource#">
				SELECT *
				FROM tblPayHeader
				WHERE phEmployee = #val(args.form.employee)#
				AND phDate = '#args.form.weekending#'
			</cfquery>
			<cfset loc.result.header = (loc.header.recordcount is 0) ? {} : QueryToStruct(loc.header)>
			<cfset loc.WeekStartDate = LSDateFormat(loc.control.ctlWeekNoStartDate,"yyyy-mm-dd")>
			<cfset loc.HolStartDate = LSDateFormat(loc.control.ctlHolidayStart,"yyyy-mm-dd")>
			<cfquery name="loc.ytd" datasource="#args.datasource#">
				SELECT Count(phID) as recs,
					(SELECT SUM(phGross) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.WeekStartDate#' AND '#args.form.weekending#') AS GrossSum,
					(SELECT SUM(phPAYE) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.WeekStartDate#' AND '#args.form.weekending#') AS PAYESum,
					(SELECT SUM(phNI) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.WeekStartDate#' AND '#args.form.weekending#') AS NISum,
					(SELECT SUM(phNP) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.WeekStartDate#' AND '#args.form.weekending#') AS NPSum,
					(SELECT SUM(phTotalHours) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.form.weekending#') AS HoursSum,
					(SELECT SUM(phWorkHours) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.form.weekending#') AS WorkSum,
					(SELECT AVG(phWorkHours) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.form.weekending#') AS WorkAvg,
					(SELECT SUM(phHolHours) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.form.weekending#') AS HolSum,
					(SELECT SUM(phMemberContribution) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.form.weekending#') AS PensionSum,
					(SELECT SUM(phLotterySubs) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.form.weekending#') AS LotterySum,
					(SELECT SUM(phAdjustment) FROM tblPayHeader
						WHERE phEmployee = #val(args.form.employee)# AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.form.weekending#') AS AdjustmentSum
				FROM tblPayHeader
				WHERE phEmployee = #val(args.form.employee)#
				AND phDate BETWEEN '#loc.HolStartDate#' AND '#args.form.weekending#'
				ORDER BY phDate
			</cfquery>
			<cfset loc.result.totals = QueryToStruct(loc.ytd)>
			<cfif loc.result.employee.ServicePrd GT 11>
				<cfset loc.result.totals.annual = val(loc.result.totals.WorkAvg) * 52 * 0.1207>
				<cfset loc.result.totals.accrued = 0>
				<cfset loc.result.totals.remain = val(loc.result.totals.annual) - val(loc.result.totals.HolSum)>
			<cfelse>
				<cfset loc.result.totals.annual = 0>
				<cfset loc.result.totals.accrued = val(loc.result.totals.WorkSum) * 0.1207>
				<cfset loc.result.totals.remain = val(loc.result.totals.accrued) - val(loc.result.totals.HolSum)>
			</cfif>

			<cfif !StructIsEmpty(loc.result.header)>
				<cfloop query="loc.depts">
					<cfset loc.deptItemArray = []>
					<cfset StructInsert(loc.result.items, depName, {})>
					<cfset loc.depStruct = StructFind(loc.result.items, depName)>

					<cfquery name="loc.items" datasource="#args.datasource#">
						SELECT *
						FROM tblPayItems
						WHERE piParent = #val(loc.result.header.phID)#
						AND piDept = #val(depID)#
					</cfquery>
					<cfset loc.deptItemArray = QueryToArrayOfStruct(loc.items)>

					<cfloop array="#loc.deptItemArray#" index="loc.itemIt">
						<cfset StructInsert(loc.depStruct, loc.itemIt.piDay, loc.itemIt)>
					</cfloop>
				</cfloop>
			<cfelse>
				<cfset loc.result.items = {}>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html"
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadEmployees" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>

		<cfquery name="loc.employees" datasource="#args.datasource#">
			SELECT *
			FROM tblEmployee
			WHERE empStatus='active'
			ORDER BY empFirstName ASC
		</cfquery>
		<cfreturn QueryToArrayOfStruct(loc.employees)>
	</cffunction>
</cfcomponent>
