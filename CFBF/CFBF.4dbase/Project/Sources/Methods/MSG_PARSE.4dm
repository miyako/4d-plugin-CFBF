//%attributes = {"invisible":true,"shared":true}
C_POINTER:C301($1)  //->BLOB (msg)
C_POINTER:C301($2)  //->ARRAY BLOB
C_POINTER:C301($3)  //->BLOB (mht)
C_OBJECT:C1216($4)  //FORMULA OBJECT
C_OBJECT:C1216($0)

C_TEXT:C284($json)
ARRAY BLOB:C1222($bytes; 0)

$console:=console

$console.start()

If (Count parameters:C259#0)
	If (Not:C34(Is nil pointer:C315($1)))
		If (Type:C295($1->)=Is BLOB:K8:12)
			CFBF PARSE DATA($1->; $json; $bytes)
		End if 
	End if 
End if 

If (Count parameters:C259>3)
	If (JSON Stringify:C1217($4)="\"[object Formula]\"")
		Use (Storage:C1525)
			Storage:C1525.on_err_call:=$4
		End use 
	End if 
End if 

C_OBJECT:C1216($msg; $eml)
$msg:=JSON Parse:C1218($json; Is object:K8:27)
CLEAR VARIABLE:C89($json)

C_BLOB:C604($header)
ARRAY OBJECT:C1221($body; 0)
ARRAY OBJECT:C1221($attachments; 0)

$eml:=New object:C1471("message"; New object:C1471(\
"subject"; Null:C1517; \
"id"; Null:C1517; \
"from"; New collection:C1472; \
"cc"; New collection:C1472; \
"bcc"; New collection:C1472; \
"to"; New collection:C1472; \
"all_recipients"; New collection:C1472; \
"sender"; New collection:C1472; \
"reply_to"; New collection:C1472; \
"local_date"; Null:C1517; \
"local_time"; Null:C1517; \
"utc_date"; Null:C1517; \
"utc_time"; Null:C1517; \
"body"; New collection:C1472))

$PidTagTransportMessageHeaders:=False:C215

ARRAY BLOB:C1222($data; 0)

ARRAY OBJECT:C1221($storages; 0)
OB GET ARRAY:C1229($msg; "storages"; $storages)

ARRAY LONGINT:C221($pos; 0)
ARRAY LONGINT:C221($len; 0)

//$bName is outer ($i/$max), $aName is inner ($j,$max2)

C_TEXT:C284($aName; $bName)
C_LONGINT:C283($aData; $aSize; $bData; $bSize)
C_LONGINT:C283($i; $j; $max; $max2)

$max:=Size of array:C274($storages)

For ($i; 1; $max)
	
	$storage:=$storages{$i}
	$bName:=OB Get:C1224($storage; "name"; Is text:K8:3)
	$bData:=OB Get:C1224($storage; "data"; Is longint:K8:6)
	$bSize:=OB Get:C1224($storage; "size"; Is longint:K8:6)
	
	Case of 
		: (Match regex:C1019("__properties_version1\\.0"; $bName; 1; $pos; $len))
			
			//top level header
			
			//Reserved (8 bytes)
			//Next Recipient ID (4 bytes)
			//Next Attachment ID (4 bytes)
			
			//Recipient Count (4 bytes)
			//Attachment Count (4 bytes)
			//Reserved (8 bytes)
			
			$headerSize:=32
			$entriesLength:=$bSize-$headerSize
			
			C_BLOB:C604($buf)
			COPY BLOB:C558($bytes{$bData}; $buf; $headerSize; 0; $entriesLength)
			
			$entrySize:=16
			
			For ($start; 0; $entriesLength-$entrySize; $entrySize)
				
				COPY BLOB:C558($buf; $prop; $start; 0; $entrySize)
				$hex:=Get_property_header($prop; $entrySize)
				
				If (Match regex:C1019("([:Hex_Digit:]{4})([:Hex_Digit:]{4})([:Hex_Digit:]{8})([:Hex_Digit:]{16})"; $hex; 1; $pos; $len))
					
					$propertyTag:=Substring:C12($hex; $pos{1}; $len{1})
					$propertyID:=Substring:C12($hex; $pos{2}; $len{2})
					$propertyValue:=Substring:C12($hex; $pos{4}; $len{4})
					
					Case of 
						: ($propertyID="0039")  //PidTagClientSubmitTime
							
							//FILETIME
							//Contains a 64-bit value representing the number of 100-nanosecond intervals
							//since January 1, 1601 (UTC)
							
							C_BLOB:C604($byte)
							SET BLOB SIZE:C606($byte; 4)
							
							$byte{0}:=0x0000
							$byte{1}:=0x0000
							$byte{2}:=0x0000
							
							$doubleValue:=0
							
							For ($idx; 15; 7; -1)
								$byte{3}:=$prop{$idx}
								$intValue:=BLOB to longint:C551($byte; Macintosh byte ordering:K22:2)
								If ($idx=7)
									$doubleValue:=$doubleValue+$intValue
								Else 
									$doubleValue:=$doubleValue+($intValue*(0x0100^($idx-8)))
								End if 
							End for 
							
							$UNIXTIME:=($doubleValue-1.16444736e+17)\10000000
							
							C_DATE:C307($date)
							C_TIME:C306($time)
							
							$date:=Add to date:C393(!1970-01-01!; 0; 0; $UNIXTIME\86400)
							$time:=Time:C179($UNIXTIME%86400)
							
							$utc_date:=String:C10($date; ISO date:K1:8; $time)+"Z"
							
							$eml.message.utc_date:=$utc_date
							$eml.message.utc_time:=$time
							
							$date:=Date:C102($utc_date)
							$time:=Time:C179($utc_date)
							
							$local_date:=String:C10($date; ISO date:K1:8; $time)
							
							$eml.message.local_date:=$local_date
							$eml.message.local_time:=$time
							
					End case 
					
				End if 
				
			End for 
			
		: (Match regex:C1019("__attach_version1\\.0_#([:Hex_Digit:]{8})"; $bName; 1; $pos; $len))
			
			$attachmentNo:=Substring:C12($bName; $pos{1}; $len{1})
			
			ARRAY OBJECT:C1221($aStorages; 0)
			OB GET ARRAY:C1229($storage; "storages"; $aStorages)
			
			$max2:=Size of array:C274($aStorages)
			
			For ($j; 1; $max2)
				
				$aStorage:=$aStorages{$j}
				$aName:=OB Get:C1224($aStorage; "name"; Is text:K8:3)
				$aData:=OB Get:C1224($aStorage; "data"; Is longint:K8:6)
				$aSize:=OB Get:C1224($aStorage; "size"; Is longint:K8:6)
				
				Case of 
					: (Match regex:C1019("__substg1\\.0_(([:Hex_Digit:]{4})([:Hex_Digit:]{4}))"; $aName; 1; $pos; $len))
						
						//hexadecimal representation of the property tag 
						$propertyTag:=Substring:C12($aName; $pos{1}; $len{1})
						$propertyID:=Substring:C12($aName; $pos{2}; $len{2})
						$dataType:=Substring:C12($aName; $pos{3}; $len{3})
						
						Case of 
							: ($propertyID="0FF9")  //PidTagRecordKey
								//a unique binary-comparable identifier for a specific object
								
								//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
								
								APPEND TO ARRAY:C911($attachments; New object:C1471(\
									"file_name"; Null:C1517; \
									"mime_type"; Null:C1517; \
									"content_id"; Null:C1517))
								
							: ($propertyID="3001")  //PidTagDisplayName
								//the display name of the folder
								
								//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
								
							: ($propertyID="3701")  //PidTagAttachDataBinary
								//the contents of the file to be attached
								
								$attachments{Size of array:C274($attachments)}.data:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data).value
								
							: ($propertyID="3703")  //PidTagAttachExtension
								//a file name extension that indicates the document type of an attachment
								
								//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
								
							: ($propertyID="3704")  //PidTagAttachFilename
								//the 8.3 name of the PidTagAttachLongFilename property
								
								//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
								
							: ($propertyID="3707")  //PidTagAttachLongFilename
								//the full filename and extension of the Attachment object
								
								$attachments{Size of array:C274($attachments)}.file_name:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data).value
								
							: ($propertyID="370E")  //PidTagAttachMimeTag
								//a content-type MIME header
								
								$attachments{Size of array:C274($attachments)}.mime_type:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data).value
								
							: ($propertyID="370F")  //PidTagAttachAdditionalInformation
								//attachment encoding information
								
							: ($propertyID="3712")  //PidTagAttachContentId
								//a content identifier unique to the Message object that matches a corresponding "cid:" URI schema reference in the HTML body of the Message object
								
								$attachments{Size of array:C274($attachments)}.content_id:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data).value
								
							: ($propertyID="3711")  //PidTagAttachContentBase
								//the base of a relative URI
								
							: ($propertyID="3713")  //PidTagAttachContentLocation
								//a relative or full URI that matches a corresponding reference in the HTML body of a Message object
								
							: ($propertyID="3702")  //PidTagAttachEncoding
								//encoding information about the Attachment object
								
							: ($propertyID="3714")  //PidTagAttachFlags
								//indicates which body formats might reference this attachment when rendering data
								
							: ($propertyID="370D")  //PidTagAttachLongPathname
								//the fully-qualified path and file name with extension
								
							: ($propertyID="7FFF")  //PidTagAttachmentContactPhoto
								//indicates that a contact photo attachment is attached to a Contact object
								
							: ($propertyID="7FFD")  //PidTagAttachmentFlags
								//special handling for an Attachment object
								
							: ($propertyID="7FFE")  //PidTagAttachmentHidden
								//whether an Attachment object is hidden from the end user
								
							: ($propertyID="7FFA")  //PidTagAttachmentLinkId
								//the type of Message object to which an attachment is linked
								
							: ($propertyID="3705")  //PidTagAttachMethod
								//the way the contents of an attachment are accessed
								
							: ($propertyID="0E21")  //PidTagAttachNumber
								//the Attachment object within its Message object
								
							: ($propertyID="3708")  //PidTagAttachPathname
								//the 8.3 name of the PidTagAttachLongPathname property
								
							: ($propertyID="371A")  //PidTagAttachPayloadClass
								//the class name of an object that can display the contents of the message
								
							: ($propertyID="3719")  //PidTagAttachPayloadProviderGuidString
								//the GUID of the software component that can display the contents of the message
								
							: ($propertyID="3709")  //PidTagAttachRendering
								//a Windows Metafile, as specified in [MS-WMF], for the Attachment object
								
							: ($propertyID="0E20")  //PidTagAttachSize
								//the size, in bytes, consumed by the Attachment object on the server
								
							: ($propertyID="370A")  //PidTagAttachTag
								//the identifier information for the application that supplied the Attachment object data
								
							: ($propertyID="370C")  //PidTagAttachTransportName
								//the name of an attachment file, modified so that it can be correlated with TNEF messages
								
							: ($propertyID="371D")
							: ($propertyID="3A0C")
							Else 
								
						End case 
						
				End case 
				
			End for   //__attach_version1.0
			
		: (Match regex:C1019("__substg1\\.0_(([:Hex_Digit:]{4})([:Hex_Digit:]{4}))"; $bName; 1; $pos; $len))
			
			//hexadecimal representation of the property tag 
			$propertyTag:=Substring:C12($bName; $pos{1}; $len{1})
			$propertyID:=Substring:C12($bName; $pos{2}; $len{2})
			$dataType:=Substring:C12($bName; $pos{3}; $len{3})
			
			Case of 
				: ($propertyID="001A")  //PidTagMessageClass
					
					Case of 
						: (Match regex:C1019("(?:IPM\\.Note.*)"; String:C10(Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value)))
							
						: (Match regex:C1019("(?:Remote\\.Note.*)"; String:C10(Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value)))
							
						: (Match regex:C1019("(?:REPORT\\.*)"; String:C10(Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value)))
							
						Else 
							$i:=$max  //not EMail; break
					End case 
					
				: ($propertyID="0037")  //PidTagSubject
					//the subject of the email message
					
					$eml.message.subject:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					
				: ($propertyID="003D")  //PidTagSubjectPrefix
					//the prefix for the subject of the message
					
				: ($propertyID="003B")  //PidTagSentRepresentingSearchKey
					//a binary-comparable key that represents the end user who is represented by the sending mailbox owner
					
				: ($propertyID="0064")  //PidTagSentRepresentingAddressType
					//an email address type ("EX"=Exchange) 
					
				: ($propertyID="0065")  //PidTagSentRepresentingEmailAddress
					//an email address for the end user who is represented by the sending mailbox owner
					
				: ($propertyID="5D01")  //PidTagSenderSmtpAddress
					//the SMTP email address format of the e–mail address of the sending mailbox owner
					
					If ($eml.message.sender.length>0)
						$sender:=$eml.message.sender[0]
					Else 
						$sender:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
						$eml.message.sender[0]:=$sender
					End if 
					
					If ($sender.addr="")
						$sender.addr:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					End if 
					
				: ($propertyID="5D02")  //PidTagSentRepresentingSmtpAddress
					//the SMTP email address of the end user who is represented by the sending mailbox owner
					
					If ($eml.message.from.length>0)
						$from:=$eml.message.from[0]
					Else 
						$from:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
						$eml.message.from[0]:=$from
					End if 
					
					If ($from.addr="")
						$from.addr:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					End if 
					
				: ($propertyID="5D0A")  //undocumented
					
					If ($eml.message.sender.length>0)
						$sender:=$eml.message.sender[0]
					Else 
						$sender:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
						$eml.message.sender[0]:=$sender
					End if 
					
					If ($sender.addr="")
						$sender.addr:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					End if 
					
				: ($propertyID="5D0B")  //undocumented
					
					If ($eml.message.from.length>0)
						$from:=$eml.message.from[0]
					Else 
						$from:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
						$eml.message.from[0]:=$from
					End if 
					
					If ($from.addr="")
						$from.addr:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					End if 
					
				: ($propertyID="0041")  //PidTagSentRepresentingEntryId
					//the identifier of the end user who is represented by the sending mailbox owner
					
				: ($propertyID="0042")  //PidTagSentRepresentingName
					// the display name for the end user who is represented by the sending mailbox owner
					
					If ($eml.message.from.length>0)
						$from:=$eml.message.from[0]
					Else 
						$from:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
						$eml.message.from[0]:=$from
					End if 
					
					If ($from.name="")
						$from.name:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					End if 
					
				: ($propertyID="0070")  //PidTagConversationTopic
					//an unchanging copy of the original subject
					
				: ($propertyID="0071")  //PidTagConversationIndex
					//the relative position of this message within a conversation thread
					
				: ($propertyID="0075")  //PidTagReceivedByAddressType
					//the email message receiver's email address type
					
				: ($propertyID="0076")  //PidTagReceivedByEmailAddress
					//the email message receiver's email address
					
				: ($propertyID="003F")  //PidTagReceivedByEntryId
					//the address book EntryID of the mailbox receiving the Email object
					
				: ($propertyID="0040")  //PidTagReceivedByName
					//the email message receiver's display name
					
					//Get_value ($dataType;$bData;$bSize;->$bytes).value
					
				: ($propertyID="0051")  //PidTagReceivedBySearchKey
					//an address book search key that contains a binary-comparable key that is used to identify correlated objects for a search
					
				: ($propertyID="5D07")  //PidTagReceivedBySmtpAddress
					
					//Get_value ($dataType;$bData;$bSize;->$bytes).value
					
				: ($propertyID="0077")  //PidTagReceivedRepresentingAddressType
					//the email address type for the end user represented by the receiving mailbox owner
					
				: ($propertyID="0078")  //PidTagReceivedRepresentingEmailAddress
					//the email address for the end user represented by the receiving mailbox owner
					
				: ($propertyID="0043")  //PidTagReceivedRepresentingEntryId
					//an address book EntryID that identifies the end user represented by the receiving mailbox owner
					
				: ($propertyID="0044")  //PidTagReceivedRepresentingName
					//the display name for the end user represented by the receiving mailbox owner
					
					//Get_value ($dataType;$bData;$bSize;->$bytes).value
					
				: ($propertyID="0052")  //PidTagReceivedRepresentingSearchKey
					//an address book search key that contains a binary-comparable key of the end user represented by the receiving mailbox owner
					
				: ($propertyID="5D08")  //PidTagReceivedRepresentingSmtpAddress
					
					//Get_value ($dataType;$bData;$bSize;->$bytes).value
					
				: ($propertyID="007D")  //PidTagTransportMessageHeaders
					//transport-specific message envelope information for email (SMTP header)
					
					$th:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					CONVERT FROM TEXT:C1011($th; "us-ascii"; $temp)
					
					MIME PARSE MESSAGE($temp; $json)
					
					If ($json#"")
						$eml:=JSON Parse:C1218($json; Is object:K8:27)
						OB REMOVE:C1226($eml.message; "headers")
						$PidTagTransportMessageHeaders:=True:C214
					End if 
					
				: ($propertyID="007F")  //PidTagTnefCorrelationKey
					//a value that correlates a Transport Neutral Encapsulation Format (TNEF) attachment with a message
					
				: ($propertyID="0C1E")  //PidTagSenderAddressType
					//the email address type of the sending mailbox owner
					
					//$_SenderAddressType:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					
				: ($propertyID="0C1F")  //PidTagSenderEmailAddress
					//the email address of the sending mailbox owner
					
				: ($propertyID="0C19")  //PidTagSenderEntryId
					//an address book EntryID that contains the address book EntryID of the sending mailbox owner
					
				: ($propertyID="0C1A")  //PidTagSenderName
					//the display name of the sending mailbox owner
					
					If ($eml.message.sender.length>0)
						$sender:=$eml.message.sender[0]
					Else 
						$sender:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
						$eml.message.sender[0]:=$sender
					End if 
					
					If ($sender.name="")
						$sender.name:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					End if 
					
				: ($propertyID="0C1D")  //PidTagSenderSearchKey
					//an address book search key
					
				: ($propertyID="0E02")  //PidTagDisplayBcc
					//a list of blind carbon copy (Bcc) recipient display names.
					
					If ($eml.message.bcc.length=0)
						$listValue:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
						Get_addrs($eml.message; $listValue; "bcc")
					End if 
					
				: ($propertyID="0E03")  //PidTagDisplayCc
					// a list of carbon copy (Cc) recipient display names
					
					If ($eml.message.cc.length=0)
						$listValue:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
						Get_addrs($eml.message; $listValue; "cc")
					End if 
					
				: ($propertyID="0E04")  //PidTagDisplayTo
					//a list of the primary recipient display names, separated by semicolons, when an email message has primary recipients
					
					If ($eml.message.to.length=0)
						$listValue:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
						Get_addrs($eml.message; $listValue; "to")
					End if 
					
				: ($propertyID="0E05")
					//message box name
					
				: ($propertyID="0E1D")  //PidTagNormalizedSubject
					//the normalized subject of the message
					
					$eml.message.subject:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					
				: ($propertyID="0E4D")
					//?
					
				: ($propertyID="0E4E")
					//?
					
				: ($propertyID="0E58")
					//?
					
				: ($propertyID="0E59")
					//?
					
				: ($propertyID="0F03")
					//?
					
				: ($propertyID="1000")  //PidTagBody
					//message body text in plain text format
					
					APPEND TO ARRAY:C911($body; New object:C1471("mime_type"; "text/plain; charset=\"utf-8\""; "data"; Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value))
					
				: ($propertyID="1009")  //PidTagRtfCompressed
					//message body text in compressed RTF format
					
					If (False:C215)
						APPEND TO ARRAY:C911($body; New object:C1471("mime_type"; "application/rtf"; "data"; Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value))
					End if 
					
				: ($propertyID="1013")  //PidTagHtml
					//message body text in HTML format
					
					APPEND TO ARRAY:C911($body; New object:C1471("mime_type"; "text/html"; "data"; Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value))
					
				: ($propertyID="1015")  //PidTagBodyContentId
					//a GUID that corresponds to the current message body
					
				: ($propertyID="1035")  //PidTagInternetMessageId
					//the message-id field
					
					$eml.message.id:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
					
				: ($propertyID="1039")  //PidTagInternetReferences
					//a list of message IDs that specify the messages to which this reply is related
					
				: ($propertyID="1042")  //PidTagInReplyToId
					//the value of the original message's PidTagInternetMessageId property (section 2.742) value
					
				: ($propertyID="300B")  //PidTagSearchKey
					//a unique binary-comparable key that identifies an object for a search
					
				: ($propertyID="3014")
					
				: ($propertyID="3FFA")  //PidTagLastModifierName
					//the name of the last mail user to change the Message object.
					
				: ($propertyID="3FFB")  //PidTagLastModifierEntryId
					//the Address Book EntryID of the last user to modify the contents of the message
					
				: ($propertyID="4022")
					
				: ($propertyID="4023")
					
				: ($propertyID="4024")
					
				: ($propertyID="4025")
					
				: ($propertyID="4026")
					
				: ($propertyID="4030")
					
				: ($propertyID="4031")
					
				: ($propertyID="4034")
					
				: ($propertyID="4035")
					
				: ($propertyID="4038")
					
				: ($propertyID="4039")
					
				: ($propertyID="5FE5")
					
				: ($propertyID="65E2")  //PidTagChangeKey
					//a structure that identifies the last change to the object
					
				: ($propertyID="65E3")  //PidTagPredecessorChangeList
					//a value that contains a serialized representation of a PredecessorChangeList structure
					
				: ($propertyID="8002")
					
				: ($propertyID="8003")
					
				: ($propertyID="8004")  //PidTagAddressBookFolderPathname
					//deprecated and is to be ignored
					
				: ($propertyID="8005")  //PidTagAddressBookManager
					//one row that references the mail user's manager
					
				: ($propertyID="8009")  //PidTagAddressBookMember
					//members of the distribution list
					
				: ($propertyID="800A")
					
				: ($propertyID="800B")
					
				: ($propertyID="800D")
					
				: ($propertyID="800E")  //PidTagAddressBookReports
					//all of the mail user’s direct reports
					
				: ($propertyID="800F")  //PidTagAddressBookProxyAddresses
					//alternate email addresses for the Address Book object
					
				: ($propertyID="8012")  //undocumented
					
					If (False:C215)
						If (Not:C34($PidTagTransportMessageHeaders))
							//process only if PidTagTransportMessageHeaders was absent
							
							If ($eml.message.sender.length>0)
								$sender:=$eml.message.sender[0]
								//properties of to object: addr, encoded_string, idn_addr, name, string
							Else 
								$sender:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
								$eml.message.sender[0]:=$sender
							End if 
							
							$sender.addr:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
						End if 
					End if 
					
				: ($propertyID="340D")  //PidTagStoreSupportMask
					
				: ($propertyID="004C")  //PidTagOriginalAuthorEntryId
					
				: ($propertyID="004D")  //PidTagOriginalAuthorName
					
				: ($propertyID="405E") | ($propertyID="4060")  //undocumented
					
					If (False:C215)
						If (Not:C34($PidTagTransportMessageHeaders))
							//process only if PidTagTransportMessageHeaders was absent
							
							If ($eml.message.sender.length>0)
								$sender:=$eml.message.sender[0]
								//properties of to object: addr, encoded_string, idn_addr, name, string
							Else 
								$sender:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
								$eml.message.sender[0]:=$sender
							End if 
							
							$sender.name:=Get_value($dataType; $bData; $bSize; ->$bytes; ->$data).value
						End if 
					End if 
					
				Else 
					//8011, 8013, 8015, 8016,  801A, 800C, 8008, 8007, 8006, 0E0A, 0E28, 0E55
					//0E29, 800C, 8010, 0079, 007A, 0E46, 0E48, 0E4C, 0E53
			End case 
			
		: (Match regex:C1019("__nameid_version1\\.0"; $bName; 1; $pos; $len))
			
			ARRAY OBJECT:C1221($aStorages; 0)
			OB GET ARRAY:C1229($storage; "storages"; $aStorages)
			
			$max2:=Size of array:C274($aStorages)
			
			For ($j; 1; $max2)
				
				$aStorage:=$aStorages{$j}
				$aName:=OB Get:C1224($aStorage; "name"; Is text:K8:3)
				$aData:=OB Get:C1224($aStorage; "data"; Is longint:K8:6)
				$aSize:=OB Get:C1224($aStorage; "size"; Is longint:K8:6)
				
				Case of 
					: (Match regex:C1019("__substg1\\.0_(([:Hex_Digit:]{4})([:Hex_Digit:]{4}))"; $aName; 1; $pos; $len))
						
						//hexadecimal representation of the property tag 
						$propertyTag:=Substring:C12($aName; $pos{1}; $len{1})
						$propertyID:=Substring:C12($aName; $pos{2}; $len{2})
						$dataType:=Substring:C12($aName; $pos{3}; $len{3})
						
						//all binary data
						
						//0002 0003 0004 1000 1002 1003 1006 1007 1009 100B 100C 100E 100F 1010 1012 1013 1014 1015 1016 1017 1018 101A 101B 101C 101E
						
				End case 
				
			End for 
			
		: (Match regex:C1019("__recip_version1\\.0_#([:Hex_Digit:]{8})"; $bName; 1; $pos; $len))
			
			If (Not:C34($PidTagTransportMessageHeaders))
				//process only if PidTagTransportMessageHeaders was absent
				
				$recipientNo:=Substring:C12($bName; $pos{1}; $len{1})
				
				ARRAY OBJECT:C1221($aStorages; 0)
				OB GET ARRAY:C1229($storage; "storages"; $aStorages)
				
				$max2:=Size of array:C274($aStorages)
				
				For ($j; 1; $max2)
					
					$aStorage:=$aStorages{$j}
					$aName:=OB Get:C1224($aStorage; "name"; Is text:K8:3)
					$aData:=OB Get:C1224($aStorage; "data"; Is longint:K8:6)
					$aSize:=OB Get:C1224($aStorage; "size"; Is longint:K8:6)
					
					Case of 
						: (Match regex:C1019("__properties_version1\\.0"; $aName; 1; $pos; $len))
							
						: (Match regex:C1019("__substg1\\.0_(([:Hex_Digit:]{4})([:Hex_Digit:]{4}))"; $aName; 1; $pos; $len))
							
							//hexadecimal representation of the property tag 
							$propertyTag:=Substring:C12($aName; $pos{1}; $len{1})
							$propertyID:=Substring:C12($aName; $pos{2}; $len{2})
							$dataType:=Substring:C12($aName; $pos{3}; $len{3})
							
							C_LONGINT:C283($index)
							$index:=Num:C11($recipientNo)
							
							If ($eml.message.all_recipients.length>$index)
								$all_recipients:=$eml.message.all_recipients[$index]
							Else 
								$all_recipients:=New object:C1471("addr"; ""; "encoded_string"; ""; "idn_addr"; ""; "name"; ""; "string"; "")
								$eml.message.all_recipients[$index]:=$all_recipients
							End if 
							
							Case of 
								: ($propertyID="0FF6")  //PidTagInstanceKey
									
									//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
									
								: ($propertyID="0FF9")  //PidTagRecordKey
									
									//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
									
								: ($propertyID="0FFF")  //PidTagEntryId
									
									//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
									
								: ($propertyID="3001")  //PidTagDisplayName
									
									$value:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data)
									$addr:=Get_addr($value.value)
									
									If ($addr.addr#"")
										$all_recipients.name:=$addr.name
										$all_recipients.addr:=$addr.addr
									End if 
									
								: ($propertyID="3002")  //PidTagAddressType
									
									//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
									//e.g. "SMTP" "EX"
									
								: ($propertyID="3003")  //PidTagEmailAddress
									
									$value:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data)
									$addr:=Get_addr($value.value)
									
									If ($addr.addr#"")
										$all_recipients.name:=$addr.name
										$all_recipients.addr:=$addr.addr
									End if 
									
									//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
									//e.g. /o=Exchange Lab/ou=Exchange Administrative Group (FYDIBOHF23SPDLT)/cn=Recipients/cn=4600e453da7943c8b6c997d3ad5de57d-Keisuke Miyako
									
								: ($propertyID="300B")  //PidTagSearchKey
									
									//$value:=Peek_value ($dataType;$aData;$aSize;->$bytes).value
									
								: ($propertyID="5FF6")  //PidTagRecipientDisplayName
									
									$all_recipients.name:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data).value
									
								: ($propertyID="5FF7")  //PidTagRecipientEntryId
									
								: ($propertyID="6001")  //undocumented
									
									If (False:C215)
										$all_recipients.addr:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data).value
									End if 
									
								: ($propertyID="0C24")  //?
									
								: ($propertyID="0C25")  //?
									
								: ($propertyID="5FE5")  //?
									
								: ($propertyID="39FE")  // PidTagSmtpAddress
									
									$all_recipients.addr:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data).value
									
								: ($propertyID="3A20")  // PidTagTransmittableDisplayName
									
									$all_recipients.name:=Get_value($dataType; $aData; $aSize; ->$bytes; ->$data).value
									
								Else 
									
							End case 
					End case 
					
				End for   //__recip_version1.0
				
			End if 
			
		Else 
			
	End case 
	
End for 

If (Count parameters:C259>2)
	If (Not:C34(Is nil pointer:C315($3)))
		If (Type:C295($3->)=Is BLOB:K8:12)
			C_OBJECT:C1216($mht)
			ARRAY BLOB:C1222($mData; 0)
			MIME PARSE MESSAGE($3->; $json; $mData)
			If ($json#"")
				$mht:=JSON Parse:C1218($json; Is object:K8:27)
				If ($mht.message.body#Null:C1517)
					If ($mht.message.body.length#0)
						C_OBJECT:C1216($message)
						$message:=$mht.message.body[0]
						If ($message.mime_type="text/html")
							C_TEXT:C284($html)
							$html:=$message.data
							If (Match regex:C1019("(?s)<div class=WordSection1>(.+?)<p class=MsoNormal>"; $html; 1; $pos; $len))
								//remove header section auto generated by outlook
								APPEND TO ARRAY:C911($body; New object:C1471(\
									"mime_type"; "text/html; charset=\"utf-8\""; \
									"data"; Delete string:C232($html; $pos{1}; $len{1})))
							Else 
								APPEND TO ARRAY:C911($body; New object:C1471(\
									"mime_type"; "text/html; charset=\"utf-8\""; \
									"data"; $html))
							End if 
						End if 
					End if 
				End if 
			End if 
		End if 
	End if 
End if 

OB SET ARRAY:C1227($eml.message; "body"; $body)
OB SET ARRAY:C1227($eml.message; "attachments"; $attachments)

$0:=$eml

If (Count parameters:C259>1)
	If (Not:C34(Is nil pointer:C315($2)))
		If (Type:C295($2->)=Blob array:K8:30)
			COPY ARRAY:C226($data; $2->)
		End if 
	End if 
End if 

$console.stop()

Use (Storage:C1525)
	OB REMOVE:C1226(Storage:C1525; "on_err_call")
End use 