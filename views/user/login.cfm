<link rel="stylesheet" href="/stylesheets/source/global/login.css" />
<script type="text/javascript" src="/bower_components/jquery/jquery.min.js"></script>
<script type="text/javascript" src="/javascripts/source/global/login.js"></script>
<div id="topHeadBar"></div>
<div id="header">
	<img id="logo" src="/images/logo.jpg" height="90" width="150">
	<ul></ul>
</div>
<h2>Login</h2>
<div id="loginContainer">
	<cfif structKeyExists(variables, "loginStatus") and structKeyExists(variables.loginStatus, "message")>
		<cfoutput>
			<span class="error">#variables.loginStatus.message#</span>
		</cfoutput>
	</cfif>
	<form action="/login" method="post" id="loginForm">
		<div id="loginInputContainer">
			<ul>
		  	 <cfoutput><li><label>Username:</label> <input type="text" name="username" value="#params.username#"></li></cfoutput>
			 <li><label>Password:</label> <input type="password" name="userpassword"></li>
			</ul>
		</div>
		<div class="loginBtmBtns">
			<a href=""><div class="loginBtnDiv">Login Help</div></a>
			<a href="/resetpassword"><div class="loginBtnDiv">Reset Password</div></a>
			<div class="loginBtnDiv2">Login</div>
			<div style=" display: none;"><input type="submit" value="Login"></div>
		</div>
	</form>

</div>
