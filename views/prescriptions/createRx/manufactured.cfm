
<!-- Template for create Rx Manufacturerd Drug Ajax -->
<cfloop collection="#application.categories#" item="i">
	<cfif application.categories[i].name EQ "manufactured" or application.categories[i].name EQ "manufactured drug">
		<cfset params.mainCategoryID = i>
		<cfbreak>
	</cfif>
</cfloop>

<!-- If we are showing all manufactured categories -->
<cfif !structKeyExists(params, "categoryID") and !structKeyExists(params, "drugID")>
	<div id="createRxManuDrugContainer">
		<div id="medBrowseContentContainer">
			<h4>Manufactured Drug Categories:</h4>
			<ul>
				<cfloop collection="#application.categories[params.maincategoryID].categories#" item="i">
					<cfoutput>
					<a href="javascript:openCategory('manufactured','#i#')">
					<div class="contBtnDiv blueCont tagWrapper">
					<div class="tagName">#application.categories[params.mainCategoryID].categories[i].name#</div> 
					<div class="tagCount">(#application.categories[params.mainCategoryID].categories[i].drugCount#)</div>
					</div>
					</a>
					</cfoutput>
				</cfloop>

			</ul>
		</div>
		<div id="createRxAjaxNav">
			<div class="contBtnDiv blueCont tagWrapper"><a href="javascript:toggleCurrentRxContents();">All Manufacuturers</a></div>
				<div class="contBtnDiv redCont tagWrapper"><a href="javascript:toggleCurrentRxContents();">Back to Prescription View</a></div>
				
			
		</div>
		<br />
		<div class="clear"></div>
	</div>
	
<!-- If we are shoing a manufactured drug category -->
<cfelseif structKeyExists(params, "categoryID")>
	
	<div id="createRxManuDrugContainer">
		<div id="medBrowseContentContainer">
			<cfoutput>
			<h4>Manufactured Drugs in #application.categories[params.mainCategoryID].categories[params.categoryID].name#:</h4>
			</cfoutput>
			<ul>
				<cfloop collection="#application.drugs['manufactured']#" item="i">
					<cfif application.drugs['manufactured'][i].categoryID EQ params.categoryID>
						<cfoutput>
						<a href="javascript:showRxMedInfo('manufactured', '#i#');"><div class="contBtnDiv blueCont tagWrapper">#application.drugs['manufactured'][i].name#</div></a>
						</cfoutput>
					</cfif>
				</cfloop>
			</ul>
		</div>
		<div id="createRxAjaxNav">
			<cfoutput>
			<ul>
				<a href="javascript:showRxMedContent('manufactured');"><div class="contBtnDiv redCont tagWrapper">Manufactured Drug Categories</div></a>
				<a href="javascript:toggleCurrentRxContents();"><div class="contBtnDiv redCont tagWrapper">Back to Prescription View</div></a>
			</ul>
			</cfoutput>
		</div>
		<br />
		<div class="clear"></div>
	</div>
	
<!-- If we are showing a manufactured drugs info -->
<cfelseif !structKeyExists(params, "categoryID") and structKeyExists(params, "drugID")>	
	
	<div id="createRxManuDrugContainer">
		<div id="medBrowseContentContainer">
			<cfoutput><h4>Drug Info for: #application.drugs['manufactured'][params.drugID].name#</h4></cfoutput>
			<cfoutput><div class="rxItemManu"><strong>Manufacturer:</strong> #application.manufacturers[application.drugs['manufactured'][params.drugID].manufactID].name#</div></cfoutput>
			<div class="rxItemDesc">Drug Description</div>
		</div>
		<div id="createRxAjaxNav">
			<cfoutput>
		
<a href="javascript:addToRx('manufactured', '#params.drugID#')"><div class="contBtnDiv blueCont contBtnAdd">Add Drug to Rx</div></a>

				<a href="javascript:showRxMedContent('manufactured');"><div class="contBtnDiv blueCont tagWrapper">Manufactured Drug Categories</div></a>

				<a href="javascript:openCategory('manufactured', '#application.drugs['manufactured'][params.drugID].categoryID#');"><div class="contBtnDiv redCont tagWrapper">Back to #application.categories[params.mainCategoryID].categories[application.drugs['manufactured'][params.drugID].categoryID].name#</div></a>

				<a href="javascript:toggleCurrentRxContents();"><div class="contBtnDiv redCont tagWrapper">Back to Prescription View</div></a>
				
			</ul>
			</cfoutput>
		</div>
		<br />
		<div class="clear"></div>
	</div>
	
	
</cfif>

