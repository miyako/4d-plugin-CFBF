/* --------------------------------------------------------------------------------
 #
 #	4DPlugin.h
 #	source generated by 4D Plugin Wizard
 #	Project : CFBF
 #	author : miyako
 #	2018/05/23
 #
 # --------------------------------------------------------------------------------*/

#include <gsf/gsf-input-memory.h>
#include <gsf/gsf-input-stdio.h>
#include <gsf/gsf-input.h>

#include <gsf/gsf-infile-msole.h>
#include <gsf/gsf-doc-meta-data.h>
#include <gsf/gsf-msole-utils.h>
#include <gsf/gsf-utils.h>

#include "libjson/libjson.h"

// --- CFBF
void CFBF_PARSE_DATA(PA_PluginParameters params);

void getRoot(JSONNODE *json_element, GsfInfile *root, PA_Variable *Param3);
void addElement(JSONNODE *json_element, GsfInput *input, PA_Variable *Param3);

/* hack to statically link glib */
#if VERSIONWIN
extern "C" BOOL glib_DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
extern "C" BOOL gio_DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
extern "C" BOOL gobject_DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
extern "C" BOOL gsf_DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved);
#endif
