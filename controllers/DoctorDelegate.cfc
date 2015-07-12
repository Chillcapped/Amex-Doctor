<cfcomponent>

	
	
	
	
		<!--- Authorize Rx --->
		<cffunction name="authorizeRx">
			
		
			<cfset renderPage(layout="false", hideDebugInformation="yes", template="/portal_layouts/doctor_delegate/authorize/prescription")>
		</cffunction>

</cfcomponent>