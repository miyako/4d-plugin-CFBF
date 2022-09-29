//%attributes = {"invisible":true,"preemptive":"capable"}
$console:=console

$lastError:=$console.getLastError()

$console.log($lastError)

If (Storage:C1525.on_err_call#Null:C1517)
	Storage:C1525.on_err_call.call($lastError)
End if 