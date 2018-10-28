/* --------------------------------------------------------------------------------
 #
 #	4DPlugin.cpp
 #	source generated by 4D Plugin Wizard
 #	Project : CFBF
 #	author : miyako
 #	2018/05/23
 #
 # --------------------------------------------------------------------------------*/


#include "4DPluginAPI.h"
#include "4DPlugin.h"

void json_wconv(const char *value, std::wstring &u32)
{
	if(value)
	{
		C_TEXT t;
		CUTF8String u8;
		
		u8 = (const uint8_t *)value;
		t.setUTF8String(&u8);
		
#if VERSIONWIN
		u32 = std::wstring((wchar_t *)t.getUTF16StringPtr());
#else
		
		uint32_t dataSize = (t.getUTF16Length() * sizeof(wchar_t))+ sizeof(wchar_t);
		std::vector<char> buf(dataSize);
		
		PA_ConvertCharsetToCharset((char *)t.getUTF16StringPtr(),
															 t.getUTF16Length() * sizeof(PA_Unichar),
															 eVTC_UTF_16,
															 (char *)&buf[0],
															 dataSize,
															 eVTC_UTF_32);
		
		u32 = std::wstring((wchar_t *)&buf[0]);
#endif
	}else
	{
		u32 = L"";
	}
	
}

void json_set_number(JSONNODE *n, const wchar_t *name, json_int_t value)
{
	if(n)
	{
		json_push_back(n, json_new_i(name, value));
	}
}

void json_set_text(JSONNODE *n, const wchar_t *name, char *value)
{
	if(n)
	{
		if(value)
		{
			std::wstring w32;
			json_wconv(value, w32);
			json_push_back(n, json_new_a(name, w32.c_str()));
		}else
		{
			JSONNODE *node = json_new_a(name, L"");
			json_nullify(node);
			json_push_back(n, node);
		}
	}
}

void json_set_date(JSONNODE *n, GDateTime *dt, const wchar_t *date, const wchar_t *time, const char *fmt)
{
	if(n)
	{
		json_set_number(n, time, (json_int_t)(((g_date_time_get_hour(dt) * 3600)
																					 + (g_date_time_get_minute(dt) * 60)
																					 + (g_date_time_get_second(dt))) * 1000));
		
		gchar *dateString = g_date_time_format(dt, fmt);
		
		json_set_text(n, date, dateString);
		
#if VERSIONMAC
		if(dateString)
		{
			g_free(dateString);//corrupts heap on windows
		}
#endif
		
		g_date_time_unref(dt);
	}
	
}

void json_set_object(JSONNODE *n, const wchar_t *name, JSONNODE *o)
{
	json_set_name(o, (json_const json_char *)name);
	json_push_back(n, o);
}

void json_set_text_param(JSONNODE *n, C_TEXT &t)
{
	if(n)
	{
		json_char *json_string = json_write_formatted(n);
		
		std::wstring wstr = std::wstring(json_string);
		
#if VERSIONWIN
		t.setUTF16String((const PA_Unichar *)wstr.c_str(), (uint32_t)wstr.length());
#else
		uint32_t dataSize = (uint32_t)((wstr.length() * sizeof(wchar_t)) + sizeof(PA_Unichar));
		std::vector<char> buf(dataSize);
		
		uint32_t len = PA_ConvertCharsetToCharset((char *)wstr.c_str(),
																							(PA_long32)(wstr.length() * sizeof(wchar_t)),
																							eVTC_UTF_32,
																							(char *)&buf[0],
																							dataSize,
																							eVTC_UTF_16);
		
		t.setUTF16String((const PA_Unichar *)&buf[0], len);
#endif
		
		json_free(json_string);
	}
	
}

/*
 
 since 17.x/17R2, static GLIB crashes on restarted with GSF
 
 (process:80682): GLib-GObject-[1;33mWARNING[0m **: [34m21:08:37.848[0m: cannot register existing type 'GsfDocPropVector'
 
 ** (process:80682): [1;33mWARNING[0m **: [34m21:08:37.849[0m: Failed to register objects types

 */
#pragma mark Startup / Exit

bool IsProcessOnExit()
{
	C_TEXT name;
	PA_long32 state, time;
	PA_GetProcessInfo(PA_GetCurrentProcessNumber(), name, &state, &time);
	CUTF16String procName(name.getUTF16StringPtr());
	CUTF16String exitProcName((PA_Unichar *)"$\0x\0x\0\0\0");
	return (!procName.compare(exitProcName));
}

#if VERSIONWIN

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
	glib_DllMain(hinstDLL, fdwReason, lpvReserved);
	gio_DllMain(hinstDLL, fdwReason, lpvReserved);
	gobject_DllMain(hinstDLL, fdwReason, lpvReserved);
	gsf_DllMain(hinstDLL, fdwReason, lpvReserved);
	
	return TRUE;
}

#endif

void OnExit()
{
	gsf_shutdown();
}

void OnCloseProcess()
{
	if(IsProcessOnExit())
	{
		OnExit();
	}
}

void OnStartup()
{
	gsf_init();
}

#pragma mark -

void PluginMain(PA_long32 selector, PA_PluginParameters params)
{
	try
	{
		PA_long32 pProcNum = selector;
		
		switch(pProcNum)
		{
			case kInitPlugin :
			case kServerInitPlugin :
				OnStartup();
				break;
				
			case kCloseProcess :
				OnCloseProcess();
				break;
				
			case 1 :
				CFBF_PARSE_DATA(params);
				break;
				
		}
	}
	catch(...)
	{
		
	}
}

#pragma mark -

// ------------------------------------- CFBF -------------------------------------

void addElement(JSONNODE *json_element, GsfInput *input, PA_Variable *Param3)
{
	PA_long32 i = 0;

	char *name = (char *)gsf_input_name(input);
	
	GDateTime *modtime = gsf_input_get_modtime(input);
	if(modtime)
	{
		json_set_date(json_element, g_date_time_to_local(modtime), L"local_date", L"local_time", "%Y-%m-%dT%H:%M:%S%z");
		json_set_date(json_element, g_date_time_to_utc(modtime), L"utc_date", L"utc_time", "%Y-%m-%dT%H:%M:%SZ");
	}

	size_t size = gsf_input_size(input);
	
	if(size)
	{
		std::vector<guint8> buf(size);
		guint8 const *p = gsf_input_read(input, size, &buf[0]);
		
		if(p)
		{
			i = PA_GetArrayNbElements(*Param3);
			PA_ResizeArray(Param3, ++i);
			PA_Variable element = PA_CreateVariable(eVK_Blob);
			PA_SetBlobVariable(&element, (void *) &buf[0], size);
			PA_SetBlobInArray(*Param3, i, element.uValue.fBlob);
		}
		
	}
	
	json_set_text(json_element, L"name", name);
	json_set_number(json_element, L"size", size);
	json_set_number(json_element, L"data", i);
}

void getRoot(JSONNODE *json_element, GsfInfile *root, PA_Variable *Param3)
{
	int countChildren = gsf_infile_num_children(root);
	
	JSONNODE *children = json_new(JSON_ARRAY);
	
	for(int i = 0; i < countChildren; ++i)
	{
		GsfInput *child = gsf_infile_child_by_index(root, i);
		
		if(child)
		{
			JSONNODE *json_child_element = json_new(JSON_NODE);
			
			size_t size = gsf_input_size(child);
			if(!size)
			{
				GsfInfile *node = GSF_INFILE(child);
				int countNodeChildren = gsf_infile_num_children(node);
				if(-1 != countNodeChildren)
				{
					JSONNODE *json = json_new(JSON_NODE);
					
					char *name = (char *)gsf_input_name(child);
					
					GDateTime *modtime = gsf_input_get_modtime(child);
					if(modtime)
					{
						json_set_date(json_child_element, g_date_time_to_local(modtime), L"local_date", L"local_time", "%Y-%m-%dT%H:%M:%S%z");
						json_set_date(json_child_element, g_date_time_to_utc(modtime), L"utc_date", L"utc_time", "%Y-%m-%dT%H:%M:%SZ");
					}
					
					json_set_text(json_child_element, L"name", name);
					json_set_number(json_child_element, L"size", size);
					/* recursive call */
					getRoot(json_child_element, node, Param3);
//					json_push_back(json_child_element, json);
					json_push_back(children, json_child_element);
				}else
				{
					/* leaf with no data */
					addElement(json_child_element, child, Param3);
					json_push_back(children, json_child_element);
				}
			}else
			{
				/* leaf with data */
				addElement(json_child_element, child, Param3);
				json_push_back(children, json_child_element);
			}

			g_object_unref(child);
		}
	}
	
	json_set_object(json_element, L"storages", children);
}

void CFBF_PARSE_DATA(PA_PluginParameters params)
{
	PackagePtr pParams = (PackagePtr)params->fParameters;
	
	C_TEXT Param2;
	
	PA_Variable Param3 = PA_CreateVariable(eVK_ArrayBlob);
	PA_Handle h = *(PA_Handle *)(pParams[0]);
	
	if(h)
	{
		JSONNODE *json = json_new(JSON_NODE);
		
		GsfInput *input = gsf_input_memory_new((const guint8 *)PA_LockHandle(h),
																					 PA_GetHandleSize(h), false);

		if(input)
		{
			input = gsf_input_uncompress(input);
		
			GError *err = NULL;
			GsfInfile *root = gsf_infile_msole_new(input, &err);
			
			if(!root)
			{
				json_set_text(json, L"error", (char *)err->message);
			}else
			{
				getRoot(json, root, &Param3);
				
				g_object_unref(root);
			}
			g_object_unref(input);
		}
		
		json_set_text_param(json, Param2);
		
		PA_UnlockHandle(h);
	}

	PA_SetVariableParameter(params, 3, Param3, 0);
	Param2.toParamAtIndex(pParams, 2);
}