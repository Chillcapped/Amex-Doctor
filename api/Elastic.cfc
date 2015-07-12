<cfcomponent hint="Handles Elastic and Amex Data Interaction">



		<!--- Get Indexes --->
		<cffunction name="getIndexes" access="public" hint="Returns array of Current Elastic Search Indexes">

		</cffunction>

		<cffunction name="createAmexIndex" access="public" hint="Creates Patient Index">



		</cffunction>



		<!--- Index All Prescriptions --->
		<cffunction name="indexAllPrescriptions" access="public" hint="Re-Indexes all Prescriptions Data in Elastic Search">
			<cfargument name="purge" type="boolean" default="false">


			<!--- Create Struct to populate Data before sending to Elastic--->
			<cfset rxStruct = structNew()>

			<!--- get prescriptions --->
			<cfquery name="getPrescriptions" datasource="#application.rxDB#">
				select prescriptions.rxID, prescriptions.doctorID, prescriptions.patientID, prescriptions.firstName,
				prescriptions.middleName, prescriptions.lastName, prescriptions.email, prescriptions.dob_full,
				prescriptions.dob_month, prescriptions.dob_year,prescriptions.dob_day,prescriptions.ssn,prescriptions.homePhone,
				prescriptions.mobilePhone,prescriptions.status,prescriptions.numItems,prescriptions.shipAddress1,
				prescriptions.shipAddress2,prescriptions.shipCity,prescriptions.shipState,prescriptions.shipZip,prescriptions.shipCountry,
				prescriptions.billAddress1,prescriptions.billAddress2,prescriptions.billCity,
				prescriptions.billState,prescriptions.billZip,prescriptions.billCountry, prescriptions.insCardImage,
				prescriptions.insCarrierID, prescriptions.insCarrierName, prescriptions.insPlanName,
				prescriptions.insGroupNumber,prescriptions.insPcnNumber,prescriptions.insCarrierPhone,prescriptions.insPlanNumber, prescriptions.insBinNumber,
				prescriptions.authID,prescriptions.createdBy,prescriptions.createDate,prescriptions.createIP,prescriptions.trackingNumber,prescriptions.lastUpdate,
				concat(prescriptions_ingredients.rxIngredientID) as ingredientIDlist,
				concat(prescriptions_ingredients.name) as ingredientNameList,
				prescriptions_authorization.signaturePadID, prescriptions_authorization.ip as signatureIP,
				prescriptions_authorization.sessionID as signingSession, prescriptions_authorization.timestamp as signTimestamp,
				prescriptions_authorization.signatureImage, prescriptions_authorization.pdf
				from prescriptions
				left join prescriptions_ingredients on prescriptions.rxID = prescriptions_ingredients.rxID
				left join prescriptions_authorization on prescriptions.authID = prescriptions_authorization.authID
				group by prescriptions.rxID
			</cfquery>

			<!--- Add general Info to prescription struct --->
			<cfloop query="getPrescriptions">
				<cfset rxStruct[getPrescriptions.rxID] = structNew()>

				<cfloop list="#getPrescriptions.columnList#" index="i">
					<cfset rxStruct[getPrescriptions.rxID][i] = getPrescriptions[i][getPrescriptions.currentRow]>
				</cfloop>

				<cfset rxStruct[getPrescriptions.rxID].events = arrayNew(1)>
				<cfset rxStruct[getPrescriptions.rxID]['medications'] = arrayNew(1)>
				<cfset rxStruct[getPrescriptions.rxID]['notes'] = arrayNew(1)>

			</cfloop>

			<!--- Get Prescribed Medications --->
			<cfquery name="getMedications" datasource="#application.rxDB#">
				select prescriptions_medications.rxMedID,prescriptions_medications.rxID,prescriptions_medications.drugID,
				prescriptions_medications.interval,prescriptions_medications.name,prescriptions_medications.refills,
				prescriptions_medications.roa,type,prescriptions_medications.dateCreated,prescriptions_medications.lastUpdate,
				prescriptions_medications.manufacturer,prescriptions_medications.totalAmmount,prescriptions_medications.dosage
				from prescriptions_medications
			</cfquery>

			<!--- Add Medications to prescription struct --->
			<cfloop query="getMedications">
				<cfif structKeyExists(rxStruct, getMedications.rxID)>
				<cfset rxStruct[getMedications.rxID]['medications'][arrayLen(rxStruct[getMedications.rxID]['medications']) + 1] = structNew()>
				<cfloop list="#getMedications.columnList#" index="i">
					<cfset rxStruct[getMedications.rxID]['medications'][arrayLen(rxStruct[getMedications.rxID]['medications'])][i] = getMedications[i][getMedications.currentRow]>
				</cfloop>
				</cfif>
			</cfloop>


			<!--- Get Prescription Events --->
			<cfquery name="getEvents" datasource="#application.rxDB#">
				select prescriptions_events.rxEventID, prescriptions_events.type, prescriptions_events.rxID,
				prescriptions_events.description, prescriptions_events.timeStamp, prescriptions_events.initiatedBy
				from prescriptions_events
			</cfquery>

			<cfloop query="getEvents">
				<cfset rxStruct[getEvents.rxID]['events'][arrayLen(rxStruct[getEvents.rxID]['events'] +1)] = structNew()>
				<cfloop list="#getEvents.columnList#" index="i">
					<cfset rxStruct[getEvents.rxID]['events'][arrayLen(rxStruct[getEvents.rxID]['events'])][i] = getEvents[i][getEvents.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Get Notes --->
			<cfquery name="getNotes" datasource="#application.rxDB#">
				select prescriptions_notes.rxNoteID,prescriptions_notes.rxID,prescriptions_notes.createdBy,
				prescriptions_notes.noteText,prescriptions_notes.timestamp
				from prescriptions_notes
			</cfquery>

			<cfloop query="getNotes">
				<cfset rxStruct[getNotes.rxID]['notes'][arrayLen(rxStruct[getNotes.rxID]['notes'] + 1)] = structNew()>
				<cfloop list="#getNotes.columnList#" index="i">
					<cfset rxStruct[getNotes.rxID]['notes'][arrayLen(rxStruct[getNotes.rxID]['notes'])][i] = getNotes[i][getNotes.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Now That Struct is populated, Loop Each Item and Send to Elastic For Indexing --->

			<cfloop collection="#rxStruct#" item="i">
				<!--- Send Json Struct to Elastic --->
				<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
					<cfinvokeargument name="data" value="#rxStruct[i]#">
					<cfinvokeargument name="index" value="amex">
					<cfinvokeargument name="table" value="prescriptions">
					<cfinvokeargument name="id" value="#i#">
				</cfinvoke>
			</cfloop>

			<cfset result= structNew()>
			<cfset result.status = true>
			<cfset result.PrescriptionCount = structCount(rxStruct)>
			<cfset result.message = "Successfully Index'ed all Prescriptions">
			<cfreturn result>
		</cffunction>

		<!--- Index All Users --->
		<cffunction name="indexAllDoctors" access="public" hint="Re-Indexes all Doctors" returntype="struct">
			<cfargument name="purge" type="boolean" default="false">

			<!--- Create Doctor Struct to populate --->
			<cfset doctors = structNew()>


			<!--- Get Doctors --->
			<cfquery name="getDoctors" datasource="#application.contentDB#">
				select * from doctors
			</cfquery>

			<!--- loop Doctors --->
			<cfloop query="getDoctors">
				<cfset doctors[getDoctors.doctorID] = structNew()>
				<cfset doctors[getDoctors.doctorID]['Delegates'] = arrayNew(1)>
				<cfset doctors[getDoctors.doctorID]['Offices'] = arrayNew(1)>
				<cfset doctors[getDoctors.doctorID]['IPs'] = arrayNew(1)>

				<cfloop list="#getDoctors.columnList#" index="i">
					<cfset doctors[getDoctors.doctorID][i] = getDoctors[i][getDoctors.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Get Delegates --->
			<cfquery name="getDelegates" datasource="#application.contentDB#">
				select *
				from doctors_delegates
			</cfquery>

			<cfloop query="getDelegates">
				<cfif structKeyExists(doctors, getDelegates.doctorID)>
					<cfset doctors[getDelegates.doctorID]['Delegates'][arrayLen(doctors[getDelegates.doctorID]['Delegates']) + 1] = structNew()>
					<cfloop list="#getDelegates.columnList#" index="i">
						<cfset doctors[getDelegates.doctorID]['Delegates'][arrayLen(doctors[getDelegates.doctorID]['Delegates'])][i] = getDelegates[i][getDelegates.currentRow]>
					</cfloop>
				</cfif>
			</cfloop>

			<!--- Get Doctors Offices --->
			<cfquery name='getOffices' datasource="#application.contentDB#">
				select *
				from doctors_offices
			</cfquery>

			<cfloop query="getOffices">
				<cfif structKeyExists(doctors, getOffices.doctorID)>
					<cfset doctors[getOffices.doctorID]['Offices'][arrayLen(doctors[getOffices.doctorID]['Offices']) + 1] = structNew()>
					<cfloop list="#getOffices.columnList#" index="i">
					<cfset doctors[getOffices.doctorID]['Offices'][arrayLen(doctors[getOffices.doctorID]['Offices'])][i] = getoffices[i][getOffices.currentRow]>
					</cfloop>
				</cfif>
			</cfloop>

			<!--- Get Doctors Authorized IPs --->
			<cfquery name="getIps" datasource="#application.contentDB#">
				select *
				from doctors_ip_authorized
			</cfquery>

			<cfloop query="getIPS">
				<cfif structKeyExists(doctors, getIPS.doctorID)>
					<cfset doctors[getIPS.doctorID]['IPs'][arrayLen(doctors[getIPS.doctorID]['IPs']) + 1] = structNew()>
					<cfloop list="#getIPs.columnList#" index="i">
						<cfset doctors[getIPS.doctorID]['IPs'][arrayLen(doctors[getIPS.doctorID]['IPs'])][i] = getIPs[i][getIPs.currentRow]>
					</cfloop>
				</cfif>
			</cfloop>

			<!--- Now Submit To Elastic --->
			<cfloop collection="#doctors#" item="i">
				<!--- Send Json Struct to Elastic --->
				<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
					<cfinvokeargument name="data" value="#doctors[i]#">
					<cfinvokeargument name="index" value="amex">
					<cfinvokeargument name="table" value="doctors">
					<cfinvokeargument name="id" value="#i#">
				</cfinvoke>
			</cfloop>

			<cfset result= structNew()>
			<cfset result.status = true>
			<cfset result.doctors = structCopy(doctors)>
			<cfset result.message = "Successfully Index'ed all Doctors">
			<cfreturn result>
		</cffunction>

		<!--- Index All Patients --->
		<cffunction name="indexAllPatients" access="public" hint="Index All Patients">
			<cfargument name="purge" type="boolean" default="false">



			<cfset patients = structNew()>

			<!--- Get All Patients --->
			<cfquery name="getPatients" datasource="#application.contentDB#">
				select * from patients
			</cfquery>

			<cfloop query="getPatients">
				<cfset patients[getPatients.patientID] = structNew()>
				<cfset patients[getPatients.patientID].address = arrayNew(1)>
				<cfset patients[getPatients.patientID].insurance = arrayNew(1)>

				<cfloop list="#getPatients.columnList#" index="i">
					<cfset patients[getPatients.patientID][i] = getPatients[i][getPatients.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Get patient Addresses --->
			<cfquery name="getPatientAddress" datasource="#application.contentDB#">
				select * from patients_address
			</cfquery>

			<cfloop query="getPatientAddress">
				<cfif structKeyExists(patients, getPatientAddress.patientID)>
					<cfset patients[getPatientAddress.patientID].address[arrayLen(patients[getPatientAddress.patientID].address) + 1] = structNew()>
					<cfloop list="#getPatientAddress.columnList#" index="i">
						<cfset patients[getPatientAddress.patientID].address[arrayLen(patients[getPatientAddress.patientID].address)][i] = getPatientAddress[i][getPatientAddress.currentRow]>
					</cfloop>
				</cfif>
			</cfloop>

			<!--- Get Patient Insurance --->
			<cfquery name="getPatientInsurance" datasource="#application.contentDB#">
				select * from patients_insurance
			</cfquery>

			<cfloop query="getPatientInsurance">
				<cfset patients[getPatientInsurance.patientID].insurance[arrayLen(patients[getPatientInsurance.patientID].insurance) + 1] = structNew()>
				<cfloop list="#getPatientInsurance.columnList#" index="i">
					<cfset patients[getPatientInsurance.patientID].insurance[arrayLen(patients[getPatientInsurance.patientID].insurance)][i] = getpatientInsurance[i][getPatientInsurance.currentRow]>
				</cfloop>
			</cfloop>
			<cfset result= structNew()>
			<cfset result.response = structNew()>


			<!--- Send Data to Elastic --->
			<cfloop collection="#patients#" item="i">
				<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
					<cfinvokeargument name="data" value="#patients[i]#">
					<cfinvokeargument name="index" value="amex">
					<cfinvokeargument name="table" value="patients">
					<cfinvokeargument name="id" value="#i#">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>
				<cfset result.response[i] = indexStatus>
			</cfloop>


			<cfset result.status = true>
			<cfset result.Patients= structCopy(patients)>
			<cfset result.message = "Successfully Index'ed all Patients">
			<cfreturn result>
		</cffunction>



		<!--- Index All Medications --->
		<cffunction name="indexAllMedications" access="public" hint="indexes all medications">
			<cfargument name="purge" type="boolean" default="false">


			<cfset compounds = structNew()>

			<cfquery name="getCompounds" datasource="#application.contentDb#">
				select * from compounds
			</cfquery>

			<!--- Add Compounds to Struct --->
			<cfloop query="getcompounds">
				<cfset compounds[getCompounds.compoundID] = structNew()>
				<cfset compounds[getCompounds.compoundID].notes = arrayNew(1)>
				<cfset compounds[getCompounds.compoundID].ingredients = arrayNew(1)>

				<cfloop list="#getcompounds.columnList#" index="i">
					<cfset compounds[getCompounds.compoundID][i] = getCompounds[i][getCompounds.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Add Compound Notes ---->
			<cfquery name="getCompoundNotes" datasource="#application.contentDB#">
				select * from compounds_notes
			</cfquery>

			<cfloop query="getCompoundNotes">
				<cfset compounds[getCompounds.compoundID].notes[arrayLen(compounds[getCompounds.compoundID].notes) + 1] = structNew()>
				<cfloop list="#getCompoundNotes.columnList#" index="i">
					<cfset compounds[getCompounds.compoundID].notes[arrayLen(compounds[getCompounds.compoundID].notes)][i] = getCompoundNotes[i][getCompoundNotes.currentRow]>
				</cfloop>
			</cfloop>

			<!--- ADd Compound Ingredients --->
			<cfquery name="getCompoundIngredients" datasource="#application.contentDb#">
				select * from compounds_ingredients
			</cfquery>

			<cfloop query="getCompoundIngredients">
				<cfset x = arrayLen(compounds[getCompoundIngredients.compoundID].ingredients) + 1>
				<cfset compounds[getCompoundIngredients.compoundID].ingredients[x] = structNew()>
				<cfset compounds[getCompoundIngredients.compoundID].ingredients[x]['notes'] = arrayNew(1)>
				<cfloop list="#getCompoundIngredients.columnList#" index="i">
					<cfif structKeyExists(compounds, getCompoundIngredients.compoundID)>
						<cfset compounds[getCompoundIngredients.compoundID].ingredients[x][i] = getCompoundIngredients[i][getCompoundIngredients.currentRow]>
					</cfif>
				</cfloop>
			</cfloop>

			<!--- Add Compound Ingredient Notes --->
			<cfquery name="getCompoundIngredientNotes" datasource="#application.contentDB#">
				select * from compounds_ingredients_notes
			</cfquery>

			<cfloop query="getCompoundIngredientNotes">
				<cfset compounds[getCompoundIngredients].ingredients[arrayLen(compounds[getCompoundIngredients].ingredients)]['notes'][arrayLen(compounds[getCompoundIngredients].ingredients[arrayLen(compounds[getCompoundIngredients].ingredients)]['notes']) + 1] = structNew()>
				<cfloop list="#getCompoundIngredientNotes.columnList#" index="i">
					<cfset compounds[getCompoundIngredients].ingredients[arrayLen(compounds[getCompoundIngredients].ingredients)]['notes'][arrayLen(compounds[getCompoundIngredients].ingredients[arrayLen(compounds[getCompoundIngredients].ingredients)]['notes'])][i] = getcompoundIngredientNotes[i][getCompoundIngredientNotes.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Send Compounds to Elastic --->
			<cfloop collection="#compounds#" item="i">
				<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
					<cfinvokeargument name="data" value="#compounds[i]#">
					<cfinvokeargument name="index" value="amex">
					<cfinvokeargument name="table" value="compounds">
					<cfinvokeargument name="id" value="#i#">
				</cfinvoke>
			</cfloop>

			<cfset manufacturedDrugs = structNew()>

			<!--- Get manufacturerd Drugs --->
			<cfquery name="getManufacturedDrugs" datasource="#application.contentDB#">
				select * from manufactured_drugs
				left join manufacturers on manufactured_drugs.manufactID = manufacturers.manufactID
			</cfquery>

			<cfloop query="getManufacturedDrugs">
				<cfset manufacturedDrugs[getManufacturedDrugs.drugID] = structNew()>
				<cfloop list="#getManufacturedDrugs.columnList#" index="i">
					<cfset manufacturedDrugs[getManufacturedDrugs.drugID][i] = getManufacturedDrugs[i][getManufacturedDrugs.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Send Manufactured Drugs to Elastic --->
			<cfloop collection="#manufacturedDrugs#" item="i">
				<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
					<cfinvokeargument name="data" value="#manufacturedDrugs[i]#">
					<cfinvokeargument name="index" value="amex">
					<cfinvokeargument name="table" value="manufacturedDrugs">
					<cfinvokeargument name="id" value="#i#">
				</cfinvoke>
			</cfloop>

			<cfset ingredients = structNew()>

			<!--- Get Ingredients --->
			<cfquery name="getIngredients" datasource="#application.contentDB#">
				select * from ingredients
				left join manufacturers on ingredients.manufactID = manufacturers.manufactID
			</cfquery>

			<cfloop query="getIngredients">
				<cfset ingredients[getIngredients.ingredientID] = structNew()>
				<cfloop list="#getIngredients.columnList#" index="i">
					<cfset ingredients[getIngredients.ingredientID][i] = getIngredients[i][getIngredients.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Send Ingredients To Elastic --->
			<cfloop collection="#ingredients#" item="i">
				<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
					<cfinvokeargument name="data" value="#ingredients[i]#">
					<cfinvokeargument name="index" value="amex">
					<cfinvokeargument name="table" value="ingredients">
					<cfinvokeargument name="id" value="#i#">
				</cfinvoke>
			</cfloop>

			<cfset result= structNew()>
			<cfset result.status = true>
			<cfset result.ingredients = structCopy(ingredients)>
			<cfset result.manufacturedDrugs = structCopy(manufacturedDrugs)>
			<cfset result.compounds = structCopy(compounds)>
			<cfset result.message = "Successfully Index'ed all Medications">
			<cfreturn result>
		</cffunction>


		<!--- Index All Events --->
		<cffunction name="indexAllEvents" access="public" hint="indexes  all events">
			<cfargument name="purge" type="boolean" default="false">


			<cfset events = structNew()>

			<cfquery name="getEvents" datasource="#application.internalDB#">
				select * from events
			</cfquery>

			<cfloop query="getEvents">
				<cfset events[getevents.eventID] = structNew()>
				<cfloop list="#getEvents.columnList#" index="i">
					<cfset events[getevents.eventID][i] = getEvents[i][getEvents.currentRow]>
				</cfloop>
			</cfloop>

			<!--- Send Ingredients To Elastic --->
			<cfloop collection="#events#" item="i">
				<cfinvoke component="miscellaneous.elastic.elastic" method="indexData" returnvariable="indexStatus">
					<cfinvokeargument name="data" value="#events[i]#">
					<cfinvokeargument name="index" value="amex">
					<cfinvokeargument name="table" value="events">
					<cfinvokeargument name="id" value="#i#">
				</cfinvoke>
			</cfloop>


			<cfset result= structNew()>
			<cfset result.status = true>
			<cfset result.events = structCopy(events)>
			<cfset result.message = "Successfully Index'ed all Events">
			<cfreturn result>
		</cffunction>



		<cffunction name="purgeAll" access="public" hint="purges elastic data">

			<cfinvoke component="miscellaneous.elastic.Elastic" method="deleteIndex" returnvariable="deleteStatus">
				<cfinvokeargument name="index" value="amex">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>

		</cffunction>

</cfcomponent>
