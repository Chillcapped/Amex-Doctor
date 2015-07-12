<cfcomponent extends="controller">

  <cfset application.shippingSchedule =
  [ {},
    {Shipping: 5},
    {Shipping: 2},
    {Shipping: 2},
    {Shipping: 3},
    {Shipping: 4}
   ]>

	<cffunction name="shipments">
    <cfset renderPage( hideDebugInformation="yes", template="/portal_layouts/doctor/shipments/shipments")>
	</cffunction>

  <cffunction name="schedule">

    <cfset renderPage( hideDebugInformation="yes", template="/portal_layouts/doctor/shipments/schedule")>
  </cffunction>

</cfcomponent>
