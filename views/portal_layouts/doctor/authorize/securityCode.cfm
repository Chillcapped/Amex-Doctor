
<cfif application.roles[session.user.role].name EQ "doctor">
	<cftry>
		<div id="rxSecurityCodeContainer">
			<h4>Authorization Security Code:</h4>
			<p>Your signature has been saved, enter your authorization code to finalize this prescription</p>
			<form action="" method="post" id="securityCodeForm">
				<cfoutput>
				<input type="text" name="#hash('securityCode')#" value="" id="rxSecurityInput">
				<input type="hidden" name="#hash('imageData')#" value="#form.image#" id="rxSecurityInput1">
				<input type="hidden" name="#hash('pad')#" value="#form.pad#" id="rxSecurityInput2">
				<input type="hidden" name="#hash('rx')#" value="#form.rx#" id="rxSecurityInput3">
				<input type="hidden" name="#hash('securityToken')#" value="#form.securityToken#" id="rxSecurityInput4">
				</cfoutput>
			</form>
				<a href="javascript:validateSecurityInput();" class="blueButton" id="rxSecuritFormValidateBtn">Authorize</a>
		</div>	
		<cfcatch>
			<p>Signature Required for Security Prompt</p>
		</cfcatch>
	</cftry>
</cfif>