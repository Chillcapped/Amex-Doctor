<div id="header">	
	<img id="logo" src="/images/logo.jpg" height="90" width="150">
	<ul></ul>
</div>
<cfoutput>#includePartial("/portal_layouts/doctor/includes/sideMenu")#</cfoutput>
<h2>My Account</h2>

<div id="accountUserInfo">
	<ul>
		<cfoutput>
		<li><label>Name:</label> <span>Dr. #session.user.firstName# #session.user.lastName#</span></li>
		<li><label>Email:</label> <span>#session.user.email#</span></li>
		<li><label>Authorized Users:</label> <a href="/doctor/staff"><span>1</span></a></li>
		<li><label>Authorized Locations:</label> <a href="/doctor/offices"><span>0</span></a></li>
		</cfoutput>
	</ul>
</div>

<div id="accountUserAvatarContainer">
	<h4>Profile Image:</h4>
	<div id="userAvatarContainer">
		<img src="/images/noPhoto.jpg" height="150" width="150" />
	</div>
</div>


<!---
<cfdump var="#session#" />

--->
