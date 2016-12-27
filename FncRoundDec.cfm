<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Round</title>
</head>

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

<body style="font-family:'Courier New', Courier, monospace; font-size:14px;">
<cfoutput>
<h3>Round Function</h3> 
<ul> 
	<li>Round(7.49) : #Round(7.49)# </li>
	<li>Round(7.5) : #Round(7.5)# </li>
	<li>Round(-10.775) : #Round(-10.775)# </li>
	<li>Round(-35.5) : #Round(-35.5)# </li>
	<li>Round(35.5) : #Round(35.5)# </li>
	<li>Round(1.2345*100)/100 : #Round(1.2345*100)/100# </li>
</ul>
<h3>RoundDec Function</h3> 
<ul> 
	<li>RoundDec(7.49,0) : #RoundDec(7.49,0)# </li>
	<li>RoundDec(7.5,0) : #RoundDec(7.5,0)# </li>
	<li>RoundDec(-10.775,0) : #RoundDec(-10.775,0)# </li>
	<li>RoundDec(-35.5,0) : #RoundDec(-35.5,0)# </li>
	<li>RoundDec(35.5,0) : #RoundDec(35.5,0)# </li>
	<li>RoundDec(1.2345*100,0)/100 : #RoundDec(1.2345*100,0)/100# </li>
</ul>
<ul> 
	<li>RoundDec(7.49,2) : #RoundDec(7.49,2)# </li>
	<li>RoundDec(7.5,2) : #RoundDec(7.5,2)# </li>
	<li>RoundDec(-10.775,2) : #RoundDec(-10.775,2)# </li>
	<li>RoundDec(-35.5,2) : #RoundDec(-35.5,2)# </li>
	<li>RoundDec(35.5,2) : #RoundDec(35.5,2)# </li>
	<li>RoundDec(1.2345*100,2)/100 : #RoundDec(1.2345*100,2)/100# </li>
</ul>
<ul> 
	<li>RoundDec(1.25,2) : #RoundDec(1.25,2)# </li>
	<li>RoundDec(1.5,2) : #RoundDec(1.5,2)# </li>
	<li>RoundDec(1.75,2) : #RoundDec(1.75,2)# </li>
	<li>RoundDec(1.99,2) : #RoundDec(1.99,2)# </li>
	<li>RoundDec(2.001,2) : #RoundDec(2.001,2)# </li>
	<li>RoundDec(2.15,2)/100 : #RoundDec(2.15,2)/100# </li>
</ul>
<ul> 
	<li>RoundDec(-1.25,2) : #RoundDec(-1.25,2)# </li>
	<li>RoundDec(-1.5,2) : #RoundDec(-1.5,2)# </li>
	<li>RoundDec(-1.75,2) : #RoundDec(-1.75,2)# </li>
	<li>RoundDec(-1.99,2) : #RoundDec(-1.99,2)# </li>
	<li>RoundDec(-2.001,2) : #RoundDec(-2.001,2)# </li>
	<li>RoundDec(-2.15,2)/100 : #RoundDec(-2.15,2)/100# </li>
</ul>
<ul> 
	<li>RoundDec(123456.25,2) : #RoundDec(123456.25,2)# </li>
	<li>RoundDec(123456.5,2) : #RoundDec(123456.5,2)# </li>
	<li>RoundDec(123456.75,2) : #RoundDec(123456.75,2)# </li>
	<li>RoundDec(-123456.99,2) : #RoundDec(-123456.99,2)# </li>
	<li>RoundDec(123456.001,2) : #RoundDec(123456.001,2)# </li>
	<li>RoundDec(123456.15,2)/100 : #RoundDec(123456.15,2)/100# </li>
</ul>
<ul>
	<li>RoundDec(7.49) : #RoundDec(7.49)# </li>
	<li>RoundDec(7.5) : #RoundDec(7.5)# </li>
	<li>RoundDec(-10.775) : #RoundDec(-10.775)# </li>
	<li>RoundDec(-35.5) : #RoundDec(-35.5)# </li>
	<li>RoundDec(35.5) : #RoundDec(35.5)# </li>
	<li>RoundDec(1.2345) : #RoundDec(1.2345)# </li>
	<li>RoundDec(1.2345*100)/100 : #RoundDec(1.2345*100)/100# </li>
	<li>RoundDec(1.2345) : #RoundDec(1.2345)# </li>
	<li>RoundDec(1.2345*100,0)/100 : #RoundDec(1.2345*100,0)/100# </li>
</ul>
<ul>
	<li>RoundDec(1.2345) : #RoundDec(1.2345,-3.5)# </li>
	<li>RoundDec("string") : #RoundDec("string")# </li>
	<li>RoundDec("string","places") : #RoundDec("string","places")# </li>
	<li>RoundDec()empty : #RoundDec()# </li>
</ul>
<ul>
	<cfloop from="1" to="15" index="i">
		<cfset num=1.494+(i/10000)>
		<li>#num# = #RoundDec(num,2)#</li>
	</cfloop>
	<cfloop from="1" to="15" index="i">
		<cfset num=1.4+(i/10)>
		<li>#num# = #RoundDec(num,0)#</li>
	</cfloop>
</ul>
</cfoutput>
</body>
</html>