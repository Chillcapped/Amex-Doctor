<cfcomponent>

	<!---- Component Handles authorizing

			Functions

			1. isValidToken
			2. getTokenOwner
			3. isRoleToken
	---->


	<!--- Validate Auth Token --->
	<cffunction name="isValidToken" access="public" returnType="string" hint="Returns boolean if auth token is valid. Pass userID and type to check if userID and token match">
		<cfargument name="token" type="string" required="true">
		<cfargument name="userID" type="numeric" hint="If supplied, userID must match token">
		<cfargument name="type" type="string" hint="Type of token">
		<cfargument name="enc" type="string" default="true" hint="If function should enc auth token to check for match. But if we are already passing an encrypted token, we dont need to re-encrypt it">

		<cfif arguments.token EQ "">
			<cfreturn false>
		</cfif>

		<cfif cgi.server_name EQ "amex.rxportal.io">
			<cfset arguments.type = "amex">
		<cfelseif cgi.server_name EQ "md.rxportal.io">
			<cfset arguments.type = "doctor">
		<cfelseif cgi.server_name EQ "sales.rxportal.io">
			<cfset arguments.type = "sales">
		</cfif>

		<!--- If we are encrypting --->
		<cfif arguments.enc>
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="authToken">
				<cfinvokeargument name="info" value="#arguments.token#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>
		<cfelse>
			<Cfset authToken = arguments.token>
		</cfif>

		<cfif arguments.type EQ "amex" or arguments.type EQ "sales">
			<cfquery name="checkToken" datasource="#application.contentDB#">
				select userID
				from users
				where lower(authToken) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(authtoken)#">
				<cfif structKeyExists(arguments, "userID")>
					and userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
				</cfif>
			</cfquery>
		<cfelseif  arguments.type EQ "doctor">
			<cfquery name="checkToken" datasource="#application.contentDB#">
				select doctorID
				from doctors
				where lower(authToken) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(authtoken)#">
				<cfif structKeyExists(arguments, "userID")>
					and doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
				</cfif>
			</cfquery>
		<cfelseif  arguments.type EQ "delegate">
			<cfquery name="checkToken" datasource="#application.contentDB#">
				select delegateID
				from doctors_delegates
				where lower(authToken) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(authtoken)#">
				<cfif structKeyExists(arguments, "userID")>
					and doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
				</cfif>
			</cfquery>
		</cfif>

		<cfif checkToken.recordCount GT 0>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>



	</cffunction>


	<!--- Get a Token Owners User ID --->
	<cffunction name="getTokenOwner" access="public" hint="Returns userID of token owner. Returns 0 if invalid token">
		<cfargument name="token" type="string" required="true">
		<cfargument name="enc" type="string" default="true" hint="If function should enc auth token to check for match. But if we are already passing an encrypted token, we dont need to re-encrypt it">


		<cfset result = structNew()>
		<cfif arguments.token EQ "">
			<cfset result.status = false>
		</cfif>

		<cfif arguments.enc>
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="authToken">
				<cfinvokeargument name="info" value="#arguments.token#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>
		<cfelse>
			<cfset authToken = arguments.token>
		</cfif>

		<cfquery name="checkToken" datasource="#application.contentDB#">
			select userID, userRole, email
			from users
			where lower(authToken) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(authtoken)#">
		</cfquery>

		<cfif checkToken.recordCount EQ 0>
			<cfquery name="checkToken" datasource="#application.contentDB#">
				select doctorID, '4' as userRole, email, doctorID as userID
				from doctors
				where lower(authToken) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(authtoken)#">
			</cfquery>
		</cfif>

		<cfif checkToken.recordCount EQ 0>
			<cfquery name="checkToken" datasource="#application.contentDB#">
				select delegateID, '5' as userRole, email, delegateID as userID, doctorID
				from doctors_delegates
				where lower(authToken) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(authtoken)#">
			</cfquery>
		</cfif>

		<cfif checkToken.recordCount Gt 0>
			<cfset result.status = true>
			<cfset result.userID = checkToken.userID>
			<cfset result.role = checkToken.userRole>
			<cfif structKeyExists(checkToken, "doctorID")>
				<cfset result.doctorID = checkToken.doctorID>
			</cfif>
			<cfset result.email = checkToken.email>
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "User not found with that token">
		</cfif>

		<cfreturn result>
	</cffunction>


	<!--- Check if Token owner is in specific security role --->
	<cffunction name="isRoleToken" access="public" hint="Returns boolean based on if auth token has requested role privledges">
		<cfargument name="token" type="string" required="true">
		<cfargument name="role" type="string" required="true" hint="Sales,Admin,Tech,Doctor etc">
		<cfargument name="enc" type="string" default="true" hint="If function should enc auth token to check for match. But if we are already passing an encrypted token, we dont need to re-encrypt it">

		<!--- Get Role ID --->
		<cfloop collection="#application.roles#" item="i">
			<cfif application.roles[i].name EQ arguments.role>
				<cfset roleID = application.roles[i].roleID>
			</cfif>
		</cfloop>

		<cfif arguments.enc>
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="authToken">
				<cfinvokeargument name="info" value="#arguments.token#">
				<cfinvokeargument name="info2" value="#application.oversalt#">
			</cfinvoke>
		<cfelse>
			<cfset authToken = arguments.token>
		</cfif>

		<!--- If we got back a role ID, check if token and role match --->
		<cfif roleID NEQ 0>
			<cfif arguments.role EQ "Doctor">
				<cfquery name="checkToken" datasource="#application.contentDB#">
					select doctorID
					from doctors
					where authToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#authtoken#">
				</cfquery>

				<cfif checkToken.recordCount GT 0>
					<cfreturn true>
				<cfelse>
					<cfreturn false>
				</cfif>

			<cfelseif arguments.role EQ "Delegate">

				<cfquery name="checkToken" datasource="#application.contentDB#">
					select delegateID
					from doctors_delegates
					where authToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#authtoken#">
				</cfquery>
				<cfif checkToken.recordCount GT 0>
					<cfreturn true>
				<cfelse>
					<cfreturn false>
				</cfif>

			<cfelse>

				<cfquery name="checkToken" datasource="#application.contentDB#">
					select userID
					from users
					where authToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#authtoken#">,
					and userRole = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.role#">
				</cfquery>
				<cfif checkToken.recordCount GT 0>
					<cfreturn true>
				<cfelse>
					<cfreturn false>
				</cfif>
			</cfif>

		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>



	<!--- Login user to Application --->
	<cffunction name="loginUser" access="public" hint="Logs a user into the application">
		<cfargument name="userName" type="string" required="true" hint="Email of User">
		<cfargument name="password" type="string" hint="Password to login">
		<cfargument name="applicationToken" type="string" hint="Token to make sure we are coming from a valid application">
		<cfargument name="userType" type="string" default="doctor" hint="Type of doctor logging in">

		<cfset resultStruct = structNEw()>
		<cfset resultStruct.status = true>

		<cfif cgi.server_name EQ "amex.rxportal.io">
			<cfset arguments.userType = "amex">
		<cfelseif cgi.server_name EQ "md.rxportal.io">
			<cfset arguments.userType = "doctor">
		<cfelseif cgi.server_name EQ "sales.rxportal.io">
			<cfset arguments.userType = "sales">
		<cfelse>
			<cfset resultstruct.status = false>
			<cfset resultstruct.message = "Domain name not recognized as valid application">
		</cfif>


		<!--- If User Type is Amex, Check  Employee DB --->
		<cfif arguments.userType EQ "Amex">
			<!--- Check User DB --->
			<cfquery name="getUsers" datasource="amex">
				select firstName, lastName, users.userID, users.email, users.authToken, users.password, userRole from users
				left join users_info on users.userID = users_info.userID
				where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.userName)#">
				AND userRole IN ('1','2','6')
			</cfquery>

			<cfif getUsers.recordCount>
				<cfset result.userID = getUsers.userID>
				<cfset result.authToken = getUsers.authTOken>
				<cfset result.firstName =  getUsers.firstName>
				<cfset result.roleID =  getUsers.userRole>
				<cfset result.email = getUsers.email>
				<cfset result.lastName =  getUsers.lastName>
				<cfset passHash = getUsers.password>
				<cfset result.accountType = "user">
				<cfset result.role = application.roles[result.roleID].name>




			<cfelse>
				<cfset resultstruct.status = false>
				<cfset resultstruct.message = "Invalid Username or Password">
			</cfif>
		</cfif>


		<!--- If Sales User --->
		<cfif arguments.userType EQ "sales">
			<!--- Check User DB --->
			<cfquery name="getUsers" datasource="amex">
				select firstName, lastName, users.userID, users.email, users.authToken, users.password, userRole from users
				left join users_info on users.userID = users_info.userID
				where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.userName)#">
				AND userRole = 3
			</cfquery>
			<cfif getUsers.recordCount>
				<cfset result.userID = getUsers.userID>
				<cfset result.authToken = getUsers.authTOken>
				<cfset result.firstName =  getUsers.firstName>
				<cfset result.roleID =  getUsers.userRole>
				<cfset result.email = getUsers.email>
				<cfset result.lastName =  getUsers.lastName>
				<cfset passHash = getUsers.password>
				<cfset result.accountType = "user">
				<cfset result.role = application.roles[result.roleID].name>
			<cfelse>
				<cfset resultstruct.status = false>
				<cfset resultstruct.message = "Invalid Username or Password">
			</cfif>
		</cfif>
		<!--- If User Type is doctor, Check Doctor --->
		<cfif arguments.userType EQ "doctor">
				<!--- Check Doctor DB --->
				<cfquery name="getDoctors" datasource="#application.contentDB#">
					select * from doctors
					where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.userName)#">
				</cfquery>
				<!--- If Doctor Record not found, check deligates ---->
				<cfif getDoctors.recordCount EQ 0>
					<cfquery name="getDelagetes" datasource="#application.contentDB#">
						select * from doctors_delegates
						where lower(email) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(arguments.userName)#">
					</cfquery>

					<cfif getDelagetes.recordCount GT 0>
						<cfset result.accountType = "Delegate">
						<cfset result.userID = getDelagetes.delegateID>
						<cfset result.firstName = getDelagetes.firstName>
						<cfset result.email = getDelagetes.email>
						<cfset result.lastName = getDelagetes.lastName>
						<cfset result.roleID =  6>
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
		</cfif>

		<cfif resultStruct.status>

			<!--- get Salt --->
			<cfinvoke component="authorize" method="getKey" returnvariable="userSalt">
				<cfinvokeargument name="id" value="#result.userID#">
				<cfinvokeargument name="roleID" value="#result.roleID#">
			</cfinvoke>

			<cfset result.salt = usersalt>

			<!--- Hash Submited Password --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="submittedPassword">
				<cfinvokeargument name="password" value="#arguments.password#">
				<cfinvokeargument name="salt" value="#userSalt#">
			</cfinvoke>

			<!--- Add App Salt on Top of User Salt --->
			<cfinvoke component="miscellaneous.utils" method="computeHash" returnvariable="submittedPassword">
				<cfinvokeargument name="password" value="#submittedPassword#">
				<cfinvokeargument name="salt" value="#application.overSalt#">
			</cfinvoke>

			<!--- If hashes doesnt match submitted password its not real --->
			<cfif submittedPassword NEQ passHash>
				<cfset resultStruct.status = false>
				<cfset resultStruct.message = "Invalid Username or Password">
			</cfif>
		</cfif>


		<!--- Check that IP is Valid --->
		<Cfif resultStruct.status>
			<cfif arguments.userType EQ "Amex">
				<cfif !structKeyExists(application.authorizedIPs.amexIPs, cgi.remote_addr)>
					<cfset resultstruct.status = false>
					<cfset resultstruct.message = "Invalid IP">
				</cfif>
			</cfif>
			<cfif arguments.userType EQ "sales">
				<cfif !structKeyExists(application.authorizedIPs.salesIPs, cgi.remote_addr)>
					<cfset resultstruct.status = false>
					<cfset resultstruct.message = "Invalid IP">
				</cfif>
			</cfif>
			<cfif arguments.userType EQ "doctor">
				<cfif !structKeyExists(application.authorizedIPs.doctorIPs, cgi.remote_addr)>
					<cfset resultstruct.status = false>
					<cfset resultstruct.message = "Invalid IP">
				</cfif>
			</cfif>

			<cfif !resultStruct.status>
				<cfinvoke component="authorize" method="createIPAuthorization" returnVariable="authorizeRequest">
					<cfinvokeargument name="userInfo" value="#result#">
					<cfinvokeargument name="ip" value="#cgi.remote_addr#">
				</cfinvoke>
				<cflocation url="/unrecognized">
			</cfif>
		</cfif>


		<!--- if we are still ok to login --->
		<Cfif resultStruct.status>

			<cfset resultStruct.status = true>

			<cflogin>
				<cfloginuser name="#lcase(arguments.username)#" password="#arguments.password#" roles="#result.accountType#" >
			</cflogin>

			<cfset session.failedLogins = 0>
			<cfset session.user = structCopy(result)>

			<!--- Enc Auth token with user Salt --->
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="session.user.esToken">
				<cfinvokeargument name="info" value="#session.user.authToken#">
				<cfinvokeargument name="info2" value="#session.user.salt#">
			</cfinvoke>

			<cfif result.accountType EQ "user">
				<cfset session.user.role = application.roles[result.roleID].roleid>
			<cfelse>
				<cfloop collection="#application.roles#" item="i">
					<cfif application.roles[i].name EQ result.accountType>
						<cfset session.user.role = i>
						<cfset session.user.subdomain = application.roles[i].subdomain>
						<cfbreak>
					</cfif>
				</cfloop>
			</cfif>

			<!--- Add User to currently Logged in Users --->
			<cfif structKeyExists(application, "liveUsers")>
				<cfif !structKeyExists(APPLICATION.liveUsers, getUsers.userID)>
					<cfset application.liveUsers[getUsers.userID] = structNew()>
				</cfif>
				<cfset APPLICATION.liveUsers[getUsers.userID].status = "online">
				<cfset APPLICATION.liveUsers[getUsers.userID].LastLoginTime = now()>
			</cfif>

		<!--- If failed to login --->
		<cfelse>

			<cfset resultStruct.status = false>

			<cfif structKeyExists(arguments, "applicationToken")>
				<cfset resultStruct.userToken = arguments.applicationToken>
			</cfif>
			<cfif structKeyExists(arguments, "userName")>
				<cfset resultStruct.userName = arguments.userName>
			</cfif>

			<cfif !isDefined("session.failedLogins")>
				<cfset session.failedLogins = 0>
			<cfelse>
				<cfset session.failedLogins = session.failedLogins + 1>
			</cfif>

			<!--- Send IP and Info to Logger --->

		</cfif>

		<cfreturn resultStruct>
	</cffunction>


	<!--- Check if User is in Specified Security Role --->
	<cffunction name="checkSecurityRole" returnType="string" returnFormat="plain" access="public" hint="Checks if UserID is in specified role. Admin Users return true for every role.">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="roleID" type="numeric" required="true">
		<cfquery name="getUser" datasource="#application.contentDB#">
			select userID
			from users
			where userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
			and userRole = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.roleID#">
			or userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
			and userRole = 1
		</cfquery>
		<cfif getUser.recordCount EQ 1>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

    <!--- Validate Doctor ACcess --->
	<cffunction name="validateDoctorAccess" returnFormat="plain" access="public" hint="Validates if an auth token has access to this doctor">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="doctorID" type="numeric" required="true">


	</cffunction>


	<!--- Lookup Secret Key --->
	<cffunction name="getKey" access="public" hint="Returns a users secret key">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="type" type="string" default="">
		<cfargument name="roleID" type="numeric" default="0">

		<cfset key = "">
		<cfif arguments.roleID GT 0 and arguments.type EQ "">
			<cfset arguments.type = application.roles[arguments.roleID].name>
		</cfif>

		<cfif arguments.type EQ "user" or arguments.type EQ "sales"
		or arguments.type EQ "tech" or arguments.type EQ "pharmacist"
		or arguments.type EQ "admin">
			<cfquery name="getKey" datasource="#application.internalDB#">
				select keyVal
				from users_keys
				where userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			</cfquery>
			<cfset key = getKey.keyVal>
		<cfelseif arguments.type EQ "Doctor">
			<cfquery name="getKey" datasource="#application.internalDB#">
				select keyVal
				from doctors_keys
				where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			</cfquery>
			<cfset key = getKey.keyVal>
		<cfelseif arguments.type EQ "delegate">
			<cfquery name="getKey" datasource="#application.internalDB#">
				select keyVal
				from delegate_keys
				where delegateID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			</cfquery>
			<cfset key = getKey.keyVal>
		<cfelseif arguments.type EQ "patient">
			<cfquery name="getKey" datasource="#application.internalDB#">
				select keyVal
				from patients_keys
				where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			</cfquery>
			<cfset key = getKey.keyVal>
		</cfif>
		<cfreturn key>
	</cffunction>



	<!--- Send Security Code --->
	<cffunction name="sendSecurityCode">
		<cfargument name="authToken" type="string" required="true">


		<cfreturn>
	</cffunction>


	<!--- Validate Security Response --->
	<cffunction name="validateSecurityResponse" returnType="boolean" returnFormat="plain" hint="Returns true or false if security token is authentic">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="response" type="string" required="true">

		<cfreturn true>
	</cffunction>



	<!--- Validate IP Request Token --->
	<cffunction name="validateIpRequestToken" returnFormat="plain" hint="Validates a request token for Authorizing an IP for access">
		<cfargument name="requestToken" type="string" required="true">
		<cfargument name="user" type="string" required="true">
		<cfargument name="apiKey" type="string" required="true">
		<cfargument name="returnType" default="struct" type="string">


		<!--- Get ID from User --->
		<cfinvoke component="users" method="getUserFromEmail" returnVariable="userInfo">
			<cfinvokeargument name="email" value="#arguments.user#">
			<cfinvokeargument name="returnType" value="struct">
		</cfinvoke>

		<!--- GEt User Salt --->
		<cfinvoke component="authorize" method="getKey" returnvariable="userSalt">
			<cfinvokeargument name="id" value="#userInfo.userID#">
			<cfinvokeargument name="roleID" value="#userInfo.roleID#">
		</cfinvoke>

		<!--- Decrypt Request Token with app salt --->
		<cfinvoke component="miscellaneous.utils" method="dec" returnvariable="decRequestToken">
			<cfinvokeargument name="info" value="#arguments.requestToken#">
			<cfinvokeargument name="info2" value="#application.oversalt#">
		</cfinvoke>

		<!--- Decrypt Request Token with user salt --->
		<cfinvoke component="miscellaneous.utils" method="dec" returnvariable="decRequestToken">
			<cfinvokeargument name="info" value="#decRequestToken#">
			<cfinvokeargument name="info2" value="#userSalt#">
		</cfinvoke>






		<!--- We should now have the real request token, look for match --->
		<cfquery name="checkToken" datasource="#application.internalDB#">
			select requestID, requestToken, redeemed, userID, requestIP, requestDate
			from authorize_ip_requests
			where requestToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#decRequestTOken#">
			and redeemed = 0
		</cfquery>

		<!--- If token is valid, we need to add this IP to users IP list and update IP Cache --->
		<cfif checkToken.recordCount>

			<cfif userInfo.roleID EQ 1 or userInfo.roleID EQ 2 or userInfo.roleID EQ 3
			or userInfo.roleID EQ 6>

			<!--- Check that this IP doesnt already exists --->
			<cfquery name="checkIP" datasource="#application.contentDB#">
				select ip
				from users_ip_authorized
				where userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userInfo.userID#">
				and ip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkToken.requestIP#">
			</cfquery>

				<cfif !checkIP.recordCount>
					<cfquery name="insertIp" datasource="#application.contentDB#">
						insert into users_ip_authorized
						(userID, ip, dateAdded)
						values
						(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#userInfo.userID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#checkToken.requestIP#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
						)
					</cfquery>

					<!--- Update token to redeemed --->
					<cfquery name="redeemToken" datasource="#application.internalDB#">
						update authorize_ip_requests
						set redeemed = 1,
						    redeemedAt = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						    redeemIP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.cgi.remote_addr#">
						where requestID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkToken.requestID#">
					</cfquery>

					<cfset result.status = true>
					<Cfset result.message = "IP Authorized for User">

					<cfset ipDataStruct = structNew()>
					<cfset ipDataStruct.userID = userInfo.userID>
					<cfset ipDataStruct.ip = checkToken.requestIP>
					<cfset ipDataStruct.dateAdded = now()>
					<cfset ipDataStruct.expires = 0>
					<cfset ipDataStruct.expiresAt = "">

					<cfif userInfo.roleID EQ 1 or userInfo.roleID EQ 2 or userINfo.roleID EQ 6>
						<cfset application.authorizedIps.amexIps[checkToken.requestIP] = ipDataStruct>
						<cfset result.addedTo = "amexIps">
					</cfif>
					<cfif userINfo.roleID EQ 3>
						<cfset application.authorizedIps.salesIps[checkToken.requestIP] = ipDataStruct>
						<cfset result.addedTo = "salesIps">
					</cfif>
					<cfif userInfo.roleID EQ 4 or userINfo.roleID EQ 5>
						<cfset application.authorizedIps.doctorIps[checkToken.requestIP] = ipDataStruct>
						<cfset result.addedTo = "doctorIps">
					</cfif>
				<cfelse>
					<cfset result.status = false>
					<Cfset result.message = "IP Already authorized for this User.">
				</cfif>

			<cfelse>
				<!--- Check that this IP doesnt already exists --->
				<cfquery name="checkIP" datasource="#application.contentDB#">
					select ip
					from doctors_ip_authorized
					where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userInfo.userID#">
					and ip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkToken.requestIP#">
				</cfquery>


				<cfif !checkIP.recordCount>

					<cfquery name="insertIp" datasource="#application.contentDB#">
						insert into doctors_ip_authorized
						(doctorID, ip, dateAdded)
						values
						(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#userInfo.userID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#checkToken.requestIP#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
						)
					</cfquery>

					<!--- Update token to redeemed --->
					<cfquery name="redeemToken" datasource="#application.internalDB#">
						update authorize_ip_requests
						set redeemed = 1,
						redeemedAt = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						redeemIP = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.cgi.remote_addr#">
						where requestID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#checkToken.requestID#">
					</cfquery>

					<cfset result.status = true>
					<Cfset result.message = "IP Authorized for User">

					<cfset ipDataStruct = structNew()>
					<cfset ipDataStruct.userID = userInfo.userID>
					<cfset ipDataStruct.ip = checkToken.requestIP>
					<cfset ipDataStruct.dateAdded = now()>
					<cfset ipDataStruct.expires = 0>
					<cfset ipDataStruct.expiresAt = "">

					<cfif structKeyExists(application.authorizedIps.doctorIps, checkToken.requestIP)>
						<cfset application.authorizedIps.doctorIps[checkToken.requestIP].users = listAppend(application.authorizedIps.doctorIps[checkToken.requestIP].users, userINfo.userID)>
					<cfelse>
						<cfset application.authorizedIps.doctorIps[checkToken.requestIP] = ipDataStruct>
						<cfset application.authorizedIps.doctorIps[checkToken.requestIP].users = userInfo.userID>
					</cfif>
					<cfset result.addedTo = "doctorIps">
				<cfelse>
					<cfset result.status = false>
					<Cfset result.message = "IP Already authorized for this User.">
				</cfif>


			</cfif>

		<cfelse>
			<cfset result.status = false>
			<Cfset result.message = "Request Token not Found">
		</cfif>

		<!--- Create Log that Authorize Ip Request was Invoked --->




		<!--- If Success, Add to users Timeline --->
		<cfif result.status>


		</cfif>




		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>

	<!--- Create IP Authorization Request---->
	<cffunction name="createIPAuthorization" returnFormat="plain" hint="creates new Ip Authorize Request">
		<cfargument name="userInfo" type="struct" required="true">
		<cfargument name="returnType" default="json" type="string">

		<cfset result = structNew()>
		<cfset result.status = true>

		<cfset requestToken = createUUID()>

		<!--- get Salt --->
		<cfinvoke component="authorize" method="getKey" returnvariable="userSalt">
			<cfinvokeargument name="id" value="#arguments.userInfo.userID#">
			<cfinvokeargument name="roleID" value="#arguments.userInfo.roleID#">
		</cfinvoke>

		<cfset arguments.userInfo.userSalt = userSalt>

		<!--- Log Request --->
		<cfquery name="insertLog" datasource="#application.internalDB#">
			insert into authorize_ip_requests
			(requestIP, userType, userID, requestToken, requestDate)
			values
			(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userInfo.roleID#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userInfo.userID#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#requestToken#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			)
		</cfquery>

		<!--- Encrypt Request Token --->
		<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="eToken">
			<cfinvokeargument name="info" value="#requestToken#">
			<cfinvokeargument name="info2" value="#userSalt#">
		</cfinvoke>

		<!--- Add App Salt on Top of User Salt  --->
		<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="eToken">
			<cfinvokeargument name="info" value="#eToken#">
			<cfinvokeargument name="info2" value="#application.overSalt#">
		</cfinvoke>

		<!--- Send Email --->
		<cfinvoke component="email" method="sendIpApprovalRequest" returnVariable="emailResult">
			<cfinvokeargument name="userInfo" value="#arguments.userInfo#">
			<cfinvokeargument name="requestToken" value="#eToken#">
		</cfinvoke>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>

</cfcomponent>
