<cfcomponent extends="Controller">



		<!---- AJax Tabs --->
		<cffunction name="tabs">
			<cfparam name="params.tab" default="allOrders">
			<cfparam name="params.tabType" default="home">

			<cfset authorizedTabTypes = "home">

			<cfif params.tabType EQ "home">
				<cfset authorizedHomeTabList = "patients,prescriptions,unsignedrx,history">

				<cfif !listFind(authorizedHomeTabList, params.tab)>
					<cfset params.tab = "allOrders">
				</cfif>
				<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/doctor/tabs/#params.tabType#/#params.tab#")>
			</cfif>

			<cfif params.tabType EQ "rx">
				<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/doctor/tabs/#params.tabType#/#params.tab#")>
		  </cfif>

		</cffunction>




		<!--- Doctor Contact Amex Page --->
		<cffunction name="contact">

			<!--- If we Have Message ---->
			<cfif structKeyExists(params, "message")>
				<cfinvoke component="api.contact" method="createNewContactRequest" returnVariable="contactResult">
					<cfinvokeargument name="message" value="#params.message#">
					<cfinvokeargument name="authToken" value="#session.user.authToken#">
					<cfinvokeargument name="enc" value="false">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>
			</cfif>

			<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/doctor/contact/contact")>
		</cffunction>


		<!--- Doctors authorized users  --->
		<cffunction name="staff">

			<!--- Get Doctors Staff --->
			<cfinvoke component="api.doctor" method="getDelegates" returnVariable="staffLookup">
				<cfinvokeargument name="doctorID" value="#session.user.userID#">
				<cfinvokeargument name="authToken" value="#session.user.authToken#">
				<cfinvokeargument name="returnType" value="struct">
				<cfinvokeargument name="enc" value="false">
			</cfinvoke>

			<cfset renderPage(template="/portal_layouts/doctor/staff/authorizedUsers")>
		</cffunction>


		<!--- Add Authorized User --->
		<cffunction name="addAuthorizedUser">
			<cfparam name="params.email" default="">
			<cfparam name="params.firstName" default="">
			<cfparam name="params.lastName" default="">
			<cfparam name="params.password1" default="">
			<cfparam name="params.password2" default="">
			<cfparam name="params.jobRole" default="">


			<cfif structKeyExists(form, "password1")>
				<cfset errors = arrayNew(1)>
				<cfset requiredCols = "email,firstName,lastName,password1,password2,jobRole">

				<cfloop list="#requiredCols#" index="i">
					<cfif !structKeyExists(params, i) or structKeyExists(params, i) and len(params[i]) EQ 0>
						<cfset errors[arrayLen(errors) + 1] = structNew()>
						<cfset errors[arrayLen(errors)].message = "#i# is required">
					</cfif>
				</cfloop>

				<!--- Check that passwords match --->
				<cfif arrayLen(errors) EQ 0>
					<cfif form.password1 NEQ form.password2>
						<cfset errors[arrayLen(errors) + 1] = structNew()>
						<cfset errors[arrayLen(errors)].message = "Password1 and Password2 must match">
					</cfif>

					<cfif !isValid("email", params.email)>
						<cfset errors[arrayLen(errors) + 1] = structNew()>
						<cfset errors[arrayLen(errors)].message = "Email must be valid">
					</cfif>

				</cfif>

				<!--- If we have all the vars we need, send form submission to component --->
				<cfif arrayLen(errors) EQ 0>
					<cfinvoke component="api.doctor" method="createDelegate" returnVariable="createdStaff">
						<cfinvokeargument name="doctorID" value="#session.user.userID#">
						<cfinvokeargument name="authToken" value="#session.user.authToken#">
						<cfinvokeargument name="returnType" value="struct">
						<cfinvokeargument name="firstName" value="#params.firstName#">
						<cfinvokeargument name="lastName" value="#params.lastName#">
						<cfinvokeargument name="password1" value="#params.password1#">
						<cfinvokeargument name="password2" value="#params.password2#">
						<cfinvokeargument name="jobRole" value="#params.jobRole#">
						<cfinvokeargument name="email" value="#params.email#">
						<cfinvokeargument name="enc" value="false">
					</cfinvoke>
				</cfif>

				<cfif createdStaff.status>
					<cflocation url="/doctor/staff">
				<cfelse>

				</cfif>
			</cfif>
			<cfset renderPage(layout="false", hideDebugInformation="yes")>
		</cffunction>


		<!--- Custom Compound Inquiry Form --->
		<cffunction name="customCompoundInquiry">


			<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/doctor/contact/compoundInquiry")>
		</cffunction>



		<!--- Doctors Current Offices --->
		<cffunction name="offices">
			<!--- Get Doctors Offices --->
			<cfinvoke component="api.doctor" method="getOffices" returnVariable="officeLookUp">
				<cfinvokeargument name="doctorID" value="#session.user.userID#">
				<cfinvokeargument name="authToken" value="#session.user.authToken#">
				<cfinvokeargument name="returnType" value="struct">
				<cfinvokeargument name="enc" value="false">
			</cfinvoke>

			<cfset renderPage(template="/portal_layouts/doctor/offices/offices", hideDebugInformation="yes")>
		</cffunction>



		<!--- Doctor Signup Page  {Excluded from Force Login}--->
		<cffunction name="signUp">
			<cfparam name="params.numOffices" default="1">
			<cfparam name="params.phoneExt" default="">

			<cfif !structKeyExists(params, "inviteCode") or params.inviteCode EQ "">
				<cfif isUserLoggedIn()>
					<cflocation url="/home" addtoken="false">
				<cfelse>
					<cflocation url="/login" addtoken="false">
				</cfif>
			</cfif>


			<!--- Check that Invite Code is Unclaimed --->
			<cfinvoke component="api.doctor" method="checkInviteCode" returnVariable="params.inviteResult">
				<cfinvokeargument name="inviteCode" value="#params.inviteCode#">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>


			<!--- If Invite Code Isnt Valid --->
			<cfif !params.inviteResult.status>

			</cfif>


			<cfif structKeyExists(params, "firstName")
				and structKeyExists(params, "inviteCode") and structKeyExists(params, "lastName") and  structKeyExists(params, "middleName")
				and  structKeyExists(params, "numOffices") and  structKeyExists(params, "phone") and  structKeyExists(params, "title")
					 and  structKeyExists(params, "password1") and  structKeyExists(params, "password2") and structKeyExists(params.inviteResult, "email")>
					<!--- Submit Form to Create Doctor 	---->
					<cfinvoke component="api.doctor" method="createDoctor" returnVariable="signUpResult">
						<cfinvokeargument name="firstName" value="#params.firstName#">
						<cfinvokeargument name="middleName" value="#params.middleName#">
						<cfinvokeargument name="lastName" value="#params.lastName#">
						<cfinvokeargument name="title" value="#params.title#">
						<cfinvokeargument name="phone" value="#params.phone#">
						<cfinvokeargument name="phoneExt" value="#params.phoneExt#">
						<cfinvokeargument name="password1" value="#params.password1#">
						<cfinvokeargument name="password2" value="#params.password2#">
						<cfinvokeargument name="email" value="#params.inviteResult.email#">
						<cfinvokeargument name="inviteCode" value="#params.inviteResult.inviteCode#">
						<cfinvokeargument name="returnType" value="struct">
					</cfinvoke>
				<cfif signUpResult.status>
				<!--- Login Doctor and Send to Create Offices Page --->


				</cfif>
			</cfif>

			<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/doctor/signUp/signUp")>
		</cffunction>


		<cffunction name="messages">

			<cfset renderPage( template="/portal_layouts/doctor/messages")>
		</cffunction>



		<!--- Authorize Rx --->
		<cffunction name="authorizeRx">


			<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/doctor/authorize/prescription")>
		</cffunction>

		<cffunction name="securityCodePrompt">


			<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/doctor/authorize/securityCode")>
		</cffunction>


		<cffunction name="prescribe">

			<!--- Get patients --->
			<cfinvoke component="api.doctor" method="getPatients" returnVariable="patientLookup">
				<cfinvokeargument name="doctorID" value="#session.user.userID#">
				<cfinvokeargument name="authToken" value="#session.user.authToken#">
				<cfinvokeargument name="returnType" value="struct">
				<cfinvokeargument name="enc" value="false">
			</cfinvoke>

			<!--- Create List of patients --->
			<cfset ptList = "">
			<cfloop list="#structKeyList(form)#" index="i">
					<cfif left(i, 3) EQ "PT:">
						<cftry>
						<cfset ptID = right(i, len(i) - 3)>
						<cfset ptList = listAppend(ptList, ptID)>
						<cfcatch>

						</cfcatch>
						</cftry>
					</cfif>
			</cfloop>



			<cfif !structKeyExists(params, "type")>
			<cfset renderPage(hideDebugInformation="yes", template="/portal_layouts/doctor/prescriptions/prescribe")>
			<cfelse>
			<cfset renderPage(hideDebugInformation="yes", template="/portal_layouts/doctor/prescriptions/#params.type#")>
			</cfif>
		</cffunction>
</cfcomponent>
