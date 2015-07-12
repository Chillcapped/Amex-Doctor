


  <cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
  <cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>


  <div id="contentContainer">
  	<h4>Bulk Order - Delivery Options</h4>
    <div class="bulkOrderSteps" id="createRxCurrentStepContainer">
      <ul>
        <a href="/order/bulk">
        <li id="selectPatientStep" class="activeRxStep">
          <span class="stepNumber">1</span>
          <span class="stepText">Select Patients </span>
        </li>
        </a>
        <li id="selectMedicationStep">
          <span class="stepNumber">2</span>
          <span class="stepText">Select Medications</span>
        </li>
        <li id="authorizedStep">
          <span class="stepNumber activeStep">3</span>
          <span class="stepText activeStepText">Delivery Options</span>
        </li>
        <li id="authorizedStep">
          <span class="stepNumber">4</span>
          <span class="stepText">Finalize Order</span>
        </li>
      </ul>
    </div>
        <div id="content" class="selectTypeContainer bulkOrderContent">
            <p>Select prefered shipping locations:</p>
            <form action="/order/bulkshipping" method="post" id="bulkOrderForm">
  					<div id="boPreviewContainer">
              <ul>
                <cfloop from="1" to="#arrayLen(patientLookup.patients)#" index="i">
                  <cfif listFind(ptList, patientLookup.patients[i]['_source'].patientID)>
                      <cfset ptID = patientLookup.patients[i]['_source'].patientID>
                        <cfoutput>
                        <li class="boPreviewItem boShippingItem">
                            <div class="boPatientContainer">
                              <div class="boPatientInfo">
                                <span class="black">#patientLookup.patients[i]['_source'].firstName# #patientLookup.patients[i]['_source'].lastName#</span>
                                <span>Shipping Method: <font class="red">UPS</font></span>

                              </div>
                            </div>
                              <div class="boShippingInfo">
                                <span>Estimated Delivery: <font class="red">-</font></span>

                                <div class="boShippingLocContainer">
                                  <select name="ptShipLoc:#ptID#">
                                      <option value="Main Office">Main Office</option>
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

            <div id="boFormControls">
              <ul>
                <a href="/order/bulk"><li class="fullBtn">Back</li></a>
                <a href="javascript:submitBulkPatientForm();"><li class="right fullBtn">Next</li><a/>
              </ul>
            </div>
        </div>
  </div>
