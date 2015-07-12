<cfcomponent>

      <cffunction name="init">


      </cffunction>


      <!--- Validate Daily Key --->
      <cffunction name="validateDailyKey" access="remote" returnFormat="plain">



      </cffunction>



      <cffunction name="createShieldUser" access="remote" returnFormat="plain">
            <cfargument name="user" type="string" required="true">

            <!---
            <cfargument name="nodeID" type="string" required="true">
            <cfargument name="nodeID" type="string" required="true">
            --->
            <cfset application.elastic.dailyKey = hash(createUUID())>

            <!--- Daily Api Key is Encrypted with Destination Nodes Permanent ID --->


            <cfhttp method="post" url="https://esproxy:553/actions/createuser">
                  <cfhttpparam type="Formfield" name="dailyApiKey" value="#application.elastic.dailyKey#">
                  <cfhttpparam type="Formfield" name="credentials" value="base64Admin">
                  <cfhttpparam type="Formfield" name="user" value="#arguments.user#">
            </cfhttp>


            <cfdump var="#cfhttp#">


      </cffunction>



</cfcomponent>
