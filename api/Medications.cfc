<cfcomponent>
	
<!---

	Ingredient Functions

--->	
	
	
	<!--- Get Ingredients ---->
	<cffunction name="getIngredients" access="public" hint="Returns all ingredients in database">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="fromCache" type="string" default="true">
		
		<cfset result = structNew()>
		<!--- Check if token is valid --->		
			<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
		
		<!--- If token is valid, get and return ingredients ---->
		<cfif tokenOwner.status>
			<cfset result.ingredients = arrayNew(1)>
			<cfset result.status = true>
			<!--- If we are pulling from cache --->
			<cfif arguments.fromCache>
					<cfloop collection="application.ingredients" item="i">
						<cfset result.ingredients[arrayLen(result.ingredients)] = structNew()>
						<cfset result.ingredients[arrayLen(result.ingredients)].ingredientID = application.ingredients[i].ingredientID>
						<cfset result.ingredients[arrayLen(result.ingredients)].name = application.ingredients[i].name>
						<cfset result.ingredients[arrayLen(result.ingredients)].active = application.ingredients[i].active>
					</cfloop>
			<!--- if we are querying DB --->
			<cfelse>
				<cfquery name="getIngredients" datasource="#application.contentDB#">
					select ingredientID, name, available
					from ingredients
				</cfquery>
				<cfloop query="getIngredients">
					<cfset result.ingredients[arrayLen(result.ingredients)] = structNew()>
					<cfset result.ingredients[arrayLen(result.ingredients)].ingredientID = getIngredients.ingredientID>
					<cfset result.ingredients[arrayLen(result.ingredients)].name = getIngredients.name>
					<cfset result.ingredients[arrayLen(result.ingredients)].active = getIngredients.active>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset result.status = false>
			<cfset result.message = "Invalid Auth Token">
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>	
	
	
	<!--- Create Ingredient --->
	<cffunction name="createIngredient" access="public" hint="creates a globally available ingrediant">
		<cfargument name="name" type="string" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin,Tech">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!---- Check if ingredient Exists --->
		<cfif result.status>
			<cfquery name="checkExisting" datasource="#application.contentDB#">
				select ingredientID
				from ingredients
				where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#"> 
			</cfquery>
			
			<cfif checkExisting.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Ingredient Exists in Database">
			</cfif>
		</cfif>
	
		<!--- Insert Ingredient if still valid --->
		<cfif result.status>
			
			<cfquery name="newIngredient" datasource="#application.contentDB#" result="createdIngredient">
				insert into ingredients
				(name, createDate, active, addedBy)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,     
				<cfqueryparam cfsqltype="cf_sql_integer" value="1">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#">   
				)
			</cfquery>
			
			<!--- Add Ingredient to cache --->
			<cfset application.ingredients[createdIngredient.generated_key] = structNew()>
			<cfset application.ingredients[createdIngredient.generated_key].name = arguments.name>
			<cfset application.ingredients[createdIngredient.generated_key].active = 1>
			<cfset application.ingredients[createdIngredient.generated_key].id = createdIngredient.generated_key>
			
			
			<cfset result.message = "Created Global Ingredient: #arguments.name#">
		</cfif>
			
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	<!--- Remove Ingredient --->
	<cffunction name="removeIngredient" access="public" hint="Removes an ingredient from database">
		<cfargument name="ingredientID" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin,Tech">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!---- Check if ingredient Exists --->
		<cfif result.status>
			<cfquery name="checkExisting" datasource="#application.contentDB#">
				select ingredientID
				from ingredients
				where ingredientID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ingredientID#"> 
			</cfquery>
			
			<cfif checkExisting.recordCount>
				
				<cfquery name="deleteIngredient" datasource="#applocation.contentDB#">
					delete from ingredients
					where ingredientID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ingredientID#"> 
				</cfquery>
				
				<cfset result.message = "Removed Ingredient from Database">
				
				<!--- Check if exists in cache, if it does, remove it --->
				<cfif structKeyExists(application.drugs["ingredients"], arguments.ingredientID)>
					<cfset structDelete(application.ingredients, arguments.ingredientID)>
				</cfif>
			<Cfelse>	
				<cfset result.status = false>
				<cfset result.message = "Ingredient does not exist in Database">
			</cfif>
		</cfif>
	
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!---Update Availability --->
	<cffunction name="updateIngredientAvaiability">
		<cfargument name="available" default="1" type="numeric">
		<cfargument name="ingredientID" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = true>
		<cfset result.message = "Invalid Auth Token">
		<cfset statusOptions = "0,1">
		<cfset authorizedRoles = "Pharmacist,Admin,Tech">

		
		<cfif !listFind(arguments.available, status.options)>
			<cfset result.message = "Invalid Status. Accepted Values are 0 or 1">
			<cfset result.status = false>	
		</cfif>
		
		<cfif result.status>
			<cfset result.status = false>
			
			<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
				<cfinvokeargument name="token" value="#arguments.authToken#">
				<cfinvokeargument name="enc" value="#arguments.enc#">
			</cfinvoke>
				
			<!--- Check if token is in authorized Role List  --->
			<cfloop list="#authorizedRoles#" index="i">
				<cfif tokenOwner.role eq application.roleLookup[i].roleID>
					<cfset result.status = true>
				</cfif>
			</cfloop>
		
		</cfif>
	
		
		<cfif result.status>
			<!--- Change Status --->
			<cfquery name="changeStatus" datasource="#application.contentDB#">
				update ingredients
				set active = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.available#"> 
			</cfquery>
			<cfset result.message = "Updated Ingredient Status">	
		</cfif>
	
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction> 



<!---
	
	Category Functions
	
---->

	<!--- Create Category ---->
	<cffunction name="createCategory" access="public" hint="Creates a new Category">
		<cfargument name="name" type="string" required="true">
		<cfargument name="icon" type="string" default="">
		<cfargument name="type" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Admin,Pharmacist,Tech">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		
		<!--- Upload Icon --->
		
		
		
		<!--- Check that Type is Valid --->
		<cfif result.status>
			<cfquery name="checkType" datasource="#application.contentDB#">
				select catTypeID
				from categories_types
				where catTypeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.type#"> 
			</cfquery>		
			<cfif !checkType.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Invalid Category Type">
			</cfif>
		</cfif>
		
		<!--- Check that category doesnt exist for this type already --->
		<cfif result.status>
			<cfquery name="checkCat" datasource="#application.contentDB#">
				select categoryID
				from categories
				where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#"> 
			</cfquery>	
			<cfif checkCat.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Category already Exists">
			</cfif>
		</cfif>
		
		
		<!--- create Category record --->
		<cfif result.status>
			
			<!--- Create Seo String --->
			<cfinvoke component="miscellaneous.Utils" method="createSEOstring" returnVariable="seoString"> 
				<cfinvokeargument name="string" value="#arguments.name#">
			</cfinvoke>
			
			
			<cfquery name="insertCategory" datasource="#application.contentDB#" result="newCategory">
				insert into categories
				(
				name, type, dateCreated, createdBy, icon, seoName
				)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.type#">,   
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, 
				<cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.icon#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#seoString#">
				)
			</cfquery>
		
			<cfset result.message = "Created New Category: #arguments.name#">
			<cfset i = newCategory.generated_key>
			
			<!--- Add To Cache --->
			<cfset application.categories[arguments.type].categories[i] = structNew()>
			<cfset application.categories[arguments.type].categories[i].categoryID = i>
			<cfset application.categories[arguments.type].categories[i].name = arguments.name>
			<cfset application.categories[arguments.type].categories[i].seoName = seostring>
			<cfset application.categories[arguments.type].categories[i].dateCreated = now()>
			<cfset application.categories[arguments.type].categories[i].createdBy = tokenOwner.userID>
			<cfset application.categories[arguments.type].categories[i].icon = arguments.icon>	
		
			<cfset application.categories[arguments.type].seoLookup[seostring] = structNew()>
			<cfset application.categories[arguments.type].seoLookup[seostring].id = i>
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>


	<!--- Create New Category Type --->
	<cffunction name="createCategoryType" access="public" hint="Creates new Type of Category System">
		<cfargument name="name" type="string" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Admin">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!--- Check that type doesnt exist --->
		<cfif result.status>
			<cfquery name="checkType" datasource="#application.contentDB#">
				select catTypeID
				from categories_types
				where name= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#"> 
			</cfquery>
	
			<cfif checkType.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Category Type already Exists">
			</cfif>
		</cfif>
	
		<!--- Create Category --->
		<cfif result.status>
			
			<!--- Create Seo String --->
			<cfinvoke component="miscellaneous.Utils" method="createSEOstring" returnVariable="seoString"> 
				<cfinvokeargument name="string" value="#arguments.name#">
			</cfinvoke>
			
			<cfquery name="createCategory" datasource="#application.contentDB#" result="createdCategory">
				insert into categories_types
				(name, createdDate, createdBy, seoName)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#seoString#"> )
			</cfquery>
			
			<cfset result.message = "Created Category: #arguments.name#">
			
			<!--- Add To Cache --->
			<cfset i = createdCategory.generated_key>
			
			<cfset application.categories[i] = structNew()>
			<cfset application.categories[i].name = arguments.name>
			<cfset application.categories[i].catTypeID = i>
			<cfset application.categories[i].seoName = seoString>
			<cfset application.categories[i].createdDate = now()>
			<cfset application.categories[i].createdBy = tokenOwner.userID>
			<cfset application.categories[i].categories = structNew()>
			<cfset application.categories[i].seoLookup = structNew()>
			
			<cfset application.categoryTypeLookup[seoString] = structNew()>
			<cfset application.categoryTypeLookup[seoString].id = i>
		</cfif>
	
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!--- Get Categories --->
	<cffunction name="getCategories" access="public" hint="">
		<cfargument name="type" type="numeric" default="0" hint="type of Categories to get, 0 to get all">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin,Tech,Sales">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<cfif result.status>
			<cfset result.categories = arrayNew(1)>
			<cfquery name="categories" datasource="#application.contentDB#">
				select categoryID, name, type, dateCreated, createdBy, icon, seoName
				from categories
				<cfif arguments.type NEQ 0>
					where type = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.type#" > 
				</cfif>
			</cfquery>
			
			<cfloop query="categories">
				<cfset i = arrayLen(result.categories) + 1>
				<cfset result.categories[i] = structNew()>
				<cfset result.categories[i].categoryID = categories.categoryID>
				<cfset result.categories[i].name = categories.name>
				<cfset result.categories[i].type = categories.type>
				<cfset result.categories[i].dateCreated = categories.dateCreated>
				<cfset result.categories[i].createdBy = categories.createdBy>
				<cfset result.categories[i].icon = categories.icon>
				<cfset result.categories[i].seoName = categories.seoName>
			</cfloop>
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	
	
	<!--- Link Med Category to Item --->
	<cffunction name="linkToCategory" access="public" hint="Links a medication to a categoryID">
		<cfargument name="categoryID" type="numeric" required="true">
		<cfargument name="itemID" type="string" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin,Tech">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		
	
	
	
	
	
	
	
	
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
		
		
		
<!--- 

	Compound Functions
	
--->		
	
	
	<cffunction name="createCompound" access="public" hint="creates new available compound">
		<cfargument name="name" type="string" required="true">
		<cfargument name="ingredientList" type="string" required="true">
		<cfargument name="category" type="numeric" required="true">
		
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin,Tech">

		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!--- Check that Ingredients are valid --->
		<cfloop list="#arguments.ingredientList#" index="i">
			<cfif !structKeyExists(application.ingredients, i)>
				<cfset result.status = false>
				<cfset result.message = "IngredientID #i# not found">
			</cfif>
		</cfloop>
		
		<!--- Check that compound doesnt exist --->
		<cfif result.status>
			<cfquery name="checkCompound" datasource="#application.contentDB#">
				select compoundID
				from compounds
				where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#"> 
			</cfquery>
		
			<cfif checkCompound.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Compound Exists in Database">
			</cfif>
		</cfif>
		
		<!--- Check that categoryID is valid --->
		<cfif result.status>
			<cfinvoke component="medications" method="isValidCategory" returnVariable="validCategory">
				<cfinvokeargument name="categoryID" value="#arguments.category#">
			</cfinvoke>
			<cfif !validCategory>
				<cfset result.status = false>
				<cfset result.message = "Invalid Category ID">
			</cfif>
		</cfif>
		
		<cfif result.status >
			
			<!--- Create Seo String --->
			<cfinvoke component="miscellaneous.Utils" method="createSEOstring" returnVariable="seoString"> 
				<cfinvokeargument name="string" value="#arguments.name#">
			</cfinvoke>
			
			<!--- Insert Compound --->
			<cfquery name="insertCompound" datasource="#application.contentDB#" result="newCompound">
				insert into compounds
				(name, categoryID, createDate, createdBy, seoName, lastModified)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#seoString#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				)
			</cfquery>
		
			<!--- Insert Ingredients --->
			<cfloop list="#arguments.ingredientList#" index="i">
				<cfquery name="insertIngredient" datasource="#application.contentDB#">
					insert into compounds_ingredients
					(ingredientID, compoundID, dateCreated)
					values
					(
					<cfqueryparam cfsqltype="cf_sql_integer" value="#i#">, 
					<cfqueryparam cfsqltype="cf_sql_integer" value="#newCompound.generated_key#">, 
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
					
					)
				</cfquery>
			</cfloop>
			
			<cfset result.message = "Created Global Compound: #arguments.name#">
			
			
			<!---- Add To Cache --->	
			<cfset i = newCompound.generated_key>
			<cfset application.drugs["compounds"][i] = structNEw()>
			<cfset application.drugs["compounds"][i].compoundID = i>
			<cfset application.drugs["compounds"][i].name = arguments.name>
			<cfset application.drugs["compounds"][i].seoname = seoString>
			<cfset application.drugs["compounds"][i].categoryID = arguments.category>
			<cfset application.drugs["compounds"][i].createDate = now()>
			<cfset application.drugs["compounds"][i].createdBy = tokenOwner.userID>
			<cfset application.drugs["compounds"][i].available = 1>
			<cfset application.drugs["compounds"][i].lastModified = now()>
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	
	
	<!--- Update Compound --->
	<cffunction name="updateCompound" access="public" hint="Update Compound Ingredient List, category and Name">
		<cfargument name="compoundID" type="numeric" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="ingredientList" type="string" required="true">
		<cfargument name="category" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!--- Check that Compound ID is valid --->
		<cfinvoke component="medications" method="isValidCompound" returnVariable="validCompound">
			<cfinvokeargument name="compoundID" value="#arguments.compoundID#">
		</cfinvoke>
		
		<!--- If Compoound ID is valid --->
		<cfif !validCompound>
			<cfset result.status = false>
			<cfset result.message = "Invalid Compound ID">
		</cfif>		
		
		<!--- Check Categoiry ID is valid --->
		<cfif result.status>
			<cfinvoke component="medications" method="isValidCategory" returnVariable="validCategory">
				<cfinvokeargument name="categoryID" value="#arguments.category#">
			</cfinvoke>
			<cfif !validCategory>
				<cfset result.status = false>
				<cfset result.message = "Invalid Category ID">
			</cfif>
		</cfif>
		
		<!--- Check that Ingredients are valid --->
		<cfloop list="#arguments.ingredientList#" index="i">
			<cfif !structKeyExists(application.ingredients, i)>
				<cfset result.status = false>
				<cfset result.message = "IngredientID #i# not found">
			</cfif>
		</cfloop>
		
		
		<!--- If we made it this far, update compound ID --->
		<cfif result.status>
			
			<!--- Update Main Compound Table --->
			<cfquery name="updateCompound" datasource="#application.contetDB#">
				update compounds
				set name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#" >,
					categoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.categoryID#" >,
					lastModified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" > 
				where compoundID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundID#"> 
			</cfquery>
			
			<!--- get Current Ingredients --->
			<cfinvoke component="medications" method="getIngredients" returnVariable="currentIngredients" > 
				<cfinvokeargument name="fromCache" value="false">
				<cfinvokeargument name="authToken" value="#arguments.authToken#">
				<cfinvokeargument name="returnType" value="struct">
			</cfinvoke>
			
			<cfset toDelete = "">
			<cfset toAdd = arguments.ingredients>
			
			<!--- Find items to Delete and Items that need to be added  --->
			<cfloop from="1" to="#arrayLen(currentIngredients.ingredients)#" index="i">
				<cfif !listFind(i, arguments.ingredients)>
					<cfset toDelete = listAppend(toDelete, i)>
				</cfif>
				<cfset toAdd = ListDeleteAt(arguments.ingredients, ListFind(i, arguments.ingredients), ",")>
			</cfloop>
			
			<!--- If we have items to Delete --->
			<cfif ListLen(toDelete)>
				
				<!--- Delete Ingredients --->
				<cfquery name="deleteOldRecs" datasource="#application.contentDB#">
					delete from compounds_ingredients
					where compoundID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundID#"> 
					and ingredientID in <cfqueryparam cfsqltype="cf_sql_varchar" value="#toDelete#" > 
				</cfquery>
				
				<!--- Delete Ingredient Notes --->
				<cfquery name="deleteOldNoteRecs" datasource="#application.contentDB#">
					delete from compounds_ingredients_notes
					where compoundID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundID#"> 
					and ingredientID in <cfqueryparam cfsqltype="cf_sql_varchar" value="#toDelete#" > 
				</cfquery>
			</cfif>
			
			<!--- Insert Ingredient Records for the New Items --->
			<cfif listLen(toAdd)>
				<cfloop list="#toAdd#" index="i">
					<cfquery name="createIngredientRec" datasource="#application.contentDB#">
						insert into compounds_ingredients
						(ingredientID, compoundID, dateCreated)
						values
						(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#i#">,
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundID#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">    
						)
					</cfquery>
				</cfloop>
			</cfif>
			
			<!--- Update Cache --->	
				
				
			<!--- Record Action --->	
			
				
			
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!--- Update Compound Ingredient ---->
	<cffunction name="updateCompoundIngredient" access="public" hint="Update Compound Ingredient">
		<cfargument name="compoundIngridientID" type="numeric" required="true">
		<cfargument name="percentage" type="string" required="true">
		<cfargument name="dosage" type="string" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<cfif result.status>
			<!--- Check that Compound Ingredient ID is valid --->
			<cfquery name="checkID" datasource="#application.contentDB#">
				select compIngID
				from compounds_ingredients
				where compIngID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundIngredientID#" > 
			</cfquery>
			
			<cfif !checkID.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Invalid Compound Ingredient ID">
			</cfif>
		</cfif>
		
		<!-- Update Info --- >
		<cfif result.status>
			
			<!--- Update DB --->
			<cfquery name="updateIngredient" datasource="#application.contentDB#">
				update compounds_ingredients
				set percentage = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.precentage#">, 
					dosage = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.dosage#" >,
					lastModified = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" > 
				where compIngID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundIngredientID#" > 
			</cfquery>
		
			<!--- Update Cache --->
		
		
		
		
		
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!--- Check if Compound ID is Valid --->
	<cffunction name="isValidCompound" returnType="string" access="public" hint="Returns boolean if compound ID exists">
		<cfargument name="compoundID" type="numeric" required="true">
		<cfquery name="checkID" datasource="#application.contentDB#">
			select compoundID
			from compounds
			where compoundID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundID#"> 
		</cfquery>
		<cfif checkID.recordCount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	
	<!--- Check if Valid Category --->
	<cffunction name="isValidCategory" returnType="string" access="public" hint="returns boolean if category exists">
		<cfargument name="categoryID" type="numeric" required="true">
		<cfquery name="checkCat" datasource="#application.contentDB#">
			select categoryID
			from categories
			where categoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.categoryID#"> 
		</cfquery>
		<cfif checkCat.recordCount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	
	<!--- Delete Compound --->
	<cffunction name="deleteCompound" access="public" hint="creates new available compound">
		<cfargument name="compoundID" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!--- Check that Compound ID is valid --->
		<cfinvoke component="medications" method="isValidCompound" returnVariable="validCompound">
			<cfinvokeargument name="compoundID" value="#arguments.compoundID#">
		</cfinvoke>
		
		<!--- If Compoound ID is valid --->
		<cfif !validCompound>
			<cfset result.status = false>
			<cfset result.message = "Invalid Compound ID">
		</cfif>		
		
		
		<cfif result.status>
			
			<!--- Create Undo Datastore --->
			
			
			<!--- Delete Compound --->
			<cfquery name="deleteCompound" datasource="#application.contentDB#">
				delete from compounds_ingredients
				where compoundID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundID#"> 
			</cfquery>
			
			<!--- Delete Ingredients --->
			<cfquery name="deleteIngredients" datasource="#application.contentDB#">
				delete from compounds_ingredients
				where compoundID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundID#"> 
			</cfquery>
			
			<!--- Delete Ingredient Notes --->
			<cfquery name="deleteNotes" datasource="#application.contentDB#">
				delete from compounds_ingredients_notes
				where compoundID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.compoundID#"> 
			</cfquery>
			
			<cfset message = "Removed Compound ID from database">
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	
	<!--- 
	
		Manufactured Drugs 
	
	---->
	
	
	<!--- Get Manufactured Drugs --->
	<cffunction name="getManufacturedDrugs" access="public" hint="Returns manufactured drugs in requested format">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
	
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<cfif tokenOwner.status>
			<cfset result.status = true>
			
			<cfif arguments.source EQ "database">
				
				<cfset result.drugs = arrayNew(1)>
				
				<cfquery name="manufacturedDrugs" datasource="#application.contentDB#">
					select drugID, manufactID, categoryID, name, createDate, available, createdBy, lastModified, seoName
					from manufactured_drugs
				</cfquery>
				
				<cfloop query="manufacturedDrugs">
					<cfset x = arrayLen(result.drugs) + 1>
					<cfset result.drugs[x] = structNew()>	
					<cfloop list="#manufacturedDrugs.columnList#" index="i">
						<cfset result.drugs[x][i] = manufacturedDrugs[i][manufacturedDrugs.currentRow]>
					</cfloop>
				</cfloop>
			
			<cfelse>
			
			
			</cfif>
			
			
		</cfif>
	
	
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	
	
	
	
	
	
	<!--- Create Manufactured Drug --->
	<cffunction name="createManufacturedDrug" access="public" hint="creates a manufactured Drug record">
		<cfargument name="name" type="string" required="true" hint="Name of new Manufactured Drugs">
		<cfargument name="manufacturer" type="string" required="true" hint="Manufacturer Name">
		<cfargument name="category" type="numeric" required="true" hint="Category ID to assign Drug">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!--- Check that Drug doesnt exist --->
		<cfif result.status>
			<cfquery name="existingDrug" datasource="#application.contentDB#">
				select name
				from manufactured_drugs
				where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">				
			</cfquery>
			<cfif existingDrug.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Drug with that name already exists in database">
			</cfif>
		</cfif>
		
		<!--- Check category ID is valid --->
		<cfif result.status>
			<cfquery name="checkCat" datasource="#application.contentDB#">
				select categoryID
				from categories
				where categoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#"> 
				and categories.Type =  <cfqueryparam cfsqltype="cf_sql_integer" value="5"> 
			</cfquery>
			<cfif !checkCat.recordCount>
				<cfset result.status = false>
				<cfset result.message = "Invalid Category ID">
			</cfif>
		</cfif>
		
		
		<cfif result.status>
			<!--- Get Manufacturer ID --->
				<cfloop collection="#application.manufacturers#" item="i">
					<cfif structKeyExists(application.manufacturers[i], "name") and application.manufacturers[i].name EQ arguments.manufacturer>
						<cfset result.manufactID = i>
					</cfif>
				</cfloop>	
			<cfif !structKeyExists(result, "manufactID")>
				<!--- Insert Manufacturer --->
				<cfinvoke component="medications" method="createMedManufacturer" returnVariable="createdManufacturer" > 
					<cfinvokeargument name="name" value="#arguments.manufacturer#">
					<cfinvokeargument name="returnType" value="struct">
					<cfinvokeargument name="authtoken" value="#arguments.authToken#">
					<cfinvokeargument name="enc" value="#arguments.enc#">
				</cfinvoke>
				<cfset result.manufactID = createdManufacturer.manufactID>
			</cfif>
		</cfif>
		
		<cfif result.status>
			<cfquery name="insertDrug" datasource="#application.contentDB#" result="newDrug">
				insert into manufactured_drugs
				(manufactID, name, categoryID, createDate, available, createdBy)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_integer" value="#result.manufactID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="1"> ,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#"> 
				)
			</cfquery>
			
			<!--- Add Drug to Cache --->
			<cfset application.drugs["manufactured"][newDrug.generated_key] = structNew()>
			<cfset application.drugs["manufactured"][newDrug.generated_key].name = arguments.name>
			<cfset application.drugs["manufactured"][newDrug.generated_key].createDate = now()>
			<cfset application.drugs["manufactured"][newDrug.generated_key].manufactID = result.manufactID>
			<cfset application.drugs["manufactured"][newDrug.generated_key].categoryID = arguments.categoryID>
			<cfset application.drugs["manufactured"][newDrug.generated_key].available = 1>
			<cfset application.drugs["manufactured"][newDrug.generated_key].createdBy = tokenOwner.userId>
			
			<cfset result.message = "Created New Manufactured Drug: #arguments.name#">
		</cfif>
		
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	
	<cffunction name="createMedManufacturer" access="public" hint="Creates a manufacturer record">
		<cfargument name="name" type="string" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!--- Check that manufacturer doesnt exist --->
		<cfif result.status>
			
			<cfquery name="checkExisting" datasource="#application.contentDB#">
				select manufactID
				from manufacturers
				where name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#"> 
			</cfquery>
			
			<cfif checkExisting.recordCount>
				<cfset result.status = false>
			</cfif>
		</cfif>
		
		
		<!--- If we passed checks, create manufacturer --->
		<cfif result.status>
			
			<!--- Create Seo Name --->
			<cfinvoke component="miscellaneous.Utils" method="createSEOstring" returnVariable="seoName"> 
				<cfinvokeargument name="string" value="#arguments.name#">
			</cfinvoke>
			
			<cfquery name="insertManu" datasource="#application.contentDB#" result="newManufacturer">
				insert into manufacturers
				(name,createDate,createdBy,seoName)
				values
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#">,  
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#seoName#">
				)
			</cfquery>
			
			<cfset result.message = "Created Manufacturer: #arguments.name#">
			<cfset result.manufactID = newManufacturer.generated_key>
			
			<!--- Add New Manufacturer to Cache --->
			<cfset application.manufacturers[result.manufactID] = structNew()>
			<cfset application.manufacturers[result.manufactID].name = arguments.name>
			<cfset application.manufacturers[result.manufactID].createdBy = tokenOwner.userID>
			<cfset application.manufacturers[result.manufactID].created = now()>
			<cfset application.manufacturers[result.manufactID].id = result.manufactID>
		</cfif>
		
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!--- Remove Manufactured Drug --->
	<cffunction name="deleteManufacturedDrug" access="public" hint="creates a manufactured Drug record">
		<cfargument name="drugID" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
		
		
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!--- Check that DrugID exists --->
		<cfif result.status>
			<cfquery name="checkExisting" datasource="#application.contentDB#">
				select drugID
				from manufactured_drugs
				where drugID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.drugID#" > 
			</cfquery>
			<cfif !checkExisting.recordCount>
				<cfset result.status = false>
				<cfset result.message = "DrugID: #arguments.drugID# not found">
			</cfif>
		</cfif>
		
		<cfif result.status>
			
			<!--- Remove Record --->
			<cfquery name="removeRecord" datasource="#application.contentDB#">
				delete from manufactured_drugs
				where drugID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.drugID#" > 
			</cfquery>
			
			<!--- Save in Archives --->
			
			
			
			<!--- Remove from Cache --->
			<cfset structDelete(application.drugs["manufactured"], arguments.drugID)>
			
			<cfset result.message = "Deleted Manufactured Drug: #arguments.drugID#">
		</cfif>
		
		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!--- Update Manufactured Drug --->
	<cffunction name="updateManufacturedDrug" access="public" hint="Updates manufactured Drugs information">
		<cfargument name="drugID" type="numeric" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="manufacturer" type="numeric" required="true">
		<cfargument name="authToken" type="string" required="true">
		<cfargument name="returnType" type="string" default="json">
		<cfargument name="enc" type="string" default="false">
	
		<cfset result = structNew()>
		<cfset result.status = false>
		<cfset result.message = "Invalid Auth Token">
		<cfset authorizedRoles = "Pharmacist,Admin">
		
		<!--- Get Token Info --->
		<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
			<cfinvokeargument name="token" value="#arguments.authToken#">
			<cfinvokeargument name="enc" value="#arguments.enc#">
		</cfinvoke>
			
		<!--- Check if token is in authorized Role List  --->
		<cfloop list="#authorizedRoles#" index="i">
			<cfif tokenOwner.role eq application.roleLookup[i].roleID>
				<cfset result.status = true>
			</cfif>
		</cfloop>
		
		<!--- Check that DrugID exists --->
		<cfif result.status>
			<cfquery name="checkExisting" datasource="#application.contentDB#">
				select drugID, manufactID, name
				from manufactured_drugs
				where drugID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.drugID#" > 
			</cfquery>
			<cfif !checkExisting.recordCount>
				<cfset result.status = false>
				<cfset result.message = "DrugID: #arguments.drugID# not found">
				
			<cfelse>
				<cfif arguments.manufacturer NEQ checkExisting.manufactID>
					<cfquery name="checkManu" datasource="#application.contentDB#">
						select manufactID from manufacturers
						where manufactID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.manufacturer#"> 
					</cfquery>
					<cfif !checkManu.recordCount>
						<cfset result.status = false>
						<cfset result.message = "Invalid Manufacturer">
					</cfif>
				</cfif>	
			</cfif>
		</cfif>
		
		<!--- Update Record --->
		<cfif result.status>
			
			
			
		</cfif>

		<cfif arguments.returnType EQ "json">
			<cfreturn serializeJson(result)>
		<cfelse>
			<cfreturn result>
		</cfif>
	</cffunction>
	
	
	<!--- Gets General info about a Medication --->
	<cffunction name="getMedicationInfo" access="public" hint="Gets Information about a drug from database">
		<cfargument name="medicationID" type="numeric" required="true">
		<cfargument name="type" type="string" required="true">
		
			
			
			
			
	</cffunction>
	
	
</cfcomponent>