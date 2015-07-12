

		
<cfif params.inviteResult.status>
	<style>
		input{
			padding:5px;
			margin-bottom:10px;
			border:1px solid #bfbfbf;
		}
		ul{
			list-style:none;
			padding:0;
		}
	</style>
	
	<h2>Create Doctor Account</h2>
	
	<div>
		<p>Invites are tied to the email they were sent to. If you would like to use a different email, please contact us.</p>
		<cfoutput>
		<span>Email: #params.inviteResult.email#</span>
		<span>Invite Code: #params.inviteResult.inviteCode#</span>
		<span>Your Customer Service Rep: #params.inviteResult.salesRep# </span>
		</cfoutput>
	</div>
	
	<form action="/doctor/signUp" method="post">
		<h4>Basic Info</h4>
		<cfoutput>
		<input type="text" name="title" value="#params.inviteResult.title#" placeholder="Title"> <br />
		<input type="text" name="firstName" value="#params.inviteResult.firstName#" placeholder="First Name"> <br />
		<input type="text" name="MiddleName" value="#params.inviteResult.middleName#" placeholder="Middle Name"> <br />
		<input type="text" name="lastName" value="#params.inviteResult.lastName#" placeholder="Last Name"> <br />
		<input type="text" name="password1" value="" placeholder="Password1"> <br />
		<input type="text" name="password2" value="" placeholder="Password2"> <br />
		<input type="text" name="phone" value="" placeholder="Phone"> <br />
		<input type="text" name="phoneExt" value="" placeholder="Phone Ext"> <br />
		<input type="hidden" name="inviteCode" value="#params.inviteCode#" />
		<input type="hidden" name="verifyString" value="#params.verifyString#" />
		<input type="hidden" name="email" value="#params.inviteResult.email#" /> 
		</cfoutput>
		<input type="submit" value="Sign Up">
	</form>

<cfelse>
	<cfoutput>
 	<h3>Error</h3>
	<p>#params.inviteResult.message#</p>
	</cfoutput>
</cfif>

<cfdump var="#params#">



	
	<!---
	<h4>Offices</h4>
	<p>Select the Number of Offices where you will use <cfoutput>#application.appDisplayName#</cfoutput>.</p>
	<select name="numOffices" id="numOffices">
		<cfloop from="1" to="5" index="i">
			<cfoutput>
				<cfif params.numOffices EQ i>
					<option value="#i#" selected>#i#</option>
				<cfelse>
					<option value="#i#">#i#</option>
				</cfif>
			</cfoutput>
		</cfloop>
	</select>
	--->
	
	<!---- Javascript show Divs for number of items selected 
	<div class="officeContainer">
		<input type="text" name="address1" placeholder="Address Line 1"> <br />
		<input type="text" name="address2" placeholder="Address Line 2"> <br />
		<input type="text" name="suite" placeholder="Suite / Office Number"> <br />
		<input type="text" name="city" placeholder="Address Line 1"> <br />
		<input type="text" name="state" placeholder="State"> <br />
		<input type="text" name="zip" placeholder="Zip"> <br />
		<input type="text" name="country" placeholder="Country"> <br />
		<input type="text" name="daysOfWeek" placeholder="Days of Week" value="Mon,Tue,Wed,Thu,Fri"> <br />
	</div>--->