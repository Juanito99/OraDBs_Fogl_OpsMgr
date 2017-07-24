param($sourceId,$managedEntityId,$qryItem)

$api = New-Object -ComObject 'MOM.ScriptAPI'
$discoveryData = $api.CreateDiscoveryData(0, $sourceId, $managedEntityId)

$xmlFilePath = 'C:\Temp\FoglightMonitoring\'
$xmlFileHash = @{
  'Servers' = 'fogoracledboServers.xml'
  'Database' = 'fogoracledboDatabase.xml'
  'DatabaseSystem' = 'fogoracledboDatabase.xml'
  'Tablespace' = 'fogoracledboTablespace.xml'
  'Agent' = 'fogoracledboAgentModel.xml'
  'Listener' = 'fogoracledboListenerstatus.xml'
}

$xmlFile = $xmlFileHash[$qryItem]
$xmlFilePath += $xmlFile
$xmlFileContent = Get-Content -Path $xmlFilePath

#$api.LogScriptEvent('ABC.Database.Oracle.Foglight.DBO - DiscoverDBOs.ps1',100,4,"DiscoverDBOs.ps1 Started - Source $($sourceId) managEnt $($managedEntityId) qryItem $($qryItem)")

Function Convert-XmlToObjectDicts {
  param(
	[ref]$outDict,
	[array]$xmlFileContent,
	[string]$qryItem
  )

  $rtn = $false

  $dboDict = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,PSCustomObject]'
  $xmlDBOChilds = ([xml]$xmlFileContent).'top-objects'.'top-obj'

  $xmlDBOChilds | ForEach-Object {
	$xmlDboChild = $_
	$uniqueId  = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'uniqueId' }).value
	$uniqueId = $uniqueId -replace '-',''
	$lastUpdated  = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'lastUpdated' }).value
	$longName  = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'longName' }).value
	$isBlackedOut  = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'isBlackedOut' }).value
	$localState  = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'localState' }).value
	$aggregateState  = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'aggregateState' }).value
	$alarmTotalCount  = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'alarmTotalCount' }).value
	$alarmAggregateTotalCount  = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'alarmAggregateTotalCount' }).value

	$fileName = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'file_name' }).value
	$autoExtensible = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'auto_extensible' }).value
	$fileSystemName = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'filesystem_name' }).value
	$tablespaceName = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'tablespace_name' }).value
	$status = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'status' }).value
	$contents = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'contents' }).value
	$retention = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'retention' }).value
	$blocksize = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'block_size' }).value
	$agentVersion = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'agentVersion' }).value
	$agentName = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'agentName' }).value
	$build = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'build' }).value
	$monitoringHost = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'hostname' }).value
	$type = ($xmlDboChild.ChildNodes | Where-Object { $_.Name -eq 'type' }).value

	$null = [int]::TryParse($localState, [ref]$localState)
	$null = [int]::TryParse($aggregateState, [ref]$aggregateState)
	$null = [int]::TryParse($alarmTotalCount, [ref]$alarmTotalCount)
	$null = [int]::TryParse($alarmAggregateTotalCount, [ref]$alarmAggregateTotalCount)
	$null = [int]::TryParse($blocksize, [ref]$blocksize)

	$lastUpdatedS = [Regex]::Matches($($lastUpdated),'\d{4}-\d{2}-\d{2}\s{1}\d{2}\:\d{2}\:\d{2}').Value
	[datetime]$lastUpdatedTime = [datetime]::Now
	$dateFormat = 'yyyy-MM-dd HH:mm:ss'
	$culture = [System.Globalization.CultureInfo]::InvariantCulture
	$style = [System.Globalization.DateTimeStyles]::None
	$null = [datetime]::TryParseExact($lastUpdatedS,$dateformat,$culture,$style,[ref]$lastUpdatedTime)

	$dbName = [Regex]::Matches($($longName),'[a-zA-Z]{5,}[a-zA-Z]{1,}[a-zA-Z]{1,}[dbDB]{2}').Value

	if ( $($dbName.Length) -gt 0 ) {
	  if($qryItem -eq 'Servers' -or $qryItem -eq 'Database' -or $qryItem -eq 'Listener')  {
		$dboObj = [PSCustomObject] @{
			  [string]'uniqueId' = $uniqueId
			  'lastUpdated' = $lastUpdatedTime
			  [string]'longName' = $longName
			  [string]'dbName' = $dbName
			  [bool]'isBlackedOut' = if ($isBlackedOut -eq 'false') { $false } else { $true }
			  'localState' = $localState
			  'aggregateState' = $aggregateState
			  'alarmTotalCount' = $alarmTotalCount
			  'alarmAggregateTotalCount' = $alarmAggregateTotalCount
		}
	  } elseif ($qryItem -eq 'DatabaseSystem') {
		$dboObj = [PSCustomObject] @{
			  [string]'uniqueId' = $uniqueId + '-Sys'
			  'lastUpdated' = $lastUpdatedTime
			  [string]'longName' = $dbName + '_Long'
			  [string]'dbName' = $dbName
		}
		$dbName += $fileName
	  } elseif ($qryItem -eq 'Tablespace') {
		$dboObj = [PSCustomObject] @{
			  [string]'uniqueId' = $uniqueId
			  'lastUpdated' = $lastUpdatedTime
			  [string]'longName' = $longName
			  [string]'dbName' = $dbName
			  [bool]'isBlackedOut' = if ($isBlackedOut -eq 'false') { $false } else { $true }
			  'localState' = $localState
			  'aggregateState' = $aggregateState
			  'alarmTotalCount' = $alarmTotalCount
			  'alarmAggregateTotalCount' = $alarmAggregateTotalCount
			  [string]'tableSpaceName' = $tablespaceName
			  [string]'status' = $status
			  [string]'contents' = $contents
			  [string]'retention' = $retention
			  'blocksize' = $blocksize
		}
		$dbName += $tablespaceName
	  } elseif ($qryItem -eq 'Agent') {
		$dboObj = [PSCustomObject] @{
			  [string]'uniqueId' = $uniqueId
			  'lastUpdated' = $lastUpdatedTime
			  [string]'longName' = $longName
			  [string]'dbName' = $dbName
			  [bool]'isBlackedOut' = if ($isBlackedOut -eq 'false') { $false } else { $true }
			  'localState' = $localState
			  'aggregateState' = $aggregateState
			  'alarmTotalCount' = $alarmTotalCount
			  'alarmAggregateTotalCount' = $alarmAggregateTotalCount
			  [string]'agentVersion' = $agentVersion
			  [string]'agentName' = $agentName
			  [string]'build' = $build
			  [string]'monitoringHost' = $monitoringHost
			  [string]'type' = $type
		}
	  } else {
		$dboObj = $null
	  }
	  $null = $dboDict.Add($dbName,$dboObj)
	} else {
	  $foo = 'skipping empty entry'
	}
  } #END $xmlDBOChilds | ForEach-Object { }

  #$api.LogScriptEvent('ABC.Database.Oracle.Foglight.DBO - DiscoverDBOs.ps1',101,4,"DiscoverDBOs.ps1 Convert... - dboDict.count $($dboDict.Count) for qyrItem $($qryItem)")

  $outDict.Value = $dboDict

  if ($dboDict.Count -gt 1) {
	$rtn = $true
  } else {
	$rtn = $false
  }
} #END Function Convert-XmlToObjectDicts { }

Function Publish-ObjectToSCOM {
  param(
	[string]$qryItem,
	[System.Collections.Generic.Dictionary[String,PSCustomObject]]$dboDict,
	[ref]$stateMsg
  )

  $rtn = $false

  $fglClasses = @{
	'Servers' = 'ABC.Database.Oracle.Foglight.DBO.Server'
	'Database' = 'ABC.Database.Oracle.Foglight.DBO.Database'
	'DatabaseSystem' = 'ABC.Database.Oracle.Foglight.DBO.DatabaseSystem'
	'Tablespace' = 'ABC.Database.Oracle.Foglight.DBO.Tablespace'
	'Agent' = 'ABC.Database.Oracle.Foglight.DBO.Agent'
	'Listener' = 'ABC.Database.Oracle.Foglight.DBO.Listener'
  }

  $fglClass = $fglClasses[$qryItem]

	#$api.LogScriptEvent('ABC.Database.Oracle.Foglight.DBO - DiscoverDBOs.ps1',102,4,"DiscoverDBOs.ps1 - Publish ... - fglClass $($fglClass) - qryItem $($qryItem)")
	#$api.LogScriptEvent('ABC.Database.Oracle.Foglight.DBO - DiscoverDBOs.ps1',102,2,"DiscoverDBOs.ps1 - Publish ... - dboDict.Count $($dboDict.Count)")

  foreach ($dboItem in $dboDict.Values) {
	  $displayName = "$($qryItem)-$($dboItem.dbName)"
	if($qryItem -eq 'Servers') {
		$instance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Server']$")
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Server']/uniqueId$",$dboItem.uniqueId)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$",$dboItem.longName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$",$dboItem.dbName)
		$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
		$discoveryData.AddInstance($instance)
	} elseif ($qryItem -eq 'Database') {
		$instance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Database']$")
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Database']/uniqueId$",$dboItem.uniqueId)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$",$dboItem.longName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$",$dboItem.dbName)
		$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
		$discoveryData.AddInstance($instance)
	} elseif ($qryItem -eq 'DatabaseSystem') {
		$instance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.DatabaseSystem']$")
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.DatabaseSystem']/uniqueId$",$dboItem.uniqueId)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$",$dboItem.longName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$",$dboItem.dbName)
		$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
		$discoveryData.AddInstance($instance)
	} elseif ($qryItem -eq 'Listener') {
		$instance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Listener']$")
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Listener']/uniqueId$",$dboItem.uniqueId)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$",$dboItem.longName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$",$dboItem.dbName)
		$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
		$discoveryData.AddInstance($instance)
	} elseif ($qryItem -eq 'Tablespace') {
		$displayName = "$($qryItem)-$($dboItem.dbName)-$($dboItem.tableSpaceName)"
		$instance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']$")
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/uniqueId$",$dboItem.uniqueId)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$",$dboItem.longName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$",$dboItem.dbName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/tableSpaceName$",$dboItem.tableSpaceName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/status$",$dboItem.status)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/contents$",$dboItem.contents)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/retention$",$dboItem.retention)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Tablespace']/blocksize$",$dboItem.blocksize)
		$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
		$discoveryData.AddInstance($instance)
	} elseif ($qryItem -eq 'Agent') {
		$instance = $discoveryData.CreateClassInstance("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']$")
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/uniqueId$",$dboItem.uniqueId)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/longName$",$dboItem.longName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Base']/dbName$",$dboItem.dbName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/agentVersion$",$dboItem.agentVersion)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/agentName$",$dboItem.agentName)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/build$",$dboItem.build)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/monitoringHost$",$dboItem.monitoringHost)
		$instance.AddProperty("$MPElement[Name='ABC.Database.Oracle.Foglight.DBO.Agent']/type$",$dboItem.type)
		$instance.AddProperty("$MPElement[Name='System!System.Entity']/DisplayName$", $displayName)
		$discoveryData.AddInstance($instance)
	} else {
		$foo = 'bar'
	}
  } #END foreach ($domItem in $dboDict.Value) { }

  if($Error) {
	$stateMsg.Value = "Publish-ObjectToSCOM - Error occured: $Error"
	$rtn = $false
  } else {
	$stateMsg.Value = "Publish-ObjectToSCOM - All good."
	$rtn = $true
  }
} #END Function Publish-ObjectToSCOM {}

$dboDBDict = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,PSCustomObject]'
$dboServerDict = New-Object -TypeName 'System.Collections.Generic.Dictionary[String,PSCustomObject]'

$rtnDboDB = Convert-XmlToObjectDicts -outDict ([ref]$dboDBDict) -xmlFileContent $xmlFileContent -qryItem $qryItem

$publishObjMsg = ''
$rtnPubToSCOM = Publish-ObjectToSCOM -qryItem $qryItem -dboDict $dboDBDict -stateMsg ([ref]$publishObjMsg)

$discoveryData