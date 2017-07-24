set fogUsr=Foglight_QryUs
set fogPwd=ZZZZ1123
set fogFileDir=C:\TEMP\FoglightMonitoring

cd %fogFileDir%
del  *.xml /f /q

cd C:\TEMP\fglcmd

call fglcmd.bat -usr %fogUsr% -pwd %fogPwd% -cmd util:topologyexport -srv foglightsrv -port 8443 -ssl -topology_query "DBO_Agent_Model" -f %fogFileDir%\fogoracledboAgentModel.xml -property_names "uniqueId,lastUpdated,longName,isBlackedOut,localState,aggregateState,alarmTotalCount,alarmAggregateTotalCount,agentVersion,agentName,build,hostName,type"

call fglcmd.bat -usr %fogUsr% -pwd %fogPwd% -cmd util:topologyexport -srv foglightsrv -port 8443 -ssl -topology_query "DBO_Servers" -f %fogFileDir%\fogoracledboServers.xml -property_names "uniqueId,lastUpdated,longName,isBlackedOut,localState,aggregateState,alarmTotalCount,alarmAggregateTotalCount"

call fglcmd.bat -usr %fogUsr% -pwd %fogPwd% -cmd util:topologyexport -srv foglightsrv -port 8443 -ssl -topology_query "DBO_Database" -f %fogFileDir%\fogoracledboDatabase.xml -property_names "uniqueId,lastUpdated,longName,isBlackedOut,localState,aggregateState,alarmTotalCount,alarmAggregateTotalCount"

call fglcmd.bat -usr %fogUsr% -pwd %fogPwd% -cmd util:topologyexport -srv foglightsrv -port 8443 -ssl -topology_query "DBO_Listener_Status" -f %fogFileDir%\fogoracledboListenerstatus.xml -property_names "uniqueId,lastUpdated,longName,isBlackedOut,localState,aggregateState,alarmTotalCount,alarmAggregateTotalCount"

call fglcmd.bat -usr %fogUsr% -pwd %fogPwd% -cmd util:topologyexport -srv foglightsrv -port 8443 -ssl -topology_query "DBO_Tablespace" -f %fogFileDir%\fogoracledboTablespace.xml -property_names "uniqueId,lastUpdated,longName,isBlackedOut,localState,aggregateState,alarmTotalCount,alarmAggregateTotalCount,tablespace_name,status,contents,retention,block_size"
