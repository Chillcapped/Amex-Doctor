<h4>Current Offices</h4>

<ul class="tabs">
	<li>Offices</li>
	<li><a href="/offices/add">Add Office Location</a></li>
</ul>

	<!--- If Doctor has Addresses --->
	<cfif arrayLen(officeLookUp.offices) GT 0>
		<ul id="officeLocations">
			<cfloop from="1" to="#arrayLen(officeLookUp.offices)#" index="i">
				<cfoutput>
				<a href="javascript:showAddressInfo('#officeLookup.Offices[i].officeID#')">
					<li>
								<div class="officeImageContainer">
									<img src="gMapImage" class="officeStreetThumb" />
								</div>
								<div class="officeLocationInfo">
									<font class="officeTitle">#officeLookUp.offices[i].name#</font>
									<span class="officeAdd">#officeLookUp.offices[i].address1#</span>
							  	<span class="officeAdd">#officeLookUp.offices[i].address2# </span>
									<span class="officeAdd">#officeLookUp.offices[i].city# #officeLookUp.offices[i].state#</span>
									<span class="officeNumber">#officeLookUp.offices[i].phoneNumber#</span>
								</div>
								<div class="officeToggleContainer">
									<span class="officeMainAddr">Main Address:<input type="checkbox" checked value="mainAddress"></input></span>
								</div>
						</cfoutput>
					</li>
				</a>
			</cfloop>
	<!--- If Doctor doesnt have Addresses --->
	<cfelse>
		<p>You have no Office Locations saved</p>
	</cfif>
