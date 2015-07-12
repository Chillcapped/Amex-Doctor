
  <cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
  <cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>

  <cfset expires = createDate((year(now()) + 1), month(now()), day(now()))>
  <div id="contentContainer">
  	<h4>Bulk Prescribe - Authorize Medications</h4>
    <div class="bulkOrderSteps" id="createRxCurrentStepContainer">
      <ul>
        <li id="selectPatientStep">
  				<span class="stepNumber">1</span>
  				<span class="stepText">Select Patients</span>
  			</li>
        <li id="selectMedicationStep">
          <span class="stepNumber">2</span>
          <span class="stepText">Select Medications</span>
        </li>
        <li id="authorizedStep" class="activeRxStep">
  				<span class="stepNumber activeStep">3</span>
  				<span class="stepText activeStepText">Authorize</span>
  			</li>
      </ul>
      </div>
      <div id="content" class="selectTypeContainer">
        <ul>
           <a href="/prescribe/single">
                 <li>
                    <i class="fa fa-clock-o fa-3x"></i>
                    <span>Authorize & Ship Later</span>
                 </li>
           </a>
           <a href="/prescribe/bulk">
               <li>
                  <i class="fa fa-truck fa-3x"></i>
                  <span>Authorize & Ship Now</span>
               </li>
           </a>
        </ul>
      </div>
      <div id="boFormControls">
        <ul>
          <a href="/prescribe/bulk"><li class="fullBtn">Back</li></a>
          <a href="javascript:submitBulkPatientForm();"><li class="right fullBtn">Next</li><a/>
        </ul>
      </div>

    </div>
