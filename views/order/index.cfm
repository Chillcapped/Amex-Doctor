<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>



<div id="contentContainer">
	<h4>Order</h4>
      <div id="content" class="selectTypeContainer">
            <ul>
               <a href="javascript:showCreateRx();">
                     <li>
                        <i class="fa fa-user fa-3x"></i>
                        <span>Single Patient Order</span>
                     </li>
               </a>
               <a href="/order/bulk">
                     <li>
                        <i class="fa fa-users fa-3x"></i>
                        <span>Multiple Patient Order</span>
                     </li>
               </a>
            </ul>
      </div>
</div>
