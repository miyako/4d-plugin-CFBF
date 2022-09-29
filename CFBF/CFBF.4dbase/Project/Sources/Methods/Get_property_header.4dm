//%attributes = {"invisible":true,"preemptive":"capable"}
C_BLOB:C604($1; $buf)

$buf:=$1

C_LONGINT:C283($2; $len)

$len:=$2

C_COLLECTION:C1488($bytes)
$bytes:=New collection:C1472

For ($start; 0; BLOB size:C605($buf)-2; 2)
	
	COPY BLOB:C558($buf; $prop; $start; 0; 2)
	
	$bytes.push(Substring:C12(String:C10($prop{1}; "&x"); 5))
	$bytes.push(Substring:C12(String:C10($prop{0}; "&x"); 5))
	
End for 

C_TEXT:C284($0; $hex)

$hex:=$bytes.join()

$0:=$hex