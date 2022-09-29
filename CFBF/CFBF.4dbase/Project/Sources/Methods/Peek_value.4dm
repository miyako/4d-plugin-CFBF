//%attributes = {"invisible":true,"preemptive":"capable"}
C_TEXT:C284($1; $dataType)
C_POINTER:C301($4)
C_LONGINT:C283($2; $data; $3; $size)
C_OBJECT:C1216($0; $result)

$dataType:=$1
$data:=$2
$size:=$3

C_BLOB:C604($buf)

Case of 
	: ($dataType="001F")  //PtypString
		
		COPY BLOB:C558($4->{$data}; $buf; 0; 0; $size)
		OB SET:C1220($result; "value"; Convert to text:C1012($buf; "utf-16le"))
		
	: ($dataType="0102")  //PtypBinary
		
		COPY BLOB:C558($4->{$data}; $buf; 0; 0; $size)
		$value:=""
		If ($size#0)
			For ($i; 0; $size-1)
				$value:=$value+Substring:C12(String:C10($buf{$i}; "&x"); 5)
			End for 
		End if 
		OB SET:C1220($result; "value"; $value)
		
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