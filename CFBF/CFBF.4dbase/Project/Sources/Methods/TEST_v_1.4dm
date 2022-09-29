//%attributes = {}
$file:=Folder:C1567(fk desktop folder:K87:19).file("test.msg")

$data:=$file.getContent()

C_OBJECT:C1216($eml)
ARRAY BLOB:C1222($attachments; 0)

$callback:=Formula:C1597(TEST_callback)

ARRAY BLOB:C1222($mht; 0)

$eml:=MSG_PARSE(->$data; ->$attachments; ->$mht; $callback)
