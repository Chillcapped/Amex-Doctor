<cfcomponent>
	
	
	<!--- Is Valid Patient ID --->
	<cffunction name="isValidPatientID" returnType="string" returnFormat="plain" access="public" hint="Returns boolean if Patient ID is valid">
		<cfargument name="patientID" type="numeric" required="true">
		
		<cfquery name="checkID" datasource="#application.contetDB#">
			select patientID
			from patients where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
		</cfquery>
		
		<cfif checkID.recordCount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
			
	<!--- is Authorized for patient accesss --->
	<cffunction name="isAuthorizedForPatientAccess" returnType="string" returnformat="plain" access="public" hint="Returns boolean if user is authorized to access patient information">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="patientID" type="numeric" required="true">
		
		<cfquery name="checkAuthorized" datasource="#application.contentDB#">
			select patientID
			from patients
			inner join doctors on patients.doctorID = doctors.doctorID
			where salesRep = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#" > 
			and patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
			or doctors.doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#" > 
			and patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
		</cfquery>
		
		<cfif checkAuthorized.recordCount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- Get Patient INfo --->
	<cffunction name="getPatientInfo" access="public" hint="Returns Info about a specified patient">
		<cfargument name="patientID" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">	
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" default="false" type="string">
		
		<!--- Roles that bypass check for patient access --->
		<cfset authorizedRoles = "Pharmacist,Tech,Admin">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		
		
		<!--- Get Token Owner --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
		
		<cfif tokenOwner.status>
			<cfset result.status = true>
		<cfelse>	
			<cfset result.message = "Invalid Auth Token">
		</cfif>
		
		
		<!--- If token is not Tech,Pharm or Admin, Check that token can access user --->
		<cfif result.status>
			<cfinvoke component="patients" method="isAuthorizedForPatientAccess" returnVariable="AuthorizedForPatient" > 
				<cfinvokeargument name="patientID" value="#arguments.patientID#">
				<cfinvokeargument name="userID" value="#tokenOwner.userID#">
			</cfinvoke>
			
			<cfif !authorizedForPatient>
				<cfset result.status = false>
				<cfset result.message = "User not Authorized to View Patient Info">
			</cfif>
		</cfif>
		
		
		<!--- If we can pull Patient Info --->
		<cfif result.status>
			
			<cfquery name="basicInfo" datasource="#application.contentDB#">
				select *
				from patients
				where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
			</cfquery>
			
			<cfquery name="addresses" datasource="#application.contentDB#">
				select *
				from patients_address
				where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
			</cfquery>
			
			<cfquery name="insuranceInfo" datasource="#application.contentDB#">
				select *
				from patients_insurance
				where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
			</cfquery>
			
			<cfset result.patient = structNew()>
			<cfset result.patient.address = structNew()>
			<cfset result.patient.insurance = structNew()>
			
			<cfloop query="basicInfo">
				<cfloop list="#basicInfo.columnList#" index="i">
					<cfset result.patient[i] = basicInfo[i][basicInfo.currentRow]>
				</cfloop>
			</cfloop> 
			
			<cfloop query="addresses">
				<cfset result.patient.address[addresses.addressID] = structNew()>
				<cfloop list="#addresses.columnList#" index="i">
					<cfset result.patient.address[addresses.addressID][i] = addresses[i][addresses.currentRow]>
				</cfloop>
			</cfloop>
			
			<cfloop query="insuranceInfo">
				<cfset result.patient.insurance[insuranceInfo.patientInsuranceID] = structNew()>
				<cfloop list="#insuranceInfo.columnList#" index="i">
					<cfset result.patient.insurance[insuranceInfo.patientInsuranceID][i] = insuranceInfo[i][insuranceInfo.currentRow]>	
				</cfloop>
			</cfloop>
			
			<cfloop collection="#result.patient.insurance#" item="i">
				<cfif !structKeyExists(result.patient, "primaryInsurance")> 
					<cfset result.patient["primaryInsurance"] = i>
				<cfelseif result.patient.insurance[i].primary EQ 1>
					<cfset result.patient["primaryInsurance"] = i>
				</cfif>
			</cfloop>
			
			<cfif structCount(result.patient.address)>
				<cfloop collection="#result.patient.address#" item="i">
					<cfif !structKeyExists(result.patient, "primary#result.patient.address[i].addresstype#")>
						<cfset result.patient["primary#result.patient.address[i].addresstype#"] = i>
					<cfelseif result.patient.address[i].primary EQ 1>	
						<cfset result.patient["primary#result.patient.address[i].addresstype#"] = i>
					</cfif>
				</cfloop>
			</cfif>
			
		</cfif>
		
		
		<cfif arguments.returnType EQ "json">	
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>	
	</cffunction>
	
	
	
	<!--- Create New Patient --->
	<cffunction name="createPatient" access="remote" returnFormat="plain" hint="creates a new patient record for a doctor" > 
		<cfargument name="doctorID" type="numeric" default="0" hint="Required IF user creating patient isnt a doctor">
		<cfargument name="generalInfo" type="struct" required="true">	
		<cfargument name="shippingAddress" type="struct" required="true">	
		<cfargument name="billingAddress" type="struct" required="true">	
		<cfargument name="insurance" type="struct" required="true">	
		<cfargument name="enc" type="string" required="true">	
		<cfargument name="authToken" type="string" required="true">	
		<cfargument name="returnType" type="string" default="json">		
		
		<cfset result = structNew()>
		<cfset result.status = true>	
			
		<cfset doctorList = "Doctor,Doctor-Delegate">	
		
		<cfif !isValid("date", arguments.generalInfo.dob)>
			<cfset result.status = false>
			<cfset result.message = "Invalid Patient Date of Birth">		
		</cfif>
			
		<cfif !isValid("email", arguments.generalInfo.email)>
			<cfset result.status = false>
			<cfset result.message = "Invalid Email">		
		</cfif>
		
		<cfif result.status and len(arguments.generalInfo.email) EQ 0 or result.status and !isValid("email", arguments.generalInfo.email)>
			<cfset result.status = false>
			<cfset result.message = "Patient Email is Required">	
		</cfif>	
		
		<cfif len(arguments.generalInfo.ssn) EQ 0 and result.status>
			<cfset result.status = false>
			<cfset result.message = "Patient Social Security Number is Required">	
		</cfif>
			
		
		<cfif result.status>
			
			<!--- Get Token Owner --->
			<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
				<cfinvokeargument name="token" value="#arguments.authToken#">
				<cfinvokeargument name="enc" value="#arguments.enc#">
			</cfinvoke>
			
			
			<cfif tokenOwner.status>
				<cfif application.roles[tokenOwner.role].name EQ "doctor">
					<cfset doctorID = tokenOwner.userID>
				<cfelseif  application.roles[tokenOwner.role].name EQ "doctor-delegate">	
					<cfset doctorID = tokenOwner.doctorID>
				<cfelse>
					<cfif arguments.doctorID NEQ 0>
						<cfset doctorID = arguments.doctorID>
					<cfelse>
						<cfset result.status = false>
						<cfset result.message = "Doctor ID is required">
					</cfif>
				</cfif>
			<cfelse>
				<cfset result.status = false>
				<cfset result.message = "Invalid Token">
			</cfif>	
		</cfif>			
		
		
		<cfif result.status>
				<!--- Set DOB Vars --->
				<cfset dMonth = month(arguments.generalInfo.dob)>
				<cfset dDay = day(arguments.generalInfo.dob)>
				<cfset dYear = year(arguments.generalInfo.dob)>
				
				<!--- Check that This Patient Doesnt Exist already --->
				<cfquery name="checkPatientRecs" datasource="#application.contentDB#">
					select patientID
					from patients
					where doctorID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#doctorID#"> 
					and email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.generalInfo.email#" > 
				</cfquery>
				
				<cfif checkPatientRecs.recordCount GT 0>
					<cfset result.status = false>
					<cfset result.message = "Patient already exists for this Doctor ID">
				</cfif>
				
				<cfif result.status>
					
					<!--- If we have home phone, send to formater --->
					<cfif arguments.generalInfo.homePhone NEQ "">
						<cfinvoke component="miscellaneous.Utils" method="formatPhone" returnvariable="homePhone"> 
							<cfinvokeargument name="phoneNumber" value="#arguments.generalInfo.homePhone#">
						</cfinvoke>
						<cfset arguments.generalInfo.homePhone = homePhone>
					</cfif>
					
					<!--- If we have mobile phone, send to formater --->
					<cfif arguments.generalInfo.mobilePhone NEQ "">
						<cfinvoke component="miscellaneous.Utils" method="formatPhone" returnvariable="mobilePhone"> 
							<cfinvokeargument name="phoneNumber" value="#arguments.generalInfo.mobilePhone#">
						</cfinvoke>
						<cfset arguments.generalInfo.mobilePhone = mobilePhone>
					</cfif>
					
					<!--- Create UUID --->
					<cfset uuID = replace(createUUID(), "-", "", "all")>
						
					<!--- Encrypt SSN w/ UUID --->
					<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="ssn"> 	
						<cfinvokeargument name="info" value="#uuID#">
						<cfinvokeargument name="info2" value="#arguments.generalInfo.ssn#">
					</cfinvoke>
					
					<!--- App over Crypt --->
					<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="ssn"> 	
						<cfinvokeargument name="info" value="#application.overSalt#">
						<cfinvokeargument name="info2" value="#ssn#">
					</cfinvoke>
					
					<!--- Insert Patient --->
					<cfquery name="insertPatient" datasource="#application.contentDB#" result="createdPatient">
						insert into patients
						(doctorID, email, firstName, middleName, lastName, title, DOB_month, DOB_day, DOB_year, DOB_full, homePhone, mobilePhone, ssn, dateCreated)
						values
						(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#doctorID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.generalInfo.email#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.generalInfo.firstName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.generalInfo.middleName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.generalInfo.lastName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.generalInfo.title#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#dMonth#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#dDay#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#dYear#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#dMonth#/#dDay#/#dYear#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.generalInfo.homePhone#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.generalInfo.mobilePhone#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#SSN#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
						)
					</cfquery>
					
					<!--- Save Patient KEy --->
					<cfquery name="insertPatientKey" datasource="#application.internalDB#">
						insert into patients_keys
						(patientID, keyVal)
						values
						(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#createdPatient.generated_key#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#uuID#">)
					</cfquery>
					
					<!--- Save Insurance Info --->
					<cfif structKeyExists(arguments, "insurance") NEQ "">
						
						<!--- Lookup Carrier ID --->
						<cfinvoke component="api.insurance" method="getCarrierID" returnVariable="carrier">
							<cfinvokeargument name="name" value="#arguments.insurance.carrierName#">
							<cfinvokeargument name="returnType" value="struct">
						</cfinvoke>
						
						<cfif carrier.status>
							<cfset carrierID = carrier.carrierID>
						<cfelse>
							
							<!--- Create Carrier --->
							<cfinvoke component="api.insurance" method="createCarrier" returnVariable="carrier">
								<cfinvokeargument name="name" value="#arguments.insurance.carrierName#">
								<cfinvokeargument name="authToken" value="#arguments.authToken#">
								<cfinvokeargument name="returnType" value="struct">
								<cfinvokeargument name="enc" value="false">
							</cfinvoke>
						
							<cfset carrierID = carrier.ID>
							
						</cfif>
						
						
						<cfquery name="insertInsurance" datasource="#application.contentDB#">
							insert into patients_insurance
							(patientID, carrierID, name, groupNumber, pcnNumber, planNumber, binNumber, cardImage,
							verified, patients_insurance.primary)
							values
							(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#createdPatient.generated_key#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#carrierID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.name#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.groupNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.pcnNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.planNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.binNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.cardImage#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="0">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="1">
							)
						</cfquery>
					</cfif>
					
					<!--- Insert Shipping Address --->
					<cfif arguments.shippingAddress.address1 NEQ "">
						<cfquery name="createPrimaryAddress" datasource="#application.contentDB#">
								insert into patients_address
								(patientID, addressType, address1, address2, city, state, zip, patients_address.primary)
								values
								(
								<cfqueryparam cfsqltype="cf_sql_integer" value="#createdPatient.generated_key#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="shipping" > ,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.address1#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.address2#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.city#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.state#">,
								<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.zip#">,
								<cfqueryparam cfsqltype="cf_sql_integer" value="1">
								)
						</cfquery>
					</cfif>
					
					
					<!--- INsert Billing Address --->
					<cfif arguments.billingAddress.address1 NEQ "">
						<cfquery name="createPrimaryAddress" datasource="#application.contentDB#">
							insert into patients_address
							(patientID, addressType, address1, address2, city, state, zip, patients_address.primary)
							values
							(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#createdPatient.generated_key#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="billing" > ,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.address1#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.address2#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.city#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.state#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.zip#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="1">
							)
						</cfquery>
					</cfif>
					
					
					<!--- Get Patient INfo --->
					<cfinvoke component="api.patients" method="getPatientInfo" returnVariable="patientInfo">
						<cfinvokeargument name="patientID" value="#createdPatient.generated_key#">
						<cfinvokeargument name="authToken" value="#session.user.authToken#">
						<cfinvokeargument name="returnType" value="struct">
					</cfinvoke>
					
					<!--- Send to Elastic --->
					<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
						<cfinvokeargument name="data" value="#patientInfo.patient#">
						<cfinvokeargument name="index" value="amex">
						<cfinvokeargument name="table" value="patients">	
						<cfinvokeargument name="id" value="#createdPatient.generated_key#">
						<cfinvokeargument name="returnType" value="struct">
					</cfinvoke>
				
					<cfset action = structNew()>
					<cfset action.description = "Created Patient Record: #createdPatient.generated_key#">
					<cfset action.type = application.eventTypes['createdPatient'].id>
					<cfset action.eventGroupID = application.eventTypes['createdPatient'].eventGroupID>
					<cfset action.typeID = createdPatient.generated_key>
					<cfset action.timestamp = now()>
					
					<!--- Log Created Event --->
					<cfinvoke component="api.events" method="logEvent"	returnVariable="loggedevent">
						<cfinvokeargument name="user" value="#tokenowner#">
						<cfinvokeargument name="action" value="#action#">
						<cfinvokeargument name="authToken" value="#arguments.authToken#">
					</cfinvoke>
					
					
					<cfset result.message = "Created Patient Record">			
					
				</cfif>
			</cfif>
	
			
		<cfif arguments.returnType EQ "json">	
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>	
			
	</cffunction>
	
	
	
	<!--- Delete Patient --->
	<cffunction name="deletePatient" access="remote" returnFormat="plain" hint="Removes a Patient from patient database. Moves to archives">
		<cfargument name="patientID" type="numeric" required="true">
		
		
		
		
	
	</cffunction>
	
	
	
	<!--- Update Patient Info --->
	<cffunction name="updatePatientInfo" access="public" hint="Updates a Patients Information">
		<cfargument name="patientID" type="numeric" required="true"> 
		<cfargument name="authToken" type="string" required="true">	
		<cfargument name="returnType" type="string" default="json">		
		<cfargument name="firstName" type="string" required="true">
		<cfargument name="middleName" type="string" required="true">
		<cfargument name="lastName" type="string" required="true">
		<cfargument name="dob" type="string" required="true">
		<cfargument name="ssn" type="string" required="true">
		<cfargument name="email" type="string" required="true">
		<cfargument name="homePhone" type="string" required="true">
		<cfargument name="mobilePhone" type="string" required="true">
		<cfargument name="allergies" type="string" required="true">
	
		
		<!--- Roles that bypass check for patient access --->
		<cfset authorizedRoles = "Pharmacist,Tech,Admin">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		
		<!--- Check That DOB is Valid --->
		<cfif !isValid("date", arguments.dob)>
			<cfset result.status = false>
			<cfset result.message = "Invalid Date of Birth">
		</cfif>
		
		
		<!--- Get Token Owner --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
		
		<cfif tokenOwner.status>
			<cfset result.status = true>
		<cfelse>	
			<cfset result.message = "Invalid Auth Token">
		</cfif>
		
		<!--- If token is not Tech,Pharm or Admin, Check that token can access user --->
		<cfif result.status>
			<cfinvoke component="patients" method="isAuthorizedForPatientAccess" returnVariable="AuthorizedForPatient" > 
				<cfinvokeargument name="patientID" value="#arguments.patientID#">
				<cfinvokeargument name="userID" value="#tokenOwner.userID#">
			</cfinvoke>
			
			<cfif !authorizedForPatient>
				<cfset result.status = false>
				<cfset result.message = "User not Authorized to View Patient Info">
			</cfif>
		</cfif>
		
		
		<!--- If we can Update Patient --->
		<cfif result.status>
			
			<!--- Create Update Result Variable so we can return what happened --->
			<cfset result.updateResults = structNew()>
			<cfset result.updateResults["General"] = structNew()>
			<cfset result.updateResults["General"].status = false>
			<cfset result.updateResults["Shipping"] = structNew()>
			<cfset result.updateResults["Shipping"].status = false>
			<cfset result.updateResults["Billing"] = structNew()>
			<cfset result.updateResults["Billing"].status = false>
			<cfset result.updateResults["Insurance"] = structNew()>
			<cfset result.updateResults["Insurance"].status = false>
			
			<cfset dobMonth = month(arguments.dob)>
			<cfset dobYear = year(arguments.dob)>
			<cfset dobDay = day(arguments.dob)>
			
			<!--- Get Patient Key --->
			<cfinvoke component="api.authorize" method="getKey" returnVariable="patientKey">
				<cfinvokeargument name="id" value="#arguments.patientID#">
				<cfinvokeargument name="type" value="patient">
			</cfinvoke>
			
			<!--- Encrypt SSN --->
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="ssn"> 	
				<cfinvokeargument name="info" value="#patientKey#">
				<cfinvokeargument name="info2" value="#arguments.ssn#">
			</cfinvoke>
					
			<!--- App over Crypt --->
			<cfinvoke component="miscellaneous.utils" method="enc" returnvariable="ssn"> 	
				<cfinvokeargument name="info" value="#application.overSalt#">
				<cfinvokeargument name="info2" value="#ssn#">
			</cfinvoke>
			
			
			<!--- update general --->
			<cfquery name="updatePatientGeneral" datasource="#application.contentDB#">
				update patients
				set email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#"> ,
					firstName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.firstName#">,
					middleName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.middleName#">,
					lastName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lastName#">,
					title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.title#">,
					dob_month = <cfqueryparam cfsqltype="cf_sql_integer" value="#dobMonth#">,
					dob_year  =  <cfqueryparam cfsqltype="cf_sql_integer" value="#dobYear#">,
					dob_full =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.dob#">,
					homePhone =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.homePhone#">,
					mobilePhone =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mobilePhone#">,
					ssn =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ssn#">,
					lastUpdate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#"> 
				where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
			</cfquery> 
			
			<cfset result.updateResults["General"].status = true>
			<cfset result.updateResults["General"].message = "Updated General information">	
			
		<!--- If we are Updating Insurance --->
		<cfif structKeyExists(arguments, "insurance")>	
			
			<!--- Lookup Carrier ID --->
			<cfinvoke component="api.insurance" method="getCarrierID" returnVariable="carrier">
				<cfinvokeargument name="name" value="#arguments.insurance.carrierName#">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>
			
			<cfif carrier.status>
				<cfset carrierID = carrier.carrierID>
			<cfelse>
				
				<!--- Create Carrier --->
				<cfinvoke component="api.insurance" method="createCarrier" returnVariable="carrier">
					<cfinvokeargument name="name" value="#arguments.insurance.carrierName#">
					<cfinvokeargument name="authToken" value="#arguments.authToken#">
					<cfinvokeargument name="returnType" value="struct">
					<cfinvokeargument name="enc" value="false">
				</cfinvoke>
			
				<cfset carrierID = carrier.ID>
				
			</cfif>
			
			<!--- If primary isnt set, default to true --->
			<cfif !structKeyExists(arguments.insurance, "primary")>
				<cfset arguments.insurance.primary = true>
			</cfif>
			
			
			<!--- If we have Insurance ID in Form, we are updating this record --->
			<cfif structKeyExists(arguments.insurance, "insuranceID")>
					<!--- Check That Insurance Record Is Valid --->
					<cfquery name="checkInsuranceID" datasource="#application.contentDB#">
						select patientInsuranceID
						from patients_insurance
						where patientInsuranceID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.insurance.insuranceID#"> 
						and patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
					</cfquery>
				
					<cfif checkInsuranceID.recordCount>
						<!--- Update Insurance --->
						<cfquery name="updateInsurance" datasource="#application.contentDB#">
							update patients_insurance
							set carrierID = <cfqueryparam cfsqltype="cf_sql_integer" value="#carrierID#">,
								name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.name#">,
								groupNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.groupNumber#">,
								pcnNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.pcnNumber#">,
								planNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.planNumber#">,
								binNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.binNumber#">,
								cardImage = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.cardImage#">,
								verified = "0",
								<cfif arguments.insurance.primary>
									primary = 1
								<cfelse>
									primary = 0	
								</cfif>
							where patientInsuranceID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.insurance.tInsuranceID#"> 
							and patientID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
						</cfquery>		
						
						<cfset result.updateResults["Insurance"].status = true>
						<cfset result.updateResults["Insurance"].message = "Updated Insurance information">	
					<cfelse>	
						<cfset result.updateResults["Insurance"].message = "Failed to Find Supplied Insurance Record">
					</cfif>
					
			<!--- If no Insurance ID in Form --->
			<cfelse>
			
					<!--- Check if Primary Insurance Exists --->
					<cfquery name="checkExisting" datasource="#application.contentDB#">
						select patientInsuranceID
						from patients_insurance
						where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
						and patients_insurance.primary = 1
					</cfquery>
					
					<!--- If we have primary insurance, update it --->
					<cfif checkExisting.recordCount>
						
						<!--- Update Insurance --->
						<cfquery name="updateInsurance" datasource="#application.contentDB#">
							update patients_insurance
							set carrierID = <cfqueryparam cfsqltype="cf_sql_integer" value="#carrierID#">,
								name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.name#">,
								groupNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.groupNumber#">,
								pcnNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.pcnNumber#">,
								planNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.planNumber#">,
								binNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.binNumber#">,
								cardImage = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.cardImage#">,
								verified = "0",
								<cfif arguments.insurance.primary>
									patients_insurance.primary = 1
								<cfelse>
									patients_insurance.primary = 0	
								</cfif>
							where patientInsuranceID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkExisting.patientInsuranceID#"> 
						</cfquery>		
						
						<cfset result.updateResults["Insurance"].status = true>
						<cfset result.updateResults["Insurance"].message = "Updated Primary Insurance information">	
					<!--- if no primary insurance, Create Insurance Rec --->	
					<cfelse>
						
						<cfquery name="insertInsurance" datasource="#application.contentDB#">
							insert into patients_insurance
							(patientID, carrierID, name, groupNumber, pcnNumber, planNumber, binNumber, cardImage,
							verified, patients_insurance.primary)
							values
							(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#carrierID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.name#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.groupNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.pcnNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.planNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.binNumber#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.insurance.cardImage#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="0">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="1">
							)
						</cfquery>
						
						<cfset result.updateResults["Insurance"].status = true>
						<cfset result.updateResults["Insurance"].message = "Created Primary Insurance information">		
					</cfif>	
				</cfif>
			<!--- End of If Updating Insurance --->
		</cfif>
		
				
		<!--- If we are Updating Shipping Information --->
		<cfif structKeyExists(arguments, "shippingAddress")>		
					
				
			<cfif !structKeyExists(arguments.shippingAddress, "primary")>	
				<cfset arguments.shippingAddress.primary = true>
			</cfif>
			
			<!--- If we have the address ID in arguments --->
			<cfif structKeyExists(arguments.shippingAddress, "addressID")>
				
				<!--- Check if Shipping Address Exists --->		
				<cfquery name="checkAddressID" datasource="#application.contentDB#">
					select addressID, patients_address.primary
					from patients_address
					where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
					and addressID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.shippingAddress.addressID#"> 
				</cfquery>
				
				<!--- If shipping address is found, ---->
				<cfif checkAddressID.recordCount>
					
					<!--- If primary status has changed for this address,  update old to non primary --->
					<cfif checkAddressId.primary NEQ arguments.shippingAddress.primary>
						<!--- Update shipping info --->
						<cfquery name="updateShippingPrimary" datasource="#application.contentDB#">
							update patients_address
							set patients_address.primary = 0	
							where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
							and addressType = <cfqueryparam cfsqltype="cf_sql_varchar" value="Shipping"> 
						</cfquery>
					</cfif>
					
					<!--- Update shipping info --->
					<cfquery name="updateShippingInfo" datasource="#application.contentDB#">
						update patients_address
						set address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.address1#">,
							address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.address2#">,
							city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.city#">,
							state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.state#">,
							zip =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.zip#">
							<cfif arguments.shippingAddress.primary>
									patients_address.primary = 1
							<cfelse>
									patients_address.primary = 0	
							</cfif>
						where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
						and addressID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.shippingAddress.addressID#"> 
					</cfquery>
					
					<cfset result.updateResults["Shipping"].status = true>
					<cfset result.updateResults["Shipping"].message = "Updated Shipping Information">		
				<cfelse>	
					<cfset result.updateResults["Shipping"].message = "Failed to Find Supplied Address">	
				</cfif> 
			<!--- If we dont have address ID --->	
			<cfelse>	
				
					<!--- Check if Primary Address Exists --->
					<cfquery name="checkExisting" datasource="#application.contentDB#">
						select addressID
						from patients_address
						where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
						and patients_address.primary = 1
					</cfquery>
					
					<!--- If we have Primary Address, we are going to update it with submitted info --->
					<cfif checkExisting.recordCount>
						<cfquery name="updateExisting" datasource="#application.contentDB#">
							update patients_address
							set address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.address1#">,
								address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.address2#">,
								city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.city#">,
								state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.state#">,
								zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.zip#">
							where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
							and addressID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkExisting.addressID#"> 
						</cfquery>
						<cfset result.updateResults["Shipping"].status = true>
						<cfset result.updateResults["Shipping"].message = "Updated Primary Shipping Information">	
					<!--- If we dont have primary address, create it --->
					<cfelse>
						<cfquery name="createPrimaryAddress" datasource="#application.contentDB#">
							insert into patients_address
							(patientID, addressType, address1, address2, city, zip, state, patients_address.primary)
							values
							(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="shipping" > ,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.address1#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.address2#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.city#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.zip#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.shippingAddress.state#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="1">
							)
						</cfquery>
						<cfset result.updateResults["Shipping"].status = true>
						<cfset result.updateResults["Shipping"].message = "Created Primary Shipping Information">
					</cfif>
			</cfif>
		</cfif>
		<!--- End of Shipping Info --->
		
		<!--- If we are Updating billing Information --->	
		<cfif structKeyExists(arguments, "billingAddress")>
				
			<cfif !structKeyExists(arguments.billingAddress, "primary")>	
				<cfset arguments.billingAddress.primary = true>
			</cfif>
			
			<!--- If we have the address ID in arguments --->
			<cfif structKeyExists(arguments.billingAddress, "addressID")>
				<!--- Check if billing Address Exists --->		
				<cfquery name="checkAddressID" datasource="#application.contentDB#">
					select addressID, patients_address.primary
					from patients_address
					where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
					and addressID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.billingAddress.addressID#"> 
				</cfquery>
				<!--- If billing address is found, ---->
				<cfif checkAddressID.recordCount>
					
						<!--- If primary status has changed for this address,  update old to non primary --->
					<cfif checkAddressId.primary NEQ arguments.billingAddress.primary>
						<!--- Update shipping info --->
						<cfquery name="updateBillingPrimary" datasource="#application.contentDB#">
							update patients_address
							set patients_address.primary = 0	
							where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
							and addressType = <cfqueryparam cfsqltype="cf_sql_varchar" value="Billing"> 
						</cfquery>
					</cfif>
					
					<!--- Update billing info --->
					<cfquery name="updatebillingInfo" datasource="#application.contentDB#">
						update patients_address
						set address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.address1#">,
							address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.address2#">,
							city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.city#">,
							state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.state#">,
							zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.zip#">
							<cfif arguments.billingAddress.primary>
									patients_address.primary = 1
							<cfelse>
									patients_address.primary = 0	
							</cfif>
						where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
						and addressID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.billingAddress.addressID#"> 
					</cfquery>
					<cfset result.updateResults["Billing"].status = true>
					<cfset result.updateResults["Billing"].message = "Updated Billing Information">
				</cfif> 
			<!--- If we dont have address ID --->	
			<cfelse>	
					<!--- Check if Primary Address Exists --->
					<cfquery name="checkExisting" datasource="#application.contentDB#">
						select addressID
						from patients_address
						where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
						and addressType = <cfqueryparam cfsqltype="cf_sql_varchar" value="Billing"> 
						and patients_address.primary = 1
					</cfquery>
					
					<!--- If we have Primary Address, we are going to update it with submitted info --->
					<cfif checkExisting.recordCount>
						
						<cfquery name="updateExisting" datasource="#application.contentDB#">
							update patients_address
							set address1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.address1#">,
								address2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.address2#">,
								city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.city#">,
								state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.state#">,
								zip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.zip#">
							where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#" > 
							and addressID = <cfqueryparam cfsqltype="cf_sql_integer" value="#checkExisting.addressID#"> 
						</cfquery>
						<cfset result.updateResults["Billing"].status = true>
						<cfset result.updateResults["Billing"].message = "Updated Primary Billing Information">
					<!--- If we dont have primary address, create it --->
					<cfelse>
						<cfquery name="createPrimaryAddress" datasource="#application.contentDB#">
							insert into patients_address
							(patientID, addressType, address1, address2, city, state, zip, patients_address.primary)
							values
							(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="billing" > ,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.address1#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.address2#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.city#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.state#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billingAddress.zip#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="1">
							)
						</cfquery>
						<cfset result.updateResults["Billing"].status = true>
						<cfset result.updateResults["Billing"].message = "Created Primary Billing Information">
					</cfif>
			</cfif>
			
		</cfif>
		<!-- End of Billing Info --->
	</cfif>	
		
		<!--- Send Updated Patient info to Elastic --->
		<cfif result.status>
		
			<!--- Get Patient INfo --->
			<cfinvoke component="api.patients" method="getPatientInfo" returnVariable="patientInfo">
				<cfinvokeargument name="patientID" value="#arguments.patientID#">
				<cfinvokeargument name="authToken" value="#session.user.authToken#">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>
			
			<!--- Send to Elastic --->
			<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
				<cfinvokeargument name="data" value="#patientInfo.patient#">
				<cfinvokeargument name="index" value="amex">
				<cfinvokeargument name="table" value="patients">	
				<cfinvokeargument name="id" value="#arguments.patientID#">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>
			
			<cfset action = structNew()>
			<cfset action.description = "Updated Information for Patient: #arguments.firstName# #arguments.lastName#">
			<cfset action.type = application.eventTypes['updatedPatient'].id>
			<cfset action.eventGroupID = application.eventTypes['updatedPatient'].eventGroupID>
			<cfset action.typeID = arguments.patientID>
			<cfset action.timestamp = now()>
			
			<!--- Log Created Event --->
			<cfinvoke component="api.events" method="logEvent"	returnVariable="loggedevent">
				<cfinvokeargument name="user" value="#tokenowner#">
				<cfinvokeargument name="action" value="#action#">
				<cfinvokeargument name="authToken" value="#arguments.authToken#">
			</cfinvoke>
	
		</cfif>
		
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	
	<!--- Create New patient Address --->
	<cffunction name="createPatientAddress" access="remote" returnFormat="plain" hint="Creates an Address Record for a patient.">
		<cfargument name="doctorID" type="numeric" required="true"> 
		<cfargument name="patientID" type="numeric" required="true"> 
		<cfargument name="addressType" type="string" required="true" > 
		<cfargument name="address1" type="string" required="true">
		<cfargument name="address2" type="string" default="">
		<cfargument name="zip" type="string" required="true">
		<cfargument name="city" type="string" required="true">
		<cfargument name="state" type="string" required="true">
		<cfargument name="country" type="string" default="US">
		<cfargument name="authToken" type="string" required="true">	
		<cfargument name="returnType" type="string" default="json">	
		
		
		<cfset result = structNew()>
		<cfset result.status = true>
		
		
		<cfif len(arguments.address1) EQ 0>
			<cfset result.status = false>
			<cfset result.message = "Address is required">
		</cfif>
		
		<cfif len(arguments.zip) EQ 0>
			<cfset result.status = false>
			<cfset result.message = "Zip is required">
		</cfif>
		
		<cfif len(arguments.city) EQ 0>
			<cfset result.status = false>
			<cfset result.message = "City is required">
		</cfif>
		
		<cfif len(arguments.state) EQ 0>
			<cfset result.status = false>
			<cfset result.message = "State is required">
		</cfif>
			
		<cfif len(arguments.country) EQ 0>
			<cfset result.status = false>
			<cfset result.message = "Country is required">
		</cfif>		
		
		<cfif result.status>
			<!--- Check if DoctorID and Auth Token Matches --->
			<cfinvoke scomponent="api.authorize" method="isValidToken" returnVariable="validToken">
				<cfinvokeargument name="userID" value="#arguments.doctorID#">
				<cfinvokeargument name="type" value="doctor">
				<cfinvokeargument name="authToken" value="#arguments.authToken#">
			</cfinvoke>
		
			<!--- Token not valid --->
			<cfif !validToken>
				<cfset result.message = "Invalid Auth Token">
				<cfset result.status = false>
			
			<!--- Token is valid --->
			<cfelse>
				
				<!---  Get That Patient ID exists and is a patient of this doctor --->
				<cfinvoke component="api.doctor" method="isDoctorsPatient" returnVariable="validPatient">
					<cfinvokeargument name="patientID" value="#arguments.patientID#">
					<cfinvokeargument name="doctorID" value="">
				</cfinvoke>
				
				<cfif !validPatient>
					<cfset result.message = "Patient is not linked to this Doctor">
					<cfset result.status = false>
				</cfif>
			</cfif>	
			
		</cfif>
		
	
			<!--- If this is a valid submission, insert the patient address --->
			<cfif result.status>
				
				<!--- Check if patient has other addresses. If they do, this wont be the primary address --->
				<cfquery name="currentAddressRecs" datasource="#application.contentDB#">
					select addressID
					from patients_address
					where patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
				</cfquery>
				
				<cfif currentAddressRecs.recordCount EQ 0>
					<cfset primary = 1>
				<cfelse>
					<cfset primary = 0>
				</cfif>
				
				<cfset coords = "">
				
				
				<cfquery name="insertAddress" datasource="#application.contentDB#">
					insert into patients_address
					( patientID, addressType, address1, address2, city, state, country, primary)
					values
					(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.addressType#">, 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.address1#">, 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.address2#">, 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.city#">, 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.state#">, 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.country#">, 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#primary#">, 
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#coords#">, 
					)
				</cfquery>
				
				<cfset result.message = "Created Address Record">
				
			</cfif>
	
	
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	
	
	
	
	
	<!--- Find Patient --->
	<cffunction name="findPatient" access="public" hint="Find a patient based on supplied search type. [name, email]">
		<cfargument name="searchBy" required="true" type="string">
		<cfargument name="searchValue" required="true" type="string">
		<cfargument name="authToken" required="true" type="string">
		<cfargument name="returnType" default="json" type="string">
		<cfargument name="enc" default="false" type="string">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset roles = "Sales,Admin,Doctor">
		<cfset result.message = "Invalid Auth Token">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
	
		<cfif tokenOwner.status>
			<cfif listFind(roles, application.roles[tokenOwner.role].name)>
				<cfset result.status = true>
				
			</cfif>
		</cfif>	
			
		<!--- If valid token --->	
		<cfif tokenOwner.status>	
			
			<!--- Find Patient --->
			<cfquery name="findPatient" datasource="#application.contentDB#">
				select patientID
				from patients
				<cfif arguments.searchBy  eq "email">
					where email = <cfqueryparam cfsqltype ="cf_sql_varchar" value="#arguments.searchValue#" > 
				<cfelseif arguments.searchBy EQ "name">
					where CONCAT(firstName, ' ', lastName)  = <cfqueryparam cfsqltype ="cf_sql_varchar" value="#arguments.searchValue#" > 	
				<cfelseif arguments.searchBy EQ "lastName">
					where lastName = <cfqueryparam cfsqltype ="cf_sql_varchar" value="#arguments.searchValue#" > 	
				</cfif>
			</cfquery>
			<!--- If no patient found --->
			<cfif !findPatient.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Patient not found">
			</cfif>	
			
			<!--- If we have patient --->
			<cfif result.status>
				<!--- Get Patient Info --->
				<cfinvoke component="api.patients" method="getPatientINfo" returnVariable="patientInfo">
					<cfinvokeargument name="patientID" value="#findPatient.patientID#">
					<cfinvokeargument name="enc" value="#arguments.enc#">
					<cfinvokeargument name="returnType" value="struct">
					<cfinvokeargument name="authToken" value="#arguments.authToken#">
				</cfinvoke>
				
				<cfif patientInfo.status>
					<cfset result.patient = structCopy(patientINfo.patient)>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- Return --->
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	

	
</cfcomponent>