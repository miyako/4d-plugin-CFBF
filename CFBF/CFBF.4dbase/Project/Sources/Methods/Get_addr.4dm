//%attributes = {"invisible":true,"preemptive":"capable"}
C_TEXT:C284($1; $name; $addr)
C_OBJECT:C1216($0; $address)

$addr:=$1

ARRAY LONGINT:C221($pos; 0)
ARRAY LONGINT:C221($len; 0)

Case of 
	: (Match regex:C1019("(['\"]?)(.+)(\\1)\\s+\\(([^)]*)\\)"; $addr; 1; $pos; $len))
		$name:=Substring:C12($addr; $pos{2}; $len{2})
		$addr:=Substring:C12($addr; $pos{4}; $len{4})
		//: (Match regex("(.+)\\s+\\(([^)]*)\\)";$addr;1;$pos;$len))
		//$name:=Substring($addr;$pos{1};$len{1})
		//$addr:=Substring($addr;$pos{2};$len{2})
	: (Match regex:C1019("(['\"]?)(.+)(\\1)"; $addr; 1; $pos; $len))
		$name:=Substring:C12($addr; $pos{2}; $len{2})
		$addr:=$name
End case 

$address:=New object:C1471("name"; $name; "addr"; $addr)

$0:=$address