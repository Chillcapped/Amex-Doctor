

<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/pageHeader")#</cfoutput>
<cfoutput>#includePartial("/portal_layouts/#lcase(application.roles[session.user.role].name)#/includes/sideMenu")#</cfoutput>

<div id="contentContainer">
  <div id="scheduleContainer">
    <h4>Shipping Schedule </h4>
  <table class="table">
    <thead>
      <tr>
        <th>Placed Order</th>
        <th>Shipping Day</th>
        <th>Estimated Delivery Date</th>
      </tr>
    </thead>
    <tbody>
      <cfloop from="2" to="#arrayLen(application.shippingSchedule)#" index="i">
        <cfoutput>
        <tr>
          <td>#DayOfWeekAsString(i)#</td>
          <td>#dayOfWeekAsString(application.shippingSchedule[i].shipping)#</td>
          <td>#dayOfWeekAsString(application.shippingSchedule[i].shipping + 1)#</td>
        </tr>
        </cfoutput>
      </cfloop>
    </tbody>
  </table>


  </div>
</div>
