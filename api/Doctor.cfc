<cfcomponent>

	<cfset application.FullDoctorAccessRoles = "admin,tech,pharmacist">
	<cfset application.doctorVerifyURL = "http://amex/api/doctor/verify">
	<cfset application.doctorInviteURL = "http://amex/api/doctor/signUp">
	<cfset application.email = "support@rxportal.io">

	<!--- Get Doctor Info --->
	<cffunction name="getDoctorInfo" access="remote" hint="Gets Info about Doctor, only available if user has access to that info">
		<cfargument name="doctorID" type="numeric" required="true">
		<cfargument name="authToken" required="true" type="string" hint="Sales Rep that invited this doctor">
		<cfargument name="returnFormat" type="string" default="json">

		<cfset result = structNew()>
		<cfset result.status = true>
		<!--- Get Token Owner --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnvariable="tokenINfo">
			<cfinvokeargument name="token" value="#arguments.authToken#">
		</cfinvoke>
		<cfif !tokenInfo.status>
			<cfset result.status = false>
			<cfset result.message = "Invalid Token">
		</cfif>

		<cfif tokenINfo.status>
			<!---- Check that doctor Exists --->
			<cfquery name="checkDoctor" datasource="#application.contentDB#">
				select doctorID, email, firstName, lastName, middleName, title, phone, phoneExt, salesRep, authToken, createDate,
				verifyString, verified, verifiedDate, active
				where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#" >
			</cfquery>
			<cfif checkDoctor.recordCount EQ 0>
				<cfset result.status = false>
				<cfset result.message = "Invalid Doctor ID">
			</cfif>

			<cfif tokenINfo.status>
				<!--- IF Token and Sales rep Dont Match or User Token isnt in Full Access List --->
				<cfif tokenINfo.userID NEQ checkDoctor.salesRep or !listFind(application.roles[tokenINfo.role].name, application.fullDoctorAccessRoles)>
					<cfset result.status = false>
					<cfset result.message = "Supplied Auth Token does not have access to this Doctor.">
				</cfif>
			</cfif>

			<!--- If we have access to this doctor, add info to result struct --->
			<cfif tokenINfo.status>
				<cfloop list="#checkDoctor.getColumns()#" index="i">
					<cfset result[i] = checkDoctor[i][1]>
				</cfloop>
			</cfif>
		</cfif>
		<cfif  arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>



	<!--- Invite Doctor --->
	<cffunction name="inviteDoctor" access="public"  returnFormat="plain" hint="Creates an Invited Doctor Record and sends an Email invite to sign up. Email Contains Invite Code">
		<cfargument name="email" type="string" required="true" hint="email of doctor">
		<cfargument name="firstName" type="string" required="true" hint="first name of doctor">
		<cfargument name="lastName" type="string" required="true" hint="last name of doctor">
		<cfargument name="title" type="string" required="true" hint="Doctors Prefered Title">
		<cfargument name="middleName" type="string" default="" hint="Middle Name of Doctor. Will be Abreviated in Most Cases">
		<cfargument name="authToken" required="true" type="string" hint="Sales Rep that invited this doctor">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">

		<cfset result.status = true>

		<!--- Find Sales Role ID from Cache --->
		<cfloop collection="#application.roles#" item="i">
			<cfif application.roles[i].name EQ "sales">
				<cfset roleID = application.roles[i].roleID>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfif !isValid("email", arguments.email)>
			<cfset result.status = false>
			<cfset result.message = "Doctors Email must be valid">
		</cfif>

		<!--- Check That Auth Token is Valid --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="userTokenInfo">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<cfif userTokenInfo.status>
			<cfif userTokenInfo.role NEQ roleID>
				<cfset result.status = false>
				<cfset result.message = "User is not a sales rep. Only Sales Reps can invite doctors because they are linked to their earning reports.">
			</cfif>
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "Supplied Token is not valid">
		</cfif>

		<cfif result.status>
			<!--- Check that Doctor doesnt exist in system already --->
			<cfquery name="checkEmail" datasource="#application.contentDB#">
				select doctorID
				from doctors
				where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#" >
			</cfquery>

			<cfif checkEmail.recordCount GT 0>
				<cfset result.status = false>
				<cfset result.message = "Doctor Already Exists in System">
			</cfif>
		</cfif>
		<cfif result.status>
			<!--- Check that Doctor doesnt have an invite pending --->
			<cfquery name="checkPending" datasource="#application.contentDB#">
				select inviteID
				from doctors_invites
				where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#" >
			</cfquery>

			<cfif checkPending.recordCount GT 0>
				<cfset result.status = false>
				<cfset result.message = "Doctor already has an Invite Pending">
			</cfif>
		</cfif>
		<!--- If we made it this far, and status is still true, submission is valid --->
		<cfif result.status>
			<cfset inviteCode = replace(createUUID(), "-", "", "all")>
			<cfset verifyString = replace(createUUID(), "-", "", "all")>

			<!--- Save Invite Record in Database --->
			<cfquery name="saveInviteRec" datasource="#application.contentDB#" result="newInvite">
				insert into doctors_invites
				(inviteCode, email, verifyString, title, firstName, middleName, lastName, salesRep, inviteDate)
				values
				(
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#inviteCode#">,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#verifyString#">,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.firstName#">,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.middleName#">,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lastName#">,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#userTokenInfo.userID#">,
				 <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				)
			</cfquery>

			<!--- Email Doctor notifying them that they have been invited, aswell as send invite code w/ verify string to verify email --->
			<cfinvoke component="doctor" method="sendInviteEmail" returnvariable="inviteEmailResult">
				<cfinvokeargument name="inviteID" value="#newInvite.generated_key#">
			</cfinvoke>

		</cfif>


		<cfif arguments.returnType EQ "json">
			<cfreturn serializejson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Check if Invite Code is Valid ---->
	<cffunction name="checkInviteCode" access="public" returnFormat="plain"  >
		<cfargument name="inviteCode" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">

		<cfset result = structNew()>
		<cfset result.status = true>

		<cfquery name="getInvite" datasource="#application.contentDB#" result="">
			select inviteCode, email, firstName, middleName, lastName, title, salesRep, inviteDate,
			redeemed, redeemDate
			from doctors_invites
			where inviteCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.inviteCode#">
			and redeemed = 0
		</cfquery>

		<cfif getInvite.recordCount GT 0>
			<cfset result.message = "Valid Invite Code">
			<cfloop list="#getInvite..columnList#" index="i">
				<cfset result[i] = getInvite[i][1]>
			</cfloop>
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "InValid Invite Code or Invite Code has Been Claimed">
		</cfif>
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Create Doctor --->
	<cffunction name="createDoctor" access="public">
		<cfargument name="firstName" type="String" required="true">
		<cfargument name="middleName" type="string">
		<cfargument name="lastName" type="string" required="true">
		<cfargument name="title" type="string" required="true">
		<cfargument name="phone" type="string" required="true">
		<cfargument name="phoneExt" type="string" default="">
		<cfargument name="password1" type="string" required="true">
		<cfargument name="password2" type="string" required="true">
		<cfargument name="email" type="string" required="true">
		<cfargument name="inviteCode" type="string" required="true">
		<cfargument name="verifyString" type="string" default="">
		<cfargument name="returnType" type="string" default="json">

		<cfset result = structNew()>
		<cfset result.status = true>

		<!--- Validate Required Items --->
		<cfif len(arguments.firstName) EQ 0>
			<cfset result.status = false>
			<cfset result.message = "First Name Required">
		</cfif>

		<cfif result.status and  len(arguments.LastName) EQ 0>
			<cfset result.status = false>
			<cfset result.message = "Last Name Required">
		</cfif>

		<cfif result.status and  len(arguments.password1) LT 6 or arguments.password1 NEQ arguments.password2>
			<cfset result.status = false>
			<cfset result.message = "Password Must Match and be Longer Than 6 Characters.">
		</cfif>

		<cfif result.status and  len(arguments.email) EQ 0 and isValid("email", arguments.email)>
			<cfset result.status = false>
			<cfset result.message = "Valid Email is required">
		</cfif>

		<cfif result.status and len(arguments.phone) EQ 0>
			<cfset result.status = false>
			<cfset result.message = "Valid Phone Number is required">
		</cfif>

		<cfif result.status>
			<!--- Check that invite code and email match --->
			<cfquery name="checkInvite" datasource="#application.contentDB#">
				select * from doctors_invites
				where lower(inviteCode) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.inviteCode)#">
				and lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#">
			</cfquery>
			<cfif checkInvite.recordCount EQ 0>
				<cfset result.status = false>
				<cfset result.message = "Invite Code Not Found">

			<cfelse>
				<!--- If this invite code is redeemed --->
				<cfif checkINvite.redeemed>
					<cfset result.status = false>
					<cfset result.message = "Invite Code Has Been Redeemed">
				</cfif>

				<!--- If verification string is submited, check if matches ---->
				<cfif checkINvite.verifyString EQ arguments.verifyString>
					<cfset result.verified = 1>
				<cfelse>
					<cfset result.verified = 0>
				</cfif>
			</cfif>
		</cfif>


		<!--- If we made it this far, doctor sign up is valid, create account ---->
		<cfif result.status>

			<!--- Create Salt --->
			<cfinvoke component="miscellaneous.utils" method="genSalt" returnvariable="mySalt" />

			<!--- Create Hash --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="newPass">
				<cfinvokeargument name="password" value="#arguments.password1#">
				<cfinvokeargument name="salt" value="#mySalt#">
			</cfinvoke>

			<!--- Add App Salt on Top of User Salt --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="newPass">
				<cfinvokeargument name="password" value="#newPass#">
				<cfinvokeargument name="salt" value="#application.overSalt#">
			</cfinvoke>

			<!--- Create Auth Token --->
			<cfset unencAuthToken = "AMEX-" & replace(createUUID(), "-", "", "all")>
			<cfset verifyString = replace(createUUID(), "-", "", "all")>


			<!--- Encrypt The Auth Token --->
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="authToken">
				<cfinvokeargument name="info" value="#unencAuthToken#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>

			<!--- Insert Doc --->
			<cfquery name="insertDoc" datasource="#application.contentDB#" result="createdDoctor">
				insert into doctors
				(email, password, firstName, middleName, lastName, title, phone, phoneExt, salesRep, authToken,
				 verifyString, createDate, verified)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#newPass#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.firstName#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.middleName#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lastName#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.phone#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.phoneExt#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#checkInvite.salesRep#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#authToken#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#verifyString#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#result.verified#">
				)
			</cfquery>

			<!--- Save Salt --->
			<cfquery name="insertKey" datasource="#application.internalDB#">
				insert into doctors_keys
				(doctorID, keyVal)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#createdDoctor.generated_key#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#mySalt#">
				)
			</cfquery>

			<!--- Set Invite Code as Redeemed --->
			<cfquery name="updateInviteStatus" datasource="#application.contentDB#">
				update doctors_invites
				set redeemed = <cfqueryparam cfsqltype="cf_sql_integer" value="1">,
					redeemDate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				where inviteID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkInvite.inviteID#">
			</cfquery>

			<!--- Email Doctor Verification Email---->
			<cfif !result.verified>
				<cfinvoke component="api.doctor" method="sendVerificationEmail" returnVariable="emailResult">
					<cfinvokeargument name="doctorID" value="#createdDoctor.generated_key#">
				</cfinvoke>
			</cfif>

		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>

	</cffunction>


	<!--- Verify Doctor From Email Link --->
	<cffunction name="verifyDoctor" access="remote" hint="Verifys a Doctor From Email Link">
		<cfargument name="verifyString" type="string" required="true" hint="Verify String Sent in Email">
		<cfargument name="authToken" type="string" required="true" hint="Auth Token for Doctor">
		<cfargument name="returnType" type="string" default="json">

		<cfset result = structNew()>
		<cfset result.status = true>

		<!--- Encrypt Auth Token --->
		<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="authToken">
			<cfinvokeargument name="info" value="#arguments.authToken#">
			<cfinvokeargument name="info2" value="#application.oversalt#">
		</cfinvoke>

		<!--- Check if doctor is found with this auth token and verify string --->
		<cfquery name="getDoctor" datasource="#application.contentDB#">
			select doctorID
			from doctors
			where lower(authToken) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.authToken)#" >
			and lower(verifyString) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.verifyString)#">
		</cfquery>

		<cfif getDoctor.recordCount EQ 0>
			<cfset result.message = "Doctor Not Found">
			<cfset result.status = false>
		<cfelse>
			<cfif getDoctor.verified EQ 0>
				<!--- Update to Verified --->
				<cfquery name="updateDoctor" datasource="#application.contentDB#">
					update doctors
					set verified = 1
					where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getDoctor.doctorID#">
				</cfquery>
				<cfset result.message = "Successfully Verified Doctor">
			<cfelse>
				<cfset result.message = "Doctor Already Verified">
				<cfset result.status = false>
			</cfif>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Check if Patient is actually a Patient of the Doctor --->
	<cffunction name="isDoctorsPatient" access="public" returnType="boolean" hint="Returns boolean if patientID is a patient of doctorID">
		<cfargument name="patientID" type="numeric" required="true">
		<cfargument name="doctorID" type="numeric" required="true">

		<cfquery name="checkPatientRec" datasource="#application.contentDB#">
			select patientID
			from patients
			where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" >
			and doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
		</cfquery>

	 	<cfif checkPatientRec.recordCount EQ 0>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		 </cfif>
	</cffunction>


	<!--- Get Doctors Sales Rep --->
	<cffunction name="getDoctorSalesRep" returnType="string" access="public" hint="Returns sales rep ID that is assigned to a doctor">
		<cfargument name="doctorID" type="numeric" required="true">
		<cfquery name="getRep" datasource="#application.contentDB#">
			select salesRep
			from doctors
			where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
		</cfquery>
		<cfreturn getRep.salesRep>
	</cffunction>

	<!--- Get Doctors Patients --->
	<cffunction name="getPatients" access="remote" returnformat="plain" hint="Returns an array of Doctors Patients in requested format" >
		<cfargument name="doctorID" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="enc" type="string" default="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="fetchFrom" type="string" default="#application.lookupMethod#">
		<cfset result = structNew()>
		<cfset result.status = true>


		<!--- Check if token has access to patient list of this doctor --->
		<cfinvoke component="api.authorize" method="isValidToken" returnVariable="validToken">
			<cfinvokeargument name="userID" value="#arguments.doctorID#">
			<cfinvokeargument name="type" value="doctor">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<!--- If Token doesnt match the doctor  --->
		<cfif !validToken>

			<cfset result.status = false>
			<cfset result.message = "Invalid Auth Token">

			<!--- Get Doctors Assigned Sales Rep --->
			<cfinvoke component="api.doctor" method="getDoctorSalesRep" returnVariable="salesRep">
				<cfinvokeargument name="doctorID" value="#arguments.doctorID#">
			</cfinvoke>

			<!--- If Token isnt the sales reps, check if admin token --->
			<cfif !validToken>
				<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
					<cfinvokeargument name="token" value="#arguments.authToken#">
					<cfinvokeargument name="enc" value="#arguments.enc#">
				</cfinvoke>

				<!--- If Sales Token  --->
				<cfif tokenOwner.role EQ 3 and tokenOwner.userID EQ salesREp>
					<cfset result.status = true>
					<cfset result.message = "">
				<!--- If admin Token --->
				<cfelseif tokenOwner.role EQ 1>
					<cfset result.status = true>
					<cfset result.message = "">
				</cfif>
			</cfif>
		</cfif>

		<!--- If we can return patients to user --->
		<cfif result.status>

			<cfif arguments.fetchFrom EQ "mysql">
				<cfquery name="patients" datasource="#application.contentDB#">
					select patients.patientID, email, doctorID, firstName, middleName, lastName, title, DOB_month,
					DOB_day, DOB_year, DOB_full, homePhone, mobilePhone, ssn, dateCreated
					from patients
					where patients.doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
				</cfquery>

				<cfset result.patients = arrayNew(1)>
				<cfloop query="patients">
					<cfset result.patients[arrayLen(result.patients) + 1] = structNew()>
					<cfloop list="#patients.columnList#" index="i">
						<cfif i EQ "patientID">
							<!--- Encrypt ID --->
							<cfinvoke component="api.encryption" method="encryptFormID" returnVariable="encryptedPatientID">
								<cfinvokeargument name="id" value="#patients[i][patients.currentRow]#">
							</cfinvoke>
							<cfset result.patients[arrayLen(result.patients)]['ePatientID'] = urlEncodedFormat(encryptedPatientID)>
							<cfset result.patients[arrayLen(result.patients)][i] = patients[i][patients.currentRow]>
						<cfelse>
							<cfset result.patients[arrayLen(result.patients)][i] = patients[i][patients.currentRow]>
						</cfif>
					</cfloop>
				</cfloop>
				<cfset result.method ="db">
			<cfelse>
				<!--- Construct Query --->
				<cfset search = structNew()>
				<cfset search['query'] = structNew()>
				<cfset search['query']['query_string'] = structNew()>
				<cfset search['query']['query_string']['query'] = "*">

				<!--- Hit Rx Search --->
				<cfinvoke component="miscellaneous.elastic.Elastic" method="searchIndex" returnvariable="results">
					<cfinvokeargument name="alias" value="pr:doctor@doctor_com">
					<cfinvokeargument name="q" value="#serializeJson(search)#">
					<cfinvokeargument name="searchType" value="advanced">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>

				<!--- Get Scroll Data for This Page --->
				<cfinvoke component="miscellaneous.elastic.Elastic" method="getScrollData" returnvariable="scrollData">
					<cfinvokeargument name="scrollID" value="#results['_scroll_id']#">
					<cfinvokeargument name="scrollTimeout" value="1">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>


				<cfset result.patients = scrollData.hits.hits>
				<cfset result.method ="elastic">
			</cfif>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Get Doctor Delegates --->
	<cffunction name="getDelegates" access="public" hint="Returns Doctors Authorized Users">
		<cfargument name="doctorID" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true" >
		<cfargument name="enc" type="string" default="true">
		<cfargument name="returnType" type="string" default="json">


		<cfset result = structNew()>
		<cfset result.status = true>

		<!--- Check if token has access to delegate list of this doctor --->
		<cfinvoke component="api.authorize" method="isValidToken" returnVariable="validToken">
			<cfinvokeargument name="userID" value="#arguments.doctorID#">
			<cfinvokeargument name="type" value="doctor">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<!--- If Token doesnt match the doctor  --->
		<cfif !validToken>

			<cfset result.status = false>
			<cfset result.message = "Invalid Auth Token">

			<!--- Get Doctors Assigned Sales Rep --->
			<cfinvoke component="api.doctor" method="getDoctorSalesRep" returnVariable="salesRep">
				<cfinvokeargument name="doctorID" value="#arguments.doctorID#">
			</cfinvoke>

			<!--- If Token isnt the sales reps, check if admin token --->
			<cfif !validToken>
				<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
					<cfinvokeargument name="token" value="#arguments.authToken#">
					<cfinvokeargument name="enc" value="#arguments.enc#">
				</cfinvoke>

				<!--- If Sales Token  --->
				<cfif tokenOwner.role EQ 3 and tokenOwner.userID EQ salesREp>
					<cfset result.status = true>
					<cfset result.message = "">
				<!--- If admin Token --->
				<cfelseif tokenOwner.role EQ 1>
					<cfset result.status = true>
					<cfset result.message = "">
				</cfif>
			</cfif>
		</cfif>

		<!--- If we can return delegates to user --->
		<cfif result.status>

			<cfquery name="getDelegates" datasource="#application.contentDB#">
				select delegateID, email, firstName,lastName, password, authToken, verifyString, jobRole, verified, active
				from doctors_delegates
				where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
			</cfquery>

			<cfset result.delegates = arrayNew(1)>
			<cfloop query="getDelegates">
				<cfset result.delegates[arrayLen(result.delegates) + 1] = structNew()>
				<cfloop list="#getDelegates.columnList#" index="i">
					<cfset result.delegates[arrayLen(result.delegates)][i] = getDelegates[i][getDelegates.currentRow]>
				</cfloop>
			</cfloop>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>



	<!---- Create Delegate --->
	<cffunction name="createDelegate" access="remote" hint="Create New Authorized User for a DoctorID">
		<cfargument name="doctorID" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true" >
		<cfargument name="email" type="string" required="true">
		<cfargument name="firstName" type="string" required="true">
		<cfargument name="lastName" type="string" required="true">
		<cfargument name="password1" type="string" required="true">
		<cfargument name="password2" type="string" required="true">
		<cfargument name="jobRole" type="string" required="true">
		<cfargument name="enc" type="string" default="true">
		<cfargument name="returnType" type="string" default="json">

		<cfset result = structNew()>
		<cfset result.status = true>

		<cfif len(arguments.firstName) EQ 0>
			<cfset result.status = "First Name is required">
			<cfset result.status = false>
		</cfif>

		<cfif len(arguments.lastName) EQ 0>
			<cfset result.status = "Last Name is required">
			<cfset result.status = false>
		</cfif>

		<cfif arguments.password1 NEQ arguments.password2>
			<cfset result.status = "Passwords must match">
			<cfset result.status = false>
		</cfif>

		<cfif !isValid("email", arguments.email)>
			<cfset result.status = "Valid Email is Required">
			<cfset result.status = false>
		</cfif>

		<cfif result.status>
			<!--- Check if token has access to delegate list of this doctor --->
			<cfinvoke component="api.authorize" method="isValidToken" returnVariable="validToken">
				<cfinvokeargument name="userID" value="#arguments.doctorID#">
				<cfinvokeargument name="type" value="doctor">
				<cfinvokeargument name="token" value="#arguments.authToken#">
				<cfinvokeargument name="enc" value="#arguments.enc#">
			</cfinvoke>

			<!--- If Token doesnt match the doctor  --->
			<cfif !validToken>

				<cfset result.status = false>
				<cfset result.message = "Invalid Auth Token">

				<!--- Get Doctors Assigned Sales Rep --->
				<cfinvoke component="api.doctor" method="getDoctorSalesRep" returnVariable="salesRep">
					<cfinvokeargument name="doctorID" value="#arguments.doctorID#">
				</cfinvoke>

				<!--- If Token isnt the sales reps, check if admin token --->
				<cfif !validToken>
					<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
						<cfinvokeargument name="token" value="#arguments.authToken#">
						<cfinvokeargument name="enc" value="#arguments.enc#">
					</cfinvoke>

					<!--- If Sales Token  --->
					<cfif tokenOwner.role EQ 3 and tokenOwner.userID EQ salesREp>
						<cfset result.status = true>
						<cfset result.message = "">
					<!--- If admin Token --->
					<cfelseif tokenOwner.role EQ 1>
						<cfset result.status = true>
						<cfset result.message = "">
					</cfif>
				</cfif>
			</cfif>
		</cfif>

		<!--- Check that Account for this email doesnt exist already --->
		<cfif result.status>
			<cfquery name="checkExisting" datasource="#application.contentDB#">
				select email
				from doctors_delegates
				where email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#" >
			</cfquery>
			<cfif checkExisting.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Delegate Account already exists">
			</cfif>
		</cfif>

		<!--- If we can Create Delegate --->
		<cfif result.status>


			<!--- Create Salt --->
			<cfinvoke component="miscellaneous.utils" method="genSalt" returnvariable="mySalt" />

			<!--- Create Hash --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="newPass">
				<cfinvokeargument name="password" value="#arguments.password1#">
				<cfinvokeargument name="salt" value="#mySalt#">
			</cfinvoke>

			<!--- Add App Salt on Top of User Salt --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="newPass">
				<cfinvokeargument name="password" value="#newPass#">
				<cfinvokeargument name="salt" value="#application.overSalt#">
			</cfinvoke>

			<!--- Create Auth Token --->
			<cfset unencAuthToken = "AMEX-" & replace(createUUID(), "-", "", "all")>
			<cfset verifyString = replace(createUUID(), "-", "", "all")>

			<!--- Encrypt The Auth Token --->
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="authToken">
				<cfinvokeargument name="info" value="#unencAuthToken#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>


			<cfquery name="insertDelegate" datasource="#application.contentDB#" result="createdDelegate">
				insert into doctors_delegates
				(doctorID, email, firstName, lastName, password, authToken, verifyString, jobRole, active)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.firstName#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lastName#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#newPass#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#authToken#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#verifyString#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.jobRole#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="1">
				)
			</cfquery>


			<!---- Insert Key ---->
			<cfquery name="insertKey" datasource="#application.internalDB#">
				insert into doctors_delegate_keys
				(delegateID, keyVal)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#createdDelegate.generated_key#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#mysalt#">
				)
			</cfquery>

			<cfset result.message = "Created Doctor Delegate">
		</cfif>


		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	


	<!--- Is Authorized Delegate --->
	<cffunction name="isAuthorizedDelegate" access="public" hint="Returns boolean if supplied delegate token is authorized to perform actions for specified doctor">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="doctorID" type="numeric" required="true">

		<cfset result = structNew()>
		<cfset result.status = false>

		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<!--- If we have valid token, check access --->
		<cfif result.status>
			<cfquery name="checkAccess" datasource="#application.contentDB#">
				select delegateID
				from doctors_delegates
				where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
				and delegateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#">
			</cfquery>

			<cfif checkAccess.recordCount>
				<cfreturn true>
			<cfelse>
				<cfreturn false>
			</cfif>
		</cfif>

		<!--- Default Return false --->
		<cfreturn false>
	</cffunction>


	<!--- Get Doctor of Delegate --->
	<cffunction name="getDelegetesDoctor" access="public" returnType="numeric" hint="returns Doctor of submitted delegate">
		<cfargument name="delegateID" type="numeric" required="true">
		<cfquery name="getDoctor" datasource="#application.contentDB#">
			select doctorID
			from doctors_delegates
			where delegateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.delegateID#">
		</cfquery>
		<cfif getDoctor.recordCount>
			<cfreturn getDoctor.doctorID>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>

	<!--- Get Doctor Prescriptions --->
	<cffunction name="getDoctorsPrescriptions" access="public" hint="Returns a Prescriptions Doctor Submitted">
		<cfargument name="authToken" type="string" required="true" hint="Auth Token of Doctor or Delegate Requesting Prescriptions">
		<cfargument name="returnType" type="string" default="json" hint="Format to return data">
		<cfargument name="enc" type="string" default="false" hint="If Auth token needs to be re-encrypted">
		<cfargument name="limit" type="numeric" default="50">
		<cfargument name="fetchFrom" type="string" default="#application.lookupMethod#">
		<cfargument name="filterBy" type="numeric" default="0">

		<cfset result = structNew()>
		<cfset result.status = false>

		<!--- Get token Owner --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<!--- If token is Doctor, set doctorID --->
		<cfif application.roles[tokenowner.role].name EQ "doctor">
			<cfset doctorID = tokenOwner.userID>
			<cfset result.status = true>
		<!--- If token is delegate, get doctor ID --->
		<cfelseif application.roles[tokenOwner.role].name EQ "doctor_delegate">
			<cfset doctorID = tokenOwner.doctorID>
			<cfset result.status = true>
		</cfif>

		<!--- If we can insert --->
		<cfif result.status>

			<cfif arguments.fetchFrom EQ "db">
			<cfset result.prescriptions = arrayNew(1)>
			<!--- Get Doctors Prescriptions --->
			<cfquery name="getPrescriptions" datasource="#application.rxDB#">
				select *
				from prescriptions
				where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#doctorID#">
				<cfif arguments.filterBy GT 0>
				and status = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filterBy#">
				</cfif>
			</cfquery>
			<!--- Loop Each Rx Item and Add to Return Array --->
			<cfloop query="getPrescriptions">
				<cfset result.prescriptions[arrayLen(result.prescriptions) + 1] = structNew()>
				<cfloop list="#getPrescriptions.columnList#" index="i">
					<cfif i EQ "rxID">

						<!--- Encrypt ID --->
						<cfinvoke component="api.encryption" method="encryptFormID" returnVariable="encryptedRx">
							<cfinvokeargument name="id" value="#getPrescriptions[i][getPrescriptions.currentRow]#">
						</cfinvoke>

						<cfset result.prescriptions[arrayLen(result.prescriptions)]['eRxID'] = urlEncodedFormat(encryptedRx)>
						<cfset result.prescriptions[arrayLen(result.prescriptions)][i] = getPrescriptions[i][getPrescriptions.currentRow]>
					<cfelse>
						<cfset result.prescriptions[arrayLen(result.prescriptions)][i] = getPrescriptions[i][getPrescriptions.currentRow]>
					</cfif>
				</cfloop>
				<cfif getPrescriptions.currentRow EQ arguments.limit>
					<cfbreak>
				</cfif>
			</cfloop>
			<cfset result.method ="db">
			<!--- If we are Fetching from Elastic --->
			<cfelse>

				<cfif arguments.filterBY NEQ 0>
					<cfset search = structNew()>
					<cfset search['query'] = structNew()>
					<cfset search['query']['query_string'] = structNew()>
					<cfset search['query']['query_string']['query'] = "STATUS:#arguments.filterBy#">
				<cfelse>
						<cfset search = structNew()>
						<cfset search['query'] = structNew()>
						<cfset search['query']['query_string'] = structNew()>
						<cfset search['query']['query_string']['query'] = "*">
				</cfif>

				<!--- Hit Rx Search --->
				<cfinvoke component="miscellaneous.elastic.Elastic" method="searchIndex" returnvariable="results">
					<cfinvokeargument name="alias" value="rx:doctor@doctor_com">
					<cfinvokeargument name="q" value="#serializeJson(search)#">
					<cfinvokeargument name="searchType" value="advanced">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>

				<!--- Get Scroll Data for This Page --->
				<cfinvoke component="miscellaneous.elastic.Elastic" method="getScrollData" returnvariable="scrollData">
					<cfinvokeargument name="scrollID" value="#results['_scroll_id']#">
					<cfinvokeargument name="scrollTimeout" value="1">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>


				<cfset result.prescriptions = scrollData.hits.hits>
				<cfset result.method ="elastic">



			</cfif>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>




	<cffunction name="createSignaturePad" access="public" returnType="struct" hint="creates a signature pad">
		<cfargument name="doctorPrefix" type="string" required="true">

		<cfset signaturePadData = structNew()>

		<!--- Create Unique ID Key [Length Must be Divisible by 4, thus the trim] --->
		<cfset keyPrefix = ucase(arguments.doctorPrefix)>
		<cfset signaturePadData.uniqueSignatureKey = left(replace(keyPrefix & createUUID(), "-","", "all"), 32)>

		<!--- 1st: Encrypt unique key with app signature key  --->
		<cfset signaturePadData.eSignatureKey = Encrypt(signaturePadData.uniqueSignatureKey,application.signatureKey,'AES/CBC/PKCS5Padding','HEX') />

		<!--- 2nd: Encrypt with Application Form Key Thats generated on app start  --->
		<cfset signaturePadData.eSignatureKey = Encrypt(signaturePadData.eSignatureKey,application.formKey,'AES/CBC/PKCS5Padding','HEX') />

		<!--- 3rd: Encrypt Key With Hash of  IP and convert to Base 64 --->
		<cfset signaturePadData.ip = hash(replace(request.cgi.remote_addr, ".", "", "all"))>
		<cfset signaturePadData.eSignatureKeyBase = toBase64(encrypt(signaturePadData.eSignatureKey,signaturePadData.ip, 'CFMX_COMPAT'))>

		<cfreturn signaturePadData>
	</cffunction>


	<!--- Get Authorized IPs --->
	<cffunction name="getAuthorizedIPs" access="public" returnType="struct" hint="Returns array of authorized IPs for specified doctor">
		<cfargument name="doctorID" type="numeric" required="true">

		<cfquery name="getIPs" datasource="#application.contentDB#">
			select * from doctors_ip_authorized
			where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
		</cfquery>

		<cfset result = structNew()>
		<cfset result.ips = arrayNew(1)>

		<!--- If we have records --->
		<cfif getIPs.recordCount>
			<cfloop query="getIPs">
				<cfset ipData = structNew()>
				<cfloop list="#getIps.columnList#" index="i">
					<cfset ipData[i] = getIps[i][getIps.currentRow]>
				</cfloop>
			</cfloop>
		<!--- If we have no IPs, something went wrong [Doctor should always have atleast 1 verified IP (created on account creation)] --->
		<cfelse>
			<!--- Create Log Event --->


		</cfif>

		<cfreturn result>
	</cffunction>




</cfcomponent>
