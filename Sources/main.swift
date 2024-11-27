import WinSDK
import Foundation

// Helper extension for Windows UTF16 string conversion
extension String {
    var windowsUTF16: LPCWSTR {
        Array<WCHAR>(self.utf16).withUnsafeBufferPointer { ptr in
            return ptr.baseAddress!
        }
    }
}

@main
struct GameApp {
    static func main() {
        // Get module handle with proper error handling
        guard let hInstance = GetModuleHandleW(nil) else {
            print("Failed to get module handle: \(GetLastError())")
            return
        }

        // Register window class
        var wc = WNDCLASSEXW()
        wc.cbSize = UINT(MemoryLayout<WNDCLASSEXW>.size)
        wc.lpfnWndProc = { (hwnd, uMsg, wParam, lParam) -> LRESULT in
            switch uMsg {
            case UINT(WM_DESTROY):
                PostQuitMessage(0)
                return 0
            default:
                return DefWindowProcW(hwnd, uMsg, wParam, lParam)
            }
        }
        wc.hInstance = hInstance
        wc.lpszClassName = "GameWindow".windowsUTF16
        wc.hCursor = LoadCursorW(nil, UnsafePointer<UInt16>(bitPattern: 32512))

        guard RegisterClassExW(&wc) != 0 else {
            print("Failed to register window class: \(GetLastError())")
            return
        }

        // Create window
        guard let hwnd = CreateWindowExW(
            0,
            "GameWindow".windowsUTF16,
            "Game Window".windowsUTF16,
            DWORD(WS_OVERLAPPEDWINDOW),
            CW_USEDEFAULT, CW_USEDEFAULT,
            800, 600,
            nil,
            nil,
            hInstance,
            nil
        ) else {
            print("Failed to create window: \(GetLastError())")
            return
        }

        ShowWindow(hwnd, SW_SHOW)
        UpdateWindow(hwnd)

        var msg = MSG()
        var result: Bool = false
        repeat {
            result = GetMessageW(&msg, nil, 0, 0)
            if result {
                TranslateMessage(&msg)
                DispatchMessageW(&msg)
            }
        } while result
    }
}
