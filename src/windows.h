#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#ifdef CW_BUILDING_DLL
#define CW_EXPORT __declspec(dllexport)
#else
#define CW_EXPORT __declspec(dllimport)
#endif

CW_EXPORT void cw_hwnd_make_undecorated(void *hwnd);

#ifdef __cplusplus
}
#endif