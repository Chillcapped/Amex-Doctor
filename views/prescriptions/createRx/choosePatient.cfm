
<div id="createRxSelectContainer">
	<h2>Create Prescription</h2>
	<form id="createRxChoosePatient" action="/createRx" method="post">
	<div id="choosePatientRxContainer" class="fullBlock">
		<h4>Choose Patient</h4>
			<ul>
				<li><label>Name</label><input type="text" name="name" value="Jane Doe" id="patientName"></li>
				<li><label>Phone</label><input type="text" name="phone" value="" id="patientPhone"></li>
			</ul>
	</div>

	<img src="/images/surescript.jpg" id="surescriptTemp" />

	<div id="btmChoosePatientMenu" class="clear">
		<ul>
			<a href="javascript:createRxPatient();" ><li class="contBtnDiv blueCont contBtnArrow">Select Patient</li></a>
			<a href="javascript:showCreatePatient();"><li class="contBtnDiv blueCont contBtnAdd">Add Patient</li></a>
			<a href="javascript:closeDialog();"><li class="contBtnDiv redCont contBtnX">Cancel</li></a>
		</ul>
	</div>
	</form>
</div>
