<cfcomponent extends="controller">


	<cffunction name="index">



		<cfset renderPage(hideDebugInformation="yes", template="/prescriptions/browse/index")>
	</cffunction>

	<cffunction name="browse">



		<cfset renderPage(hideDebugInformation="yes", template="/prescriptions/browse/all")>
	</cffunction>

	<cffunction name="bulkOrder">



		<cfset renderPage(hideDebugInformation="yes", template="/prescriptions/bulk/order")>
	</cffunction>

	<cffunction name="bulkPrescribe">



		<cfset renderPage(hideDebugInformation="yes", template="/prescriptions/bulk/prescribe")>
	</cffunction>
	<cffunction name="type">



		<cfset renderPage(hideDebugInformation="yes", template="/prescriptions/typeSelection")>
	</cffunction>

	<!--- Create Prescription Ajax Popup --->
	<cffunction name="createRx">

		<!--- if we have Patient ID, get patient info --->
		<cfif structKeyExists(params, "patientID")>
			<cfinvoke component="api.patients" method="getPatientInfo" returnVariable="patientInfo">
				<cfinvokeargument name="patientID" value="#params.patientID#">
				<cfinvokeargument name="authToken" value="#session.user.authToken#">
				<cfinvokeargument name="returnType" value="struct">
				<cfinvokeargument name="enc" value="false">
			</cfinvoke>
		</cfif>


		<!--- If we have patient name, phoneNumber and not ID ---->
		<cfif structkeyExists(params, "name") and !structKeyExists(variables, "patientInfo")>
			<!--- Lookup Patient Name --->
			<cfinvoke component="api.patients" method="findPatient" returnVariable="patientInfo">
				<cfinvokeargument name="searchBy" value="name">
				<cfinvokeargument name="searchValue" value="#params.name#">
				<cfinvokeargument name="returnType" value="struct">
				<cfinvokeargument name="authtoken" value="#session.user.authToken#">
				<cfinvokeargument name="enc" value="false">
			</cfinvoke>
		</cfif>

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/index")>
	</cffunction>


	<!--- Handles Submission of New Prescription --->
	<cffunction name="createRx_process">
		<cfset result = structNew()>
		<cfset result.responseCode = 401>

		<cfset result.errors = arrayNew(1)>
		<cfset formData = structNew()>


		<cfset requiredFormData = "shippingSelect,billingSelect,patientID">

		<!--- Parse the Form Dataz --->
		<cfloop list="#structKeyList(params)#" index="i">
			<cfif structKeyExists(application.formMaskLookUp, i) and listFind(requiredFormData, application.formMaskLookUp[i].name)>
				<cfset formData[application.formMaskLookUp[i].name] = structNew()>
				<cfset formData[application.formMaskLookUp[i].name].hash = i>
				<cfset formData[application.formMaskLookUp[i].name].name = application.formMaskLookUp[i].name>
				<cfset formData[application.formMaskLookUp[i].name].value = params[i]>
			</cfif>
		</cfloop>

		<cfif structCount(formData) NEQ listLen(requiredFormData)>
			<cfset result.errors[arrayLen(errors) +1] = structNew()>
			<cfset result.errors[arrayLen(errors)].message = "Missing Required Form Data to Create Prescription">
		</cfif>

		<!--- Decrypt Patient ID --->
		<cftry>
			<cfinvoke component="api.encryption" method="decryptFormID"  returnVariable="patientID">
				<cfinvokeargument name="id" value="#formData['patientID'].value#">
			</cfinvoke>

		<cfcatch>
			<cfset result.errors[arrayLen(errors) +1] = structNew()>
			<cfset result.errors[arrayLen(errors)].message = "Unable to Determine Patient">
		</cfcatch>
		</cftry>

		<!--- Attempt to Create Content Struct --->
		<cftry>
			<cfset contents = structNew()>
			<cfloop from="1" to="#params.numItems#" index="i">
				<cfset contents[i] = structNew()>
				<cfset contents[i].id = params['itemID#i#']>
				<cfset contents[i].interval = params['itemInterval#i#']>
				<cfset contents[i].name = params['itemName#i#']>
				<cfset contents[i].roa = params['itemROA#i#']>
				<cfset contents[i].refills = params['itemRefills#i#']>
				<cfset contents[i].totalAmmount = params['itemAmmount#i#']>
				<cfset contents[i].dosage = params['itemDosage#i#']>
				<cfset contents[i].type = params['itemType#i#']>
			</cfloop>
			<!--- If we cant, throw error --->
			<cfcatch>
				<cfset result.errors[arrayLen(errors)].message = "Unable to Determine Contents">
			</cfcatch>
		</cftry>

		<!--- if we dont have any errors --->
		<cfif !arrayLen(result.errors)>
			<!--- Send To Api 	---->
			<cfinvoke component="api.prescriptions" method="createRx" returnVariable="createdResult">
				<cfinvokeargument name="patientID" value="#patientID#">
				<cfinvokeargument name="shippingAddress" value="#formData['shippingSelect'].value#">
				<cfinvokeargument name="billingAddress" value="#formData['billingSelect'].value#">
				<cfinvokeargument name="contents" value="#contents#">
				<cfinvokeargument name="returnType" value="struct">
				<cfinvokeargument name="authtoken" value="#session.user.authToken#">
				<cfinvokeargument name="enc" value="false">
			</cfinvoke>

			<!--- If we were able to Create Prescription, Create Struct for JSON response --->
			<cfif createdResult.status>

				<!--- Encrypted Rx ID --->
				<cfinvoke component="api.Encryption" method="encryptFormID" returnvariable="eRxID">
					<cfinvokeargument name="ID" value="#createdResult.prescription#">
				</cfinvoke>

				<cfset createdResult.prescription = eRxID>
			</cfif>
			<cfset response = serializeJson(createdResult)>


		<!--- Create Failed Json REsponse so We can Handle in Creator --->
		<cfelse>
			<cfset response= serializeJson(result)>
		</cfif>



		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/process")>
	</cffunction>


	<!--- Create RX Manufactured Drug Ajax Content --->
	<cffunction name="createRx_manufactured">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/manufactured")>
	</cffunction>

	<!--- Create Rx Compound Ajax Content --->
	<cffunction name="createRx_compounds">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/compounds")>
	</cffunction>


	<cffunction name="createRX_creator">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/creator")>
	</cffunction>


	<!--- Create Rx Ajax Table Content --->
	<cffunction name="createRx_addTableItem">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/addTableItem")>
	</cffunction>


	<!--- Create Rx Approve  --->
	<cffunction name="createRx_approve">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/approve")>
	</cffunction>

	<!--- Create Rx Authorize Preview --->
	<cffunction name="createRx_authorizePreview">



		<cfif structKeyExists(params, "prescription")>

			<cfset errors = arrayNew(1)>
			<cfif application.roles[session.user.role].name EQ "Doctor">
				<cfset params.doctorID = session.user.userID>
				<cfset doctorLastName = left(session.user.firstName, 1) & session.user.lastName  & "/">
	 		<cfelseif application.roles[session.user.role].name EQ "Doctor-Delegate">
			 	<cfset params.doctorID = session.user.userID>
				<cfset doctorLastName = left(session.user.firstName, 1) & session.user.lastName  & "/">
			<cfelse>
				<cfset errors[arrayLen(errors + 1)] = structNew()>
				<cfset errors[arrayLen(errors)].message = "User Role Not Authorized to Perform this Function">
			</cfif>


			<cfif !arrayLen(errors)>

				<cfinvoke component="api.encryption" method="decryptFormID" returnVariable="PrescriptionID">
					<cfinvokeargument name="ID" value="#params.prescription#">
				</cfinvoke>

				<!--- Get Prescription Info --->
				<cfinvoke component="api.prescriptions" method="getPrescriptionInfo" returnVariable="prescriptionInfo">
					<cfinvokeargument name="prescription" value="#prescriptionID#">
					<cfinvokeargument name="authToken" value="#session.user.authToken#">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>

				<!--- Create Signature pad --->
		 		<cfinvoke component="api.Doctor" method="createSignaturePad" returnVariable="signaturePadData">
					<cfinvokeargument name="doctorPrefix" value="#doctorLastName#">
				 </cfinvoke>


			</cfif>

		</cfif>










		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/authorize")>
	</cffunction>


	<!--- Prescription Creator Step 2 Ajax Page --->
	<cffunction name="PrescriptionCreator">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/createRx/creator")>
	</cffunction>

	<!--- Info Popup --->
	<cffunction name="information">

		<cfif structKeyExists(params, "prescriptionID")>

			<cfinvoke component="api.encryption" method="decryptFormID"  returnVariable="prescriptionID">
				<cfinvokeargument name="id" value="#params.prescriptionID#">
			</cfinvoke>

				<!--- Get Prescription Info --->
				<cfinvoke component="api.prescriptions" method="getPrescriptionInfo" returnVariable="rx">
					<cfinvokeargument name="prescription" value="#prescriptionID#">
					<cfinvokeargument name="returnType" value="struct">
					<cfinvokeargument name="authtoken" value="#session.user.authToken#">
					<cfinvokeargument name="enc" value="false">
				</cfinvoke>
		</cfif>
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/information/index")>
	</cffunction>



	<!--- Authorize --->
	<cffunction name="authorize">

		<cfif structKeyExists(params, "prescription")>

			<cfset errors = arrayNew(1)>


			<cfif application.roles[session.user.role].name EQ "Doctor">
				<cfset params.doctorID = session.user.userID>
				<cfset doctorLastName = left(session.user.firstName, 1) & session.user.lastName  & "/">
	 		<cfelseif application.roles[session.user.role].name EQ "Doctor-Delegate">
			 	<cfset params.doctorID = session.user.userID>
				<cfset doctorLastName = left(session.user.firstName, 1) & session.user.lastName  & "/">
			<cfelse>
				<cfset errors[arrayLen(errors + 1)] = structNew()>
				<cfset errors[arrayLen(errors)].message = "User Role Not Authorized to Perform this Function">
			</cfif>


			<cfif !arrayLen(errors)>

				<cfinvoke component="api.encryption" method="decryptFormID" returnVariable="PrescriptionID">
					<cfinvokeargument name="ID" value="#params.prescription#">
				</cfinvoke>

				<!--- Get Prescription Info --->
				<cfinvoke component="api.prescriptions" method="getPrescriptionInfo" returnVariable="prescriptionInfo">
					<cfinvokeargument name="prescription" value="#prescriptionID#">
					<cfinvokeargument name="authToken" value="#session.user.authToken#">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>

				<!--- Create Signature pad --->
		 		<cfinvoke component="api.Doctor" method="createSignaturePad" returnVariable="signaturePadData">
					<cfinvokeargument name="doctorPrefix" value="#doctorLastName#">
				 </cfinvoke>


			</cfif>

		</cfif>


		<cfset renderPage(layout="/prescriptions/authorize/iFrameLayout",hideDebugInformation="yes", template="/prescriptions/authorize/userAuthorize")>
	</cffunction>

	<!--- Signature Pad --->
	<cffunction name="sign">
		<cfset doctorLastName = left(session.user.firstName, 1) & session.user.lastName  & "/">
		<!--- Create Signature pad --->
 		<cfinvoke component="api.Doctor" method="createSignaturePad" returnVariable="signaturePadData">
			<cfinvokeargument name="doctorPrefix" value="#doctorLastName#">
		 </cfinvoke>

		<cfset renderPage(layout="/prescriptions/authorize/iFrameLayout", hideDebugInformation="yes", template="../portal_layouts/doctor/authorize/sign")>
	</cffunction>

	<!--- process Signature --->
	<cffunction name="processSignature">

		<!---
		<cfdump var="#form['#hash('securityCode')#']#" label="Security Code">
		<cfdump var="#form['#hash('imageData')#']#" label="Signature Image">
		<cfdump var="#form['#hash('pad')#']#" label="Pad Number">
		<cfdump var="#form['#hash('rx')#']#" label="Rx Number">
		<cfdump var="#form['#hash('securityToken')#']#" label="Security Token">
		--->
		<cfset errors = arrayNew(1)>

		<cftry>
			<cfif application.roles[session.user.role].name EQ "doctor">
				<cfset doctorID = session.user.userID>
			<cfelseif  application.roles[session.user.role].name EQ "doctor-delegate">
				<cfset doctorID = session.user.doctorID>
			</cfif>

			<!--- If we failed to Determine Doctor --->
			<cfcatch>
				<cfset errors[arrayLen(errors)+1] = "Unable to Determine Doctor">
			</cfcatch>
		</cftry>

		<cfif !arrayLen(errors)>

			<cfinvoke component="api.encryption" method="decryptFormID" returnVariable="prescriptionID">
				<cfinvokeargument name="id" value="#urlDecode(form['#hash('rx')#'])#">
			</cfinvoke>

			<!--- Decrypt  --->
			<cfset signaturePadData = structNew()>
			<cfset signaturePadData.ip = hash(replace(request.cgi.remote_addr, ".", "", "all"))>
			<cfset signaturePadData.decodedBaseIP = decrypt(toString(toBinary(form['#hash('securityToken')#'])), signaturePadData.ip, 'CFMX_COMPAT')/>
			<cfset signaturePadData.decodedKey = Decrypt(signaturePadData.decodedBaseIP, application.formKey, 'AES/CBC/PKCS5Padding','HEX')/>
			<cfset signaturePadData.decodedKey = Decrypt(signaturePadData.decodedKey, application.signatureKey, 'AES/CBC/PKCS5Padding','HEX')/>

			<!--- If Decoded Key Matches Unique Signature Key, This is a valid signature --->
			<cfif signaturePadData.decodedKey EQ form['#hash('pad')#']>
				<cfset signaturePadData.valid = true>
			<cfelse>
				<cfset errors[arrayLen(errors)+1] = "Signature Key is not valid, please resign and submit.">
			</cfif>

		</cfif>


		<!--- Check IF Security Code is Valid --->
		<cfif !arrayLen(errors)>



		</cfif>

		<!--- Check that ID is Valid and prescription is Pending Authorization ---->
		<cfif !arrayLen(errors)>
			<cfquery name="checkStatus" datasource="#application.rxDB#">
				select rxID, status
				from prescriptions
				where rxID = <cfqueryparam cfsqltype="cf_sql_integer" value="#prescriptionID#">
				and status = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.rxStatus['Pending Authorization'].statusID#" >
			</cfquery>
			<cfif checkStatus.recordCount EQ 0>
				<cfset errors[arrayLen(errors)+1] = "Unauthorized Prescription ">
			</cfif>
		</cfif>

		<!--- Convert SVG Data Image to PNG --->
		<cfif !arrayLen(errors)>
			<cfimage isBase64="yes" action="write" name="image"
			destination="#application.saveLocations.signatureSaveLocation#/#hash(prescriptionID)#.png"
			source="#form['#hash('imageData')#']#" overwrite="true">
		</cfif>

		<!--- Create PDF --->


		<!--- If we dont have an errors, change the RX status --->
		<cfif !arrayLen(errors)>
			<!--- Save Authorization ---->
			<cfquery name="insertAuth" datasource="#application.rxDB#" result="newAuthRecord">
				insert into prescriptions_authorization
				(signaturePadID,ip,sessionID,timestamp,signatureImage,pdf)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#signaturePadData.decodedKey#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.cgi.remote_addr#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.sessionID#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(prescriptionID)#.png">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(prescriptionID)#.pdf">
				)
			</cfquery>

			<!--- Update Prescription as Authorized --->
			<cfquery name="updateAuthorization" datasource="#application.rxDB#">
				update prescriptions
				set authID = <cfqueryparam cfsqltype="cf_sql_integer" value="#newAuthRecord.generated_key#">,
					status = <cfqueryparam cfsqltype="cf_sql_integer" value="#application.rxStatus['Authorized'].statusID#" >
				where rxID = <cfqueryparam cfsqltype="cf_sql_integer" value="#prescriptionID#" >
			</cfquery>

			<!--- Send New Status to Elastic --->
			<cfset elastic = structNew()>
			<cfset elastic.status = application.rxStatus['Authorized'].statusID>

			<cfinvoke component="miscellaneous.elastic.Elastic" method="updateIndexItem" returnvariable="elasticUpdate">
				<cfinvokeargument name="index" value="amex">
				<cfinvokeargument name="table" value="prescriptions">
				<cfinvokeargument name="itemID" value="#prescriptionID#">
				<cfinvokeargument name="updatedItemData" value="#elastic#">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>



		</cfif>



		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/authorize/processSignature")>
	</cffunction>

	<cffunction name="rx_notes">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/information/notes")>
	</cffunction>

	<cffunction name="rx_messages">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/information/messages")>
	</cffunction>


	<cffunction name="rx_timeline">
		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/information/timeLine")>
	</cffunction>


	<cffunction name="avastin">


		<cfset renderPage(hideDebugInformation="yes", template="/prescriptions/avastin/index")>
	</cffunction>



	<cffunction name="expired">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/browse/expired")>
	</cffunction>


	<cffunction name="active">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/browse/active")>
	</cffunction>


	<cffunction name="expiring">

		<cfset renderPage(layout="false", hideDebugInformation="yes", template="/prescriptions/browse/expiring")>
	</cffunction>



</cfcomponent>
