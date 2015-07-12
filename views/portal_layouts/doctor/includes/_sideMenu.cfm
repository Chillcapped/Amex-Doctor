<div id="navMenu">
	<ul>
		<cfif structKeyExists(params, "route") and params.route EQ "home">
			<a href="/home"><li id="docMenuMain" class="blueBtn"> <i class="fa fa-home"></i> Main</li></a>
		<cfelse>
			<a href="/home"><li id="docMenuMain"> <i class="fa fa-home"></i> Main</li></a>
		</cfif>

		<cfif structKeyExists(params, "route") and params.route EQ "userMessages">
			<a href="/messages"><li id="docMenuMessages" class="blueBtn"> <i class="fa fa-envelope"></i> Messages</li></a>
		<cfelse>
			<a href="/messages"><li id="docMenuMessages"> <i class="fa fa-envelope"></i> Messages</li></a>
		</cfif>

		<cfif params.controller EQ "medications">
			<a href="/medications"><li id="docMenuMedications" class="blueBtn"> <i class="fa fa-medkit"></i> Medications</li></a>
		<cfelse>
			<a href="/medications"><li id="docMenuMedications"> <i class="fa fa-medkit"></i> Medications</li></a>
		</cfif>
		<cfif params.controller EQ "prescriptions">
			<a href="/prescriptions/browse"><li id="docMenuMedications" class="blueBtn"> <i class="fa fa-medkit"></i> Prescriptions</li></a>
		<cfelse>
			<a href="/prescriptions/browse"><li id="docMenuMedications"> <i class="fa fa-medkit"></i> Prescriptions</li></a>
		</cfif>
		<a href="/shipments"><li id="docMenuAccount"> <i class="fa fa-user-md"></i> Shipments</li></a>

		<cfif structKeyExists(params, "route") and params.route EQ "offices">
			<a href="/offices"><li id="docMenuOffices" class="blueBtn"> <i class="fa fa-hospital-o"></i> Offices</li></a>
		<cfelse>
			<a href="/offices"><li id="docMenuOffices"> <i class="fa fa-hospital-o"></i> Offices</li></a>
		</cfif>

		<cfif structKeyExists(params, "route") and params.route EQ "account">
			<a href="/account"><li id="docMenuAccount" class="blueBtn"> <i class="fa fa-user-md"></i> Account</li></a>
		<cfelse>
			<a href="/account"><li id="docMenuAccount"> <i class="fa fa-user-md"></i> Account</li></a>
		</cfif>




		<cfif structKeyExists(params, "route") and params.route EQ "help">
			<a href="/help"><li id="docMenuAccount" class="blueBtn"> <i class="fa fa-support"></i> Help</li></a>
		<cfelse>
			<a href="/help"><li id="docMenuAccount"> <i class="fa fa-support"></i> Help</li></a>
		</cfif>
	</ul>
</div>
