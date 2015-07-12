

<cfoutput>#includePartial("/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>
<h4>Create Category</h4>
<form action="/categories/createCategory" method="post">
	<label>Category Type:</label>
	<select name="type">
		<cfloop collection="#application.categories#" item="i">
			<cfoutput>
				<option value="#i#">#application.categories[i].name#</option>
			</cfoutput>
		</cfloop>
	</select>
	<label>Category:</label>
	<input type="text" name="name" value="">
	<input type="submit" value="create">
</form>
