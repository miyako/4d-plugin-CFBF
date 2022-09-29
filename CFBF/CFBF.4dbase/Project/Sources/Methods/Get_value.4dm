//%attributes = {"invisible":true,"preemptive":"capable"}
C_TEXT:C284($1; $dataType)
C_POINTER:C301($4; $5)
C_LONGINT:C283($2; $data; $3; $size)
C_OBJECT:C1216($0; $result)

$dataType:=$1
$data:=$2
$size:=$3

C_BLOB:C604($buf)

Case of 
	: ($dataType="001F")  //PtypString
		
		COPY BLOB:C558($4->{$data}; $buf; 0; 0; $size)
		$value:=Convert to text:C1012($buf; "utf-16le")
		
		//ARRAY LONGINT($pos; 0)
		//ARRAY LONGINT($len; 0)
		
		$value:=Replace string:C233($value; Char:C90(0); ""; *)
		//If (Match regex("(.*)\\u0000"; $value; 1; $pos; $len))
		//$value:=Substring($value; $pos{0}; $len{0})  //remove terminator
		//End if 
		
		OB SET:C1220($result; "value"; $value)
		
	: ($dataType="0102")  //PtypBinary
		
		$i:=Size of array:C274($5->)
		COPY BLOB:C558($4->{$data}; $buf; 0; 0; $size)
		APPEND TO ARRAY:C911($5->; $buf)
		
		OB SET:C1220($result; "value"; $i+1)
		
		//ignore all other data types
		
	: ($dataType="0002")  //PtypInteger16
	: ($dataType="0003")  //PtypInteger32
	: ($dataType="0004")  //PtypFloating32
	: ($dataType="0005")  //PtypFloating64
	: ($dataType="000B")  //PtypBoolean
	: ($dataType="0040")  //PtypTime
	: ($dataType="0014")  //PtypInteger64
	: ($dataType="0048")  //PtypGuid
	: ($dataType="000D")  //PtypObject
	: ($dataType="001E")  //PtypString8
	Else 
		
End case 

$0:=$result