<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>



<div id="contentContainer">
	<h4>Prescribe</h4>
      <div id="content" class="selectTypeContainer">
            <ul>
               <a href="javascript:showCreateRx();">
                     <li>
                        <i class="fa fa-user fa-3x"></i>
                        <span>Single Prescription</span>
                     </li>
               </a>
               <a href="/prescriptions/bulkprescribe">
                     <li>
                        <i class="fa fa-users fa-3x"></i>
                        <span>Multiple Prescription</span>
                     </li>
               </a>
            </ul>
      </div>
</div>
