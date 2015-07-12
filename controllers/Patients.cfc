<cfcomponent extends="controller">
	
		<!--- Create patient --->
		<cffunction name="create">
			<cfset errors = arrayNew(1)>
			
			<Cfparam name="params.shipAddress1" default="">
			<cfparam name="params.shipAddress2" default="">
			<cfparam name="params.shipCity" default="">
			<cfparam name="params.shipZip" default="">
			<cfparam name="params.shipState" default="">
			
			<cfparam name="params.billAddress1" default="">
			<cfparam name="params.billAddress2" default="">
			<cfparam name="params.billCity" default="">
			<cfparam name="params.billZip" default="">
			<cfparam name="params.billState" default="">
			
			
			<cfif structKeyExists(form, "firstName")>		
					
					<cfset billingInfo = structNew()>
					<cfset shippingInfo = structNew()>
					<cfset insuranceInfo = structNew()>
					
					<cfset requiredCols = "DOB,firstName,lastName,middleName,homePhone,ssn">
					<cfset shipAddressList = "shipAddress1,shipAddress2,shipCity,shipState,shipZip">
					<cfset billAddressList = "billAddress1,billAddress2,billCity,billState,billZip">
					<cfset insuranceList = "ins_CarrierName,ins_Name,ins_GroupName,ins_GroupNumber,ins_PcnNumber,ins_CarrierPhone,ins_PlanNumber,ins_BinNumber">
					
					<cfloop list="#requiredCols#" index="i">
						<cfif !structKeyExists(params, i) or structKeyExists(params, i) and len(params[i]) EQ 0>
							<cfset errors[arrayLen(errors) + 1] = structNew()>
							<cfset errors[arrayLen(errors)].message = "#i# is required">
						</cfif>
					</cfloop>
					
					
					<!--- Try To Create General info Struct --->
					<cftry>
						<cfset generalInfo = structNew()>
						<cfset generalInfo.title = params.title>
						<cfset generalInfo.firstName = params.firstName>
						<cfset generalInfo.lastName = params.lastName>
						<cfset generalInfo.middleName = params.middleName>
						<cfset generalInfo.homePhone = params.homePhone>
						<cfset generalInfo.mobilePhone = params.mobilePhone>
						<cfset generalInfo.ssn = params.ssn>
						<cfset generalInfo.dob = params.dob>
						<cfset generalInfo.email = params.email>
						<cfcatch>
							<cfset errors[arrayLen(errors) + 1] = structNew()>
							<cfset errors[arrayLen(errors)].message = "Unable to Determine General Info">
						</cfcatch>
					</cftry>
					
					
					<!--- Try to Create Insurance Struct --->
					<cfloop list="#shipAddressList#" index="i">
						<cfset parsed = right(i, len(i) - 4)>
						<cfif structKeyExists(params, i)>
							<cfset shippingInfo[parsed] = params[i]>
						<cfelse>
							<cfset shippingInfo[parsed] = "">
						</cfif>	
					</cfloop>	
						
					<cfloop list="#billAddressList#" index="i">
						<cfset parsed = right(i, len(i) - 4)>
						<cfif structKeyExists(params, i)>
							<cfset billingInfo[parsed] = params[i]>
						<cfelse>
							<cfset billingInfo[parsed] = "">
						</cfif>		
					</cfloop>
					
					<cfloop list="#insuranceList#" index="i">
						<cfset parsed = right(i, len(i) - 4)>
						<cfif structKeyExists(params, i)>
							<cfset insuranceInfo[parsed] = params[i]>
						<cfelse>
							<cfset insuranceInfo[parsed] = "">
						</cfif>
					</cfloop>
					
					<cfset insuranceINfo['cardImage'] = "">
						
					<!--- If we have all the vars we need, send form submission to component --->
					<cfif arrayLen(errors) EQ 0>
						<cfinvoke component="api.patients" method="createPatient" returnVariable="createdPatient">
							<cfinvokeargument name="generalInfo" value="#generalInfo#">
							<cfinvokeargument name="insurance" value="#insuranceInfo#">
							<cfinvokeargument name="shippingAddress" value="#shippingInfo#">
							<cfinvokeargument name="billingAddress" value="#billingInfo#">
							<cfinvokeargument name="authToken" value="#session.user.authToken#">
							<cfinvokeargument name="returnType" value="struct">
							<cfinvokeargument name="enc" value="false">
						</cfinvoke>
						
						<cfif createdPatient.status>
							<cflocation url="/home" addToken="false" />
						</cfif>
					</cfif>
					
					
			</cfif>
		
			<cfset renderPage(layout="false", hideDebugInformation="yes")>
		</cffunction>
		
		
		<!--- Patient Information Page --->
		<cffunction name="information">
			<!--- Get Patient INfo --->
			
			<cfif structKeyExists(params, "patient")>
				
				<cfinvoke component="api.encryption" method="decryptFormID" returnVariable="patientID">
					<cfinvokeargument name="ID" value="#params.patient#">
				</cfinvoke> 
				
				<cfinvoke component="api.patients" method="getPatientInfo" returnVariable="patientInfo">
					<cfinvokeargument name="patientID" value="#patientID#">
					<cfinvokeargument name="authToken" value="#session.user.authToken#" >
					<cfinvokeargument name="enc" value="false">
					<cfinvokeargument name="returnType" value="struct">
				</cfinvoke>
				
			</cfif>
			<cfset renderPage(layout="false", hideDebugInformation="yes")>
		</cffunction>
		

		
		<cffunction name="update">
				
			<cfset status = false>	
			<cfset errors = arrayNew(1)>
			<cfset formData = structNew()>	
			
			<!--- loop Submiited adding Parseable Form Data --->
			<cfloop list="#structKeyList(params)#" index="i">
				<cfif structKeyExists(application.formMaskLookUp, i)>
					<cfset formData[application.formMaskLookUp[i].name] = params[i]>
				</cfif>
			</cfloop>	
			
			<!--- If we have patient ID, attempt to decrypt it --->
			<cftry>
				<cfif structKeyExists(formData, "patientID")>
					<cfinvoke component="api.encryption" method="decryptFormID" returnVariable="patientID">
						<cfinvokeargument name="ID" value="#formData['patientID']#">
					</cfinvoke> 
					<cfset formData['patientID'] = patientID>
				</cfif>
				<cfcatch>
					<cfset status = false>
				</cfcatch>
			</cftry>
			
			
			<!--- If we have form data --->
			<cfif structCount(formData)>
				<cfset status = true>
			</cfif>
			<cfif status>	
				
				<cfset shippingAddress = structNew()>
				<cfset shippingAddress.address1 = formData.shipAddress1>
				<cfset shippingAddress.address2 = formData.shipAddress2>
				<cfset shippingAddress.city = formData.shipcity>
				<cfset shippingAddress.zip = formData.shipzip>
				<cfset shippingAddress.state = formData.shipstate>
				
				<cfset billingAddress = structNew()>
				<cfset billingAddress.address1 = formData.billAddress1>
				<cfset billingAddress.address2 = formData.billAddress2>
				<cfset billingAddress.city = formData.billcity>
				<cfset billingAddress.zip = formData.billzip>
				<cfset billingAddress.state = formData.billstate>
				
			
				<cfset insuranceStruct = structNew()>
				<cfset insuranceStruct.name = formData.insInsuranceName>
				<cfset insuranceStruct.groupNumber = formData.insGroupNumber>
				<cfset insuranceStruct.pcnNUmber = formData.inspcnNumber>
				<cfset insuranceStruct.planNumber = formData.insPlanNumber>
				<cfset insuranceStruct.binNumber = formData.insBinNumber>
				<cfset insuranceStruct.cardImage = "">
				<cfset insuranceStruct.carrierName = formData.insCarrierName>
				
				<cfinvoke component="api.patients" method="updatePatientInfo" returnVariable="updateStatus"> 
					<cfinvokeargument name="patientID" value="#formData.patientID#">
					<cfinvokeargument name="authToken" value="#session.user.authToken#">
					<cfinvokeargument name="firstName" value="#formData.firstName#">
					<cfinvokeargument name="title" value="">
					<cfinvokeargument name="lastName" value="#formData.lastName#">
					<cfinvokeargument name="middleName" value="#formData.middleName#">
					<cfinvokeargument name="dob" value="#formData.dob#">
					<cfinvokeargument name="ssn" value="#formData.ssn#">
					<cfinvokeargument name="email" value="#formData.email#">
					<cfinvokeargument name="homePhone" value="#formData.homePhone#">
					<cfinvokeargument name="mobilePhone" value="#formData.mobilePhone#">
					<cfinvokeargument name="shippingAddress" value="#shippingAddress#">
					<cfinvokeargument name="billingAddress" value="#billingAddress#">
					<cfinvokeargument name="insurance" value="#insuranceStruct#">	
					<cfinvokeargument name="allergies" value="#formData.allergies#">
					<cfinvokeargument name="returnType" value="struct">
					<cfinvokeargument name="enc" value="false">
				</cfinvoke>
				
			</cfif>
			<cfset renderPage(layout="false", hideDebugInformation="yes")>
		</cffunction>
		
		
		<cffunction name="notes">
		
			<cfset renderPage(layout="false", hideDebugInformation="yes")>
		</cffunction>
		
		
		<cffunction name="history">
			
			<cfset renderPage(layout="false", hideDebugInformation="yes")>
		</cffunction>
</cfcomponent>