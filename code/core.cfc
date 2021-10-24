<cfcomponent displayname="core">

	<cfset coreArea={}>

	<cffunction name="InitCoreArea" access="public" returntype="struct">
		<cfargument name="parm" type="struct" required="yes">
		<cfset var key=0>
		<cftry>
			<cfloop collection="#parm#" item="key">
				<cfset "coreArea.#key#"=StructFind(parm,key)>
			</cfloop>
			<cfset coreArea.errors=0>
			<cfset coreArea.init=true>
		<cfcatch type="any">
			<cfset coreArea.init=false>
			<cfset coreArea.error=cfcatch>
		</cfcatch>
		</cftry>
		<cfreturn coreArea>
	</cffunction>
	
	<cffunction name="GetCoreArea" access="public" returntype="struct">
		<cfreturn coreArea>
	</cffunction>
	
	<cffunction name="newSession" access="public" output="false" returntype="boolean">
		<cfset onSessionStart()>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="GetInfo" output="false" returnType="any">
		<cfargument name="structure" type="struct" required="true">
		<cfargument name="field" type="string" required="true">
		<cftry>
			<cfif StructKeyExists(structure,field)>
				<cfreturn StructFind(structure,field)>
			<cfelse>
				<cfreturn "">
			</cfif>
		<cfcatch type="any">
			<cfreturn "">	<!--- undefined --->
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="SetInfo" output="false" returnType="boolean">
		<cfargument name="structure" type="struct" required="true">
		<cfargument name="field" type="string" required="true">
		<cfargument name="value" type="any" required="true">
		<cfif StructKeyExists(structure,field)>
			<cfreturn StructUpdate(structure,field,value)>
		<cfelse>
			<cfreturn StructInsert(structure,field,value)>
		</cfif>
	</cffunction>

	<cffunction	name="GetRequestTimeout" access="public" returntype="numeric" output="false" hint="Returns the timeout period for the current page request.">	
		<cfset var local=StructNew() />
		<cfset local.RequestMonitor = CreateObject("java","coldfusion.runtime.RequestMonitor")>
		<cfreturn local.RequestMonitor.GetRequestTimeout() />
	</cffunction>

	<cffunction name="HandleError" access="public" returntype="struct" output="yes" hint="Extract info from cfcatch struct and write it to an error page.">
		<cfargument name="err" type="any" required="yes">
		<cfargument name="data" type="any" required="no" default="">
		<cfset var result=StructNew()>
		<cfset var tagItem=StructNew()>
		<cfset var i=0>
		<cfset var outputfile="#LSDateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHmmss')#">
		
		<cfsetting requesttimeout="#(getRequestTimeout() + 3)#">	<!--- add more time to handle time-outs --->
		<cfset result.tags=ArrayNew(1)>
		<cfloop from="1" to="#ArrayLen(err.TagContext)#" index="i">
			<cfset tagItem={}>
			<cfset StructInsert(tagItem,err.TagContext[i].template,err.TagContext[i].line)>
			<cfset ArrayAppend(result.tags,tagItem)>
		</cfloop>
		<cfswitch expression="#err.type#">
			<cfcase value="Database">
				<cfset result.sql=err.sql>
			</cfcase>
		</cfswitch>
		<cfset result.type=err.type>
		<cfset result.message=err.message>
		<cfset result.detail=err.detail>
		<cfset result.errorPath="#application.core.dir_logs#err#outputfile#.htm">
		<cfset result.session=session.visitor>
		<cfif StructKeyExists(arguments,"data")>
			<cfset result.data=data>
		</cfif>
		<cfif StructKeyExists(application.core,"errors")>
			<cfset application.core.errors++>
		</cfif>
		<cfdump var="#result#" format="html" output="#result.errorPath#">
		<cfreturn result>
	</cffunction>

	<cffunction name="FormatBytes" output="false" returntype="string">
		<cfargument name="bytes" type="numeric" required="true">
		<cfset var str="">
		<cfif bytes GT  1099511627776>
			<cfset str=NumberFormat(bytes / 1099511627776,"_.__") & "TB">
		<cfelseif bytes GT 1073741824>
			<cfset str=NumberFormat(bytes / 1073741824,"_.__") & "GB">
		<cfelseif bytes GT 1048576>
			<cfset str=NumberFormat(bytes / 1048576,"_.__") & "MB">
		<cfelseif bytes GT 1024>
			<cfset str=NumberFormat(bytes / 1024,"_.__") & "KB">
		<cfelse>
			<cfset str=NumberFormat(bytes) & "bytes">
		</cfif>
		<cfreturn str>
	</cffunction>
	
	<cffunction name="QueryToStruct" access="public" returntype="struct" output="false" hint="returns a struct for a single record from query.">
		<cfargument name="queryname" type="query" required="true">
		<cfset var qStruct={}>
		<cfset var columns=queryname.columnlist>
		<cfset var colName="">
		<cfset var fldValue="">
		<cfloop query="queryname">
			<cfset qStruct={}>
			<cfloop list="#columns#" index="colName">
				<cfset fldValue=StructFind(queryname,colName)>
				<cfset StructInsert(qStruct,colName,fldValue)>
			</cfloop>
			<cfreturn StructCopy(qStruct)>	<!--- only return first record if query contains more than one. --->
		</cfloop>
		<cfreturn qStruct> <!--- returns empty struct if query if empty --->
	</cffunction>

	<cffunction name="QueryToArrayOfStruct" access="public" returntype="array" output="false" 
		hint="returns array of structs of records from query. Can return an array containing an empty struct.">
		<cfargument name="queryname" type="query" required="true">
		<cfset var qArray=ArrayNew(1)>
		<cfset var qStruct=StructNew()>
		<cfset var columns=queryname.columnlist>
		<cfset var colName="">
		<cfset var fldValue="">
		<cfloop query="queryname">
			<cfset qStruct=StructNew()>
			<cfloop list="#columns#" index="colName">
				<cfset fldValue=StructFind(queryname,colName)>
				<cfset StructInsert(qStruct,colName,fldValue)>
			</cfloop>
			<cfset ArrayAppend(qArray,StructCopy(qStruct))>
		</cfloop>
		<cfif ArrayIsEmpty(qArray)>
			<cfset ArrayAppend(qArray,QueryNew(columns))>
		</cfif>
		<cfreturn qArray>
	</cffunction>

	<cffunction name="FindTemplate" output="false" returntype="boolean">
		<cfargument name="filePath" type="string" required="false">
		<cfset var result=false>
		<cfset var checkPath="">
		<cfif IsDefined("filePath")>
			<cfif Left(filePath,3) eq "std">
				<cfset checkPath="#application.MapCFPath#\#filePath#">
			<cfelse>
				<cfset checkPath="#application.baseDir##filePath#">
			</cfif>
			<cfset result=FileExists(checkPath)>
		<cfelse>
			<cftrace text="no path specified" />
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="VerifyEncryptedString" access="public" returntype="boolean">
		<cfargument name="stringToTest" type="string" required="yes">
		<cfargument name="originalString" type="binary" required="yes">
		<cfset var loc = {}>
		<cftry>
		
		<cfquery name="loc.enc" datasource="#application.site.datasource1#">
			SELECT (DES_ENCRYPT("#stringToTest#")) AS encryptedString
		</cfquery>
		<cfset loc.result = (ToString(loc.enc.encryptedString) eq ToString(originalString)) ? true : false>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			 	output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="EncryptStr" output="false" returntype="string">
		<cfargument name="pwdStr" type="string" required="false">
		<cfargument name="encStr" type="string" required="false">
		<cfset var mypw="">
		<cfif NOT IsDefined("pwdStr") OR len(pwdStr) EQ 0><cfreturn ""></cfif>		<!--- no string passed, return nothing --->
		<cfif NOT IsDefined("encStr") OR len(encStr) EQ 0><cfreturn pwdStr></cfif>	<!--- no string passed, return original intact --->
		<cftry>
			<cfset mypw=Encrypt(pwdStr,encStr)>		<!--- attempt encryption --->
			<cfset mypw=toBase64(mypw)>				<!--- convert to base64 for storage--->
			<cfcatch type="expression">				<!--- error during encryption --->
				<cfset mypw=pwdStr>					<!--- return original string --->
			</cfcatch>
		</cftry>
		<cfreturn mypw>
	</cffunction>
	
	<cffunction name="DecryptStr" output="false" returntype="string">
		<cfargument name="pwdStr" type="string" required="false">
		<cfargument name="encStr" type="string" required="false">
		<cfset var mypw="">
		<cfif NOT IsDefined("pwdStr") OR len(pwdStr) EQ 0><cfreturn ""></cfif>		<!--- no string passed, return nothing --->
		<cfif NOT IsDefined("encStr") OR len(encStr) EQ 0><cfreturn pwdStr></cfif>	<!--- no string passed, return original intact --->
		<cftry>
			<cfset mypw=toBinary(pwdStr)>					<!--- convert back to string from base64--->
			<cfset mypw=Decrypt(toString(mypw),encStr)>		<!--- Convert to string from binary then decrypt --->
			<cfcatch type="expression">						<!--- error during decryption --->
				<cfset mypw=pwdStr>							<!--- return original string --->
			</cfcatch>
		</cftry>
		<cfreturn mypw>
	</cffunction>
	
	<cffunction name="CreatePassword" access="public" returntype="struct" hint="">
		<cfargument name="CharacterSet" required="no" default="alphanumeric">	<!---[alphanumeric|numeric|alpha]--->
		<cfargument name="Case" required="no" default="mixed">					<!---[mixed|upper|lower]--->
		<cfargument name="Symbols" required="no" default="no">					<!---[yes|no]--->
		<cfargument name="Length" required="no" default="8">
		<cfset var result={}>
		
		<cfset result.args=arguments>
		<cfset result.charArray=[]>	
		<cfif CharacterSet is "alphanumeric" OR CharacterSet is "numeric">		<!--- include numbers --->
			<cfloop from="48" to="57" index="item">
				<cfset ArrayAppend(result.charArray,Chr(item))>
			</cfloop>
		</cfif>
		<cfif CharacterSet is "alphanumeric" OR CharacterSet is "alpha">		<!--- include alphabet --->
			<cfif Case is "mixed" or Case is "upper">							<!--- add upper chars --->
				<cfloop from="65" to="90" index="item">
					<cfset ArrayAppend(result.charArray,Chr(item))>
				</cfloop>
			</cfif>
			<cfif Case eq "mixed" or Case eq "lower">							<!--- add lower chars --->
				<cfloop from="97" to="122" index="item">
					<cfset ArrayAppend(result.charArray,Chr(item))>
				</cfloop>
			</cfif>
		</cfif>
		<cfif Symbols is "yes">													<!--- add symbols --->
			<cfloop list="33,35,36,37,38,42,43,61,63,64" index="item">
				<cfset ArrayAppend(result.charArray,Chr(item))>
			</cfloop>
		</cfif>
		<cfset result.pwd="">
		<cfset result.arrLen=ArrayLen(result.charArray)>
		<cfif result.arrLen eq 0>
			<cfset result.msg="no characters selected for the password, check the parameters">
		<cfelse>
			<cfloop from="1" to="#Length#" index="item">
				<cfset result.pwd="#result.pwd##result.charArray[RandRange(1,result.arrLen)]#">
			</cfloop>
		</cfif>
		<cfset result.pwdlen=Len(result.pwd)>
		<cfreturn result>
	</cffunction>

	<cffunction name="Phoenetic" output="false" returntype="string">
		<cfargument name="pwdStr" type="string" required="false">
		<cfif NOT IsDefined("pwdStr")><cfreturn ""></cfif>	<!--- no string passed --->
		<cfset codes="alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima mike november oscar papa quebec romeo sierra tango uniform victor whiskey xray yankee zulu">
		<cfset var pwdLen=len(pwdStr)>
		<cfset var phonOut="">
		<cfloop from="1" to="#pwdLen#" index="item">
			<cfset char=mid(pwdStr,item,1)>
			<cfif len(phonOut)><cfset phonOut="#phonOut#-"></cfif>
			<cfif REFind("[[:upper:]]",char,1)>
				<cfset phonOut="#phonOut##UCase(GetToken(codes,asc(char)-64,' '))#">
			<cfelseif REFind("[[:lower:]]",char,1)>
				<cfset phonOut="#phonOut##GetToken(codes,asc(char)-96,' ')#">
			<cfelseif REFind("[0-9]",char,1)>
				<cfset phonOut="#phonOut##GetToken("zero one two three four five six seven eight nine",asc(char)-47,' ')#">
			<cfelse>
				<cfset phonOut="#phonOut##char#">
			</cfif>
		</cfloop>
		<cfreturn phonOut>
	</cffunction>

	<cffunction name="CheckDateStr" returntype="any" output="yes">
		<cfargument name="str" type="string" required="yes">
		<cfargument name="reversed" type="boolean" required="no" default="false">
		<cfargument name="style" type="string" required="no" default="date">
		<cfset var dateStr="">
		<cfset var rev=2*(reversed NEQ 0)>
		<cfset var yy="">
		<cfset var mm="">
		<cfset var dd="">
		<cfset var lastDay="">
		<cfset var timeStr="">
		<cfset var tmp=0>

		<cfif Find(":",str,1)>
			<cfset timeStr=ListLast(str," ")>	<!--- get time portion --->
			<cfset str=ListFirst(str," ")>		<!--- get date portion --->
		</cfif>
		<cfif len(str) gt 0>
			<cfset yy=GetToken(str,3-rev,"/-")>
			<cfset mm=val(GetToken(str,2,"/-"))>
			<cfset dd=GetToken(str,1+rev,"/-")>
			
			<cfif dd gt 1000>	<!--- yy & dd are reversed --->
				<cfset tmp=dd>
				<cfset dd=yy>
				<cfset yy=tmp>
			</cfif>
			
			<cfswitch expression="#mm#">
				<cfcase value="1,3,5,7,8,10,12" delimiters=",">
					<cfset lastDay=31>
				</cfcase>
				<cfcase value="4,6,9,11">
					<cfset lastDay=30>				
				</cfcase>
				<cfcase value="2">
					<cfset lastDay=28>				
					<cfif (yy MOD 4) EQ 0><cfset lastDay=29></cfif>
					<cfif (yy MOD 100) EQ 0 AND (yy MOD 400) NEQ 0><cfset lastDay=28>
						<cfelseif (yy MOD 400) EQ 0><cfset lastDay=29></cfif>
				</cfcase>
			</cfswitch>
			
			<cfif yy LTE 9999 AND mm GT 0 AND mm LTE 12 AND dd GTE 0 AND dd LTE lastDay>
				<cfswitch expression="#style#">
					<cfcase value="date">
						<cfset dateStr=LSDateFormat(CreateDate(yy,mm,dd),"dd/mm/yyyy")>					
					</cfcase>
					<cfcase value="mysqldate">
						<cfset dateStr=LSDateFormat(CreateDate(yy,mm,dd),"yyyy-mm-dd")>					
					</cfcase>
					<cfcase value="mysqldatetime">
						<cfset dateStr=LSDateFormat(CreateDate(yy,mm,dd),"yyyy-mm-dd")>	
						<cfset dateStr="#dateStr# #timeStr#">				
					</cfcase>
					<cfcase value="datetime">
						<cfset dateStr=CreateDate(yy,mm,dd)>
					</cfcase>
					<cfdefaultcase>
						<cfset dateStr=CreateDate(yy,mm,dd)>
					</cfdefaultcase>
				</cfswitch>
			<cfelse><cfreturn JavaCast( "null", 0 )></cfif>
		</cfif>
		<cfreturn dateStr>
	</cffunction>
	
	<!--- Ref: https://www.codeproject.com/Articles/10860/Calculating-Christian-Holidays - May 2017 --->
	<cffunction name="BankHolidays" access="public" returntype="array" hint="Pass a year value and it returns an array of bank holidays for that year">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		<cftry>
			<cfloop from="1" to="12" index="loc.mm">
				<cfif loc.mm eq 1>	<!--- new years day bank holiday --->
					<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,1)>
					<cfif DayOfWeek(loc.theDate) eq 7>	<!--- if sat --->
						<cfset loc.theDate = DateAdd("d",2,loc.theDate)>	<!--- jump to mon --->
					<cfelseif DayOfWeek(loc.theDate) eq 1>	<!--- if sun --->
						<cfset loc.theDate = DateAdd("d",1,loc.theDate)>	<!--- jump to mon --->
					</cfif>
					<cfset ArrayAppend(loc.result,loc.theDate)>
				</cfif>
				<cfif loc.mm eq 5>	<!--- may bank holidays --->
					<cfloop from="1" to="31" index="loc.dd">
						<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,loc.dd)>
						<cfif DayOfWeek(loc.theDate) eq 2 AND loc.dd lte 7>	<!--- 1st mon in May --->
							<cfset ArrayAppend(loc.result,loc.theDate)>
						<cfelseif DayOfWeek(loc.theDate) eq 2 AND loc.dd gt 24>	<!--- last mon in May --->
							<cfset ArrayAppend(loc.result,loc.theDate)>
						</cfif>
					</cfloop>
				</cfif>
				<cfif loc.mm eq 8>	<!--- august bank holiday --->
					<cfloop from="24" to="31" index="loc.dd">
						<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,loc.dd)>
						<cfif DayOfWeek(loc.theDate) eq 2 AND loc.dd gt 24>	<!--- last mon in Aug --->
							<cfset ArrayAppend(loc.result,loc.theDate)>
						</cfif>
					</cfloop>
				</cfif>
				<cfif loc.mm eq 12>	<!--- christmas day bank holiday / boxing day bank holiday--->
					<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,25)>
					<cfif DayOfWeek(loc.theDate) eq 7>	<!--- if sat --->
						<cfset loc.theDate = DateAdd("d",2,loc.theDate)>	<!--- jump to mon --->
					<cfelseif DayOfWeek(loc.theDate) eq 1>	<!--- if sun --->
						<cfset loc.theDate = DateAdd("d",1,loc.theDate)>	<!--- jump to mon --->
					</cfif>
					<cfset ArrayAppend(loc.result,loc.theDate)>
					
					<cfset loc.theDate = CreateDate(args.yyyy,loc.mm,26)>
					<cfif DayOfWeek(loc.theDate) eq 7>	<!--- if sat --->
						<cfset loc.theDate = DateAdd("d",2,loc.theDate)>	<!--- jump to mon --->
					<cfelseif DayOfWeek(loc.theDate) eq 1>	<!--- if sun --->
						<cfset loc.theDate = DateAdd("d",2,loc.theDate)>	<!--- jump to tue because xmas bh on mon --->
					<cfelseif DayOfWeek(loc.theDate) eq 2>	<!--- if mon --->
						<cfset loc.theDate = DateAdd("d",1,loc.theDate)>	<!--- jump to tue because xmas bh on mon --->
					</cfif>
					<cfset ArrayAppend(loc.result,loc.theDate)>
				</cfif>
			</cfloop>
			<cfset loc.z = {}>
			<!--- calculate Easter Sunday --->
			<cfscript>
			  	loc.z.g = int(args.yyyy MOD 19);
				loc.z.c = int(args.yyyy / 100);
				loc.z.h = (loc.z.c - int(loc.z.c / 4) - int((8 * loc.z.c + 13) / 25) + 19 * loc.z.g + 15) MOD 30;
				loc.z.i = loc.z.h - int(loc.z.h / 28) * (1 - int(loc.z.h / 28) * int(29 / (loc.z.h + 1)) * int((21 - loc.z.g) / 11));
				loc.z.dd  = loc.z.i - ((args.yyyy + int(args.yyyy / 4) +  loc.z.i + 2 - loc.z.c + int(loc.z.c / 4)) MOD 7) + 28;
				loc.z.mm = 3;
				if (loc.z.dd > 31) {
					loc.z.mm++;
					loc.z.dd -= 31;
				}
				loc.z.es = CreateDate(args.yyyy,loc.z.mm,loc.z.dd);
				loc.z.gf = DateAdd("d",-2,loc.z.es);
				loc.z.em = DateAdd("d",1,loc.z.es);
				ArrayAppend(loc.result,loc.z.gf);	// Good Friday
				ArrayAppend(loc.result,loc.z.es);	// Easter Sunday
				ArrayAppend(loc.result,loc.z.em);	// Easter Monday
			</cfscript>
			<cfset ArraySort(loc.result,"numeric","asc")>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="IsBankHoliday" access="public" returntype="boolean" hint="Pass a date and function will return true if it is a bank holiday">
		<cfargument name="yourDate" type="date" required="true">
		<cfif IsDate(yourDate)>
			<cfloop array="#application.holidays#" index="bh">
				<cfif yourDate eq bh>
					<cfreturn true>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="ValidEmail" output="false" returnType="boolean">
		<cfargument name="email" type="string" required="false">
		<cfset var posAt=0>
		<cfset var nextAt=0>
		<cfset var posDot=0>
		<cfset var lastDot=0>
		<cfif NOT IsDefined("email")><cfreturn false></cfif>		<!--- no string passed --->
		<cfif Find(" ",email)><cfreturn false></cfif>				<!--- no spaces allowed --->
		<cfset posAt=Find("@",email,1)>
		<cfset nextAt=Find("@",email,posAt+1)>
		<cfif posAt LT 2 OR nextAt GT 1><cfreturn false></cfif>		<!--- too many or no @'s --->
		<cfset domainName=ListLast(email,"@")>
		<cfset posDot=find(".",domainName)>
		<cfset lastDot=find(".",Reverse(domainName))>
		<cfif posDot lt 3 OR lastDot LT 3><cfreturn false></cfif>	<!--- no dots or in wrong place --->
		<cfreturn true>
	</cffunction>
	
	<cffunction name="CleanText" output="false" returnType="boolean">
		<cfargument name="badText" type="string" required="false">	<!--- find this --->
		<cfargument name="yourStr" type="string" required="false">	<!--- in that --->
		<cfif NOT IsDefined("yourStr") OR NOT IsDefined("badText")><cfreturn true></cfif>	<!--- no strings passed so it can't be bad --->
		<cfif len(yourStr) EQ 0 OR len(badText) EQ 0><cfreturn true></cfif>					<!--- strings passed were empty so it can't be bad --->
		<cfreturn ReFind(badText,yourStr,1,false) eq 0>
	</cffunction>

	<cffunction name="extractLinks" output="yes" returntype="struct">
		<cfargument name="urlPath" required="yes" type="string" />
		<cfargument name="urlLink" required="yes" type="string" />
		<cfset var item={}>
		<cfset var result={}>
		<cfset var content="">
		<cfset var line="">
		<cfset var arrayResult={}>
		
		<cfset result.lines=[]>
		<!---<cfset result.images=[]>--->
		<cfset result.linecount=0>
		<cfset result.refcount=0>
		<cfset result.title="(not found)">
		<cfset result.urlPath=urlPath>
		<cfset result.urlLink=urlLink>

		<cfhttp method="get" url="#urlPath##urlLink#" useragent="#CGI.http_user_agent#" resolveurl="no" multipart="yes" result="content">
			<cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0" />
			<cfhttpparam type="Header" name="TE" value="deflate;q=0" />
			<cfhttpparam type="cookie" name="CFID" value="#cookie.cfid#" />
			<cfhttpparam type="cookie" name="CFToken" value="#cookie.cftoken#" />
		</cfhttp>
		<cfif find("200",content.statuscode)>
			<cfloop list="#content.filecontent#" delimiters="#chr(10)##chr(13)#" index="line">
				<cfset item={}>
				<cfset result.linecount++>
				<cfif FindNoCase("href",line,1)>
					<cfif FindNoCase("<link",line,1)>
						<cfset item.type="link">
						<cfset item.posn1=ReFindNoCase('<link\s([^>]*)href=\"([^\"]*)\"[^>]*\/>',line,1,true)>
						<cfif ArrayLen(item.posn1.pos)>
							<cfloop from="1" to="#arraylen(item.posn1.pos)#" index="i">
								<cfif item.posn1.pos[i] gt 0>
									<cfset "item.link#i#"=mid(line,item.posn1.pos[i],item.posn1.len[i])>
								</cfif>
							</cfloop>
						</cfif>
						<!---<cfdump var="#item#" label="item" expand="yes" abort="false">--->
						
					<cfelseif FindNoCase("<a",line,1)>
						<cfset item.type="a">
						<cfset item.posn1=ReFindNoCase('<a\s[^>]*href=\"([^\"]*)\"[^>]*>(.*)<\/a>',line,1,true)>
						<cfif ArrayLen(item.posn1.pos) AND item.posn1.pos[1] gt 0>
							<cfloop from="1" to="#arraylen(item.posn1.pos)#" index="i">
								<cfif item.posn1.pos[i] gt 0>
									<cfset "item.link#i#"=mid(line,item.posn1.pos[i],item.posn1.len[i])>
								</cfif>
							</cfloop>
							<!---<cfdump var="#item#" label="item" expand="yes" abort="false">--->
						<cfelse>
							<cfset item.short=ReFindNoCase('<a\s[^>]*href=\"([^\"]*)\"([^>]*)>',line,1,true)>
							<cfloop from="1" to="#arraylen(item.short.pos)#" index="i">
								<cfif item.short.pos[i] gt 0>
									<cfset "item.link#i#"=mid(line,item.short.pos[i],item.short.len[i])>
								<cfelse>
									<cfset item.failed=htmleditformat(line)>
								</cfif>
							</cfloop>
							<!---<cfdump var="#item#" label="short" expand="yes" abort="false">--->
						</cfif>	
					</cfif>
					<cfif NOT StructIsEmpty(item)>
						<cfset ArrayAppend(result.lines,item)>
					</cfif>
					
				<cfelseif FindNoCase("<meta",line,1)>
					<cfset item.line=line>
					<cfset item.type="meta">
					<cfset item.posn1=ReFindNoCase('<meta\s([^>]*)>',line,1,true)>
					<cfif ArrayLen(item.posn1.pos)>
						<cfloop from="1" to="#arraylen(item.posn1.pos)#" index="i">
							<cfif item.posn1.pos[i] gt 0>
								<cfset "item.link#i#"=mid(line,item.posn1.pos[i],item.posn1.len[i])>
							</cfif>
						</cfloop>
					</cfif>
					<cfif NOT StructIsEmpty(item)>
						<cfset ArrayAppend(result.lines,item)>
					</cfif>

				<cfelseif FindNoCase("<script",line,1)>
					<cfset item.type="script">
					<cfset item.posn1=ReFindNoCase('src=\"([^"]*)',line,1,true)>
					<cfset item.link2="">
					<cfif ArrayLen(item.posn1.pos) gt 1>
						<cfset item.link3=mid(line,item.posn1.pos[2],item.posn1.len[2])>		
					<cfelse>
						<cfset item.link3="inline script">			
					</cfif>
					<!---<cfdump var="#item#" label="short" expand="yes" abort="false">--->
					<cfif NOT StructIsEmpty(item)>
						<cfset ArrayAppend(result.lines,item)>
					</cfif>
								
				<cfelseif FindNoCase("<form",line,1)>
					<cfset item.type="form">
					<cfset item.link2="">
					<cfset item.link3=htmleditformat(line)>
					<cfif NOT StructIsEmpty(item)>
						<cfset ArrayAppend(result.lines,item)>
					</cfif>
					
				<cfelseif FindNoCase("<title>",line,1)>
					<cfset arrayResult=ReFindNoCase('<title>([^<]*)</title>',line,1,true)>
					<cfif ArrayLen(arrayResult.pos) gt 1>
						<cfset result.title=mid(line,arrayResult.pos[2],arrayResult.len[2])>					
					</cfif>
				</cfif>

				<cfif FindNoCase("<h1",line,1)>
					<cfset result.h1Line=line>
					<cfset arrayResult=ReFindNoCase('<h1[^>]+>(.+)<\/h1>',line,1,true)>
					<cfif ArrayLen(arrayResult.pos) gt 1>
						<cfset result.h1=mid(line,arrayResult.pos[2],arrayResult.len[2])>					
					</cfif>
				</cfif>
				<cfif FindNoCase("<img",line,1)>
					<cfset item={}>
					<cfset item.posn1=ReFindNoCase('alt=[\"''](.*)[\"'']',line,1,true)>
					<cfif ArrayLen(item.posn1.pos) gt 1>
						<cfset item.type="image">
						<cfset item.AltText=mid(line,item.posn1.pos[2],item.posn1.len[2])>
						<cfset ArrayAppend(result.lines,item)>
					</cfif>
				</cfif>
			</cfloop>
			<cfset result.refcount=ArrayLen(result.lines)>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="showLinks" access="public" output="yes" returntype="void" hint="">
		<cfargument name="args" type="struct" required="yes">
		<cfset var lineNo=0>
		<cfoutput>
			<table border="1" width="98%" class="results">
				<tr class="titles">
					<th>&nbsp;</th>
					<th width="5%">Type</th>
					<th width="45%">URL</th>
					<th width="50%">Parameters</th>
				</tr>
				<tr class="header">
					<td>&nbsp;</td>
					<td>Path</td>
					<td>#args.urlPath#</td>
					<td>LINES: #args.lineCount# LINKS: #args.refCount#</td>
				</tr>
				<tr class="header">
					<td>&nbsp;</td>
					<td>Title</td>
					<td>#args.title#</td>
					<td><a href="#args.urlPath##args.urlLink#">#args.urlLink#</a></td>
				</tr>
				<tr class="header">
					<td>&nbsp;</td>
					<td>H1</td>
					<td><cfif StructKeyExists(args,"h1")>#args.h1#<cfelse>NO H1</cfif></td>
					<td></td>
				</tr>
				<cfloop array="#args.lines#" index="item">
					<cfset lineNo++>
					<cfif StructKeyExists(item,"type")>
						<tr class="#item.type#">
							<td>#lineNo#</td>
							<td>#item.type#</td>
							<cfif item.type is "a">
								<cfif StructKeyExists(item,"failed")>
									<td colspan="2">#item.failed#</td>
								<cfelseif StructKeyExists(item,"link3")>
									<cfif FindNoCase("img",item.link3)>
										<cfset link3=ReFindNoCase('src=\"([^\"]*)\"',item.link3,1,true)>
										<cfif link3.pos[1] gt 0>
											<cfset newlink3=mid(item.link3,link3.pos[1],link3.len[1])>
										</cfif>
									<cfelse><cfset newlink3=item.link3></cfif>
									<!---<td><a href="#script_name#?urlPath=#args.urlPath#&amp;urlLink=#ListLast(item.link2,"/")#">#item.link2#</a></td>--->
									<td><a href="#script_name#?urlPath=#args.urlPath#&amp;urlLink=#ListRest(ListRest(item.link2,"/"),"/")#">#item.link2#</a></td>
									<td><a href="#item.link2#">#newlink3#</a></td>
								<cfelse>
									<cfset newlink3="">
									<!---<cfdump var="#item#" label="item" expand="no" abort="false">--->
								</cfif>
							<cfelseif item.type is "meta">
								<td><cfif StructKeyExists(item,"link2")>#item.link2#</cfif></td>
								<td><cfif StructKeyExists(item,"link1")>#item.link1#</cfif></td>
							<cfelseif item.type is "image">
								<td><cfif StructKeyExists(item,"altText")>alt= #item.altText#</cfif></td>
								<td></td>
							<cfelse>
								<td><cfif StructKeyExists(item,"link3")>#item.link3#</cfif></td>
								<td><cfif StructKeyExists(item,"link2")>#item.link2#</cfif></td>
							</cfif>
						</tr>
					</cfif>
				</cfloop>
			</table>
		</cfoutput>
	</cffunction>

	<cffunction name="RoundDec" returntype="numeric" hint="Validates arguments then rounds number to n places">
		<cfargument name="num" type="any" required="no" default="0">
		<cfargument name="places" type="any" required="no" default="2" hint="positive integer">
		<cfset var loc={}>
		<cfif NOT IsNumeric(num)><cfreturn 0></cfif>
		<cfset loc.places=abs(val(places))>
		<cfif loc.places gt 0>
			<cfset loc.decimalPlaces=Left("__________",loc.places)>
			<cfset loc.multiplier=10^loc.places>
			<cfset loc.newNum=Round(num*loc.multiplier)/loc.multiplier>
			<cfset loc.newNum=Replace(NumberFormat(loc.newNum,"_________.#loc.decimalPlaces#")," ","","all")>
		<cfelse>
			<cfset loc.newNum=Round(num)>
		</cfif>
		<cfreturn loc.newNum>
	</cffunction>

	<cffunction name="GetDatasource" access="public" returntype="any">
		<cfreturn application.site.datasource1>
	</cffunction>
	
	<cffunction name="GetVatTypes" access="public" returntype="array">
		<cfset var loc = {}>
		<cfquery name="loc.types" datasource="#GetDatasource()#">
			SELECT *
			FROM tblVATRates
			WHERE vatCode != 0
		</cfquery>
		<cfreturn QueryToArrayOfStruct(loc.types)>
	</cffunction>
	
	<cffunction name="GetSuspenseAccount" access="public" returntype="numeric">
		<cfreturn 31>
	</cffunction>
	
	<cffunction name="GetSettlementAccount" access="public" returntype="numeric">
		<cfargument name="type" type="string" required="yes">
		<cfif type eq "sales">
			<cfreturn 101>
		<cfelse>
			<cfreturn 111>
		</cfif>
	</cffunction>
	
	<cffunction name="GetNominalVATRecordID" access="public" returntype="numeric">
		<cfreturn 21><!---DEV[1152]--->
	</cffunction>

	<cffunction name="AddClientPayNomItems" access="public" returntype="numeric">
		<cfargument name="tranID" type="numeric" required="yes">
		<cfargument name="amount" type="numeric" required="yes">
		<cfargument name="balAcct" type="numeric" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfquery name="loc.QLoadTran" datasource="#GetDatasource()#">
				SELECT *
				FROM tblTrans
				WHERE trnID=#val(tranID)#
				LIMIT 1;
			</cfquery>
			<cfif loc.QLoadTran.recordCount EQ 1>
				<cfswitch expression="#loc.QLoadTran.trnMethod#">
					<cfcase value="cash">
						<cfset loc.nomID=871>	<!--- A17 News accounts payment via shop (was 181) --->
					</cfcase>
					<cfcase value="chqs">
						<cfset loc.nomID=871>	<!--- A17 News accounts payment via shop (was 1472) --->
					</cfcase>
					<cfcase value="card">
						<cfset loc.nomID=871>	<!--- A17 News accounts payment via shop (was 191) --->
					</cfcase>
					<cfcase value="coll">
						<cfset loc.nomID=1482>	<!--- cash collected account --->
					</cfcase>
					<cfcase value="chq">
						<cfset loc.nomID=1472>	<!--- cheque holding account (cheques collected or posted --->
					</cfcase>
					<cfcase value="phone">
						<cfset loc.nomID=2862>	<!--- payments taken online via card system (Stripe) --->
					</cfcase>
					<cfcase value="ib">
						<cfset loc.nomID=41>	<!--- Bank Account --->
					</cfcase>
					<cfcase value="acct">
						<cfset loc.nomID=2802>	<!--- Customer Shop Account --->
					</cfcase>
					<cfcase value="dv">
						<cfset loc.nomID=231>	<!--- News Subscription Vouchers --->
					</cfcase>
					<cfcase value="qchq|qs|qsib|qslost" delimiters="|">
						<cfset loc.nomID=1561>	<!--- Paid Via Quickstop (no longer used) --->
					</cfcase>
					<cfcase value="cp">
						<cfset loc.nomID=1752>	<!--- Council Payments via BACS --->
					</cfcase>
					<cfcase value="na">
						<cfset loc.nomID=31>	<!--- Suspense Account --->
					</cfcase>
					<cfdefaultcase>
						<cfset loc.nomID=31>	<!--- Suspense Account --->
					</cfdefaultcase>
				</cfswitch>
				<cfquery name="loc.InsertItem" datasource="#GetDatasource()#">
					INSERT INTO tblNomItems 
						(niNomID,niTranID,niAmount) 
					VALUES 
						(#loc.nomID#,#tranID#,#amount#),
						(#balAcct#,#tranID#,#-amount#)
				</cfquery>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn 1>
	</cffunction>

<!---	<cffunction name="GetSpecialAccounts" access="public" returntype="struct">
		<cfargument name="type" type="string" required="yes">
		<cfset var loc={}>
		<cfquery name="loc.Nominals" datasource="#GetDatasource()#">
			SELECT nomID,nomTitle,nomType,nomGroup,nomClass
			FROM tblNominal
			WHERE nomID < 161
		</cfquery>
		<cfloop query="loc.Nominals">
			<cfif type eq "sales">
				<cfswitch expression="#nomID#">
					<cfcase value="1"></cfcase>
				</cfswitch>
			<cfelse>
			</cfif>
		</cfloop>
	</cffunction>--->
	
	<cffunction name="LoadActivity" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QActivity="">
		<cfset var QClient="">
		<cfset var startDate=DateAdd("d",-args.days,Now())>

		<cfquery name="QActivity" datasource="#args.datasource#">
			SELECT *
			FROM tblActivity
			WHERE actTimestamp >= '#LSDateFormat(startDate,"yyyy-mm-dd")#'
			GROUP BY actClientID, actType, actClass, actText
			ORDER BY actTimestamp desc
		</cfquery>
		<cfloop query="QActivity">
			<cfquery name="QClient" datasource="#args.datasource#">
				SELECT cltRef,cltName,cltCompanyName,cltDelTel
				FROM tblClients
				WHERE cltID=#actClientID#
				LIMIT 1;
			</cfquery>
			<cfquery name="QPub" datasource="#args.datasource#">
				SELECT pubTitle
				FROM tblPublication
				WHERE pubID=#val(actPubID)#
				LIMIT 1;
			</cfquery>
			<cfset item={}>
			<cfset item.ID=actID>
			<cfset item.Timestamp=actTimestamp>
			<cfset item.Pub=QPub.pubTitle>
			<cfset item.Type="#actType# #actClass#">
			<cfset item.Ref=QClient.cltRef>
			<cfif actClientID neq 0>
				<cfif len(QClient.cltName) AND len(QClient.cltCompanyName)>
					<cfset item.Text="(#QClient.cltRef#) #QClient.cltName# #QClient.cltCompanyName#">
				<cfelse>
					<cfset item.Text="(#QClient.cltRef#) #QClient.cltName##QClient.cltCompanyName#">
				</cfif>
				<cfset item.Info=actText>
			<cfelse>
				<cfset item.Text=actText>
				<cfset item.Info="">
			</cfif>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddActivity" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QActivity="">

		<cfquery name="QActivity" datasource="#args.datasource#">
			INSERT INTO tblActivity (
				actType,
				actClass,
				actClientID,
				actPubID,
				actText
			) VALUES (
				'#args.Type#',
				'#args.Class#',
				#val(args.ClientID)#,
				#val(args.PubID)#,
				'#args.Text#'
			)
		</cfquery>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SearchClients" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QClients="">

		<cftry>
			<cfquery name="QClients" datasource="#args.datasource#">
				SELECT *
				FROM tblClients,tblStreets2
				WHERE <cfif val(args.search) neq 0>1<cfelse>cltAccountType <> 'N'</cfif>
				AND cltStreetCode=stID
				AND (
				<cfloop list="#args.search#" delimiters=" " index="i">
					<cfif val(args.search) neq 0>
						cltRef=#val(i)# OR
					<cfelse>
						cltName LIKE '%#i#%'
						OR cltCompanyName LIKE '%#i#%'
						OR cltDelHouseName LIKE '%#i#%'
						OR cltDelHouseNumber LIKE '%#i#%'
						OR cltDelTown LIKE '%#i#%'
						OR cltDelCity LIKE '%#i#%'
						OR cltDelPostcode LIKE '%#i#%'
						OR stName LIKE '%#i#%' OR
					</cfif>
				</cfloop>
				cltID=0
				)
				ORDER BY cltRef asc
			</cfquery>
			<cfloop query="QClients">
				<cfset item={}>
				<cfset item.ID=cltID>
				<cfset item.Ref=cltRef>
				<cfif len(cltName) AND len(cltCompanyName)>
					<cfset item.Name="#cltName# #cltCompanyName#">
				<cfelse>
					<cfset item.Name="#cltName##cltCompanyName#">
				</cfif>
				<cfif len(cltDelHouseName) AND len(cltDelHouseNumber)>
					<cfset item.House="#cltDelHouseName#, #cltDelHouseNumber#">
				<cfelse>
					<cfset item.House="#cltDelHouseName##cltDelHouseNumber#">
				</cfif>
				<cfset item.Street="#stName#">
				<cfset ArrayAppend(result,item)>
			</cfloop>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="no">
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>	
	
	<cffunction name="ExpiringVouchers" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var QVouchers="">
		<cfset var group={}>
		<cfset var item={}>
		<cfset var i="">
		<cfset var pub="">

		<cfquery name="QVouchers" datasource="#args.datasource#" result="QVouchersResult">
			SELECT *
			FROM tblVoucher,tblPublication
			WHERE vchOrderID=#args.orderID#
			<cfif StructKeyExists(args,"pubID")>AND pubID IN (#args.pubID#)</cfif>
			AND vchPubID=pubID
			AND vchStatus='in'
			<cfif StructKeyExists(args,"showCurrent")>AND vchStop >= '#LSDateFormat(Now(),"yyyy-mm-dd")#'</cfif>	
			<cfif StructKeyExists(args,"hideOld")>AND vchStop > DATE_ADD(Now(), INTERVAL -1 YEAR)</cfif>	
			ORDER BY vchPubID asc, vchStop desc
		</cfquery>
		<cfloop query="QVouchers">
			<cfset item={}>
			<cfset item.ID=vchID>
			<cfset item.pub=pubTitle>
			<cfset item.start=LSDateFormat(vchStart,"dd/mm/yyyy")>
			<cfset item.stop=vchStop>
			<cfset item.expired=false>
			<cfif StructKeyExists(args,"Date")>
				<cfset item.reDays=DateDiff("d",args.Date,vchStop)>
			<cfelse>
				<cfset item.reDays=DateDiff("d",Now(),vchStop)>
			</cfif>
			<cfif item.reDays lte 3>
				<cfset item.expired=true>
			<cfelse>
				<cfset item.expired=false>
			</cfif>
			<cfif StructKeyExists(group,vchPubID)>
				<cfset pub=StructFind(group,vchPubID)>
				<cfif vchStop gt pub.stop>
					<cfset StructDelete(group,vchPubID)>
					<cfset StructInsert(group,vchPubID,item)>
				</cfif>
			<cfelse>
				<cfset StructInsert(group,vchPubID,item)>
			</cfif>
		</cfloop>
		
		<cfset groupSort=StructSort(group,"textnocase","asc","pub")>
		
		<cfloop array="#groupSort#" index="x">
			<cfset i=StructFind(group,x)>
			<cfif StructKeyExists(args,"showExp")>
				<cfif i.expired>
					<cfset ArrayAppend(result,i)>
				</cfif>
			<cfelse>
				<cfset ArrayAppend(result,i)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="textMessage" access="public" returntype="string" hint="Converts an html email message into a plain text message with line breaks.">
		<cfargument name="string" required="true" type="string">
		<cfscript>
			var pattern = "<br />";
			var CRLF = chr(13) & chr(10);
			var message = ReplaceNoCase(arguments.string, pattern, CRLF , "ALL");
			pattern = "<[^>]*>";
		</cfscript>
		<cfreturn REReplaceNoCase(message, pattern, "" , "ALL")>
	</cffunction>

	<cffunction name="AutoEmail" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cftry>
			<cfsavecontent variable="content">
				<cfoutput>
					<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
					<html xmlns="http://www.w3.org/1999/xhtml">
					<head>
						<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
						<style type="text/css">
							html {font-family:Arial, Helvetica, sans-serif;}
						</style>
					</head>				
					<body>
						<h1>Shortlanesend Store</h1>
						<h3 style="color:##666;">Newspaper Delivery</h3>
						<hr />
						<h3 style="padding:5px 0;">Hello #args.name#,</h3>
						<h2 style="padding:5px 0;margin:0;">#args.subject#</h2>
						<div style="padding:5px 0;">
							<p>#args.text#</p>
						</div>
						<hr>
						<p style="color:##666;">
							If any the information here is incorrect, please contact us on: 01872 275102 or email us at: news@shortlanesendstore.co.uk
						</p>
					</body>
					</html>
				</cfoutput>
			</cfsavecontent>
			<cfsavecontent variable="logit">
				to="#args.email#" 
				from="news@shortlanesendstore.co.uk" 
				bcc="news@shortlanesendstore.co.uk" 
				server="mail.shortlanesendstore.co.uk" 
				username="cfmail@shortlanesendstore.co.uk" 
				password="#DecryptStr(application.siteclient.cltMailPassword,application.siteRecord.scCode1)#"
				subject="#args.subject# - Shortlanesend Store X">
				cfmailpart type="plain">
					Hello #args.name#,
					#args.subject#
					#args.text#
					If any the information here is incorrect, please contact us on: 01872 275102 or email us at: news@shortlanesendstore.co.uk
				/cfmailpart>
				cfmailpart type="html">
					#content#
				/cfmailpart>
			</cfsavecontent>
			<cflog text="#logit#">
			<cfmail 
				to="#args.email#" 
				from="news@shortlanesendstore.co.uk" 
				bcc="news@shortlanesendstore.co.uk" 
				server="mail.shortlanesendstore.co.uk" 
				username="cfmail@shortlanesendstore.co.uk" 
				password="#DecryptStr(application.siteclient.cltMailPassword,application.siteRecord.scCode1)#"
				subject="#args.subject# - Shortlanesend Store X">
				<cfmailpart type="plain">
					Hello #args.name#,
					#args.subject#
					#args.text#
					If any the information here is incorrect, please contact us on: 01872 275102 or email us at: news@shortlanesendstore.co.uk
				</cfmailpart>
				<cfmailpart type="html">
					#content#
				</cfmailpart>
			</cfmail>
			<cffile action="append" addnewline="yes" file="#application.site.dir_data#logs\email\mail-#DateFormat(Now(),'yyyymmdd')#.txt"
				output="Message sent to: #args.email# - #args.subject#">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="AutoEmail" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>



