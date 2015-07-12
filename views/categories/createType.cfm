<h4>Create Category Type:</h4>
<cfif structKeyExists(params, "name")>
	<cfoutput>
	<span>#params.name#</span>
	</cfoutput>
</cfif>
<form action="/categories/createType" method="post">
	<input type="text" name="name" value="">
	<input type="submit" value="create">
</form>

