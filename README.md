# 4d-plugin-CFBF
Parse CFBF ([Compound File Binary Format](https://en.wikipedia.org/wiki/Compound_File_Binary_Format)) with [libgsf](https://github.com/GNOME/libgsf)

### Platform

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
||<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|

### Releases

## About

CFBF is the structured binary file format used by classic Microsoft applications. XLS, DOC, MSG are all CFBF files.

## Syntax

```
CFBF PARSE DATA (data;json;bytes)
```

Parameter|Type|Description
------------|------------|----
data|BLOB|
json|TEXT|
bytes|ARRAY BLOB|

### Examples

```
$path:=System folder(Desktop)+"sample.msg"

C_BLOB($data)
DOCUMENT TO BLOB($path;$data)

C_TEXT($json)
ARRAY BLOB($bytes;0)

CFBF PARSE DATA ($data;$json;$bytes)
```

#### Structure of parsed object

``storages[]``  
  ``.name``  
  ``.size``  
  ``.local_date`` (optional)  
  ``.local_time`` (optional)  
  ``.utc_date`` (optional)  
  ``.utc_time`` (optional)  
  ``.storages[]`` or ``.data``  
  
  
