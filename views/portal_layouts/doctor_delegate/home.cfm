<cfparam name="params.tab" default="patients">



<div id="header">
	
	
	<ul>
		<li><a href="/doctor/createPatient">Add Patient</a></li>
		<li><a href="/createRx">Create Perscription</a></li>
		<li><a href="/doctor/contact">Contact Amex</a></li>
	</ul>
	
</div>
<cfoutput>#includePartial("/doctor_delegate/includes/sideMenu")#</cfoutput>


<div id="contentContainer">
	<ul>
		<a href="/home?&tab=patients"><li>Patients</li></a>
		<a href="/home?&tab=prescriptions"><li>Prescriptions</li></a>
		<a href="/home?&tab=unsignedrx"><li>Unsigned RXs</li></a>
		<a href="/home?&tab=history"><li>History</li></a>
	</ul>
	<!---
	<div id="content">
		<cfoutput>#includePartial("/doctor_delegate/includes/#params.tab#")#</cfoutput>
	</div>
	--->
</div>

<!---
<div class="clear">
<cfdump var="#session#">
</div>
--->


