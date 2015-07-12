<div id="avastinFormContainer">
<h4>Prescription for Compounded unit dose Avastin with Dexamethasone</h4>

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
                        <label>Avastin with Dexamathasone</label>
                        <select name="dosage">
                              <option value="1.25mg(0.05ml)/400mcg">1.25mg(0.05ml)/400mcg</option>
                              <option value="1.25mg(0.05ml)/800mcg">1.25mg(0.05ml)/800mcg</option>
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
                       <span>Send Luer Lock 30G 1/2 inch needle For Luer lock syringe only</span>
                 </li>
                 <li>
                       <input type="radio" value="5" name="needle">
                       <span>Send Luer Lock 32G 1/2 inch needle For Luer lock syringe only</span>
                 </li>
                 <li>
                       <input type="radio" value="6" name="needle">
                       <span>Prefer a different syringe or needle?</span>
                       <input type="text" name="customSyringe" id="customSyringe"/>
                 </li>
            </ul>
            </div>
            <div id="notesContainer">
                  <span class="formHead">Additional Comments / Concerns:</span>
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
