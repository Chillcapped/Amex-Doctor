<cfcomponent extends="controller">


<cffunction name="index">
  <!--- Get Doctors Offices --->
  <cfinvoke component="api.offices" method="getOffices" returnVariable="officeLookUp">
    <cfinvokeargument name="doctorID" value="#session.user.userID#">
    <cfinvokeargument name="authToken" value="#session.user.authToken#">
    <cfinvokeargument name="returnType" value="struct">
    <cfinvokeargument name="enc" value="false">
  </cfinvoke>

  <cfset renderPage( hideDebugInformation="yes", template="/portal_layouts/doctor/offices/offices")>
</cffunction>


<cffunction name="add">
    <cfif structKeyExists(params, "address1")>
      <cfset errors = arrayNew(1)>
      <cfset required="name,line1,state,zip">
      <cfloop list="#required#" index="i">
        <cfif !structKeyExists(params, i) or len(params[i]) EQ 0>
          <cfset error = "#i# is required">
          <cfset arrayAppend(errors, error)>
        </cfif>
      </cfloop>
      <!--- Get Doctors Offices --->
      <cfinvoke component="api.offices" method="createOffice" returnVariable="newOffice">
        <cfinvokeargument name="doctorID" value="#session.user.userID#">
        <cfinvokeargument name="authToken" value="#session.user.authToken#">
        <cfinvokeargument name="returnType" value="struct">
        <cfinvokeargument name="enc" value="false">
        <cfinvokeargument name="label" value="#params.name#">
        <cfinvokeargument name="address1" value="#params.address1#">
        <cfinvokeargument name="address2" value="#params.address2#">
        <cfinvokeargument name="zip" value="#params.zip#">
        <cfinvokeargument name="state" value="#params.state#">
      </cfinvoke>
    </cfif>
    <cfset renderPage( hideDebugInformation="yes", template="/portal_layouts/doctor/offices/add")>
</cffunction>

<cffunction name="delete">


  <cfset renderPage( hideDebugInformation="yes", template="/portal_layouts/doctor/offices/delete")>
</cffunction>


<cffunction name="edit">

  <!--- Get Single Office Info --->
  <cfinvoke component="api.offices" method="getOffice" returnVariable="officeData">
      <cfinvokeargument name="officeID" value="#params.officeID#">
      <cfinvokeargument name="doctorID" value="#session.user.userID#">
      <cfinvokeargument name="authToken" value="#session.user.authToken#">
  </cfinvoke>

  <cfset renderPage( hideDebugInformation="yes", template="/portal_layouts/doctor/offices/edit")>
</cffunction>


</cfcomponent>
