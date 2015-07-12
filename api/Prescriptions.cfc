<cfcomponent>

	<!--- Is valid prescription number --->
	<cffunction name="isValidPrescriptionNumber" returnType="string" returnFormat="plain" hint="Returns boolean if supplied prescription number exists in database">
		<cfargument name="doctorID" type="numeric" required="true">
		<cfargument name="number" type="string" required="true">

		<cfquery name="checkNumber" datasource="#application.contentDB#">
			select prescriptionID
			from prescriptions
			where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
			and rxNumber = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.number#">
		</cfquery>

		<cfif checkNumber.recordCount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>


	<!--- Get Prescription Info --->
	<cffunction name="getPrescriptionInfo" access="public" hint="">
		<cfargument name="prescription" type="string" required="true">
		<cfargument name="authToken" type="string" required="true" hint="Auth Token of Doctor or Delegate Requesting Prescriptions">
		<cfargument name="returnType" type="string" default="json" hint="Format to return data">
		<cfargument name="enc" type="string" default="false" hint="If Auth token needs to be re-encrypted">
		<cfargument name="fetchFrom" type="string" default="database">

		<cfset result = structNew()>
		<cfset result.status = false>

		<cfset authorizedRoles = "Admin,Tech,Pharmacist,Doctor,Doctor-Delegate">
		<cfset noDoctorCheckRoles = "Admin,Tech,Pharmacist">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<cfif !listfind(authorizedRoles, application.roles[tokenOwner.role].name)>
			<cfset result.message = "invalid auth token">
		<cfelse>
			<cfset result.status = true>
		</cfif>

		<!--- Get Prescription --->
		<cfif result.status>
			<cfquery name="getPrescription" datasource="#application.rxDB#">
				select *
				from prescriptions
				where rxID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.prescription#">
			</cfquery>

			<cfif !getPrescription.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Prescription Not Found">
			</cfif>
		</cfif>

		<!--- If we need to make sure that doctor submited this RX --->
		<cfif !listFind(noDoctorCheckRoles, application.roles[tokenOwner.role].name)>
			<cfset result.status = false>
			<cfset result.message = "">
			<cfif application.roles[tokenOwner.role].name EQ "doctor" and getPrescription.doctorID EQ tokenOwner.userID>
				<cfset result.status = true>
			</cfif>

			<!--- If this is a doctor authorized user, make sure their  doctor is the one that create this rx --->
			<cfif application.roles[tokenOwner.role].name EQ "doctor-delegate">
				<!--- Get Delegates Doctor --->
				<cfinvoke component="api.doctor" method="getDelegetesDoctor" returnType="delegatesDoctor">
					<cfinvokeargument name="delegateID" value="#tokenOwner.userID#">
				</cfinvoke>

				<cfif delgatesDoctor EQ getPrescription.doctorID>
					<cfset result.status = true>
				</cfif>
			</cfif>
		</cfif>

		<!--- If we can return prescription --->
		<cfif result.status>

			<!--- Populate Prescription info --->
			<cfset result.prescription = structNew()>
			<cfloop list="#getPrescription.columnList#" index="i">
				<cfif i EQ "rxID">
					<cfinvoke component="api.encryption" method="encryptFormID" returnVariable="eRxID">
						<cfinvokeargument name="id"value="#getPrescription[i][1]#">
					</cfinvoke>
					<cfset result.prescription['eRxID'] = urlEncodedFormat(eRxID)>
					<cfset result.prescription[i] = getPrescription[i][1]>
				<cfelse>
					<cfset result.prescription[i] = getPrescription[i][1]>
				</cfif>
			</cfloop>

			<!--- Now we need to get Prescriptions Contents --->
			<cfquery name="getRxContents" datasource="#application.rxDB#">
				select rxMedID, rxID, drugID, prescriptions_medications.interval, name, refills, roa, type, manufacturer, dateCreated, lastUpdate, totalAmmount, dosage
				from prescriptions_medications
				where rxID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.prescription#">
			</cfquery>

			<cfset result.prescription.contents = structNew()>

			<cfset compound = 0>
			<cfloop query="getRxContents">
				<cfset result.prescription.contents[getRxContents.rxMedID] = structNew()>
				<cfloop list="#getRxContents.columnList#" index="i">
					<cfset result.prescription.contents[getRxContents.rxMedID][i] = getRxContents[i][getRxContents.currentRow]>

					<cfif getRxContents.type EQ "compound">
						<cfset compound++>
					</cfif>
				</cfloop>
			</cfloop>

			<!--- If we need to fetch ingredients --->
			<cfif compound GT 0>
				<cfquery name="getIngredients" datasource="#application.rxDB#">
					select rxIngredientID, rxID, rxMedID, rxItemID, dateCreated, name, percentage, dosage
					from prescriptions_ingredients
					where rxID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.prescription#">
				</cfquery>

				<cfloop query="getIngredients">

					<cfset result.prescription.contents[getIngredients.rxMedID].ingredients[getIngredients.rxIngredientID] = structNew()>
					<cfloop list="#getIngredients.columnList#" index="i">
						<cfset result.prescription.contents[getIngredients.rxMedID].ingredients[getIngredients.rxIngredientID][i] = getIngredients[i][getIngredients.currentRow]>
					</cfloop>
				</cfloop>
			</cfif>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>



	<!--- Get All Prescriptions --->
	<cffunction name="getAllPrescriptions" access="public" hint="">
		<cfargument name="authToken" type="string" required="true" hint="Auth Token of Doctor or Delegate Requesting Prescriptions">
		<cfargument name="returnType" type="string" default="json" hint="Format to return data">
		<cfargument name="enc" type="string" default="false" hint="If Auth token needs to be re-encrypted">
		<cfargument name="fetchFrom" type="string" default="#application.lookupMethod#">
		<cfargument name="filterBy" type="numeric" default="0">

		<cfset authorizedRoles = "Admin,Tech,Pharmacist">

		<cfset result = structNew()>
		<cfset result.status = false>

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<cfif !tokenOwner.status or !listFind(authorizedRoles, application.roles[tokenOwner.role].name)>
			<cfset result.status = false>
			<cfset result.message = "Invalid Auth Token">
		<cfelseif tokenOwner.status and listFind(authorizedRoles, application.roles[tokenOwner.role].name)>
			<cfset result.status = true>
		</cfif>

		<!--- If we can return prescriptions --->
		<cfif result.status>

			<cfif arguments.fetchFrom EQ "db">
				<cfset result.prescriptions = arrayNew(1)>
				<!--- Get Doctors Prescriptions --->
				<cfquery name="getPrescriptions" datasource="#application.rxDB#">
					select *
					from prescriptions
					<cfif arguments.filterBy GT 0>
					where status = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filterBy#">
					</cfif>
				</cfquery>
				<!--- Loop Each Rx Item and Add to Return Array --->
				<cfloop query="getPrescriptions">
					<cfset result.prescriptions[arrayLen(result.prescriptions) + 1] = structNew()>
					<cfloop list="#getPrescriptions.columnList#" index="i">
						<cfset result.prescriptions[arrayLen(result.prescriptions)][i] = getPrescriptions[i][getPrescriptions.currentRow]>
					</cfloop>
					<cfif getPrescriptions.currentRow EQ arguments.limit>
						<cfbreak>
					</cfif>
				</cfloop>
					<cfset result.method = "db">
			<cfelse>
				<cfset result.method = "elastic">

				<cfset search = structNew()>
				<cfset search['query'] = structNew()>
				<cfset search['query']['bool'] = structNew()>
				<cfset search['query']['bool']['must'] = arrayNew(1)>
				<cfset search['query']['bool']['must'][arrayLen(search['query']['bool']['must']) + 1] = structNew()>
				<cfset search['query']['bool']['must'][arrayLen(search['query']['bool']['must'])]["match"] = structNew()>
				<cfset search['query']['bool']['must'][arrayLen(search['query']['bool']['must'])]["match"]["STATUS"] = arguments.filterBy>

				<!--- Hit Rx Search --->
				<cfinvoke component="miscellaneous.elastic.Elastic" method="searchIndex" returnvariable="results">
					<cfinvokeargument name="index" value="amex">
					<cfinvokeargument name="table" value="prescriptions">
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

				<cfset result.method ="elastic">
				<cfset result.scrollData = scrollData>


			</cfif>

		</cfif>


		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Create Prescription --->
	<cffunction name="createRx" access="public" hint="Creates a Prescription">
		<cfargument name="patientID" type="numeric" required="true" hint="Patient ID Rx is for">
		<cfargument name="billingAddress" type="numeric" required="true" hint="Structure of Billing Info">
		<cfargument name="shippingAddress" type="numeric" required="true" hint="Structure of Shipping Info">
		<cfargument name="contents" type="struct" required="true" hint="Structure of Prescription Contents">
		<cfargument name="authToken" type="string" required="true" hint="Auth Token of User Submitting Prescription">
		<cfargument name="returnType" type="string" default="json" hint="Format to return data">
		<cfargument name="enc" type="string" default="false" hint="If Auth token needs to be re-encrypted">

		<cfset result = structNew()>
		<cfset result.responseCode = 401>

		<cfset reqAddressVars = "ADDRESS1,ADDRESS2,CITY,COUNTRY,STATE,ZIP">
		<cfset reqItemVars = "ID,INTERVAL,NAME,REFILLS,ROA,TYPE,TOTALAMMOUNT,DOSAGE">
		<cfset validItemTypes = "compound,manufactured">

		<!--- Check that we have item data for all items in this prescription --->
		<cfloop collection="#arguments.contents#" item="i">
			<cfset FoundContentVars = 0>
			<cfloop list="#structKeyList(arguments.contents[i])#" index="x">
				<cfif listFInd(reqItemVars, x)>
					<cfif x EQ "TYPE">
						<cfif listFind(validitemTypes, arguments.contents[i]['type'])>
							<cfset foundContentVars++>
						</cfif>
					<cfelse>
						<cfset foundContentVars++>
					</cfif>
				</cfif>
			</cfloop>

			<cfif contents[i]['type'] EQ "manufactured">
				<cfif !structKeyExists(application.drugs['manufactured'], "#contents[i]['id']#")>
					<cfset result.status = false>
					<cfset result.message = "Invalid Manufactured Content Data">
					<cfbreak>
				</cfif>
			<cfelse>
				<cfif !structKeyExists(application.drugs['compounds'], "#contents[i]['id']#")>
					<cfset result.status = false>
					<cfset result.message = "Invalid Compound Content Data">
					<cfbreak>
				</cfif>
			</cfif>

			<cfif foundContentVars NEQ listLen(reqItemVars)>
				<cfset result.status =  false>
				<cfset result.message = "Invalid Content Data for Item #i#">
				<cfbreak>
			<cfelse>
				<cfset result.status = true>
			</cfif>
		</cfloop>

		<!--- Check That Auth Token is Valid --->
		<cfif result.status>
			<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
				<cfinvokeargument name="token" value="#arguments.authToken#">
				<cfinvokeargument name="enc" value="#arguments.enc#">
			</cfinvoke>
			<cfif !tokenOwner.status>
				<cfset result.status = false>
				<cfset result.status = "Invalid Auth Token">
			<cfelse>
				<cfset result.status = true>

				<!--- If this is a doctor, set ID --->
				<cfif application.roles[tokenOwner.role].name Eq "doctor">
					<cfset doctorID = tokenOwner.userID>
				</cfif>

				<!--- If Doctor Delegate, check that it has access to make requests on behalf of this doctor --->
				<cfif application.roles[tokenOwner.role].name EQ "doctor_delegate">
					<cfif application.roles[tokenOwner.role].name EQ "doctor_delegate">
						<!--- If auth token is a doctor delegate, check that  delegate can submit orders for this doctor --->
						<cfinvoke component="api.doctor" method="isAuthorizedDelegate" returnVariable="authorizedDelegate">
							<cfinvokeargument name="doctorID" value="#patientInfo.doctorID#">
							<cfinvokeargument name="authToken" value="#arguments.authTOken#">
							<cfinvokeargument name="enc" value="#arguments.enc#">
						</cfinvoke>
						<cfif !authorizedDelegate>
							<cfset result.status = false>
							<cfset result.message = "User Not Authorized to Submit Prescriptions for this Doctor">
						<!--- If delegate is authorized, set doctorID from patient lookup --->
						<cfelse>
							<cfset doctorID = patientInfo.doctorID>
						</cfif>
					</cfif>
				</cfif>

			</cfif>
		</cfif>


		<!--- Get Patient Info --->
		<cfif result.status>
			<cfinvoke component="api.patients" method="getPatientInfo" returnVariable="patientInfo">
				<cfinvokeargument name="patientID" value="#arguments.patientID#">
				<cfinvokeargument name="authToken" value="#arguments.authToken#">
				<cfinvokeargument name="returnType" value="struct">
				<cfinvokeargument name="enc" value="#arguments.enc#">
			</cfinvoke>
			<cfif !patientInfo.status>
				<cfset result.status = false>
			</cfif>
		</cfif>



		<!--- Check that AddressID's are valid 	--->
		<cfif result.status>
			<cfif !structKeyExists(patientInfo.patient.address, arguments.shippingAddress)
				or !structKeyExists(patientInfo.patient.address, arguments.billingAddress)>
				<cfset result = false>
			</cfif>
		</cfif>


		<!--- Check If Doctor can submit prescriptions for this patient --->
		<cfif result.status>
			<cfinvoke component="api.patients" method="isAuthorizedForPatientAccess" returnVariable="authorizedForPatientAccess">
				<cfinvokeargument name="patientID" value="#arguments.patientID#">
				<cfinvokeargument name="userID" value="#doctorID#">
			</cfinvoke>

			<cfif !authorizedForPatientAccess>
				<cfset result.status = false>
				<cfset result.message = "Doctor is not authorized to submit prescriptions for this Patient">
			</cfif>
		</cfif>

		<!--- Insert Rx If we are still authorized	--->
		<cfif result.status>
			<cfset expires = createDate((year(now()) + 1), month(now()), day(now()))>
			<!--- Insert General Info about RX --->
			<cfquery name="insertRx" datasource="#application.rxDB#" result="createdRx">
				insert into prescriptions
				(doctorID,patientID,firstName,middleName,lastName,ssn,dob_full,dob_month,dob_year,dob_day,email,homePhone,mobilePhone,
				shipAddress1,shipAddress2,shipCity,shipState,shipZip,shipCountry,
				billAddress1,billAddress2,billCity,billState,billZip,billCountry,
				insCarrierName, insCarrierID,  insPlanName, insCarrierPhone, insPlanNumber, insGroupNumber, insPCNNumber,insBinNumber, insCardImage,
				status,createIP,numItems,lastUpdate,expires)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#doctorID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.firstName#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.middleName#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.lastName#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.ssn#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.dob_full#">,
				<cfqueryparam cfsqltype="cf_sql_ingeger" value="#patientInfo.patient.dob_month#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#patientInfo.patient.dob_day#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#patientInfo.patient.dob_year#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.email#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.homePhone#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.mobilePhone#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.shippingAddress].address1#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.shippingAddress].address2#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.shippingAddress].city#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.shippingAddress].state#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.shippingAddress].zip#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.shippingAddress].country#">,

				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.billingAddress].address1#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.billingAddress].address2#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.billingAddress].city#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.billingAddress].state#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.billingAddress].zip#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.address[arguments.billingAddress].country#">,
				<!--- If we have insurance Info --->
				<cfif structCount(patientInfo.patient.insurance)>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.insuranceCarriers[patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].carrierID].name#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].carrierID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].name#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].carrierPhone#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].planNumber#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].groupNumber#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].PCNNumber#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].BinNumber#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="0">,
				<!--- If no Insurance --->
				<cfelse>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="0">,
				</cfif>
				<!--- Set as Pending Authorization --->
				<cfqueryparam cfsqltype="cf_sql_integer" value="#application.rxStatus['Pending Authorization'].statusID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.cgi.remote_addr#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#structCount(arguments.contents)#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#expires#">
				)
			</cfquery>

			<cfset rxStruct = structNew()>
			<cfset rxStruct['medications'] = arrayNew(1)>

			<!--- Now Insert Medication Items  --->
			<cfloop collection="#arguments.contents#" item="i">
				<cfquery name="insertRxItem" datasource="#application.rxDB#" result="newMedItem">
					insert into prescriptions_medications
					(drugID, rxID, prescriptions_medications.interval, name, refills, roa, type, dateCreated, lastUpdate, manufacturer, totalAmmount, dosage)
					values
					(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contents[i].id#">,
					<cfqueryparam cfsqltype="cf_sql_integer" value="#createdRx.generated_key#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contents[i].interval#">,
					<cfif arguments.contents[i]['type'] eq "manufactured">
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.drugs['manufactured'][arguments.contents[i].id].name#">,
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.drugs['compounds'][arguments.contents[i].id].name#">,
					</cfif>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contents[i].refills#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contents[i].ROA#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contents[i].type#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					<cfif arguments.contents[i]['type'] eq "manufactured">
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.drugs['manufactured'][arguments.contents[i].id].manufactID#">,
					<cfelse>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.drugs['compounds'][arguments.contents[i].id].manufactID#">,
					</cfif>
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contents[i].totalAmmount#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contents[i].dosage#">
					)
				</cfquery>

				<cfset rxStruct['medications'][arrayLen(rxStruct['medications']) + 1] = structNew()>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].DATECREATED = now()>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].DOSAGE = now()>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].DRUGID = arguments.contents[i].id>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].INTERVAL = arguments.contents[i].interval>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].LASTUPDATE = now()>
				<cfif arguments.contents[i]['type'] eq "manufactured">
					<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].MANUFACTURER = application.drugs['manufactured'][arguments.contents[i].id].manufactID>
					<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].NAME = application.drugs['manufactured'][arguments.contents[i].id].name>
				<cfelse>
					<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].MANUFACTURER = application.drugs['compounds'][arguments.contents[i].id].manufactID>
					<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].NAME = application.drugs['compounds'][arguments.contents[i].id].name>
				</cfif>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].REFILLS = arguments.contents[i].refills>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].ROA = arguments.contents[i].ROA>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].RXID = createdRx.generated_key>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].RXMEDID = newMedItem.generated_key>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].TOTALAMMOUNT = arguments.contents[i].totalAmmount>
				<cfset rxStruct['medications'][arrayLen(rxStruct['medications'])].TYPE = arguments.contents[i].type>

				<!--- If Compound Drug, Save Ingredients --->
				<cfif arguments.contents[i]['type'] eq "compound">
					<cfloop collection="#application.drugs['compounds'][arguments.contents[i].id].ingredients#" item="x">
						<cfquery name="insertIngredients" datasource="#application.rxDB#" result="newIngredient">
							insert into prescriptions_ingredients
							(rxID,rxItemID,rxMedID,dateCreated,name,percentage,dosage,manufactID)
							values
							(
							<cfqueryparam cfsqltype="cf_sql_integer" value="#createdRx.generated_key#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contents[i].id#">,
							<cfqueryparam cfsqltype="cf_sql_integer" value="#newMedItem.generated_key#">,
							<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.drugs['ingredients'][application.drugs['compounds'][arguments.contents[i].id].ingredients[x].ingredientID].name#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.drugs['compounds'][arguments.contents[i].id].ingredients[x].percentage#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.drugs['compounds'][arguments.contents[i].id].ingredients[x].dosage#">,
							<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.drugs['ingredients'][application.drugs['compounds'][arguments.contents[i].id].ingredients[x].ingredientID].manufactID#">
							)
						</cfquery>
					</cfloop>
				</cfif>
			</cfloop>
			<cfset result.prescription = createdRx.generated_key>
			<cfset result.message = "Created Rx">
			<cfset result.responseCode = 200>


			<!--- Create Rx Struct to Send to Elastic  --->
			<cfset rxStruct.DOCTORID = doctorID>
			<cfset rxSTRUCT.rxID = createdRx.generated_key>
			<cfset rxStruct.PATIENTID = arguments.patientID>
			<cfset rxStruct.FIRSTNAME = patientInfo.patient.firstName>
			<cfset rxStruct.MIDDLENAME = patientInfo.patient.middleName>
			<cfset rxStruct.LASTNAME = patientInfo.patient.lastName>
			<cfset rxStruct.SSN = patientInfo.patient.ssn>
			<cfset rxStruct['DOB_FULL'] = patientInfo.patient.dob_full>
			<cfset rxStruct['DOB_MONTH'] = patientInfo.patient.dob_month>
			<cfset rxStruct['DOB_YEAR'] = patientInfo.patient.dob_year>
			<cfset rxStruct.EMAIL = patientInfo.patient.email>
			<cfset rxStruct.HOMEPHONE = patientInfo.patient.homePhone>
			<cfset rxStruct.SHIPADDRESS1 = patientInfo.patient.address[arguments.shippingAddress].address1>
			<cfset rxStruct.SHIPADDRESS2 = patientInfo.patient.address[arguments.shippingAddress].address2>
			<cfset rxStruct.SHIPCITY = patientInfo.patient.address[arguments.shippingAddress].city>
			<cfset rxStruct.SHIPSTATE = patientInfo.patient.address[arguments.shippingAddress].state>
			<cfset rxStruct.SHIPZIP = patientInfo.patient.address[arguments.shippingAddress].zip>
			<cfset rxStruct.SHIPCOUNTRY = "USA">
			<cfset rxStruct.BILLADDRESS1 = patientInfo.patient.address[arguments.billingAddress].address1>
			<cfset rxStruct.BILLADDRESS2 = patientInfo.patient.address[arguments.billingAddress].address2>
			<cfset rxStruct.BILLCITY = patientInfo.patient.address[arguments.billingAddress].city>
			<cfset rxStruct.BILLSTATE = patientInfo.patient.address[arguments.billingAddress].state>
			<cfset rxStruct.BILLZIP = patientInfo.patient.address[arguments.billingAddress].zip>
			<cfset rxStruct.BILLCOUNTRY = "USA">
			<cfset rxStruct.INSCARRIERNAME = application.insuranceCarriers[patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].carrierID].name>
			<cfset rxStruct.INSCARRIERID = patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].carrierID>
			<cfset rxStruct.INSPLANNAME = patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].name>
			<cfset rxStruct.INSCARRIERPHONE = patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].carrierPhone>
			<cfset rxStruct.INSPLANNUMBER = patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].planNumber>
			<cfset rxStruct.INSGROUPNUMBER = patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].groupNumber>
			<cfset rxStruct.INSPCNNUMBER = patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].PCNNumber>
			<cfset rxStruct.INSBINNUMBER = patientInfo.patient.insurance[patientInfo.patient.primaryInsurance].BinNumber>
			<cfset rxStruct.STATUS = application.rxStatus['Pending Authorization'].statusID>
			<cfset rxStruct.CREATEIP = request.cgi.remote_addr>
			<cfset rxStruct.EXPIRES = expires>
			<cfset rxStruct.NUMITEMS = structCount(arguments.contents)>
			<cfset rxStruct.events = arrayNew(1)>
			<cfset rxStruct['notes'] = arrayNew(1)>

			<!--- Send RX struct to Elastic --->
			<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
				<cfinvokeargument name="data" value="#rxStruct#">
				<cfinvokeargument name="index" value="amex">
				<cfinvokeargument name="table" value="prescriptions">
				<cfinvokeargument name="id" value="#createdRx.generated_key#">
			</cfinvoke>


			<cfset action = structNew()>
			<cfset action.description = "Created Prescription for #rxStruct.FIRSTNAME# #rxStruct.LastName#">
			<cfset action.type = application.eventTypes['createdRx'].id>
			<cfset action.eventGroupID = application.eventTypes['createdRx'].eventGroupID>
			<cfset action.typeID = createdRx.generated_key>
			<cfset action.timestamp = now()>

			<!--- Log Created Event --->
			<cfinvoke component="api.events" method="logEvent"	returnVariable="loggedevent">
				<cfinvokeargument name="user" value="#tokenowner#">
				<cfinvokeargument name="action" value="#action#">
				<cfinvokeargument name="authToken" value="#arguments.authToken#">
			</cfinvoke>

			<cfset result.elasticStatus = indexStatus>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Delete Prescription --->
	<cffunction name="deleteRx" access="public" hint="">




	</cffunction>




	<!--- Create Eligable Status --->
	<cffunction name="createEligableStatus" access="public" hint="Creates new eligable rx status">
		<cfargument name="name" type="string" required="true" hint="Name of Status">
		<cfargument name="authToken" type="string" required="true" hint="Auth Token of User">
		<cfargument name="returnType" type="string" default="json" hint="Format to return data">
		<cfargument name="enc" type="string" default="false" hint="If Auth token needs to be re-encrypted">

		<cfset result = structNew()>
		<cfset result.status = false>

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<cfif tokenOwner.status and application.roles[tokenOwner.role].name EQ "Admin">
			<cfset result.status = true>
		<cfelse>
			<cfset result.message = "Invalid Auth Token">
		</cfif>

		<!--- Check that this status doesnt exist already --->
		<cfif result.status>
			<cfquery name="checkExisting" datasource="#application.rxDB#">
				select name
				from prescriptions_status
				where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" >
			</cfquery>

			<cfif checkExisting.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Status Already Exists in Database">
			</cfif>
		</cfif>

		<!--- If we can insert --->
		<cfif result.status>
			<cfquery name="createStatus" datasource="#application.rxDB#" result="newStatus">
				insert into
				prescriptions_status
				(name,createdBy, createDate)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#"> ,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				)
			</cfquery>
			<cfset result.message = "Created New Rx Status">

			<!--- Add to Cache --->
			<cfset application.rxStatus[arguments.name] = structNew()>
			<cfset application.rxStatus[arguments.name].statusID = newStatus.generated_key>
			<cfset application.rxStatus[arguments.name].name = arguments.name>
			<cfset application.rxStatus[arguments.name].createDate = now()>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>



	<!--- Change Prescription Status --->
	<cffunction name="changeRxStatus" access="public" hint="">
		<cfargument name="prescriptionID" type="numeric" required='true'>
		<cfargument name="newStatus" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" required='true'>
		<cfargument name="enc" type="string" required="true">

		<cfset result = structNew()>
		<cfset result.status = false>

		<cfset authorizedRoles = "Admin,Tech,Pharmacist">
		<cfset noChangeList = "Pending Authorization">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>

		<cfif !listfind(authorizedRoles, application.roles[tokenOwner.role].name)>
			<cfset result.message = "invalid auth token">
		<cfelse>
			<cfset result.status = true>
		</cfif>


		<!--- Check that New Status is Valid --->
		<cfif result.status>
			<cfif !structKeyExists(application.rxStatus, arguments.newStatus) or application.rxStatus[arguments.newStatus].name EQ "Authorized">
				<cfset result.message = "invalid status">
				<cfset result.status = false>
			</cfif>
		</cfif>


		<!--- Get Current Status, Check that its not in no Change List --->
		<cfif result.status>
			<cfquery name="getCurrentStatus" datasource="#application.rxDb#">
				select status
				from prescriptions
				where rxID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.prescriptionID#">
			</cfquery>

			<cfif !getCurrentStatus.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Rx Not Found">
			<cfelseif listFind(noChangeList, getCurrentStatus.status)>
				<cfset result.status = false>
				<cfset result.message = "Unable to Rx Status. Rx is Currently Pending Doctor Authorization">
			</cfif>
		</cfif>


		<!--- if we can insert the new status --->
		<cfif result.status>
			<cfquery name="changeStatus" datasource="#application.rxDb#">
				update prescriptions
				set status = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.newStatus#">
				where rxID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.prescriptionID#">
			</cfquery>

			<!--- Update Elastic Status --->


			<!--- Create Event --->
			<cfset action = structNew()>
			<cfset action.description = "Updated Prescription Status for RX: #arguments.prescriptionID#">
			<cfset action.type = application.eventTypes['updatedPatient'].id>
			<cfset action.eventGroupID = application.eventTypes['updatedPatient'].eventGroupID>
			<cfset action.typeID = arguments.prescriptionID>
			<cfset action.timestamp = now()>

			<!--- Log Created Event --->
			<cfinvoke component="api.events" method="logEvent"	returnVariable="loggedevent">
				<cfinvokeargument name="user" value="#tokenowner#">
				<cfinvokeargument name="action" value="#action#">
				<cfinvokeargument name="authToken" value="#arguments.authToken#">
			</cfinvoke>


			<cfset result.message = "Updated Rx Status">
			<cfset result.newStatus = arguments.newStatus>
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>

</cfcomponent>
