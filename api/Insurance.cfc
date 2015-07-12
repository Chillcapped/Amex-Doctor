<cfcomponent>
	
	<!--- Is valid insurance ID --->
	<cffunction name="isValidInsuranceID" access="public" hint="returns boolean if insurance id is valid">
		<cfargument name="insuranceID" type="numeric" required="true">
		<cfargument name="patientID" type="numeric" required="true">
		
		<cfquery name="checkID" datasource="#application.contentDB#">
			select patientInsuranceID
			from patients_insurance
			where patientInsuranceID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.insuranceID#"> 
			and patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
		</cfquery>
	
		<cfif checkID.recordCount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	
	<!--- Checks if Insurance ID is verified --->
	<cffunction name="isVerifiedInsurance" access="public" hint="Returns boolean if insurance id is verified">
		<cfargument name="insuranceID" type="numeric" required="true">
		<cfargument name="patientID" type="numeric" required="true">
		
		<cfquery name="checkID" datasource="#application.contentDB#">
			select patientInsuranceID, primary
			from patients_insurance
			where patientInsuranceID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.insuranceID#"> 
			and patientID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.patientID#"> 
		</cfquery>
		
		<cfif checkID.recordCount and checkId.primary EQ 1>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	
	<!--- Get Carrier ID --->
	<cffunction name="getCarrierID" access="public" hint="Finds Carrier ID from carrier name">
		<cfargument name="name" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		
		<cfloop collection="#application.InsuranceCarriers#" item="i">
			<cfif lCase(arguments.Name) EQ application.InsuranceCarriers[i].name>
				<cfset result.carrierID = i>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!--- Create Carrier --->
	<cffunction name="createCarrier" access="public" hint="Createsa new Insurance Carrier">
		<cfargument name="name" type="string" required="true">
		<cfargument name="authToken" required="true" type="string">
		<cfargument name="returnType" default="json" type="string">
		<cfargument name="enc" default="false" type="string">
		
		<cfset result = structNew()>	
			
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
	
		<cfif tokenOwner.status>
			<cfset result.status = true>
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "Invalid Auth Token">
		</cfif>	
		
		<cfif result.status>
			<!--- Check that Carrier Doesnt Exists --->
			<cfquery name="checkName" datasource="#application.contentDB#">
				select carrierID
				from insurance_companies
				where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#"> 
			</cfquery>
			
			<cfif checkName.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Name Exists in Insurance Database">
				<cfset result.id = checkName.generated_key>
			</cfif>
		</cfif>	
		
		<!--- Insert Carrier --->
		<cfif result.status>	
			<cfquery name="insertCarrier" datasource="#application.contentDB#" result="newCarrier">
				insert into insurance_companies
				(name, createDate)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">   
				)
			</cfquery>
			
			<cfset result.message = "Created Insurance Carrier">
			<cfset result.id = newCarrier.generated_key>
			
			<!--- Add To APp Cache of Carriers --->
			<cfset application.insuranceCarriers[newCarrier.generatedKey] = structNew()>
			<cfset application.insuranceCarriers[newCarrier.generatedKey].name = arguments.name>
			<cfset application.insuranceCarriers[newCarrier.generatedKey].createDate = now()>
			<cfset application.insuranceCarriers[newCarrier.generatedKey].patientCount = 0>
		</cfif>
		
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	

	
	
	
	
</cfcomponent>