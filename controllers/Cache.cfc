<cfcomponent>


	<cffunction name="createGlobalCacheStructs">

		<cfset application.alphaLists = structNew()>

	</cffunction>



	 <!--- Cache Security Roles --->
	 <cffunction name="CacheRoles" returnFormat="plain" access="remote" hint="creates application variable for security roles">
	 	 <!--- Get Roles --->
	 	 <cfquery name="getRoles" datasource="#application.contentDB#">
		  	  select roleID, name, permissions, description, subdomain
		  	  from users_role
		  </cfquery>
	 	 	<cfloop query="getRoles">
				<cfset application.roles[getRoles.roleID] = structNew()>
				<cfset application.roles[getRoles.roleID].roleID = getRoles.roleID>
				<cfset application.roles[getRoles.roleID].name = getRoles.name>
				<cfset application.roles[getRoles.roleID].permissions = getRoles.permissions>
				<cfset application.roles[getRoles.roleID].description = getRoles.description>
				<cfset application.roles[getRoles.roleID].subdomain = getRoles.subdomain>
				<cfset application.roleLookup[getRoles.name] = structNew()>
				<cfset application.roleLookup[getRoles.name].roleID  = getRoles.roleID>
				<cfset application.roleLookup[getRoles.name].name = getRoles.name>
			</cfloop>
	 	  <cfreturn true>
	 </cffunction>


	<!--- Create Sales Cache Struct --->
	<cffunction name="cacheSalesTeam" access="public" hint="Creates Application struct variable of sales reps. {{application.salesTeam}}">
		<cfloop collection="#application.roles#" item="i">
			<cfif application.roles[i].name EQ "sales">
				<cfset roleID = i>
				<cfbreak>
			</cfif>
		</cfloop>

		<!--- Get Users --->
		<cfquery name="getSalesTeam" datasource="#application.contentDB#">
			select * from
			users
			where userRole = <cfqueryparam cfsqltype="cf_sql_integer" value="#roleID#" >
			and active = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
		</cfquery>

		<cfif !structKeyExists(application, "salesTeam")>
			<cfset application.salesTeam = structNew()>
		</cfif>
		<cfloop query="getSalesTeam">
			<cfset application.salesTeam[getsalesTeam.userID] = structNew()>
			<cfset application.salesTeam[getsalesTeam.userID].userID = getSalesTeam.userID>
			<cfset application.salesTeam[getsalesTeam.userID].email = getSalesTeam.email>
			<cfset application.salesTeam[getsalesTeam.userID].employeeID = getSalesTeam.employeeID>
			<cfset application.salesTeam[getsalesTeam.userID].authToken = getSalesTeam.authToken>
		</cfloop>
		<cfreturn true>
	</cffunction>


	<!--- Cache Categories --->
	<cffunction name="cacheCategories" access="public" hint="Creates Category Cache">

		<!--- Get Category Types ---->
		<cfquery name="getCategoryTypes" datasource="#application.contentDB#">
			select catTypeID, name, createdDate, createdBy, seoName, icon
			from categories_types
		</cfquery>

		<!--- Get Categories --->
		<cfquery name="categories" datasource="#application.contentDB#">
			select categoryID, name, type, dateCreated, createdBy, icon, seoName
			from categories
		</cfquery>

		<cfif !structKeyExists(application, "categories")>
			<cfset application.categories = structNew()>
			<cfset application.categoryTypeLookup = structNew()>
		</cfif>

		<cfloop query="getCategoryTypes">
			<cfset application.categories[getCategoryTypes.catTypeID] = structNew()>
			<cfset application.categories[getCategoryTypes.catTypeID].icon = getCategoryTypes.icon>
			<cfloop list="#getCategoryTypes.columnList#" index="i">
				<cfset application.categories[getCategoryTypes.catTypeID][i] = getCategoryTypes[i][getCategoryTypes.currentRow]>
			</cfloop>
			<cfset application.categories[getCategoryTypes.catTypeID].drugCount = 0>
			<cfset application.categories[getCategoryTypes.catTypeID].categories = structNew()>
			<cfset application.categoryTypeLookup[getCategoryTypes.name] = structNew()>
			<cfset application.categoryTypeLookup[getCategoryTypes.name].id = getCategoryTypes.catTypeID>
		</cfloop>

		<cfloop query="categories">
			<cfset i = categories.categoryID>
			<cfset application.categories[categories.type].categories[i] = structNew()>

			<cfloop list="#categories.columnList#" index="x">
				<cfset application.categories[categories.type].categories[i][x] = categories[x][categories.currentRow]>
			</cfloop>
			<cfset application.categories[categories.type].drugCount++>
			<cfset application.categories[categories.type].categories[i].drugCount = 0>
			<cfset application.categories[categories.type].seoLookup[categories.seoName] = structNew()>
			<cfset application.categories[categories.type].seoLookup[categories.seoName].id = i>
		</cfloop>

		<cfreturn true>
	</cffunction>


	<!--- Cache Ingredients --->
	<cffunction name="cacheIngredients" access="public" hint="Creates Application struct variable of ingredients">

		<cfset ingredientCategoryID = application.categoryTypeLookup['ingredients'].id>

		<cfquery name="getIngredients" datasource="#application.contentDB#">
			select ingredientID, name, active, categoryID, manufactID
			from ingredients
			order by name asc
		</cfquery>

		<cfif !structKeyExists(application, "ingredients")>
			<cfset application.ingredients = structNew()>
		</cfif>

		<cfset application.alphaLists.ingredients = valueList(getIngredients.ingredientID)>

		<cfloop query="getIngredients">
			<cfset application.drugs["ingredients"][getIngredients.ingredientID] = structNew()>
			<cfloop list="#getIngredients.columnList#" index="i">
				<cfset application.drugs["ingredients"][getIngredients.ingredientID][i] = getIngredients[i][getIngredients.currentRow]>
			</cfloop>
			<cfset application.categories[ingredientCategoryID].categories[getIngredients.categoryID].drugCount++>
		</cfloop>

		<cfreturn true>
	</cffunction>


	<cffunction name="createDrugCache" access="public" hint="">
			<cfset application.drugs = structNew()>

			<cfset application.drugs["ingredients"] = structNew()>
			<cfinvoke component="controllers.Cache" method="cacheIngredients" />


			<cfset application.drugs["compounds"] = structNew()>
			<cfinvoke component="controllers.Cache" method="cacheCompounds" />

			<cfset application.drugs["manufactured"] = structNew()>
			<cfinvoke component="controllers.Cache" method="cacheManufacturedDrugs" />

		<cfreturn true>
	</cffunction>



	<!--- Cache Compopunds --->
	<cffunction name="cacheCompounds" access="public" hint="Creates Compound Cache Variable">

		<cfset compoundCategoryID = application.categoryTypeLookup['compounds'].id>

		<!--- Get All Compounds --->
		<cfquery name="getCompounds" datasource="#application.contentDB#">
			select compoundID, name, categoryID, createDate, createdBy, available, lastModified, seoName, manufactID
			from compounds
		</cfquery>

		<!--- Get Compound Notes --->
		<cfquery name="getCompoundNotes" datasource="#application.contentDB#">
			select noteID, noteText, compoundID, user, postDate
			from compounds_notes
		</cfquery>


		<!--- Get Compound Ingredients --->
		<cfquery name="getCompoundIngredients" datasource="#application.contentDB#">
			select compIngID, ingredientID, compoundID, dateCreated, percentage, dosage
			from compounds_ingredients
		</cfquery>

		<!--- Get Compound Ingredient Notes --->


		<!--- Populate Compound Cache --->
		<cfloop query="getCompounds">
			<cfset application.drugs["compounds"][getCompounds.compoundID] = structNEw()>
			<cfloop list="#getCompounds.columnList#" index="i">
				<cfset application.drugs["compounds"][getCompounds.compoundID][i] = getCompounds[i][getCompounds.currentRow]>
			</cfloop>
			<cfset application.drugs["compounds"][getCompounds.compoundID].ingredients = structNew()>
			<cfset application.categories[compoundCategoryID].categories[getCompounds.categoryID].drugCount++>
		</cfloop>

		<!--- Add Ingredients to Compound Cache --->
		<cfloop query="getCompoundIngredients">

			<!--- If Compound and Ingredient are valid --->
			<cfif structKeyExists(application.drugs['compounds'], getCompoundIngredients.compoundID)
				and structKeyExists(application.drugs['ingredients'], getCompoundIngredients.ingredientID)>

				<!--- Create Ingredient Name Struct --->
				<cfset ingredientName = application.drugs['ingredients'][getCompoundIngredients.ingredientID].name>
				<cfset application.drugs['compounds'][getCompoundIngredients.compoundID].ingredients[ingredientName] = structNew()>
				<cfset application.drugs['compounds'][getCompoundIngredients.compoundID].ingredients[ingredientName].notes = structNew()>
				<!--- Populate Ingredient Struct with info about this ingredient respective to compound --->
				<cfloop list="#getCompoundIngredients.columnList#" index="i">
					<cfset application.drugs['compounds'][getCompoundIngredients.compoundID].ingredients[ingredientName][i] = getCompoundIngredients[i][getCompoundIngredients.currentRow]>
				</cfloop>
			</cfif>
		</cfloop>

		<!--- Add Notes to Compound ---->
		<cfloop query="getCompoundNotes">

		</cfloop>


		<cfreturn true>
	</cffunction>


	<!--- Cache Manufactured Drugs --->
	<cffunction name="cacheManufacturedDrugs" access="public" hint="Creates Manufactured Drug Cache Variable">

		<cfset manufacturedCategoryID = application.categoryTypeLookup['manufactured'].id>

		<cfquery name="getManufactured" datasource="#application.contentDB#">
			select drugID, manufactID, name, categoryID, createDate, available, createdBy, lastModified, seoName
			from manufactured_drugs
		</cfquery>
		<cfloop query="getManufactured">

			<cfset application.drugs["manufactured"][getManufactured.drugID] = structNEw()>
			<cfloop list="#getManufactured.columnList#" index="i">
				<cfset application.drugs["manufactured"][getManufactured.drugID][i] = getManufactured[i][getManufactured.currentRow]>
			</cfloop>

			<cfset application.categories[manufacturedCategoryID].categories[getManufactured.categoryID].drugCount++>
		</cfloop>
		<cfreturn true>
	</cffunction>


	<!--- Cache Manufacturers --->
	<cffunction name="cacheManufacturers" access="public" hint="">
		<cfquery name="getManufacturers" datasource="#application.contentDB#">
			select manufactID, name, createDate, createdBy
			from manufacturers
		</cfquery>

		<cfif !structKeyExists(application, "manufacturers")>
			<cfset application.manufacturers = structNew()>
		</cfif>
		<cfloop query="getManufacturers">
			<cfset application.manufacturers[getManufacturers.manufactID] = structNEw()>
			<cfloop list="#getManufacturers.columnList#" index="i">
				<cfset application.manufacturers[getManufacturers.manufactID][i] = getManufacturers[i][getManufacturers.currentRow]>
			</cfloop>
		</cfloop>
		<cfreturn true>
	</cffunction>


	<!--- Cache Patients --->
	<cffunction name="createPatientCache" access="public" hint="creates empty patient cache struct">
		<cfset application.patients = structNew()>
	</cffunction>


	<!--- Cache Insurance Carriers --->
	<cffunction name="cacheInsuranceCarriers" access="public" hint="">
		<cfset application.InsuranceCarriers = structNew()>
		<cfquery name="getCarriers" datasource="#application.contentDB#">
			select carrierID, name, createDate
			from insurance_companies
		</cfquery>
		<cfloop query="getCarriers">
			<cfset application.insuranceCarriers[getCarriers.carrierID] = structNew()>
			<cfset application.insuranceCarriers[getCarriers.carrierID].carrierID = getCarriers.carrierID>
			<cfset application.insuranceCarriers[getCarriers.carrierID].name = getCarriers.name>
			<cfset application.insuranceCarriers[getCarriers.carrierID].createDate = getCarriers.createDate>
		</cfloop>
		<cfreturn true>
	</cffunction>


	<!--- Cache Eligable Rx Status --->
	<cffunction name="cacheEligableRxStatus" access="public" hint="">

		<cfset application.rxStatus = structNew()>

		<cfquery name="getStatuses" datasource="#application.rxDB#">
			select statusID, name, createDate
			from prescriptions_status
		</cfquery>

		<cfloop query="getStatuses">
			<cfset application.rxStatus[getStatuses.name] = structNew()>
			<cfset application.rxStatus[getStatuses.name].statusID = getStatuses.statusID>
			<cfset application.rxStatus[getStatuses.name].name = getStatuses.name>
			<cfset application.rxStatus[getStatuses.name].createDate = getStatuses.createDate>

			<cfset application.rxStatusIDLookup[getStatuses.statusID] = structNew()>
			<cfset application.rxStatusIDLookup[getStatuses.statusID].name = getStatuses.name>
		</cfloop>

		<cfreturn true>
	</cffunction>


	<!--- Create Form Mask --->
	<cffunction name="createFormMasks" access="public" hint="Generates the Masking for Commonly used form names">

		<cfset  patientList = "firstName,middleName,lastName,dob,ssn,email,homePhone,mobilePhone,allergies">
		<cfset insuranceList = "insCarrierName,insPlanName,insBinNumber,insPlanNumber,insCarrierPhone,insPCNNumber,insInsuranceName,insGroupNumber,insuranceSelect">
		<cfset addressList = "shipAddress1,shipAddress2,shipCity,shipState,shipZip,billAddress1,billAddress2,billCity,billState,billZip,billingSelect,shippingSelect">
		<cfset idList = "patientID">
		<cfset fullMaskList = patientList & "," & insuranceList & "," & addressList & "," & idList>
		<cfset prefix = "am3x-">

		<cfset application.formMask = structNew()>
		<cfset application.formMaskLookup = structNew()>

		<cfloop list="#fullMaskList#" index="i">
			<cfset nameHash = hash(prefix & i)>
			<cfset application.formMaskLookUp[nameHash] = structNew()>
			<cfset application.formMaskLookUp[nameHash].name = i>

			<cfset application.formMask[i] = structNew()>
			<cfset application.formMask[i].hash = nameHash>
		</cfloop>

		<cfreturn true>
	</cffunction>


	<!--- Cache Event Types --->
	<cffunction name="cacheEventTypes" access="public" hint="Generates App Variable for Event ID Lookup">

		<cfset application.eventTypes = structNew()>
		<cfset application.eventTypeLookup = structNew()>

		<cfquery name="getTypes" datasource="#application.internalDB#">
			select events_types.eventTypeID, events_types.shortName, events_types.name,
			events_types.createDate, events_types.createdBy, events_types.eventGroupID,
			events_groups.name as groupName
			from events_types
			left join events_groups on events_types.eventGRoupID = events_groups.eventGroupID
		</cfquery>

		<cfloop query="getTypes">
			<cfset application.eventTypes[getTypes.shortName] = structNew()>
			<cfset application.eventTypes[getTypes.shortName].id = getTypes.eventTypeID>
			<cfset application.eventTypes[getTypes.shortName].shortName = getTypes.shortName>
			<cfset application.eventTypes[getTypes.shortName].name = getTypes.name>
			<cfset application.eventTypes[getTypes.shortName].createDate = getTypes.createDate>
			<cfset application.eventTypes[getTypes.shortName].createdBy = getTypes.createdBy>
			<cfset application.eventTypes[getTypes.shortName].eventGroupID = getTypes.eventgroupID>
			<cfset application.eventTypes[getTypes.shortName].eventGroupName = getTypes.groupName>

			<cfset application.eventTypeLookup[getTypes.eventTypeID] = structNew()>
			<cfset application.eventTypeLookup[getTypes.eventTypeID].name = getTypes.shortName>
		</cfloop>

		<cfreturn true>
	</cffunction>


	<!--- Create IP Cache --->
	<cffunction name="createIpCache" access="public" hint="Generates Cache Struct of Approved IPS">

		<cfset application.authorizedIps = structNew()>
		<cfset application.authorizedIps.amexIps = structNew()>
		<cfset application.authorizedIps.doctorIps = structNew()>
		<cfset application.authorizedIps.salesIps = structNew()>

		<!--- Get Amex Ips --->
		<cfquery name="getAmexIps" datasource="#application.contentDB#">
			select users.userID, ip, dateAdded, expires, expiresAt
			from users_ip_authorized
			inner join users on users.userID = users_ip_authorized.userID
			where users.userRole IN ('1','2','6')
		</cfquery>

		<!--- Get Doctor IPs --->
		<cfquery name="getDoctorIPs" datasource="#application.contentDB#">
			SELECT doctors.doctorID, ip, dateAdded, expires, expiresAt
			FROM doctors_ip_authorized
			inner JOIN doctors ON doctors.doctorID = doctors_ip_authorized.doctorID
		</cfquery>

		<!--- Get Sales IPs --->
		<cfquery name="getSalesIps" datasource="#application.contentDB#">
			select users.userID, ip, dateAdded, expires, expiresAt
			from users_ip_authorized
			inner join users on users.userID = users_ip_authorized.userID
			where users.userRole = 3
		</cfquery>

		<!--- Insert Amex IPs --->
		<cfloop query="getAmexIps">
			<cfset ipData = structNew()>
			<cfloop list="#getAmexIps.columnList#" index="i">
				<cfset ipData[i] = getAmexIps[i][getAmexIps.currentRow]>
			</cfloop>
			<cfif structKeyExists(application.authorizedIps.amexIps, getAmexIps.ip)>
				<cfset application.authorizedIps.amexIps.users = listAppend(application.authorizedIps.amexIps.users, getAmexIps.userID)>
			<cfelse>
				<cfset application.authorizedIps.amexIps[getAmexIps.ip] = ipData>
				<cfset application.authorizedIps.amexIps[getAmexIps.ip].users = getAmexIps.userID>
			</cfif>
		</cfloop>

		<!--- Insert All Doctor Ips --->
		<cfloop query="getDoctorIPs">
			<cfset ipData = structNew()>
			<cfloop list="#getDoctorIPs.columnList#" index="i">
				<cfset ipData[i] = getDoctorIPs[i][getDoctorIPs.currentRow]>
			</cfloop>
			<cfif structKeyExists(application.authorizedIps.doctorIps, getDoctorIPs.ip)>
				<cfset application.authorizedIps.doctorIps[getDoctorIPs.ip].users = listAppend(application.authorizedIps.doctorIps[getDoctorIPs.ip].users, getDoctorIps.userID)>
			<cfelse>
				<cfset application.authorizedIps.doctorIps[getDoctorIPs.ip] = ipData>
				<cfset application.authorizedIps.doctorIps[getDoctorIPs.ip].users = getDoctorIps.doctorID>
			</cfif>
		</cfloop>

		<!--- Insert Sales IPs --->
		<cfloop query="getSalesIPs">
			<cfset ipData = structNew()>
			<cfloop list="#getSalesIPs.columnList#" index="i">
				<cfset ipData[i] = getSalesIPs[i][getSalesIPs.currentRow]>
			</cfloop>
			<cfif structKeyExists(application.authorizedIps.salesIps, getsalesIPs.ip)>
				<cfset application.authorizedIps.salesIps[getsalesIPs.ip].users = listAppend(application.authorizedIps.salesIps[getsalesIPs.ip].users, getSalesIp.userID)>
			<cfelse>
				<cfset application.authorizedIps.salesIps[getsalesIPs.ip] = ipData>
				<cfset application.authorizedIps.salesIps[getsalesIPs.ip].users = getSalesIps.userID>
			</cfif>
		</cfloop>

		<cfreturn true>
	</cffunction>

</cfcomponent>
