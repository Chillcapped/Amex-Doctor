<div id="header">
	<img id="logo" src="/images/logo.jpg" height="90" width="150">
		<cfoutput>#includePartial("/portal_layouts/doctor/includes/searchContainer")#</cfoutput>
	<ul></ul>
</div>
<cfoutput>#includePartial("/portal_layouts/doctor/includes/sideMenu")#</cfoutput>




	<div id="contentContainer">
		<h4>My Account</h4>

		<ul class="tabs">
			<a href="javascript:changeTab('account','patients');"><li id='patientsTab' class="blueBtn">Account Profile</li></a>
			<a href="javascript:changeTab('account','prescriptions');"><li id='prescriptionsTab'>Signature</li></a>
			<a href="javascript:changeTab('account','prescriptions');"><li id='prescriptionsTab'>Authorized Ips</li></a>
			<a href="javascript:changeTab('account','prescriptions');"><li id='prescriptionsTab'>Purge</li></a>
		</ul>

		<div id="accountUserInfo">
		<div id="accountUserAvatarContainer">
			<div id="userAvatarContainer">
				<img src="/images/noPhoto.jpg" height="150" width="150" />
				<a href="javascript:showUserImageUploader();" id="updateAccountImageBtn" ><div class="contBtnDiv blueCont contBtnArrow">Upload Profile Image</div></a>
			</div>
		</div>
		<div id="accountInfoContainer">
			<ul>
			 <li>	<cfoutput><label>Member Since:</label> <div class="infoLine">#dateFormat(now(), "mm-dd-yyyy")#</div></li>
			 <li><label> <i class="fa fa-user-md"></i></label> Dr. <span>#session.user.firstName# #session.user.lastName#</span></li>
			 <li><label> <i class="fa fa-envelope"></i></label> #session.user.email#</li>	</cfoutput>
			 <li><label> <i class="fa fa-stethoscope"></i></label>  </li>
			 <li><label> <i class="fa fa-phone-square"></i> <i class="fa fa-plus-circle"></i> </label> </li>
			</ul>
		</div>
		<a href="javascript:editBasicUserInfo();" id="updateAccountInfoBtn"><div class="contBtnDiv blueCont contBtnArrow">Edit Information</div></a>

		</div>
	</div>





<!---
<cfdump var="#session#" />

--->
