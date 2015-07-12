
<cfcomponent>

  <!--- Is valid thread --->
  <cffunction name="isValidThread" access="public" returnFormat="boolean">
    <cfargument name="threadID" type="numeric" required="true">

    <cfquery name="getThread" datasource="amex_internal">
      select threadID
      from message_threads
      where threadID = <cfqueryparam value="#arguments.threadID#" CFSQLType="cf_sql_integer">
    </cfquery>

    <cfif getThread.recordCount>
      <cfreturn true>
    <cfelse>
      <cfreturn false>
    </cfif>
  </cffunction>


  <!--- is Message Author --->
  <cffunction name="isMessageAuthor" access="public" returnFormat="struct">
    <cfargument name="authToken" type="string" required="true">
    <cfargument name="messageID" type="numeric" required="true">
    <cfargument name="returnMessage" type="bool" default="false">

    <!--- Check if Auth Token is Valid Doctor --->
    <cfset result = structNew()>
    <cfset result.status = true>

    <!--- Get Token Owner --->
    <cfinvoke component="api.authorize" method="getTokenOwner" returnvariable="tokenINfo">
      <cfinvokeargument name="token" value="#arguments.authToken#">
    </cfinvoke>

    <cfif !tokenInfo.status>
      <cfset result.status = false>
      <cfset result.message = "Invalid Token">
    </cfif>

    <!--- Check If Token Owner Is Author --->
    <cfquery name="getMessage" datasource="amex_internal">
      select * from messages
      where messageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.messageID#">
      and author =
    </cfquery>



    <cfreturn result>
  </cffunction>


  <!--- Create Thread --->
  <cffunction name="createThread" access="public" returnFormat="struct">
      <cfargument name="type" type="string" required="true">
      <cfargument name="typeKey" type="numeric" required="true">
      <cfargument name="authToken" type="string" required="true">
      <cfargument name="patient" type="numeric" default="0">

      <!--- Check if Auth Token is Valid Doctor --->
      <cfset result = structNew()>
      <cfset result.status = true>
      <!--- Get Token Owner --->
      <cfinvoke component="api.authorize" method="getTokenOwner" returnvariable="tokenINfo">
        <cfinvokeargument name="token" value="#arguments.authToken#">
      </cfinvoke>
      <cfif !tokenInfo.status>
        <cfset result.status = false>
        <cfset result.message = "Invalid Token">
      </cfif>
      <!--- If we have patientID, validate it --->
      <cfif arguments.patientID NEQ 0>
        <!--- Check that Patient is one of Doctors --->
        <cfinvoke component="doctor" method="isDoctorsPatient" returnVariable="validPatient">
          <cfinvokeargument name="patientID" value="#arguments.patientID#">
          <cfinvokeargument name="doctorID" value="#tokenInfo.userID#">
        </cfinvoke>

        <cfif !validPatient>
          <cfset result.status = false>
          <cfset result.message = "Invalid Patient ID">
        </cfif>
      </cfif>
      <!--- IF we can create Thread --->
      <cfif result.status>
        <!--- Insert Thread --->
        <cfquery name="insertThread" datasource="amex_internal" result="createdThread">
          insert into message_threads
          (type,typeKey,patient,doctor,createDate)
          values
          (
            <cfsqlparam cfsqltype="cf_sql_integer" value="#arguments.type#">,
            <cfsqlparam cfsqltype="cf_sql_integer" value="#arguments.typeKey#">,
            <cfsqlparam cfsqltype="cf_sql_integer" value="#arguments.patientID#">,
            <cfsqlparam cfsqltype="cf_sql_integer" value="#tokenInfo.userID#">,
            <cfsqlparam cfsqltype="cf_sql_timestamp" value="#now()#">
          )
        </cfquery>

        <cfset result.thread = structNew()>
        <cfset result.thread.id = createdThread.generated_key>
        <cfset result.thread.type = arguments.type>
        <cfset result.thread.typeKey = arguments.typeKey>
        <cfset result.thread.patientID = arguments.patientID>
        <cfset result.thread.messages = arrayNew(1)>
        <cfset result.thread.created = now()>

        <!--- Send Thread to Elastic --->



        <cfreturn result>
      </cfif>

  </cffunction>


  <!--- Create Message --->
  <cffunction name="createMessage" access="public" returnFormat="struct">
    <cfargument name="threadID" type="numeric" required="true">
    <cfargument name="message" type="string" required="true">
    <cfargument name="authToken" type="string" required="true">

    <!--- Check that Auth Token is valid --->
    <cfset result = structNew()>
    <cfset result.status = true>
    <!--- Get Token Owner --->
    <cfinvoke component="api.authorize" method="getTokenOwner" returnvariable="tokenINfo">
      <cfinvokeargument name="token" value="#arguments.authToken#">
    </cfinvoke>

    <cfif !tokenInfo.status>
      <cfset result.status = false>
      <cfset result.message = "Invalid Token">
    </cfif>

    <!--- Check that Thread is Valid --->
    <cfinvoke component="messages" method="isValidThread" returnVariable="validThread">
      <cfinvokargument name="threadID" value="#arguments.threadID#">
    </cfinvoke>

    <cfif !validThread>
      <cfset result.status = false>
      <cfset result.emssage = "Invalid Thread">
    </cfif>

    <!--- Insert Message --->
    <cfif result.status>
      <cfquery name="insertMessage" datasource="amex_internal">
        insert into messages
        (message,author,dateCreated,authorType,threadID)
        values
        (
          <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.message#">,
          <cfqueryparam cfsqltype="cf_sql_integer" value="#tokenInfo.userID#">,
          <cfqueryparam cfsqltype="cf_sql_integer" value="#tokenINfo.roleID#">,
          <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.threadID#">
        )
      </cfquery>

      <cfreturn result>
    </cfif>

  </cffunction>

  <!--- Edit Message --->
  <cffunction name="editMessage" access="public" returnFormat="plain">
    <cfargument name="authToken" type="string" required="true">
    <Cfargument name="messageID" type="numeric" required="true">
    <cfargument name="newMessage" type="string" required="true">

    <!--- Check that Token Is Valid --->
    <cfset result = structNew()>
    <cfset result.status = true>
    <!--- Get Token Owner --->
    <cfinvoke component="api.authorize" method="getTokenOwner" returnvariable="tokenINfo">
      <cfinvokeargument name="token" value="#arguments.authToken#">
    </cfinvoke>
    <cfif !tokenInfo.status>
      <cfset result.status = false>
      <cfset result.message = "Invalid Token">
    </cfif>
    <!--- Check that Token Owner matches Message Author --->
    <cfinvoke component="messages" method="isMessageAuthor" returnVariable="isMessageAuthor">
        <cfargument name="authorID" value="#tokenInfo.userID#">
        <cfargument name="messageID" value="#arguments.messageID#">
        <cfargument name="returnMessage" value="true">
    </cfinvoke>
    <cfif !isMessageAuthor.status>
      <cfset result.status =false>
      <cfset result.message = "Author not permitted to edit this message">
    </cfif>

    <cfif result.status>
        <!--- Update message --->
        <cfquery name="updateMessage" datasource="amex_internal">
            update messages
            set message = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.newMessage#">,
                modified = <cfqueryparam cfsqltype='cf_sql_timestamp' value="#now()#">
            where messageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.messageID#">
        </cfquery>

        <!--- save previous version --->

        <cfset result.message = "Updated Message">
        <cfreturn result>
    </cfif>

  </cffunction>


  <!--- Get Messages --->
  <cffunction name="getMessages" access="public" returnFormat="struct">
    <cfargument name="threadID" type="numeric" required="true">
    <cfargument name="authToken" type="string" required="true">

    <!--- Check that Token Is Valid --->
    <cfset result = structNew()>
    <cfset result.status = true>
    <!--- Get Token Owner --->
    <cfinvoke component="api.authorize" method="getTokenOwner" returnvariable="tokenINfo">
      <cfinvokeargument name="token" value="#arguments.authToken#">
    </cfinvoke>
    <cfif !tokenInfo.status>
      <cfset result.status = false>
      <cfset result.message = "Invalid Token">
    </cfif>
    <!--- If token is valid --->
    <cfif result.status>
      <!--- Get messages --->
      <cfquery name="getMessages" datasource="amex_internal">
        select * from messages
        where threadID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.threadID#">
      </cfquery>
      <cfset result.messages = arrayNew(1)>
      <cfloop query="getMessages">
        <cfset message = structNew()>
        <cfloop list="#getMessages.columnList#" index="i">
          <cfset message[i] = getMessages[i][getmessages.currentRow]>
        </cfloop>
        <cfset arrayAppend(result.messages, message)>
      </cfloop>
      <cfreturn result>
    </cfif>
  </cffunction>

  <!--- Get Threads --->
  <cffunction name="getUserThreads" access="public" returnFormat="struct">
    <cfargument name="authToken" type="string" required="true">
    <!--- Check that Token Is Valid --->
    <cfset result = structNew()>
    <cfset result.status = true>
    <!--- Get Token Owner --->
    <cfinvoke component="api.authorize" method="getTokenOwner" returnvariable="tokenINfo">
      <cfinvokeargument name="token" value="#arguments.authToken#">
    </cfinvoke>
    <cfif !tokenInfo.status>
      <cfset result.status = false>
      <cfset result.message = "Invalid Token">
    </cfif>
    <!--- If token is valid --->
    <cfif result.status>
      <!--- get Threads --->
      <cfquery name="getThreads" datasource="amex_internal">
        select * from message_threads
        where doctorID = <cfqueryparam cfsqltype='cf_sql_integer' value="#tokenInfo.userID#">
      </cfquery>
      <cfset result.threads = arrayNew(1)>
      <cfloop query="getThreads">
        <cfset thread = structNew()>
        <cfloop list="#getThreads.columnList#" index="i">
          <cfset thread[i] = getThreads[i][getThreads.currentRow]>
        </cfloop>
      </cfloop>
      <cfreturn result>
    </cfif>
  </cffunction>

  <!--- Get All Threads --->
  <cffunction name="getAllThreads" access="public" returnFormat="struct">
    <cfargument name="authToken" type="string" required="true">


  </cffunction>

  <!--- Archive Message --->
  <cffunction name="archiveMessage" access="private" returnFormat="Struct">
    <cfargument name="messageData" type="struct">

    <cfset result = structNew()>

    <cfquery name="insertMessage" datasource="amex_internal">
      insert into message_history
      (messageID,archivedAt,message)
      values
      (
        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.messageData.messageID#">,
        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.messageData#">
      )
    </cfquery>


  </cffunction>

  <!--- Index Message --->
  <cffunction name="indexMessage" access="public" returnFormat="struct">
    <cfargument name="messageData" type="struct" required="true">




  </cffunction>

  <!--- Index Message --->
  <cffunction name="indexThread" access="public" returnFormat="struct">
    <cfargument name="threadData" type="struct" required="true">


  </cffunction>


</cfcomponent>
