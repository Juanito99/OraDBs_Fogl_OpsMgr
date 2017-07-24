param($sourceId,$managedEntityId)


$api = New-Object -ComObject 'MOM.ScriptAPI'
$discoveryData = $api.CreateDiscoveryData(0,$sourceId,$managedEntityId)

#$api.LogScriptEvent('ABC.Database.Oracle.Foglight DiscoverDBORelations.ps1',201,4,"ABC.Database.Oracle.Foglight DiscoverDBORelations starts")

$classDatabaseSystem = Get-SCOMClass -Name 'ABC.Database.Oracle.Foglight.DBO.DatabaseSystem'
$classDatabaseSystemInstances = Get-SCOMClassInstance -Class $classDatabaseSystem

$classDatabase = Get-SCOMClass -Name 'ABC.Database.Oracle.Foglight.DBO.Database'
$classDatabaseInstances = Get-SCOMClassInstance -Class $classDatabase

$classServer = Get-SCOMClass -Name 'ABC.Database.Oracle.Foglight.DBO.Server'
$classServerInstances = Get-SCOMClassInstance -Class $classServer

$classListener = Get-Scomclass -Name 'ABC.Database.Oracle.Foglight.DBO.Listener'
$classListenerInstances =  Get-SCOMClassInstance -Class $classListener

$classTablespace = Get-SCOMClass -Name 'ABC.Database.Oracle.Foglight.DBO.Tablespace'
$classTablespaceInstances = Get-SCOMClassInstance -Class $classTablespace

$classAgent = Get-SCOMClass -Name 'ABC.Database.Oracle.Foglight.DBO.Agent'
$classAgentInstances = Get-SCOMClassInstance -Class $classAgent


foreach ($dbObj in $classDatabaseSystemInstances) {
		
	$dbName = $dbObj.'[ABC.Database.Oracle.Foglight.DBO.Base].dbName'.Value
		
	$srcInstance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.DatabaseSystem']$")
	$srcInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$", $dbName)
	$srcInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.DatabaseSystem']/uniqueId$", $dbObj.'[ABC.Database.Oracle.Foglight.DBO.DatabaseSystem].uniqueId'.Value)
	$srcInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$", $dbObj.'[ABC.Database.Oracle.Foglight.DBO.Base].longName'.Value)	
	$discoveryData.AddInstance($srcInstance)

	$dbInstances = $classDatabaseInstances | Where-Object {$_.'[ABC.Database.Oracle.Foglight.DBO.Base].dbName'.value -imatch $dbName}
	foreach($dbI in $dbInstances) {

		$targetInstance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Database']$")
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$", $dbName)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Database']/uniqueId$", $dbI.'[ABC.Database.Oracle.Foglight.DBO.Database].uniqueId'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$", $dbI.'[ABC.Database.Oracle.Foglight.DBO.Base].longName'.Value)		
		$discoveryData.AddInstance($targetInstance)
	
		$relInstance = $discoveryData.CreateRelationShipInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DatabaseSystemHostsDatabase']$")
		$relInstance.Source = $srcInstance
		$relInstance.Target = $targetInstance
		$discoveryData.AddInstance($relInstance)

	} #END foreach($dbI in $dbInstances)  

	$serverInstances = $classServerInstances | Where-Object {$_.'[ABC.Database.Oracle.Foglight.DBO.Base].dbName'.value -imatch $dbName}
	foreach($server in $serverInstances) {

		$targetInstance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Server']$")
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$", $dbName)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Server']/uniqueId$", $server.'[ABC.Database.Oracle.Foglight.DBO.Server].uniqueId'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$", $server.'[ABC.Database.Oracle.Foglight.DBO.Base].longName'.Value)		
		$discoveryData.AddInstance($targetInstance)
	
		$relInstance = $discoveryData.CreateRelationShipInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DatabaseSystemHostsServer']$")
		$relInstance.Source = $srcInstance
		$relInstance.Target = $targetInstance
		$discoveryData.AddInstance($relInstance)

	} #END foreach($server in $classServerInstances) 

	$listenerInstances = $classListenerInstances | Where-Object {$_.'[ABC.Database.Oracle.Foglight.DBO.Base].dbName'.value -imatch $dbName}
	foreach($listener in $listenerInstances) {

		$targetInstance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Listener']$")
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$", $dbName)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Listener']/uniqueId$", $listener.'[ABC.Database.Oracle.Foglight.DBO.Listener].uniqueId'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$", $listener.'[ABC.Database.Oracle.Foglight.DBO.Base].longName'.Value)		
		$discoveryData.AddInstance($targetInstance)
	
		$relInstance = $discoveryData.CreateRelationShipInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DatabaseSystemHostsListener']$")
		$relInstance.Source = $srcInstance
		$relInstance.Target = $targetInstance
		$discoveryData.AddInstance($relInstance)

	} #END foreach($server in $classServerInstances)
		
	$agentInstances = $classAgentInstances | Where-Object {$_.'[ABC.Database.Oracle.Foglight.DBO.Base].dbName'.value -imatch $dbName}
	foreach($agent in $agentInstances) {

		$targetInstance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']$")
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$", $dbName)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/uniqueId$", $agent.'[ABC.Database.Oracle.Foglight.DBO.Agent].uniqueId'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$", $agent.'[ABC.Database.Oracle.Foglight.DBO.Base].longName'.Value)		
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/agentVersion$", $agent.'[ABC.Database.Oracle.Foglight.DBO.Agent].agentVersion'.Value)		
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/agentName$", $agent.'[ABC.Database.Oracle.Foglight.DBO.Agent].agentName'.Value)		
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/build$", $agent.'[ABC.Database.Oracle.Foglight.DBO.Agent].build'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/monitoringHost$", $agent.'[ABC.Database.Oracle.Foglight.DBO.Agent].monitoringHost'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/type$", $agent.'[ABC.Database.Oracle.Foglight.DBO.Agent].type'.Value)		
		$discoveryData.AddInstance($targetInstance)
	
		$relInstance = $discoveryData.CreateRelationShipInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DatabaseSystemHostsAgent']$")
		$relInstance.Source = $srcInstance
		$relInstance.Target = $targetInstance
		$discoveryData.AddInstance($relInstance)

	} #END foreach($agent in $agentInstances)
			
} #END foreach($dbObj in $classDatabaseInstances) 


foreach ($dbObj in $classDatabaseInstances) {
		
	$dbName = $dbObj.'[ABC.Database.Oracle.Foglight.DBO.Base].dbName'.Value

	$srcInstance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Database']$")
	$srcInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$", $dbName)
	$srcInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Database']/uniqueId$", $dbObj.'[ABC.Database.Oracle.Foglight.DBO.Database].uniqueId'.Value)
	$srcInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$", $dbObj.'[ABC.Database.Oracle.Foglight.DBO.Base].longName'.Value)	
	$discoveryData.AddInstance($srcInstance)

	$tableSpaceInstances = $classTablespaceInstances | Where-Object {$_.'[ABC.Database.Oracle.Foglight.DBO.Base].dbName'.value -imatch $dbName}
	foreach($tablespace in $tableSpaceInstances) {

		$targetInstance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']$")
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$", $dbName)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/uniqueId$", $tablespace.'[ABC.Database.Oracle.Foglight.DBO.Tablespace].uniqueId'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$", $tablespace.'[ABC.Database.Oracle.Foglight.DBO.Base].longName'.Value)		
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/tableSpaceName$", $tablespace.'[ABC.Database.Oracle.Foglight.DBO.Tablespace].tableSpaceName'.Value)		
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/status$", $tablespace.'[ABC.Database.Oracle.Foglight.DBO.Tablespace].status'.Value)		
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/contents$", $tablespace.'[ABC.Database.Oracle.Foglight.DBO.Tablespace].contents'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/retention$", $tablespace.'[ABC.Database.Oracle.Foglight.DBO.Tablespace].retention'.Value)
		$targetInstance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/blocksize$", $tablespace.'[ABC.Database.Oracle.Foglight.DBO.Tablespace].blocksize'.Value)		
		$discoveryData.AddInstance($targetInstance)
	
		$relInstance = $discoveryData.CreateRelationShipInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DatabaseHostsTablespace']$")
		$relInstance.Source = $srcInstance
		$relInstance.Target = $targetInstance
		$discoveryData.AddInstance($relInstance)

	} #END foreach($tablespace in $tableSpaceInstances)	
	
} #END foreach ($dbObj in $classDatabaseInstances) 


$discoveryData