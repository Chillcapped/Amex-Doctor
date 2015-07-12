


  <cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
  <cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>


  <div id="contentContainer">
  	<h4>Bulk Order - Select Medications</h4>
    <div class="bulkOrderSteps" id="createRxCurrentStepContainer">
      <ul>
        <a href="/order/bulk">
          <li id="selectPatientStep" class="activeRxStep">
            <span class="stepNumber">1</span>
            <span class="stepText">Select Patients </span>
          </li>
        </a>
        <li id="selectMedicationStep">
          <span class="stepNumber activeStep">2</span>
          <span class="stepText activeStepText">Select Medications</span>
        </li>
        <li id="authorizedStep">
          <span class="stepNumber">3</span>
          <span class="stepText">Delivery Options</span>
        </li>
        <li id="authorizedStep">
          <span class="stepNumber">4</span>
          <span class="stepText">Finalize Order</span>
        </li>
      </ul>
    </div>
        <div id="content" class="selectTypeContainer bulkOrderContent">
            <p>Selected Patients:</p>
            <form action="/order/bulkshipping" method="post" id="bulkOrderForm">
  					<div id="boPreviewContainer">
              <ul>
                <cfloop from="1" to="#arrayLen(patientLookup.patients)#" index="i">
                <cfif listFind(ptList, patientLookup.patients[i]['_source'].patientID)>
                    <cfset ptID = patientLookup.patients[i]['_source'].patientID>
                  <cfoutput>

                    <li class="boPreviewItem">
                      <input type="hidden" name="pt:#ptID#" value="true">
                      <div class="boPatientContainer">
                        <div class="boPatientInfo">
                          <span class="black">#patientLookup.patients[i]['_source'].firstName# #patientLookup.patients[i]['_source'].lastName#</span>
                          <span>Prescription: <a href="">#left(createUUID(), 10)#</a></span>
                        </div>
                        <div class="boPatientTools">
                            <a href="">View Rx</a>
                        </div>
                        <div class="boPatientMedContainer">
                          <select name="ptMed:#ptID#">
                            <option>Multi-Syringe Select</option>
                          </select>
                        </div>
                      </div>
                    </li>
                  </cfoutput>
                  </cfif>
                </cfloop>
              </ul>
  					</div>
            </form>
            <div id="boAlertContainer">
              <cfoutput>
              <span>You are ordering <font class="red bold">(#listLen(ptList)#)</font> Individual Syringes for <font class="red bold">(#listLen(ptList)#)</font> Patients</span>
              </cfoutput>
            </div>
            <div id="boFormControls">
              <ul>
                <a href="/order/bulk"><li class="fullBtn">Back</li></a>
                <a href="javascript:submitBulkPatientForm();"><li class="right fullBtn">Next</li><a/>
              </ul>
            </div>
        </div>
  </div>
