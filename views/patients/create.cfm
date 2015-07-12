

<div id="createPatientContainer">
	<h2>Create Patient</h2>
	<form action="/patients/create" method="post" id="formSubmission">
		<cfoutput>
			<div class="thirds">
				<h4>General Info</h4>
				<label>Title</label><input type="text" name="title" placeholder="Title" value="" /> 
				<label>First Name</label><input type="text" name="firstName" placeholder="First Name" value="" /> 
				<label>Middle Name</label><input type="text" name="middleName" placeholder="Middle Name" value="" /> 
				<label>Last Name</label><input type="text" name="lastName" placeholder="Last Name" value="" /> 
				<label>Email</label><input type="text" name="email" placeholder="Email" value="" /> 
				<label>Date of Birth</label><input type="text" name="dob" placeholder="Date of Birth" value="" /> 
				<label>Home Phone</label><input type="text" name="homePhone" placeholder="Home Phone" value="" /> 
				<label>Mobile Phone</label><input type="text" name="mobilePhone" placeholder="Mobile Phone" value="" /> 
				<label>SSN</label><input type="text" name="SSN" placeholder="SSN" value="" /> 
			</div>
			<div class="thirds">
				<h4>Billing Address</h4>
				<label>Address Line 1</label><input type="text" name="billAddress1" placeholder="Address Line 1" value="">
				<label>Address Line 2</label><input type="text" name="billAddress2" placeholder="Address Line 2"  value="">
				<label>City</label><input type="text" name="billcity" placeholder="City"  value="">
				<label>State</label><input type="text" name="billstate"  placeholder="State" value="">
				<label>Zip</label><input type="text" name="billZip" placeholder="Zip"  value="">

				<h4 style="padding:10px 0 0 0;">Shipping Address</h4>
				<label>Address Line 1</label><input type="text" name="shipAddress1" placeholder="Address Line 1" value="">
				<label>Address Line 2</label><input type="text" name="shipAddress2" placeholder="Address Line 2" value="">
				<label>City</label><input type="text" name="shipcity" placeholder="City" value="">
				<label>State</label><input type="text" name="shipstate"  placeholder="State" value="">
				<label>Zip</label><input type="text" name="shipZip"  placeholder="Zip" value="">
			</div>

			<div class="thirds">
				<h4>Insurance</h4>
				<label>Carrier Name</label><input type="text" name="ins_carrierName" placeholder="Carrier Name" value="">
				<label>Insurance Name</label><input type="text" name="ins_insuranceName" placeholder="Insurance Name" value="">
				<label>Group Number</label><input type="text" name="ins_groupNumber" placeholder="Group Number" value="">
				<label>PCN Number</label><input type="text" name="ins_pcnNumber" placeholder="PCN Number" value="">
				<label>Carrier Phone</label><input type="text" name="ins_carrierPhone" placeholder="Carrier Phone" value="">
				<label>Plan Number</label><input type="text" name="ins_planNumber" placeholder="Plan Number" value="">
				<label>Bin Number</label><input type="text" name="ins_binNumber" placeholder="Bin Number" value="">
			</cfoutput>
		</div>
		<div id="createPatientBtn">

			<div class="col">
				<a href="javascript:showUploadInsuranceCard();"><div class="contBtnDiv blueCont contBtnAdd">Upload Insurance Card</div></a>
				<a href="javascript:submitNewPatient();"><div class="clear contBtnDiv blueCont contBtnAdd submitterReplace">Add Patient</div></a>
			</div>
			<div  class="col">
				<a href="javascript:showInsuranceCard();"><div class="contBtnDiv blueCont contBtnArrow">View Insurance Card</div></a>
				<a href="javascript:closeDialog();"><div class="contBtnDiv redCont contBtnX">Cancel</div></a>
			</div>


			
		
		</div>
	</form>
</div>

<cfif structKeyExists(variables, "createdPatient")>
	<cfdump var="#createdPatient#">
	<cfdump var="#params#">
</cfif>
