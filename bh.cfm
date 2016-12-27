<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Bank Holidays</title>
</head>

	<cffunction name="BankHolidays" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.bh = []>
		<cftry>
			<cfloop from="1" to="12" index="loc.mm">
				<cfif loc.mm eq 1>	<!--- new years day bank holiday --->
					<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,1)>
					<cfif DayOfWeek(loc.theDate) eq 7>
						<cfset loc.theDate = DateAdd("d",2,loc.theDate)>
					<cfelseif DayOfWeek(loc.theDate) eq 1>
						<cfset loc.theDate = DateAdd("d",1,loc.theDate)>
					</cfif>
					<cfset ArrayAppend(loc.result.bh,loc.theDate)>
				</cfif>
				<cfif loc.mm eq 5>	<!--- may bank holidays --->
					<cfloop from="1" to="31" index="loc.dd">
						<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,loc.dd)>
						<cfif DayOfWeek(loc.theDate) eq 2 AND loc.dd lte 7>
							<cfset ArrayAppend(loc.result.bh,loc.theDate)>
						<cfelseif DayOfWeek(loc.theDate) eq 2 AND loc.dd gte 24>
							<cfset ArrayAppend(loc.result.bh,loc.theDate)>
						</cfif>
					</cfloop>
				</cfif>
				<cfif loc.mm eq 8>	<!--- august bank holiday --->
					<cfloop from="24" to="31" index="loc.dd">
						<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,loc.dd)>
						<cfif DayOfWeek(loc.theDate) eq 2 AND loc.dd gte 24>
							<cfset ArrayAppend(loc.result.bh,loc.theDate)>
						</cfif>
					</cfloop>
				</cfif>
				<cfif loc.mm eq 12>	<!--- christmas day / boxing day --->
					<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,25)>
					<cfif DayOfWeek(loc.theDate) eq 7>
						<cfset loc.theDate = DateAdd("d",2,loc.theDate)>
					<cfelseif DayOfWeek(loc.theDate) eq 1>
						<cfset loc.theDate = DateAdd("d",1,loc.theDate)>
					</cfif>
					<cfset ArrayAppend(loc.result.bh,loc.theDate)>
					
					<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,26)>
					<cfif DayOfWeek(loc.theDate) eq 7>
						<cfset loc.theDate = DateAdd("d",2,loc.theDate)>
					<cfelseif DayOfWeek(loc.theDate) eq 1>
						<cfset loc.theDate = DateAdd("d",1,loc.theDate)>
					</cfif>
					<cfset ArrayAppend(loc.result.bh,loc.theDate)>					
				</cfif>
			</cfloop>
			<cfset loc.z = {}>
			<cfscript>
			  	loc.z.g = args.yyyy MOD 19;
				loc.z.c = args.yyyy / 100;
				loc.z.h = (loc.z.c - int(loc.z.c / 4) - int((8 * loc.z.c + 13) / 25) + 19 * loc.z.g + 15) MOD 30;
				loc.z.i = loc.z.h - int(loc.z.h / 28) * (1 - int(loc.z.h / 28) * int(29 / (loc.z.h + 1)) * int((21 - loc.z.g) / 11));
				loc.z.dd  = loc.z.i - ((args.yyyy + int(args.yyyy / 4) +  loc.z.i + 2 - loc.z.c + int(loc.z.c / 4)) MOD 7) + 27;
				loc.z.mm = 3;
			
				if (loc.z.dd > 31)
				{
					loc.z.mm++;
					loc.z.dd -= 31;
				}
				loc.result.z = loc.z;
				ArrayAppend(loc.result.bh,LSDateFormat(CreateDate(args.yyyy,loc.z.mm,loc.z.dd),"ddd dd-mmm-yyyy"));
			</cfscript>
			
<!---

public static void EasterSunday(int year, ref int month, ref int day)
{
    int g = year % 19;
    int c = year / 100;
    int h = h = (c - (int)(c / 4) - (int)((8 * c + 13) / 25) 
                                        + 19 * g + 15) % 30;
    int i = h - (int)(h / 28) * (1 - (int)(h / 28) * 
                (int)(29 / (h + 1)) * (int)((21 - g) / 11));

    day   = i - ((year + (int)(year / 4) + 
                  i + 2 - c + (int)(c / 4)) % 7) + 28;
    month = 3;

    if (day > 31)
    {
        month++;
        day -= 31;
    }
}
--->
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<body>
<cfset parm = {}>
<cfloop from="2010" to="2020" index="yr">
	<cfset parm.yyyy = yr>
	<cfset result = BankHolidays(parm)>
	<cfdump var="#result#" label="BankHolidays" expand="true">
	<cfoutput>
		<table>
		<cfloop array="#result.bh#" index="hol">
			<tr><td>#DateFormat(hol,"ddd dd-mmm-yyyy")#</td></tr>
		</cfloop>
		</table>
	</cfoutput>
</cfloop>
</body>
</html>