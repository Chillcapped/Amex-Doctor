<!---
	Here you can add routes to your application and edit the default one.
	The default route is the one that will be called on your application's "home" page.
--->

<cfset addRoute(name="empty", pattern="", controller="user", action="home")>
<cfset addRoute(name="home", pattern="/home", controller="user", action="home")>
<cfset addRoute(name="login", pattern="/login", controller="user", action="login")>
<cfset addRoute(name="logout", pattern="/logout", controller="user", action="logOut")>
<cfset addRoute(name="account", pattern="/account", controller="user", action="account")>
<cfset addRoute(name="reset", pattern="/resetpassword", controller="user", action="resetPassword")>
<cfset addRoute(name="unrecognizedIp", pattern="/unrecognized", controller="user", action="unrecognized")>

<!--- Patient Routes --->
<cfset addRoute(name="createPatient", pattern="/createPatient", controller="patients", action="create")>

<!--- Doctor Specific Routes --->
<cfset addRoute(name="addOffice", pattern="/offices/add", controller="offices", action="add")>
<cfset addRoute(name="editOffice", pattern="/offices/edit/[officeID]", controller="offices", action="edit")>
<cfset addRoute(name="offices", pattern="/offices", controller="offices", action="index")>

<cfset addRoute(name="staff", pattern="/staff", controller="doctor", action="staff")>

<cfset addRoute(name="shipments", pattern="/shipments/schedule", controller="shipments", action="schedule")>
<cfset addRoute(name="shipments", pattern="/shipments", controller="shipments", action="shipments")>

<cfset addRoute(name="help", pattern="/help/", controller="user", action="help")>


<!--- User Tab Routes --->
<cfset addRoute(name="techTabs", pattern="/tech/tabs/[tabType]/[tab]", controller="technicians", action="tabs")>
<cfset addRoute(name="doctorTabs", pattern="/doctor/tabs/[tabType]/[tab]", controller="doctor", action="tabs")>
<cfset addRoute(name="adminTabs", pattern="/admin/tabs/[tabType]/[tab]", controller="admin", action="tabs")>


<!--- Prescription Routes --->

<cfset addRoute(name="mdPrescribe", pattern="/prescribe/[type]", controller="doctor", action="prescribe")>
<cfset addRoute(name="mdPrescribe", pattern="/prescribe", controller="doctor", action="prescribe")>
<cfset addRoute(name="mdExpiredRx", pattern="/prescriptions/expired", controller="prescriptions", action="expired")>
<cfset addRoute(name="mdActiveRx", pattern="/prescriptions/active", controller="prescriptions", action="active")>
<cfset addRoute(name="mdExpiringRx", pattern="/prescriptions/expiring", controller="prescriptions", action="expireSoon")>

<cfset addRoute(name="rxInfo", pattern="/prescriptions/info/", controller="prescriptions", action="information")>
<cfset addRoute(name="rxNotes", pattern="/prescriptions/notes/[prescriptionID]", controller="prescriptions", action="rx_notes")>
<cfset addRoute(name="rxMessages", pattern="/prescriptions/messages/[prescriptionID]", controller="prescriptions", action="rx_messages")>
<cfset addRoute(name="rxTimeLine", pattern="/prescriptions/timeline/[prescriptionID]", controller="prescriptions", action="rx_timeline")>
<cfset addRoute(name="rxSignaturePad", pattern="/prescriptions/sign/", controller="prescriptions", action="sign")>
<cfset addRoute(name="rxAuthorize", pattern="/prescriptions/authorize/[prescriptionID]", controller="prescriptions", action="authorize")>
<cfset addRoute(name="securityPrompt", pattern="/securityCodePrompt/", controller="doctor", action="securityCodePrompt")>
<cfset addRoute(name="mdExpiredRx", pattern="/prescriptions", controller="prescriptions", action="index")>
<cfset addRoute(name="compoundInfo", pattern="/compounds/info/[compoundID]", controller="compounds", action="info")>

<!--- Patient Info Routes --->
<cfset addRoute(name="patientNotes", pattern="/patients/notes/[patientID]", controller="patients", action="notes")>
<cfset addRoute(name="patientHistory", pattern="/patients/history/[patientID]", controller="patients", action="history")>
<cfset addRoute(name="patientUpdateINfo", pattern="/patients/update/[patientID]", controller="patients", action="update")>
<cfset addRoute(name="patientCreateRx", pattern="/patients/createRx/[patientID]", controller="prescriptions", action="createRx")>
<cfset addRoute(name="patientINfo", pattern="/patients/information/[patientID]", controller="patients", action="information")>
<cfset addRoute(name="processSignature", pattern="/processSignature/", controller="prescriptions", action="processSignature")>


<!--- Create Rx --->
<cfset addRoute(name="createRXCreator", pattern="/createRx/creator", controller="prescriptions", action="PrescriptionCreator")>
<cfset addRoute(name="createRXApproveSubmited", pattern="/createRx/approve", controller="prescriptions", action="createRX_approve")>
<cfset addRoute(name="createRXAuthorize", pattern="/createRx/authorize", controller="prescriptions", action="createRx_authorizePreview")>
<cfset addRoute(name="createRXProcess", pattern="/createRx/process", controller="prescriptions", action="createRx_process")>
<cfset addRoute(name="createRXaddTableItem", pattern="/createRx/add/[type]/[ID]", controller="prescriptions", action="createRX_addTableItem")>
<cfset addRoute(name="createRXmanufacturedDrug", pattern="/createRx/manufactured/info/[drugID]", controller="prescriptions", action="createRX_manufactured")>
<cfset addRoute(name="createRXmanufacturedCategories", pattern="/createRx/manufactured/[categoryID]", controller="prescriptions", action="createRX_manufactured")>
<cfset addRoute(name="createRXmanufacturedGeneral", pattern="/createRx/manufactured/", controller="prescriptions", action="createRX_manufactured")>
<cfset addRoute(name="createRXcompoundItem", pattern="/createRx/compound/info/[compoundID]", controller="prescriptions", action="createRX_compounds")>
<cfset addRoute(name="createRXcompoundCategories", pattern="/createRx/compound/[categoryID]", controller="prescriptions", action="createRX_compounds")>
<cfset addRoute(name="createRXcompoundGeneral", pattern="/createRx/compound/", controller="prescriptions", action="createRX_compounds")>
<cfset addRoute(name="createRXcompoundGeneral", pattern="/createRx/creator/", controller="prescriptions", action="createRX_creator")>
<cfset addRoute(name="createPatientRX", pattern="/createRx/[patientID]", controller="prescriptions", action="createRx")>
<cfset addRoute(name="createRX", pattern="/createRx/", controller="prescriptions", action="createRx")>
<cfset addRoute(name="createCategory", pattern="/categories/createCategory", controller="categories", action="createCategory")>
<cfset addRoute(name="createType", pattern="/categories/createType", controller="categories", action="createType")>

<--- Medication Routes --->
<cfset addRoute(name="medCreateType", pattern="/medications/createType", controller="categories", action="createType")>
<cfset addRoute(name="medCreateCategory", pattern="/medications/createCategory", controller="categories", action="createCategory")>
<cfset addRoute(name="medBrowseSpecific", pattern="/medications/[categoryType]/[category]", controller="medications", action="index")>
<cfset addRoute(name="medBrowse", pattern="/medications/[categoryType]/", controller="medications", action="index")>


<!--- messages --->
<cfset addRoute(name="userMessages", pattern="/messages/", controller="messages", action="messages")>


<!--- Admin Routes --->
<cfset addRoute(name="adminUserList", pattern="/admin/users/[role]", controller="admin", action="users")>

<!--- Elastic Routes --->
<cfset addRoute(name="adminIndexBrowse", pattern="/admin/elastic/index/[index]", controller="admin", action="elastic")>

<cfset addRoute(name="adminElasticReindexSelection", pattern="/admin/elastic/reindex/[index]", controller="admin", action="elastic")>
<cfset addRoute(name="adminElasticReindex", pattern="/admin/elastic/reindex/", controller="admin", action="elastic")>
<cfset addRoute(name="adminElasticAlias", pattern="/admin/elastic/alias/", controller="admin", action="elastic")>
<cfset addRoute(name="adminElasticAction", pattern="/admin/elastic/[eaction]/[index]", controller="admin", action="elastic")>
<cfset addRoute(name="adminElastic", pattern="/admin/elastic/[eaction]/", controller="admin", action="elastic")>

<cfset addRoute(name="adminToolItemAction", pattern="/admin/tools/[tool]/[toolaction]", controller="admin", action="tools")>
<cfset addRoute(name="adminToolItem", pattern="/admin/tools/[tool]", controller="admin", action="tools")>


<!--- Avastin --->

<cfset addRoute(name="avastin", pattern="/avastin/[type]", controller="prescriptions", action="avastin")>
<cfset addRoute(name="avastin", pattern="/avastin", controller="prescriptions", action="avastin")>
