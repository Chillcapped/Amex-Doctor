<cfcomponent>

		
	<!--- Encrypt Form ID --->	
	<cffunction name="encryptFormID" returntype="string" returnFormat="plain" hint="returns decrypted prescription ID">
		<cfargument name="ID" type="string" required="true">
			
		<!---1 Encrypt With Form Over --->
		<cfset encryptedID = Encrypt(arguments.id,application.formKey,'AES/CBC/PKCS5Padding','HEX') />				
	
		<!---2 Encrypt again With IP --->
		<cfset ip = hash(replace(request.cgi.remote_addr, ".", "", "all"))>
		<cfset encryptedID = toBase64(encrypt(encryptedID,ip, 'CFMX_COMPAT'))>
		
		<!---3 Encrypt with Session  --->
		<cfset encryptedID = toBase64(encrypt(encryptedID,session.sessionID, 'CFMX_COMPAT'))>
		
		<cfreturn encryptedID>
	</cffunction>
	
	
	<!--- Decrypt Form ID --->
	<cffunction name="decryptFormID" returntype="string" returnFormat="plain" hint="returns decrypted prescription ID">
		<cfargument name="ID" type="string" required="true">
				
		<!---1 Decrypt with Session --->		
		<cfset decodedID  = decrypt(toString(toBinary(arguments.ID)), session.sessionID, 'CFMX_COMPAT')/>
		
		<!---2 Decrypt with IP --->
		<cfset ip = hash(replace(request.cgi.remote_addr, ".", "", "all"))>
		<cfset decodedID  = decrypt(toString(toBinary(decodedID)), ip, 'CFMX_COMPAT')/>
		
		<!---3 Decrypt with Form key --->
		<cfset decodedID = Decrypt(decodedID, application.formKey, 'AES/CBC/PKCS5Padding','HEX')/>
		
		<cfreturn decodedID>
	</cffunction>


</cfcomponent>