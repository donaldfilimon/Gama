import Foundation
import WinSDK

// Helper extension for Windows UTF16 string conversion
extension String {
    var windowsUTF16: LPCWSTR {
        [WCHAR](self.utf16).withUnsafeBufferPointer { ptr in
            guard let baseAddress = ptr.baseAddress else {
                return UnsafePointer<WCHAR>(bitPattern: 0)!  // Return null pointer instead of nil
            }
            return baseAddress
        }
    }
}

/// GameApp: Main entry point for the Windows-based game application
/// Handles window creation and message processing
@main
struct GameApp {
    // Add static constants for window configuration
    private static let windowClassName = "GameWindow"
    private static let windowTitle = "Game Window"
    private static let defaultWindowSize = (width: 800, height: 600)
    private static let IDC_ARROW: Int32 = 32512
    private static let DEFAULT_BACKGROUND = COLOR_WINDOW + 1

    // Separate window creation logic
    private static func createGameWindow(hInstance: HMODULE) -> HWND? {
        return CreateWindowExW(
            0,
            windowClassName.windowsUTF16,
            windowTitle.windowsUTF16,
            DWORD(WS_OVERLAPPEDWINDOW),
            CW_USEDEFAULT, CW_USEDEFAULT,
            Int32(defaultWindowSize.width),
            Int32(defaultWindowSize.height),
            nil,
            nil,
            hInstance,
            nil
        )
    }

    // Enhanced window procedure with error handling
    private static func windowProc(hwnd: HWND?, uMsg: UINT, wParam: WPARAM, lParam: LPARAM)
        -> LRESULT
    {
        switch uMsg {
        case UINT(WM_DESTROY):
            PostQuitMessage(0)
            return 0
        case UINT(WM_CLOSE):
            // Add confirmation before closing
            if MessageBoxW(
                hwnd, "Really quit?".windowsUTF16,
                "Game".windowsUTF16,
                UINT(MB_OKCANCEL)) == IDOK
            {
                DestroyWindow(hwnd)
            }
            return 0
        default:
            return DefWindowProcW(hwnd, uMsg, wParam, lParam)
        }
    }

    /// Main entry point
    /// - Initializes Windows components
    /// - Creates and shows the main window
    /// - Runs the message loop
    static func main() {
        // Get module handle with proper error handling
        guard let hInstance = GetModuleHandleW(nil) else {
            print("Failed to get module handle: \(GetLastError())")
            return
        }

        // Enhanced window class registration
        var wc = WNDCLASSEXW()
        wc.cbSize = UINT(MemoryLayout<WNDCLASSEXW>.size)
        wc.style = UINT(CS_HREDRAW | CS_VREDRAW)  // Add window styles
        wc.lpfnWndProc = { (hwnd, uMsg, wParam, lParam) -> LRESULT in
            GameApp.windowProc(hwnd: hwnd, uMsg: uMsg, wParam: wParam, lParam: lParam)
        }
        wc.hInstance = hInstance
        wc.lpszClassName = windowClassName.windowsUTF16
        wc.hCursor = LoadCursorW(nil, UnsafePointer<UInt16>(bitPattern: 32512))  // Standard arrow cursor
        wc.hbrBackground = HBRUSH(bitPattern: UInt(COLOR_WINDOW + 1))

        guard RegisterClassExW(&wc) != 0 else {
            print("Failed to register window class: \(GetLastError())")
            return
        }

        // Create and show window with error handling
        guard let hwnd = createGameWindow(hInstance: hInstance) else {
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
