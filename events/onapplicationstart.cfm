<!--- Place code here that should be executed on the "onApplicationStart" event. --->


<!----  DO NOT CHANGE THIS SALT!!!!! YOU WILL BREAK SHIT AND IT WILL SUCK ---->
<cfset application.overSalt = hash("@M3x$@ltP@$$w0RD!XM3A")>

<cfset application.elasticURL = "http://localhost:9200">


<cfset objSecurity = createObject("java", "java.security.Security") />
<cfset objSecurity.removeProvider("JsafeJCE") />

<cfset application.contentDB = "amex">
<cfset application.internalDB = "amex_internal">
<cfset application.rxDB = "amex_rx">
<cfset application.email = "support@rxportal.io">
<cfset application.appDisplayName = "Amex RxPortal">
<cfset application.supportEmail = "support@rxportal.io">
<cfset application.noForceURLs = "/login,/doctor/signup,/resetpassword,/unrecognized">
<cfset application.noForceControllers = "login">
<cfset application.lookupMethod = "elastic">
<cfset application.fileroot = getDirectoryFromPath(ExpandPath("*.*"))>
<cfset application.saveLocations = structNew()>
<cfset application.saveLocations.rxPDFSaveLocation = "#application.fileroot#/files/pdfs/" >
<cfset application.saveLocations.imageSaveLocation = "#application.fileroot#/files/images/">
<cfset application.saveLocations.signatureSaveLocation = "#application.fileroot#/files/signatures/">
<cfset applocation.saveLocations.avatarSaveLocation = "#application.fileroot#/files/images/avatars">

<!---- Create Signature and Form Key --->
<cfset application.signatureKey = generateSecretKey("AES")>
<cfset application.formKey = generateSecretKey("AES")>

<!--- Set Application Variables that dont change --->
<cfset application.domainName = "amex.rxportal.io">
<cfset application.domainURL = "https://amex.rxportal.io">

<!--- Initialize Elastic Search  --->
<cfinvoke component="miscellaneous.elastic.elastic" method="initialize" />

<!--- Hit Cache Functions --->
<cfinvoke component="controllers.Cache" method="createGlobalCacheStructs" />
<cfinvoke component="controllers.Cache" method="cacheRoles" />
<cfinvoke component="controllers.Cache" method="cacheCategories" />
<cfinvoke component="controllers.Cache" method="cacheManufacturers" />
<cfinvoke component="controllers.cache" method="cacheInsuranceCarriers" />
<cfinvoke component="controllers.cache" method="cacheEligableRxStatus" />
<cfinvoke component="controllers.cache" method="createFormMasks" />
<cfinvoke component="controllers.cache" method="cacheEventTypes" />
<cfinvoke component="controllers.Cache" method="createDrugCache" />

<!--- Cache Ips --->
<cfinvoke component="controllers.Cache" method="createIPCache" />
