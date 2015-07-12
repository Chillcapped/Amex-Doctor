






<!-- If Landing Page -->
<cfif !structKeyExists(params, "categoryType") or params.categoryType EQ "">

	<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
	<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>


	<div id="contentContainer">
		<h4>Filter by Medication Type</h4>
		<ul>
			<cfloop collection="#application.categories#" item="i">
				<cfoutput>
					<a href="/medications/#application.categories[i].seoName#">
						<li class="medCategoryListItem"><img src="/images/#application.categories[i].icon#" class="medicationCategoryImg">
							<span class="medCategoryItemTitle">#application.categories[i].name#</span>
							<span class="medCategoryNumText">Categories: #application.categories[i].drugCount#</span>
						</li>
					</a>
				</cfoutput>
			</cfloop>
		</ul>

<!-- If we are showing categories of a specific type -->
<cfelse>


	<cfif !structKeyExists(params, "category")>
		<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
		<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>
		<div id="contentContainer">
		<cfoutput><h4>Categories in #application.categories[application.categoryTypeLookup[params.categoryType].id].name#</h4></cfoutput>
		<a href="/medications/"><div class="contBtnDiv redCont tagWrapper">Back to Medications</div></a>
			<ul>
			<cfloop collection="#application.categories[application.categoryTypeLookup[params.categoryType].id].categories#" item="i">
				<cfoutput>
					<a href="/medications/#params.categoryType#/#i#">
						<li class="medCategoryListItem"><img src="/images/noPhoto.jpg" class="medicationCategoryImg">
							<span class="medCategoryItemTitle">#application.categories[application.categoryTypeLookup[params.categoryType].id].categories[i].name#</span>
							<span class="medCategoryNumText">Medications: #application.categories[application.categoryTypeLookup[params.categoryType].id].categories[i].drugCount#</span>
						</li>
					</a>
				</cfoutput>
			</cfloop>
			</ul>
	</cfif>


	<!-- If we have Category, show medications inside it-->
	<cfif structKeyExists(params, "category")>
		<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
		<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>

		<div id="contentContainer">


		<cfoutput>
			<h4>#application.categories[application.categoryTypeLookup[params.categoryType].id].name# in #application.categories[application.categoryTypeLookup[params.categoryType].id].categories[params.category].name#</h4>

		<a href="/medications/#application.categories[application.categoryTypeLookup[params.categoryType].id].name#"><div class="contBtnDiv redCont tagWrapper">Back to #application.categories[application.categoryTypeLookup[params.categoryType].id].name#</div></a>
		</cfoutput>
		<ul>

			<cfloop collection="#application.drugs[params.categoryType]#" item="i">
				<cfoutput>
				<cfif application.drugs[params.categoryType][i].categoryID EQ params.category>
					<a href="/#params.categoryType#/info/#i#">
						<li class="medCategoryListItem"><img src="/images/noPhoto.jpg" class="medicationCategoryImg">
							<span class="medCategoryItemTitle">#application.drugs[params.categoryType][i].name#</span>

						</li>
					</a>
				</cfif>
				</cfoutput>
			</cfloop>

		</ul>

	<!--
		<cfdump var="#application.categories[application.categoryTypeLookup[params.categoryType].id]#">
		<cfdump var="#params#">
		<cfdump var="#application.compounds#">
			-->


	</cfif>
</cfif>
</div>
