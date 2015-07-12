<h4>Add Authorized User</h4>

<div id="authUserFormContainer">
	<form action="/doctor/addAuthorizedUser" method="post">
		<input type="text" name="email" placeholder="Email" value=""> 
		<input type="text" name="firstName" placeholder="First Name" value="">
		<input type="text" name="lastName" placeholder="Last Name" value="">
		<input type="text" name="jobRole" placeholder="Job Role" value="">
		<input type="password" name="password1" placeholder="Password 1" value="">
		<input type="password" name="password2" placeholder="Password 2" value="">
		<input type="submit" value="Create">
		<p>User will be required to verify their email before logging in.</p>
	</form>
</div>