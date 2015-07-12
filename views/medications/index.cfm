<cfparam name="params.tab" default="patients">



<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>


<div id="contentContainer" class="selectTypeContainer">
      <h4>Medications</h4>
        <cfif !structKeyExists(params, "categoryType")>
            <ul>
               <a href="/medications/optical">
                     <li>
                        <i class="fa fa-eye fa-3x"></i>
                        <span>Optical</span>
                     </li>
               </a>
            </ul>
        <cfelse>
          <a href="/avastin"><li class="medicationListItem">Avastin</li></a>
          <a href="/avastin/dexamethasone"><li class="medicationListItem">Avastin with Dexamethasone</li></a>
        </cfif>
</div>

<cfsavecontent variable="pageJS">
<script>
	$(document).ready(function(){
		console.log('running');
		changeTab('home','patients');
	})
</script>
</cfsavecontent>
