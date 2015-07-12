
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>



<div id="contentContainer">
  <ul class="tabs">
    <a href="javascript:changeTab('rx','all');"><li id='allTab' class="blueBtn">All</li></a>
    <a href="javascript:changeTab('rx','unsigned');"><li id='unsignedTab'>Unsigned</li></a>
    <a href="javascript:changeTab('rx','expired');"><li id='expiredTab'>Expired</li></a>
    <a href="javascript:changeTab('rx','expiring');"><li id='expiringTab'>Expiring Soon</li></a>
    <a href="javascript:changeTab('rx','active');"><li id='activeTab'>Active</li></a>
  </ul>

    <div id="content">

    </div>
</div>


<cfsavecontent variable="pageJS">
<script>
	$(document).ready(function(){
		console.log('running');
		changeTab('rx','all');
	})
</script>

</cfsavecontent>
