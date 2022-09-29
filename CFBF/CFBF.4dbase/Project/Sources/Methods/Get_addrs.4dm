//%attributes = {"invisible":true,"preemptive":"capable"}
C_OBJECT:C1216($1; $message)
C_TEXT:C284($2; $listValue; $3; $attr)

$message:=$1
$listValue:=$2
$attr:=$3

ARRAY LONGINT:C221($pos; 0)
ARRAY LONGINT:C221($len; 0)

$i:=0x0001

While (Match regex:C1019("(([^;]+)(?:;\\s*)?)"; $listValue; $i; $pos; $len))
	$value:=Substring:C12($listValue; $pos{2}; $len{2})
	$i:=$pos{1}+$len{1}
	$addr:=Get_addr($value)
	If ($addr.addr#"")
		If ($message[$attr].length>0)
			$obj:=$message[$attr][0]
		Else 
			$obj:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
			$message[$attr][0]:=$obj
		End if 
		$obj.name:=$addr.name
		$obj.addr:=$addr.addr
	End if 
	
End while 