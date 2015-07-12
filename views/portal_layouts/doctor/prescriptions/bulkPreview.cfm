
  <cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
  <cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>

  <cfset expires = createDate((year(now()) + 1), month(now()), day(now()))>
  <div id="contentContainer">
  	<h4>Bulk Prescribe - Select Medications</h4>
    <div class="bulkOrderSteps" id="createRxCurrentStepContainer">
      <ul>
        <li id="selectPatientStep">
  				<span class="stepNumber">1</span>
  				<span class="stepText">Select Patients</span>
  			</li>
  			<li id="selectMedicationStep" class="activeRxStep">
  				<span class="stepNumber activeStep">2</span>
  				<span class="stepText activeStepText">Select Medications</span>
  			</li>
  			<li id="authorizedStep">
  				<span class="stepNumber">3</span>
  				<span class="stepText">Authorize</span>
  			</li>
      </ul>
    </div>
        <div id="content" class="selectTypeContainer bulkOrderContent">
          <form action="/prescribe/bulkauthorize" method="post" id="bulkOrderForm">
          <div id="bulkRxMedContainer">
            <p class="bulkRxMedContainerTip">Medications Being Prescribed </p>
            <div id="bulkRxCurrentMedListContainer">
                <div class="bulkCurrentRxMedItem">
                  <a href="javascript:showMedItemPatients(#i#);">
                    <div class="bulkCurrentRxMedTop">
                      <p>
                        <img src="/images/syringe.png" class="qtySyringeIcon">
                        <span>Avastin:</span>
                        <select name="dosage">
                              <option value="0.05">0.05 ML (1.25 MG)</option>
                              <option value="0.06">0.06 ML (1.50 MG)</option>
                              <option value="0.07">0.07 ML (1.75 MG)</option>
                              <option value="0.08">0.08 ML (2.0 MG)</option>
                              <option value="0.1">0.1 ML (2.5 MG)</option>
                              <option value="0.12">0.12 ML (3 MG)</option>
                              <option value="0.15">0.15 ML (3.75 MG)</option>
                        </select>
                        <span>Syringe Type:</span>
                        <select name="syringe">
                          <option value="0.05">3/10cc syringe -w/ attached 31g 5/16 inch needle</option>
                          <option value="0.05">3/10cc syringe -w/ attached 30g 1/2 inch needle</option>
                          <option value="0.05">1cc Luer Lock syringe (no needle)</option>
                          <option value="0.05">30G 1/2 inch needle For Luer lock syringe only</option>
                          <option value="0.05">32G 1/2 inch needle For Luer lock syringe only</option>
                        </select>
                        <cfoutput>
                        <span>Patients:</span> <font id="bulkPtQty">#listLen(ptList)#</font>
                        <span>Total Qty:</span>
                        <font id="bulkItemQty" style="">#listLen(ptList)#</font>
                        </cfoutput>
                      </p>
                    </div>
                  </a>
                  <div class="bulkMedItemPatients" id="bulkMedItemMoreInfo#i#">
                      <ul class="subTabs">
                        <a href="javascript:showBulkMedContent(1);" id="bulkContentTab1" class="subTabSelected">
                          <li class="redBtn">Assigned Patients</li></a>
                        <a href="javascript:showBulkMedContent(2);"  id="bulkContentTab2"><li id="unsignedTab">Add Patient</li></a>
                      </ul>
                      <div class="bulkMedItemContent bulkMedItemContent1 bulkMedItemActiveContent">
                      <table class="table">
                        <thead>
                            <th class="bulkMedItemPtRow">Patient Name</th>
                            <th class="bulkMedItemSelectRow">Qty</th>
                            <th class="bulkMedItemSelectRow">Refills</th>
                            <th>Special Requests/ Notes</th>
                            <th class="bulkMedItemSelectRow">Remove</th>
                        </thead>
                        <tbody>
                          <cfloop from="1" to="#arrayLen(patientLookup.patients)#" index="i">
                          <cfif listFind(ptList, patientLookup.patients[i]['_source'].patientID)>
                              <cfset ptID = patientLookup.patients[i]['_source'].patientID>
                          <tr>
                            <cfoutput>
                            <td><span class="bulkModelTbPt">#patientLookup.patients[i]['_source'].firstName# #patientLookup.patients[i]['_source'].lastName#</span></td>
                            <td><select name="item#i#patient1qty" class="itemQtySelect" onchange="updateBulkQtyCount();">
                                  <cfloop from="1" to="20" index="z">
                                    <cfoutput><option value="#z#">#z#</option></cfoutput>
                                  </cfloop>
                                </select>
                            </td>
                            <td><select name="item#i#patient1refills">
                                  <cfloop from="1" to="20" index="z">
                                    <cfoutput><option value="#z#">#z#</option></cfoutput>
                                  </cfloop>
                                </select>
                            </td>
                            <td><input type="text" name="item#i#patient1notes" value="" placeholder="Special Requests / Notes"></td>
                            <td><a href=""><i class="fa fa-remove fa-2x bulkMedDel"></i> </a></td>
                          </cfoutput>
                          </tr>
                          </cfif>
                          </cfloop>
                        </tbody>
                      </table>
                      </div>
                      <div class="bulkMedItemContent bulkMedItemContent2">
                        <ul>
                        <cfloop from="1" to="#arrayLen(patientLookup.patients)#" index="i">
                        <cfif !listFind(ptList, patientLookup.patients[i]['_source'].patientID)>
                            <cfoutput>
                              <li>
                                <input type="checkbox" id="#patientLookup.patients[i]['_source'].patientID#" name="pt:#patientLookup.patients[i]['_source'].patientID#">
                                <span class="patientName">#patientLookup.patients[i]['_source'].firstName# #patientLookup.patients[i]['_source'].lastName#</span>
                              </li>
                            </cfoutput>
                        </cfif>
                        </cfloop>
                        </ul>
                      </div>
                  </div>

                  </div>
            </div>


          </div>
          <div id="boAlertContainer">
            <cfoutput>
              <span>All Prescriptions Expire:</span>
              <cfoutput><font>#dateFormat(expires, "full")#</font></cfoutput></cfoutput>
          </div>


            <div id="boFormControls">
              <ul>
                <a href="/prescribe/bulk"><li class="fullBtn">Back</li></a>
                <a href="javascript:submitBulkPatientForm();"><li class="right fullBtn">Next</li><a/>
              </ul>
            </div>
        </div>

      </form>
  </div>
