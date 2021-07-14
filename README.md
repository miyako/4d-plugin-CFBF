![platform](https://img.shields.io/static/v1?label=platform&message=osx-64%20|%20win-32%20|%20win-64&color=blue)
![version](https://img.shields.io/badge/version-17%2B-3E8B93)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-CFBF)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-CFBF/total)

**Note**: for v17 and earlier, move `manifest.json` to `Contents`

# 4d-plugin-CFBF

Parse [Compound File Binary Format](https://en.wikipedia.org/wiki/Compound_File_Binary_Format) file using [libgsf](https://github.com/GNOME/libgsf).

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
  ``.local_date`` 
  ``.local_time``  
  ``.utc_date``   
  ``.utc_time``  
  ``.storages[]`` or ``.data``  
  
  
The root object has one property, ``storages``, which is an array of ``storage`` objects.  

A ``storage`` object is a leaf or node.  

A leaf storage has ``data`` with ``size`` (but the size can be ``0``)

A node storage is like a directory. It has an array of ``storage`` objects and no ``data``.  

``data`` indicates the element number inside the BLOB array ``bytes``.

#### Example of a parsed MSG file

```
{
	"storages" : [
		{
			"local_time" : 63523000,
			"local_date" : "2018-05-26T17:38:43+0900",
			"utc_time" : 31123000,
			"utc_date" : "2018-05-26T08:38:43Z",
			"name" : "__nameid_version1.0",
			"size" : 0,
			"storages" : [
				{
					"name" : "__substg1.0_00020102",
					"size" : 128,
					"data" : 1
				},
				{
					"name" : "__substg1.0_00030102",
					"size" : 160,
					"data" : 2
				},
				{
					"name" : "__substg1.0_00040102",
					"size" : 776,
					"data" : 3
				},
				{
					"name" : "__substg1.0_10020102",
					"size" : 8,
					"data" : 4
				},
				{
					"name" : "__substg1.0_10040102",
					"size" : 8,
					"data" : 5
				},
				{
					"name" : "__substg1.0_10070102",
					"size" : 8,
					"data" : 6
				},
				{
					"name" : "__substg1.0_10080102",
					"size" : 16,
					"data" : 7
				},
				{
					"name" : "__substg1.0_10090102",
					"size" : 8,
					"data" : 8
				},
				{
					"name" : "__substg1.0_100D0102",
					"size" : 16,
					"data" : 9
				},
				{
					"name" : "__substg1.0_100E0102",
					"size" : 8,
					"data" : 10
				},
				{
					"name" : "__substg1.0_10100102",
					"size" : 8,
					"data" : 11
				},
				{
					"name" : "__substg1.0_10110102",
					"size" : 8,
					"data" : 12
				},
				{
					"name" : "__substg1.0_10160102",
					"size" : 16,
					"data" : 13
				},
				{
					"name" : "__substg1.0_10170102",
					"size" : 8,
					"data" : 14
				},
				{
					"name" : "__substg1.0_10180102",
					"size" : 8,
					"data" : 15
				},
				{
					"name" : "__substg1.0_10190102",
					"size" : 8,
					"data" : 16
				},
				{
					"name" : "__substg1.0_101B0102",
					"size" : 24,
					"data" : 17
				},
				{
					"name" : "__substg1.0_101C0102",
					"size" : 8,
					"data" : 18
				}
			]
		},
		{
			"name" : "__substg1.0_001A001F",
			"size" : 16,
			"data" : 19
		},
		{
			"name" : "__substg1.0_0037001F",
			"size" : 24,
			"data" : 20
		},
		{
			"name" : "__substg1.0_003B0102",
			"size" : 132,
			"data" : 21
		},
		{
			"name" : "__substg1.0_003D001F",
			"size" : 0,
			"data" : 0
		},
		{
			"name" : "__substg1.0_003F0102",
			"size" : 157,
			"data" : 22
		},
		{
			"name" : "__substg1.0_0040001F",
			"size" : 28,
			"data" : 23
		},
		{
			"name" : "__substg1.0_00410102",
			"size" : 157,
			"data" : 24
		},
		{
			"name" : "__substg1.0_0042001F",
			"size" : 28,
			"data" : 25
		},
		{
			"name" : "__substg1.0_00430102",
			"size" : 157,
			"data" : 26
		},
		{
			"name" : "__substg1.0_0044001F",
			"size" : 28,
			"data" : 27
		},
		{
			"name" : "__substg1.0_004C0102",
			"size" : 157,
			"data" : 28
		},
		{
			"name" : "__substg1.0_004D001F",
			"size" : 28,
			"data" : 29
		},
		{
			"name" : "__substg1.0_00510102",
			"size" : 132,
			"data" : 30
		},
		{
			"name" : "__substg1.0_00520102",
			"size" : 132,
			"data" : 31
		},
		{
			"name" : "__substg1.0_0064001F",
			"size" : 4,
			"data" : 32
		},
		{
			"name" : "__substg1.0_0065001F",
			"size" : 256,
			"data" : 33
		},
		{
			"name" : "__substg1.0_0070001F",
			"size" : 24,
			"data" : 34
		},
		{
			"name" : "__substg1.0_00710102",
			"size" : 22,
			"data" : 35
		},
		{
			"name" : "__substg1.0_0075001F",
			"size" : 4,
			"data" : 36
		},
		{
			"name" : "__substg1.0_0076001F",
			"size" : 256,
			"data" : 37
		},
		{
			"name" : "__substg1.0_0077001F",
			"size" : 4,
			"data" : 38
		},
		{
			"name" : "__substg1.0_0078001F",
			"size" : 256,
			"data" : 39
		},
		{
			"name" : "__substg1.0_0079001F",
			"size" : 4,
			"data" : 40
		},
		{
			"name" : "__substg1.0_007A001F",
			"size" : 256,
			"data" : 41
		},
		{
			"name" : "__substg1.0_007D001F",
			"size" : 3720,
			"data" : 42
		},
		{
			"name" : "__substg1.0_007F0102",
			"size" : 46,
			"data" : 43
		},
		{
			"name" : "__substg1.0_0C190102",
			"size" : 157,
			"data" : 44
		},
		{
			"name" : "__substg1.0_0C1A001F",
			"size" : 28,
			"data" : 45
		},
		{
			"name" : "__substg1.0_0C1D0102",
			"size" : 132,
			"data" : 46
		},
		{
			"name" : "__substg1.0_0C1E001F",
			"size" : 4,
			"data" : 47
		},
		{
			"name" : "__substg1.0_0C1F001F",
			"size" : 256,
			"data" : 48
		},
		{
			"name" : "__substg1.0_0E02001F",
			"size" : 0,
			"data" : 0
		},
		{
			"name" : "__substg1.0_0E03001F",
			"size" : 0,
			"data" : 0
		},
		{
			"name" : "__substg1.0_0E04001F",
			"size" : 30,
			"data" : 49
		},
		{
			"name" : "__substg1.0_0E05001F",
			"size" : 10,
			"data" : 50
		},
		{
			"name" : "__substg1.0_0E1D001F",
			"size" : 24,
			"data" : 51
		},
		{
			"name" : "__substg1.0_0E460102",
			"size" : 16,
			"data" : 52
		},
		{
			"name" : "__substg1.0_0E480102",
			"size" : 16,
			"data" : 53
		},
		{
			"name" : "__substg1.0_0E4C0102",
			"size" : 16,
			"data" : 54
		},
		{
			"name" : "__substg1.0_0E4D0102",
			"size" : 28,
			"data" : 55
		},
		{
			"name" : "__substg1.0_0E4E0102",
			"size" : 28,
			"data" : 56
		},
		{
			"name" : "__substg1.0_0E530102",
			"size" : 28,
			"data" : 57
		},
		{
			"name" : "__substg1.0_0E550102",
			"size" : 28,
			"data" : 58
		},
		{
			"name" : "__substg1.0_0E580102",
			"size" : 28,
			"data" : 59
		},
		{
			"name" : "__substg1.0_0E590102",
			"size" : 28,
			"data" : 60
		},
		{
			"name" : "__substg1.0_0F030102",
			"size" : 16,
			"data" : 61
		},
		{
			"name" : "__substg1.0_1000001F",
			"size" : 30,
			"data" : 62
		},
		{
			"name" : "__substg1.0_10090102",
			"size" : 730,
			"data" : 63
		},
		{
			"name" : "__substg1.0_1015001F",
			"size" : 78,
			"data" : 64
		},
		{
			"name" : "__substg1.0_1035001F",
			"size" : 90,
			"data" : 65
		},
		{
			"name" : "__substg1.0_300B0102",
			"size" : 16,
			"data" : 66
		},
		{
			"name" : "__substg1.0_30140102",
			"size" : 12,
			"data" : 67
		},
		{
			"name" : "__substg1.0_3FFA001F",
			"size" : 28,
			"data" : 68
		},
		{
			"name" : "__substg1.0_3FFB0102",
			"size" : 157,
			"data" : 69
		},
		{
			"name" : "__substg1.0_4022001F",
			"size" : 4,
			"data" : 70
		},
		{
			"name" : "__substg1.0_4023001F",
			"size" : 256,
			"data" : 71
		},
		{
			"name" : "__substg1.0_4024001F",
			"size" : 4,
			"data" : 72
		},
		{
			"name" : "__substg1.0_4025001F",
			"size" : 256,
			"data" : 73
		},
		{
			"name" : "__substg1.0_4030001F",
			"size" : 28,
			"data" : 74
		},
		{
			"name" : "__substg1.0_4031001F",
			"size" : 28,
			"data" : 75
		},
		{
			"name" : "__substg1.0_4034001F",
			"size" : 88,
			"data" : 76
		},
		{
			"name" : "__substg1.0_4035001F",
			"size" : 88,
			"data" : 77
		},
		{
			"name" : "__substg1.0_4038001F",
			"size" : 28,
			"data" : 78
		},
		{
			"name" : "__substg1.0_4039001F",
			"size" : 28,
			"data" : 79
		},
		{
			"name" : "__substg1.0_405E001F",
			"size" : 28,
			"data" : 80
		},
		{
			"name" : "__substg1.0_4060001F",
			"size" : 28,
			"data" : 81
		},
		{
			"name" : "__substg1.0_5D01001F",
			"size" : 42,
			"data" : 82
		},
		{
			"name" : "__substg1.0_5D02001F",
			"size" : 42,
			"data" : 83
		},
		{
			"name" : "__substg1.0_5FE5001F",
			"size" : 2,
			"data" : 84
		},
		{
			"name" : "__substg1.0_65E20102",
			"size" : 22,
			"data" : 85
		},
		{
			"name" : "__substg1.0_65E30102",
			"size" : 23,
			"data" : 86
		},
		{
			"name" : "__substg1.0_8005001F",
			"size" : 16,
			"data" : 87
		},
		{
			"name" : "__substg1.0_80060048",
			"size" : 16,
			"data" : 88
		},
		{
			"name" : "__substg1.0_8007001F",
			"size" : 294,
			"data" : 89
		},
		{
			"name" : "__substg1.0_8008001F",
			"size" : 34,
			"data" : 90
		},
		{
			"name" : "__substg1.0_800C001F",
			"size" : 4,
			"data" : 91
		},
		{
			"name" : "__substg1.0_800D001F",
			"size" : 38,
			"data" : 92
		},
		{
			"name" : "__substg1.0_800E001F",
			"size" : 156,
			"data" : 93
		},
		{
			"name" : "__substg1.0_8011001F",
			"size" : 4,
			"data" : 94
		},
		{
			"name" : "__substg1.0_8012001F",
			"size" : 42,
			"data" : 95
		},
		{
			"name" : "__substg1.0_8013001F",
			"size" : 274,
			"data" : 96
		},
		{
			"name" : "__properties_version1.0",
			"size" : 1984,
			"data" : 97
		},
		{
			"local_time" : 63523000,
			"local_date" : "2018-05-26T17:38:43+0900",
			"utc_time" : 31123000,
			"utc_date" : "2018-05-26T08:38:43Z",
			"name" : "__recip_version1.0_#00000000",
			"size" : 0,
			"storages" : [
				{
					"name" : "__substg1.0_0C240102",
					"size" : 28,
					"data" : 98
				},
				{
					"name" : "__substg1.0_0C250102",
					"size" : 16,
					"data" : 99
				},
				{
					"name" : "__substg1.0_0FF60102",
					"size" : 4,
					"data" : 100
				},
				{
					"name" : "__substg1.0_0FF90102",
					"size" : 157,
					"data" : 101
				},
				{
					"name" : "__substg1.0_0FFF0102",
					"size" : 157,
					"data" : 102
				},
				{
					"name" : "__substg1.0_3001001F",
					"size" : 28,
					"data" : 103
				},
				{
					"name" : "__substg1.0_3002001F",
					"size" : 4,
					"data" : 104
				},
				{
					"name" : "__substg1.0_3003001F",
					"size" : 256,
					"data" : 105
				},
				{
					"name" : "__substg1.0_300B0102",
					"size" : 132,
					"data" : 106
				},
				{
					"name" : "__substg1.0_39FE001F",
					"size" : 42,
					"data" : 107
				},
				{
					"name" : "__substg1.0_3A20001F",
					"size" : 28,
					"data" : 108
				},
				{
					"name" : "__substg1.0_5FE5001F",
					"size" : 2,
					"data" : 109
				},
				{
					"name" : "__substg1.0_5FF70102",
					"size" : 157,
					"data" : 110
				},
				{
					"name" : "__properties_version1.0",
					"size" : 344,
					"data" : 111
				}
			]
		},
		{
			"local_time" : 63523000,
			"local_date" : "2018-05-26T17:38:43+0900",
			"utc_time" : 31123000,
			"utc_date" : "2018-05-26T08:38:43Z",
			"name" : "__attach_version1.0_#00000000",
			"size" : 0,
			"storages" : [
				{
					"name" : "__substg1.0_0FF90102",
					"size" : 4,
					"data" : 112
				},
				{
					"name" : "__substg1.0_3001001F",
					"size" : 42,
					"data" : 113
				},
				{
					"name" : "__substg1.0_37010102",
					"size" : 25018,
					"data" : 114
				},
				{
					"name" : "__substg1.0_3703001F",
					"size" : 10,
					"data" : 115
				},
				{
					"name" : "__substg1.0_3704001F",
					"size" : 24,
					"data" : 116
				},
				{
					"name" : "__substg1.0_3707001F",
					"size" : 42,
					"data" : 117
				},
				{
					"name" : "__substg1.0_370E001F",
					"size" : 20,
					"data" : 118
				},
				{
					"name" : "__substg1.0_3712001F",
					"size" : 72,
					"data" : 119
				},
				{
					"name" : "__substg1.0_371D0102",
					"size" : 16,
					"data" : 120
				},
				{
					"name" : "__substg1.0_3A0C001F",
					"size" : 8,
					"data" : 121
				},
				{
					"name" : "__properties_version1.0",
					"size" : 392,
					"data" : 122
				}
			]
		}
	]
}
```
