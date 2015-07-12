<!-- Template for create Rx Prefered Compound Ajax -->
<cfloop collection="#application.categories#" item="i">
	<cfif application.categories[i].name EQ "compound" or application.categories[i].name EQ "compounds">
		<cfset params.mainCategoryID = i>
			<cfbreak>
			</cfif>
		</cfloop>

		<!-- If we are showing all compound categories -->
		<cfif !structKeyExists(params, "categoryID") and !structKeyExists(params, "compoundID")>
			<div id="preferedCompoundContainer">
				<div id="medBrowseContentContainer">
					<h4>Prefered Compound Categories:</h4>
					<ul>
						<cfloop collection="#application.categories[params.maincategoryID].categories#" item="i">
							<cfif application.categories[params.maincategoryID].categories[i].drugCount GT 0>
								<cfoutput>
									<a href="javascript:openCategory('compound','#i#')">
										<div class="contBtnDiv blueCont tagWrapper">
											<div class="tagName">#application.categories[params.maincategoryID].categories[i].name#</div> 
											<div class="tagCount">(#application.categories[params.maincategoryID].categories[i].drugCount#)</div>
										</div>
									</a>
								</cfoutput>
							</cfif>
						</cfloop>
					</ul>
				</div>
				<div id="createRxAjaxNav">
					<cfoutput>
						<div class="contBtnDiv redCont tagWrapper">
							<a style="text-decoration:none;"href="javascript:toggleCurrentRxContents();">Back to Prescription View</a>
						</div>
					</cfoutput>
				</div>
				<br />
				<div class="clear"></div>
			</div>

			<!-- If we are showing compounds in a category -->
			<cfelseif structKeyExists(params, "categoryID")>
				<div id="preferedCompoundContainer">
					<div id="medBrowseContentContainer">
						<cfoutput><h4>Prefered Compounds in #application.categories[params.mainCategoryID].categories[params.categoryID].name#:</h4></cfoutput>
						<ul>
							<cfloop collection="#application.drugs['compounds']#" item="i">
								<cfif application.drugs['compounds'][i].categoryID EQ params.categoryID>
									<cfoutput>
										<a href="javascript:showRxMedInfo('compound','#i#');">
											<div class="contBtnDiv blueCont tagWrapper">
												#application.drugs['compounds'][i].name#
											</div>
										</a>
									</cfoutput>
								</cfif>
							</cfloop>

						</ul>
					</div>
					<div id="createRxAjaxNav">
						<cfoutput>
							
							<a href="javascript:showRxMedContent('compound');"><div class="contBtnDiv blueCont tagWrapper">Compound Categories</div></a>

							<a href="javascript:toggleCurrentRxContents();"><div class="contBtnDiv redCont tagWrapper">Back to Prescription View</div></a>

					</cfoutput>
				</div>


				<br />
				<div class="clear"></div>
			</div>

			<!-- If we are showing a compounds info -->
			<cfelseif !structKeyExists(params, "categoryID") and structKeyExists(params, "compoundID")>		

				<div id="preferedCompoundContainer">
					<div id="medBrowseContentContainer">
						<cfoutput><h4>Compound Info: #application.drugs['compounds'][params.compoundID].name#</h4></cfoutput>
						<div class="rxItemDesc">Compound Description</div>
						<h4>Ingredients</h4>
						<ul>
							<li></li>
						</ul>
			<!--
			<cfdump var="#application.drugs['compounds'][params.compoundID]#">
			-->
		</div>
		<div id="createRxAjaxNav">
			<cfoutput>
				
				<a href="javascript:addToRx('compound', '#params.compoundID#')"><div class="contBtnDiv blueCont contBtnAdd">Add Compound to Rx</div></a>

				<a href="javascript:showRxMedContent('compound');"><div class="contBtnDiv blueCont tagWrapper">Compound Categories</div></a>

				<a href="javascript:openCategory('compound', '#application.drugs['compounds'][params.compoundID].categoryID#');">
<div class="contBtnDiv redCont tagWrapper">
					Back to #application.categories[params.mainCategoryID].categories[application.drugs['compounds'][params.compoundID].categoryID].name#

					</div></a>

					<a href="javascript:toggleCurrentRxContents();">

<div class="contBtnDiv redCont tagWrapper">
Back to Prescription View</div></a>

					
				</cfoutput>
			</div>

			<br />
			<div class="clear"></div>
		</div>


	</cfif>
