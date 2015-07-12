<cfcomponent>
	<!---
		Controller handles all user related functions

		Functions

		1. GetUserInfo
		2. CreateUser
		3. DeleteUser
		4. SetUserInactive
		5. reActivateUser
		6. getRoleID
		7. getRoles

	--->

	<!--- Get user info --->
	<cffunction name="getUserInfo" returnformat="plain" access="public" hint="returns info about a user in specified format. Auth token must be supplied.">
		<cfargument name="authToken" type="string" required="true">
		<cfquery name="getUser" datasource="#application.contentDB#">
			select users.userID, users.userRole, users.email, users.employeeID, users.authToken, users.email2,
			users.password, users.dateCreated, users_info.firstName, users_info.lastName, users_info.DOB_month, users_info.DOB_year,
			users_info.address1, users_info.address2, users_info.city, users_info.state, users_info.country, users_info.zip, users_info.phone,
			users_info.phoneExt
			inner join users_info on users.userID = users_info.userID
			where users.authToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
		</cfquery>
		<cfif arguments.returnType EQ "json">
			<cfset result = structNew()>
			<cfloop list="#getUser.getColumns()#" index="i">
				<cfset result[i] = getUser[i][1]>
			</cfloop>
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn getUser>
		</cfif>
	</cffunction>


	<!--- Get Logged In User Info --->
	<cffunction name="getLoggedInUserInfo" access="remote" returnformat="plain" hint='Returns json info struct of logged in user'>
		<cfset result = structNew()>
		<cfif isUserLoggedIn()>
			<cfset result.user = structCopy(session.user)>
			<cfset result.status = true>
			<cfset result.message = "User Found">
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "User is not logged in">
		</cfif>
		<cfreturn serializeJson(result)>
	</cffunction>

	<!--- Create User --->
	<cffunction name="createUser" access="public" returnformat="plain" hint="Creates a new user record">
		<cfargument name="userType" type="string" required="true" hint="Sales,Tech,Doctor,Admin">
		<cfargument name="email" type="string" required="true" hint="Email of User">
		<cfargument name="alternateEmail" type="string" required="true" hint="Alternate Email of User">
		<cfargument name="password" type="string" required="true" hint="Password of User">
		<cfargument name="employee" type="boolean" default="false">
		<cfargument name="employeeID"  default="0">
		<cfargument name="firstName" required="true" type="string">
		<cfargument name="lastName" required="true" type="string">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" default="json" type="string" hint="Json,Struct">



		<!--- Check if Admin Token --->


		<cfif arguments.employeeID EQ "">
			<cfset arguments.employeeID = 0>
		</cfif>

		<cfset result = structNew()>
		<cfset result.status = true>


		<!--- Check that Email Is Valid --->
		<cfif !isvalid("email", arguments.email)>
			<cfset result.status = false>
			<cfset result.message = "Email Address must be valid">
		</cfif>

		<!--- Check that password is longer than 6 --->
		<cfif len(arguments.password) LTE 6>
			<cfset result.status = false>
			<cfset result.message = "Password must be atleast 6 characters long.">
		</cfif>

		<!--- Get Role ID --->
		<cfquery name="getRole" datasource="Amex">
			select roleID
			from users_role
			where name = <cfqueryparam cfsqltype="varchar" value="#lcase(arguments.userType)#">
		</cfquery>

		<cfif getRole.recordCount EQ 0>
			<cfset result.status = false>
			<cfset result.message = "User Role not found.">
		</cfif>

		<!--- Check that we dont have username already --->
		<cfquery name="existing" datasource="Amex">
			select userID
			from users
			where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#" >
		</cfquery>

		<cfif existing.recordCount GT 0>
			<cfset result.status = false>
			<cfset result.message = "User already exists">
		</cfif>


		<!--- If we passed checks, create user --->
		<cfif result.status EQ true>

			<!--- Create Salt --->
			<cfinvoke component="miscellaneous.utils" method="genSalt" returnvariable="mySalt" />

			<!--- Create Hash --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="newPass">
				<cfinvokeargument name="password" value="#arguments.password#">
				<cfinvokeargument name="salt" value="#mySalt#">
			</cfinvoke>

			<!--- Add App Salt on Top of User Salt --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="newPass">
				<cfinvokeargument name="password" value="#newPass#">
				<cfinvokeargument name="salt" value="#application.overSalt#">
			</cfinvoke>

			<!--- Create Auth Token --->
			<cfset unencAuthToken = "AMEX-" & replace(createUUID(), "-", "", "all")>

			<!--- Encrypt The Auth Token --->
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="authToken">
				<cfinvokeargument name="info" value="#unencAuthToken#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>

			<!--- Insert User Info --->
			<cfquery name="insertUser" datasource="amex" result="createdUser">
				insert into users
				(userRole, email, email2, authToken,  password,
				<cfif arguments.employee EQ true>
					employee, employeeID,
				<cfelse>
					employee,
				</cfif>
				dateCreated	)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#getRole.roleID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.alternateEmail#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#authToken#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#newPass#">,
					<cfif arguments.employee EQ true>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.employee#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.employeeID#">,
				<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.employeeID#">,
				</cfif>
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				)
			</cfquery>
			<!--- Insert Salt --->
			<cfquery name="insertKey" datasource="amex_internal">
				insert into users_keys
				(userID, keyVal)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#createdUser.generated_key#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#mySalt#">
				)
			</cfquery>

			<cfset result.status = true>
			<cfset result.username = arguments.email>
			<cfset result.authToken = unencAuthToken>
			<cfset result.message = "Created User: #arguments.email#">
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializejson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>

	<!--- Delete user --->
	<cffunction name="deleteUser" returnformat="plain" access="public" hint="Moves All users data from active database to archives. Disableing their access to the application and removing all their data.">
		<cfargument name="authKey" type="string" required="true" hint="Admin Auth Key that has rights to Delete a user">
		<cfargument name="returnType" default="json" type="string" hint="Return format of Data">





	</cffunction>



	<!--- Set User as Inactive --->
	<cffunction name="setUserInactive" returnformat="plain" access="public" hint="Disables a users access to the application while maintaing their data">
		<cfargument name="authKey" type="string" required="true" hint="Admin Auth Key that has rights to De-Activate a user">
		<cfargument name="returnType" default="json" type="string" hint="Return format of Data">


	</cffunction>


	<!--- Re- Activate User --->
	<cffunction name="reActivateUser" returnformat="plain" access="public" hint="Reactives an inactive user">
		<cfargument name="authKey" type="string" required="true" hint="Admin Auth Key that has rights to Re-Activate a user">
		<cfargument name="returnType" default="json" type="string" hint="Return format of Data">



	</cffunction>


	<!--- Get Role ID --->
	<cffunction name="getRoleID" returnformat="plain" returnType="numeric" access="public" hint="returns roleID of role">
		<cfargument name="name" type="string" required="true">
		<cfargument name="returnType" default="json" type="string" hint="Return format of Data">

		<cfquery name="getRole" datasource="#application.contentDB#">
			select roleID
			from users_role
			where lower(name) = <cfqueryparam cfsqltype="varchar" value="#lcase(arguments.name)#">
		</cfquery>
		<cfif getRole.recordCount GT 0>
			<cfreturn getRole.roleID>
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>




	 <!--- Reset User Password --->
	 <cffunction name="resetUserPassword" access="public">
	 	 <cfargument name="email" type="string" required="true">
		 <cfargument name="password" type="string" required="true">
		 <cfargument name="authToken" type="string" required="true">
	 	 <cfargument name="resetString" type="string" required="true">
		<cfargument name="returnType" default="json" type="string" hint="Json,Struct">


		<cfset result = structNEw()>
		<cfset result.status = true>


		<cfif len(arguments.password) LTE 5>
			<cfset result.status = false>
			<cfset result.message = "Password must be 6 characters long">
		</cfif>


		<!--- Look up request string for this account and check that it matches --->
		 <cfif result.status>
				<cfinvoke component="api.users" method="verifyResetString" returnVariable="validResetString">
					<cfinvokeargument name="email" value="#arguments.email#">
					<cfinvokeargument name="resetString" value="#arguments.resetString#">
				</cfinvoke>

			 	 <!--- if this string matches --->
			 	 <cfif !validResetString>
			 	 	<cfset result.status = false>
			 	 	<cfset result.message = "Invalid Reset String">
				</cfif>
	 	 </cfif>

	 	 <cfif result.status>
 	 		  <!--- Lookup Email  --->
			  <cfinvoke component="users" method="getUserFromEmail" returnVariable="userInfo">
			    	<cfinvokeargument name="email" value="#arguments.email#">
					<cfinvokeargument name="returnType" value="struct">
			  </cfinvoke>

			 <!--- Get Users Salt --->
			<cfinvoke component="api.authorize" method="getKey" returnVariable="mySalt">
				<cfinvokeargument name="id" value="#userInfo.userID#">
				<cfinvokeargument name="type" value="#userInfo.accountType#">
			</cfinvoke>

			<!--- Decrypt Auth Token --->
			<cfinvoke component="miscellaneous.utils" method="dec" returnvariable="authToken">
				<cfinvokeargument name="info" value="#userInfo.authToken#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>

			<cfif authToken NEQ arguments.authToken>
 	 				<cfset result.status = false>
					<cfset result.message = "Invalid Reset String">
			  </cfif>
		 </cfif>

	 	 <!--- Reset Password if we made it this far --->
	 	 <cfif result.status>

			<!--- Create Hash --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="newPass">
				<cfinvokeargument name="password" value="#arguments.password#">
				<cfinvokeargument name="salt" value="#mySalt#">
			</cfinvoke>

			<!--- Add App Salt on Top of User Salt --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="newPass">
				<cfinvokeargument name="password" value="#newPass#">
				<cfinvokeargument name="salt" value="#application.overSalt#">
			</cfinvoke>

			<!--- Save New Pass Rec --->
			<cfif userInfo.accountType EQ "user">
				<cfquery name="savePass" datasource="#application.contentDB#">
					update users
					set password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newPass#">
					where userID = <cfqueryparam cfsqltype="cf_sql_integer"  value="#userInfo.userID#">
				</cfquery>
				<cfset result.message = "Reset Password">
			<cfelseif userINfo.accountType EQ "doctor">
				<cfquery name="savePass" datasource="#application.contentDB#">
					update doctors
					set password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newPass#">
					where doctorID = <cfqueryparam cfsqltype="cf_sql_integer"  value="#userInfo.userID#">
				</cfquery>
				<cfset result.message = "Reset Password">
			<cfelseif userInfo.accountType EQ "delegate">
				<cfquery name="savePass" datasource="#application.contentDB#">
					update doctors_delegates
					set password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newPass#">
					where delegateID = <cfqueryparam cfsqltype="cf_sql_integer"  value="#userInfo.userID#">
				</cfquery>
				<cfset result.message = "Reset Password">
			</cfif>
		</cfif>

	 	<cfif arguments.returnType EQ "json">
			<cfreturn serializejson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	 </cffunction>


	 <!--- Send Reset Password Email --->
	 <cffunction name="sendResetPasswordEmail" access="remote" hint="Sends Password Reset Email to User">
	 	 <cfargument name="email" type="string" required="true">
	 	 <cfargument name="returnType" type="string" default="json">

	 	 <cfset result = structNew()>
	 	 <cfset result.status = true>

		 <!--- Lookup Email  --->
		  <cfinvoke component="users" method="getUserFromEmail" returnVariable="userInfo">
		    	<cfinvokeargument name="email" value="#arguments.email#">
				<cfinvokeargument name="returnType" value="struct">
		  </cfinvoke>

		  <!--- Check if matches email, if does, create reset string and send reset email --->
	 	 <cfif result.status>
	 	 	<cfset resetString = replace(createUUID(), "-", "", "all")>

	 	 	<!--- Save Reset String --->
			<cfquery name="insertResetString" datasource="#application.internalDB#">
				insert into reset_strings
				(userID, email, type, requestDate, resetString, redeemed)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#userInfo.userID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#userInfo.email#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#userInfo.accountType#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#resetString#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="0"> )
		    </cfquery>

			<!--- Decrypt Auth Token --->
			<cfinvoke component="miscellaneous.utils" method="dec" returnvariable="authToken">
				<cfinvokeargument name="info" value="#userInfo.authToken#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>


	 	 	<cfmail to="andyj@materialflow.com" from="#application.supportEmail#"
					subject="RxPortal Password Reset Request">
	 	 		<a href="http://amex/resetPassword?&authToken=#authToken#&email=#userInfo.email#&resetString=#resetString#">Reset Password</a>
	 	 	</cfmail>

			<cfset message = "Sent Password Reset Email">

	 	 <cfelse>
		  	  <cfset result.status = false>
		  	  <cfset result.message = "Email Not Found">
		  </cfif>


	 	 <cfif arguments.returnType EQ "json">
			<cfreturn serializejson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	 </cffunction>


	 <!--- Get User info From Email --->
	 <cffunction name="getUserFromEmail" access="public" hint="Returns a users info if email is found in system">
	 	 <cfargument name="email" type="string" required="true">
	 	 <cfargument name="returnType" default="json" type="string">
	 	 <cfset result = structNew()>

	 	<!--- Check User DB --->
		<cfquery name="getUsers" datasource="amex">
			select firstName, userRole as roleID, lastName, users.userID, users.email, users.authToken, users.password
			from users
			left join users_info on users.userID = users_info.userID
			where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#">
		</cfquery>

		<!--- If User Record not found, Check Doctor --->
		<cfif getUsers.recordCount EQ 0>

				<!--- Check Doctor DB --->
				<cfquery name="getDoctors" datasource="#application.contentDB#">
					select * from doctors
					where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#">
				</cfquery>

				<!--- If Doctor Record not found, check deligates ---->
				<cfif getDoctors.recordCount EQ 0>

					<cfquery name="getDelagetes" datasource="#application.contentDB#">
						select * from doctors_delegates
						where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#">
					</cfquery>

					<cfif getDelagetes.recordCount GT 0>
						<cfset result.accountType = "Delegate">
						<cfset result.userID = getDelagetes.delegateID>
						<cfset result.firstName = getDelagetes.firstName>
						<cfset result.email = getDelagetes.email>
						<cfset result.roleID =  5>
						<cfset result.lastName = getDelagetes.lastName>
						<cfset result.authToken = getDelagetes.authTOken>
						<cfset passHash = getDelagetes.password>
					<cfelse>
						<cfset resultStruct.status = false>
						<cfset resultStruct.message = "Invalid Username or Password">
					</cfif>

				<!--- If Doctor Record Matches --->
				<cfelse>
					<cfset result.userID = getDoctors.doctorID>
					<cfset result.authToken = getDoctors.authTOken>
					<cfset result.firstName =  getDoctors.firstName>
					<cfset result.email = getDoctors.email>
					<cfset result.roleID =  4>
					<cfset result.lastName =  getDoctors.lastName>
					<cfset result.accountType = "Doctor">
					<cfset passHash = getDoctors.password>
				</cfif>
		<cfelse>
			<cfset result.userID = getUsers.userID>
			<cfset result.authToken = getUsers.authTOken>
			<cfset result.firstName =  getUsers.firstName>
			<cfset result.roleID =  getUsers.roleID>
			<cfset result.email = getUsers.email>
			<cfset result.lastName =  getUsers.lastName>
			<cfset passHash = getUsers.password>
			<cfset result.accountType = "user">
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializejson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	 </cffunction>


	<!--- Verify Reset String --->
	<cffunction name="verifyResetString" access="public" returnType="string" hint="Returns boolean based on if reset string is latest account reset request">
		<cfargument name="email" type="string" required="true">
		<cfargument name="resetString" type="string" required="true">

		<!--- Get latest reset string --->
		<cfquery name="latestResetString" datasource="#application.internalDB#">
			select resetString, requestDate
			from reset_strings
			where lower(email) =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.email)#" >
			order by requestDate desc
			limit 1
		</cfquery>

		<cfif arguments.resetString EQ latestResetString.resetString>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	 </cffunction>


	<!--- Get Users --->
	<cffunction name="getUsers" access="public" hint="Returns Users of Application">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" default="json" type="string" hint="Json,Struct">
		<cfargument name="filterBy" default="0" type="numeric">

		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.filterBy = arguments.filterBy>
		<!--- Get token Owner --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<cfif tokenOwner.status and application.roles[tokenOwner.role].name EQ "Admin">
			<cfset result.status = true>
		</cfif>

		<cfif result.status>

			<cfset result.users = arrayNew(1)>

			<cfif application.roles[arguments.filterBy].name EQ "doctor">
				<cfquery name="getUsers" datasource="#application.contentDB#">
					select doctorID, email, firstName, middleName, lastName, title, phone,
					phoneExt, salesRep, authToken, createDate, verified, verifiedDate, active
					from doctors
				</cfquery>
			</cfif>


			<cfif application.roles[arguments.filterBy].name EQ "delegate">
				<cfquery name="getUsers" datasource="#application.contentDB#">
					select delegateID, doctorID, email ,firstName, lastName, jobRole, verified, active, createDate
					from doctors_delegates
				</cfquery>
			</cfif>

			<cfif application.roles[arguments.filterBy].name EQ "Pharmacist" or
				application.roles[arguments.filterBy].name EQ "Tech" or
				application.roles[arguments.filterBy].name EQ "Admin" or
				application.roles[arguments.filterBy].name EQ "Sales" >
				<cfquery name="getusers" datasource="#application.contentDB#">
					select users.userID, users.userRole, users.Email, users.employee, users.employeeID,
					users.email2, users.dateCreated as createDate, users.active, users_info.firstName, users_info.lastName, users_info.dob_month,
					users_info.dob_day, users_info.dob_year, users_info.address1, users_info.address2, users_info.city, users_info.state,
					users_info.country, users_info.zip, users_info.phone, users_info.phoneExt
					from users
					left join users_info on users.userID = users_info.userID
					<cfif arguments.filterBy GT 0>
					where userROle = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filterBy#">
					</cfif>
				</cfquery>
			</cfif>
			<cfloop query="getUsers">
				<cfset result.users[arrayLen(result.users) + 1] = structNew()>
				<cfloop list="#getUsers.columnList#" index="i">
					<cfset result.users[arrayLen(result.users)][i] = getUsers[i][getUsers.currentRow]>
				</cfloop>
			</cfloop>
		</cfif>


		<cfif arguments.returnType EQ "json">
			<cfreturn serializejson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	 <!--- Get Security Roles --->
	 <cffunction name="getSecurityRoles" access="public" hint="Returns Security Roles and number of users">
	 	<cfargument name="returnType" default="json" type="string" hint="Return format of Data">
		<cfargument name="authToken" type="string" required="true" hint="Admin Auth Key that has rights to View Roles">


	 </cffunction>


</cfcomponent>
