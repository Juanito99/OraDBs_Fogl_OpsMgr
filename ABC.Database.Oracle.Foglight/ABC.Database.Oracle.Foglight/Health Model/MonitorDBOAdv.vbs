strQryItem = WScript.Arguments(0)
strXmlShare = WScript.Arguments(1)

Set objWShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objAPI = CreateObject("MOM.ScriptAPI")

Set dictXMLFiles = WScript.CreateObject("Scripting.Dictionary")
dictXMLFiles.Add "Servers", "fogoracledboServers.xml"
dictXMLFiles.Add "Database", "fogoracledboDatabase.xml"
dictXMLFiles.Add "Datafile", "fogoracledboDatafile.xml"
dictXMLFiles.Add "Tablespace", "fogoracledboTablespace.xml"
dictXMLFiles.Add "Listener", "fogoracledboListenerstatus.xml"
dictXMLFiles.Add "Agent", "fogoracledboAgentModel.xml"

strXMLFileSelected = dictXMLFiles.Item(strQryItem)
strXMLSrc = strXmlShare & "\" &strXMLFileSelected


If objFSO.FileExists(strXMLSrc) Then
	strFoo = "continue"
Else
	strFoo = "stope here"
	WScript.Quit(1)
End If


Set xmlDoc = WScript.CreateObject("Microsoft.XMLDOM")
xmlDoc.load(strXMLSrc)

Set objDoc = xmlDoc.selectNodes("//top-objects/top-obj")
	
Set allObjects = WScript.CreateObject("System.Collections.ArrayList")

For Each node In objDoc
	
	Set tmpObject = WScript.CreateObject("Scripting.Dictionary")
	For Each child In node.childNodes		
		strPair = ""
		For Each attrib In child.attributes
			strPair = strPair & "^"  & (attrib.nodeValue)			
		Next	
		strPair = Right(strPair,Len(strPair)-1)
		arrPair = Split(strPair,"^")
		tmpObject.Add arrPair(0), arrPair(1)
		
		If(arrPair(0) = "aggregateState") Then
			Select Case arrPair(1) 
				Case 0
					strState = "Good"
				Case 1
					strState = "Good"
				Case 2
					strState = "Good"
				Case 3
					strState = "Bad"
				Case 4
					strState = "Bad" 		
			End Select
			tmpObject.Add "Result", strState
		End If		
		
	Next	
	allObjects.add(tmpObject)
	Set tmpObject = Nothing 
	
Next

For Each itm In allObjects	

	strLongName = ""
	strHealthValue = ""
	strUniqueId = ""

	strLongName = itm.Item("longName") 
	strHealthValue = itm.Item("Result") 
	strUniqueId = itm.Item("uniqueId") 
	strUniqueId = Replace(strUniqueId,"-","")
	strBag = "long: " &strLongName & " health: " &strHealthValue & " uid: " &strUniqueId

	If ( (strLongName <> "" ) And ( strHealthValue <> "" ) And ( strUniqueId <> "" ) ) Then        
		Set objBag = objAPI.CreatePropertyBag()	
		Call objBag.AddValue("uniqueId",strUniqueId)    	
		Call objBag.AddValue("longName",strLongName)
		Call objBag.AddValue("Result",strHealthValue)    
		objAPI.AddItem(objBag)            
	Else        
		strFoo = "issue happened."        
	End If                  

Next

objAPI.ReturnItems
WScript.Quit(0)