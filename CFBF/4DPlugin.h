/* --------------------------------------------------------------------------------
 #
 #	4DPlugin.h
 #	source generated by 4D Plugin Wizard
 #	Project : CFBF
 #	author : miyako
 #	2018/05/23
 #
 # --------------------------------------------------------------------------------*/

#ifndef PLUGIN_CFBF_H
#define PLUGIN_CFBF_H

#include "4DPluginAPI.h"

#include "json/json.h"

#include <gsf/gsf-input-memory.h>
#include <gsf/gsf-input-stdio.h>
#include <gsf/gsf-input.h>

#include <gsf/gsf-infile-msole.h>
#include <gsf/gsf-doc-meta-data.h>
#include <gsf/gsf-msole-utils.h>
#include <gsf/gsf-utils.h>

// --- CFBF
void CFBF_PARSE_DATA(PA_PluginParameters params);

void getRoot(Json::Value& json_element, GsfInfile *root, PA_Variable *Param3);
void addElement(Json::Value& json_element, GsfInput *input, PA_Variable *Param3);

/* hack to statically link glib */
#if VERSIONWIN
extern "C" BOOL glib_DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
extern "C" BOOL gio_DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
extern "C" BOOL gobject_DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
extern "C" BOOL gsf_DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
#endif

#endif /* PLUGIN_CFBF_H */