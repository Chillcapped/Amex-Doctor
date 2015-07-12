<cfcomponent>


  	<!--- Create Office ---->
  	<cffunction name="createOffice" access="public" returnType="struct" hint="">
  		<cfargument name="authToken" type="string" required="true" hint="Auth Token of Doctor or Delegate Requesting Prescriptions">
  		<cfargument name="returnType" type="string" default="json" hint="Format to return data">
  		<cfargument name="enc" type="string" default="false" hint="If Auth token needs to be re-encrypted">
  		<cfargument name="address1" type="string" required="true">
  		<cfargument name="address2" type="string" required="true">
  		<cfargument name="state" type="string" required="true">
  		<cfargument name="zip" type="string" required="true">

  			<cfset result = structNew()>
  			<cfset result.status = false>

  			<!--- Get token Owner --->
  			<cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
  				<cfinvokeargument name="token" value="#arguments.authToken#">
  				<cfinvokeargument name="enc" value="#arguments.enc#">
  			</cfinvoke>

  			<!--- If token is Doctor, set doctorID --->
  			<cfif application.roles[tokenowner.role].name EQ "doctor">
  				<cfset doctorID = tokenOwner.userID>
  				<cfset result.status = true>
  			</cfif>

  		  <!--- Check Address --->
        <cfinvoke component="offices" method="checkExistingAddress" returnVariable="existingAddress">
            <cfinvokeargument name="doctorID" value="#tokenOwner.userID#">
            <cfinvokeargument name="address" value="#address1# #address2# #state# #zip#">
        </cfinvoke>

        <cfif existingAddress>
          <cfset result.status = false>
          <cfset result.message = "Existing Address">
        </cfif>

        <cfif result.status>
          <cfquery name="insertOffice" datasource="amex">
            insert into doctors_offices
            (doctorID,address1,address2,state,zip,fullAddress,officeCreateDate)
            values
            (
              <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.address1#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.address2#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.state#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.zip#">,
              <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.address1# #arguments.address2# #arguments.state# #arguments.zip#">,
              <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
            )
          </cfquery>
          <cfset result.message = "Created Message">
        </cfif>

        <cfreturn result>
  	</cffunction>


    <!--- Delete Office --->
    <cffunction name="deleteOffice" access="public" returnType="struct" hint="">
      <cfargument name="officeID" type="numeric" required="true">
      <cfargument name="authToken" type="string" required="true">
      <cfargument name="enc" type="string" default="false" hint="If Auth token needs to be re-encrypted">

      <cfset result = structNew()>
      <cfset result.status = false>

      <!--- Get token Owner --->
      <cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
        <cfinvokeargument name="token" value="#arguments.authToken#">
        <cfinvokeargument name="enc" value="#arguments.enc#">
      </cfinvoke>

      <!--- If token is Doctor, set doctorID --->
      <cfif application.roles[tokenowner.role].name EQ "doctor">
        <cfset doctorID = tokenOwner.userID>
        <cfset result.status = true>
      </cfif>

      <cfif result.status>
      <cfquery name="deleteOffice" datasource="amex">
        delete from doctors_offices
        where officeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.officeID#">
        and doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#tokenOwner.userID#">
      </cfquery>
        <cfset result.message = "Deleted office">
      </cfif>
      <cfreturn result>
    </cffunction>


    <!--- Check Existing Address --->
    <cffunction name="checkExistingAddress" access="public" returnType="boolean" hint="">
      <cfargument name="address" type="string" required="true">
      <cfargument name="doctorID" type="numeric" required="true">

      <cfquery name="checkAddress" datasource="amex">
        select officeID
        from doctors_offices
        where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
        and fullAddress = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.address#">
      </cfquery>
      <cfif checkAddress.recordCOunt>
        <cfreturn true>
      <cfelse>
        <cfreturn false>
      </cfif>
    </cffunction>


    <!--- Get Offices --->
    <cffunction name="getOffices" access="public">
      <cfargument name="doctorID" type="numeric" required="true">
      <cfargument name="authToken" type="string" required="true" >
      <cfargument name="enc" type="string" default="true">
      <cfargument name="returnType" type="string" default="json">

      <cfset result = structNew()>
      <cfset result.status = true>

      <cfif result.status>
        <!--- Check if token has access to delegate list of this doctor --->
        <cfinvoke component="api.authorize" method="isValidToken" returnVariable="validToken">
          <cfinvokeargument name="userID" value="#arguments.doctorID#">
          <cfinvokeargument name="type" value="doctor">
          <cfinvokeargument name="token" value="#arguments.authToken#">
          <cfinvokeargument name="enc" value="#arguments.enc#">
        </cfinvoke>

        <!--- If Token doesnt match the doctor  --->
        <cfif !validToken>

          <cfset result.status = false>
          <cfset result.message = "Invalid Auth Token">

          <!--- Get Doctors Assigned Sales Rep --->
          <cfinvoke component="api.doctor" method="getDoctorSalesRep" returnVariable="salesRep">
            <cfinvokeargument name="doctorID" value="#arguments.doctorID#">
          </cfinvoke>

          <!--- If Token isnt the sales reps, check if admin token --->
          <cfif !validToken>
            <cfinvoke component="api.authorize" method="getTokenOwner" returnVariable="tokenOwner">
              <cfinvokeargument name="token" value="#arguments.authToken#">
              <cfinvokeargument name="enc" value="#arguments.enc#">
            </cfinvoke>

            <!--- If Sales Token  --->
            <cfif tokenOwner.role EQ 3 and tokenOwner.userID EQ salesREp>
              <cfset result.status = true>
              <cfset result.message = "">
            <!--- If admin Token --->
            <cfelseif tokenOwner.role EQ 1>
              <cfset result.status = true>
              <cfset result.message = "">
            </cfif>
          </cfif>
        </cfif>
      </cfif>

      <!--- If we can return offices --->
      <cfif result.status>
        <cfquery name="getOffices" datasource="#application.contentDB#">
          select doctors_offices.officeID,  doctors_offices.address1,  doctors_offices.address2,  doctors_offices.city,  doctors_offices.daysOfWeek,  doctors_offices.state,
           doctors_offices.country,  doctors_offices.coordinates,  doctors_offices.officeCreateDate, doctors_offices.name, doctors_offices.phoneNumber, doctors_offices.phoneExt
          from doctors_offices
          where doctorID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.doctorID#">
        </cfquery>

        <cfset result.offices = arrayNew(1)>
        <cfloop query="getOffices">
          <cfset result.offices[arrayLen(result.offices) + 1] = structNew()>
          <cfloop list="#getOffices.columnList#" index="i">
            <cfset result.offices[arrayLen(result.offices)][i] = getOffices[i][getOffices.currentRow]>
          </cfloop>
        </cfloop>
      </cfif>

      <cfif arguments.returnType EQ "json">
        <cfreturn serializeJson(result)>
      <cfelse>
        <cfreturn result>
      </cfif>
    </cffunction>



</cfcomponent>
