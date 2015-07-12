<div id="avastinFormContainer">
<h4>Prescription for Compounded unit dose Avastin</h4>

<form action="" method="post" id="rxForm">
      <div class="avastinLeft">
            <ul>
              <li>
                    <span>Patients Name:</span>
                    <input type="text" name="name" value="">
              </li>
              <li>
                    <span>Name of Facility:</span>
                    <input type="text" name="facility" value="">
              </li>
              <li>
                    <div id="addressContainer">
                          <span class="officeAddrHead">Office Address:</span>
                          <select name="address">
                                <option value="1">1395 SW Example</option>
                          </select>
                          <div class="officeAddress">
                                <span>1395 SW Example</span>
                                <span>Melbourne FL, 32901</span>
                          </div>
                    </div>
              </li>
            </ul>
      </div>
      <div class="avastinRight">
            <ul>
              <li> <span>Patient DOB:</span>
                   <input type="text" name="dob" />
              </li>
              <li> <span>Patient Phone:</span>
                   <input type="text" name="phone" />
              </li>
              <li>  <span>Prescriber Name:</span>
                    <input type="text" name="doctor" />
              </li>
              <li>  <span>Office Telephone:</span>
                    <input type="text" name="doctorPhone" />
              </li>
              <li>  <span>NPI Number</span>
                    <input type="text" name="NPI" />
              </li>
              <li>  <span>State Lic ##</span>
                    <input type="text" name="license" />
              </li>
            </ul>
      </div>

      <div class="avastinMiddle">
            <ul>
                  <li>
                        <label class="medName">Avastin</label>
                        <select name="dosage">
                              <option value="0.05">0.05 ML (1.25 MG)</option>
                              <option value="0.06">0.06 ML (1.50 MG)</option>
                              <option value="0.07">0.07 ML (1.75 MG)</option>
                              <option value="0.08">0.08 ML (2.0 MG)</option>
                              <option value="0.1">0.1 ML (2.5 MG)</option>
                              <option value="0.12">0.12 ML (3 MG)</option>
                              <option value="0.15">0.15 ML (3.75 MG)</option>
                        </select>
                        <label>Quantity</label>
                        <input type="text" name="qty" value="" class="numInput">
                        <label>Number of Refills</label>
                        <input type="text" name="refills" value="" class="numInput">
                  </li>
            </ul>
      </div>

      <div class="avastinBottom">
            <div id="syringeContainer">
            <span class="formHead">Syringe & Needle Type:</span>
            <ul>
                 <li><input type="radio" value="1" name="needle">
                     <span>3/10cc syringe -w/ attached 31g 5/16 inch needle</span>
                 </li>
                 <li><input type="radio" value="2" name="needle">
                      <span>3/10cc syringe -w/ attached 30g 1/2 inch needle</span>
                 </li>
                 <li>
                       <input type="radio" value="3" name="needle">
                       <span>1cc Luer Lock syringe (no needle)</span>
                 </li>
                 <li>
                       <input type="radio" value="4" name="needle">
                       <span>30G 1/2 inch needle For Luer lock syringe only</span>
                 </li>
                 <li>
                       <input type="radio" value="5" name="needle">
                       <span>32G 1/2 inch needle For Luer lock syringe only</span>
                 </li>
            </ul>
            </div>
            <div id="notesContainer">
                  <span class="formHead">Notes:</span>
                  <textarea name="notes"></textarea>
            </div>


      </div>

      <div id="formBtm">
            <ul>
              <a href="/medications"><li class="fullBtn">Back</li></a>
              <a href=""><li class="right fullBtn">Create</li></a>
            </ul>
      </div>
</form>





</div>
