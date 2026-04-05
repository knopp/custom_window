#include "windows.h"

#define WINDOWS_LEAN_AND_MEAN
#include <windows.h>

#include <dwmapi.h>

CW_EXPORT void cw_hwnd_make_undecorated(void *hwnd_) {
  HWND hwnd = static_cast<HWND>(hwnd_);

  SetWindowLong(hwnd, GWL_STYLE,
                WS_THICKFRAME | WS_CAPTION | WS_MAXIMIZEBOX | WS_MINIMIZEBOX |
                    WS_OVERLAPPED);

  SetWindowPos(hwnd, nullptr, 0, 0, 0, 0,
               SWP_FRAMECHANGED | SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE |
                   SWP_NOZORDER);

  MARGINS margins;
  margins.cxLeftWidth = 1;
  margins.cxRightWidth = 1;
  margins.cyTopHeight = 1;
  margins.cyBottomHeight = 1;

  DwmExtendFrameIntoClientArea(hwnd, &margins);
}
