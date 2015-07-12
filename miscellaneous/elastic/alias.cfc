<cfcomponent>

      <cffunction name="createAlias" access="remote" returnFormat="plain">
            <cfargument name="index" type="string" default="" hint="Index Alias is Applied to">
            <cfargument name="alias" type="string" required="true">
            <cfargument name="terms" type="struct" required="true" hint="Structure of Terms applied to Alies">

            <cfdump var="#arguments#">



            <cfset post = structNew()>
            <cfset post["actions"] = arrayNew(1)>

            <cfset a = structNew()>
            <cfset a["add"] = structNew()>
            <cfset a["add"]["alias"] = "#arguments.alias#">
            <cfset a["add"]["index"] = "#arguments.index#">
            <cfset a["add"]["filter"] = structNew()>
            <cfset a["add"]["filter"]["term"] = arguments.terms>
            <cfset arrayAppend(post.actions, a)>




		<cfhttp method="post" url="#application.elastic.URL#/_aliases" result="status">
                  <cfhttpparam type="body" value="#serializeJson(post)#">
            </cfhttp>

            <cfreturn true>
      </cffunction>



</cfcomponent>
