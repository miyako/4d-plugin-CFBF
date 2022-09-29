//%attributes = {"invisible":true,"shared":true}
ARRAY LONGINT:C221($numbers; 0)
ARRAY TEXT:C222($names; 0)

PLUGIN LIST:C847($numbers; $names)

ASSERT:C1129(Find in array:C230($names; "MIME")#-1)
ASSERT:C1129(Find in array:C230($names; "CFBF")#-1)