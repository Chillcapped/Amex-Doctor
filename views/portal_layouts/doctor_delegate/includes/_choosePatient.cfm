
<div id="createRxSelectContainer">
	<h2>Create Prescription</h2>
	<form action="/createRx" method="post">
	<div id="choosePatientRxContainer">
		<h4>Choose Patient</h4>
			<ul>
				<li><label>Name</label><input type="text" name="name" value=""></li>
				<li><label>Phone</label><input type="text" name="phone" value=""></li>
			</ul>
	</div>
	
	<div id="bottomMenu" class="clear">
		<ul>
			<a href=""><li><input type="submit" value="Select Patient"></li></a>
			<a href=""><li>Add Patient</li></a>
			<a href=""><li>Cancel</li><a href="">
		</ul>
	</div>
	</form>	
</div>