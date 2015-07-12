<link rel="stylesheet" href="/stylesheets/source/global/login.css" />
<div id="topHeadBar"></div>
<div id="header">
	<img id="logo" src="/images/logo.jpg" height="90" width="150">
	<ul></ul>
</div>
<div id="resetPasswordFormContainer">
	<cfif status EQ "">
	<h4>Reset Password</h4>
	<p>Enter your login email below to send your password reset email. Check your inbox after submitting for the link to finalize the reset process.</p>
	<form action="/resetPassword" method="post">
		<input type="text" name="email" value="">
		<input type="submit" value="Reset">
		<a href="/login">Back to Login</a>
	</form>
	
	<cfelseif status EQ "verify">
		<h4>Enter New Password</h4>
		<cfoutput>
		<form action="/resetpassword?#request.cgi.query_string#" method="post">
			
			<input type="text" name="password1" value="" placeholder="Password">
			<input type="text" name="password2" value="" placeholder="Re-Type Password">
			<input type="submit" value="Update">
		</form>
		</cfoutput>
	<cfelseif status EQ "sent">
		<h4>Sent</h4>
		<p>Check your email to continue the reset process</p>
	</cfif>
</div>
