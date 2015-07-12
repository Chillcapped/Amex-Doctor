
<div id="header">
	<img id="logo" src="/images/logo.jpg" height="90" width="150">
	<cfoutput>#includePartial("/portal_layouts/doctor/includes/searchContainer")#</cfoutput>

</div>
<!--- Template Shows Doctors Current Offices and Form to Add and Remove --->
<cfoutput>#includePartial("/portal_layouts/doctor/includes/sideMenu")#</cfoutput>


<div class="contentContainer">
  <h3>New Office Address:</h3>
  <div id="addOfficeContainer">
    <div id="addOfficeMain">
      <form action="/offices/add" method="post">
        <div id="addOfficeLabels" class="left">
          <label>Label: </label>
          <label>Line 1: </label>
          <label>Line 2: </label>
          <label>Zip: </label>
        </div>
        <div id="addOfficeValues" class="left">
          <input type="text" name="name" value="">
          <input type="text" name="address1" value="">
          <input type="text" name="address2" value="">
        </div>
        <div id="addOfficeStateZip">
          <input type="text" name="zip" value="">
          <label>State: </label>
          <select name="state">
            <option value="FL">Florida</option>
          </select>
        </div>
        <div id="addOfficeBtmList">
          <ul>
            <a href="/offices"><li class="fullBtn" id="addOfficeBck">Back</li></a>
            <li><input type="submit" id="addOfficeBtn" value="Create" class="fullBtn" /></li>
          </ul>
        </div>
      </form>
    </div>
  </div>
