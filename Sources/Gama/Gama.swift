import Foundation
import WinSDK

// Assuming these classes are defined in the same module or imported from another module
class InputSystem {
    static let shared = InputSystem()
    func registerHandler(_ handler: Any) throws {}
    func translateWindowsMessage(msg: UINT, wParam: WPARAM, lParam: LPARAM) async throws -> Any? { return nil }
    func processEvent(_ event: Any) async {}
    func shutdown() async {}
}

class PlayerController {}
class DebugInputController {}

// MARK: - Windows UTF16 Conversion
extension String {
    @inlinable
    var windowsUTF16: LPCWSTR {
        [WCHAR](self.utf16).withUnsafeBufferPointer { ptr in
            guard let baseAddress = ptr.baseAddress else {
                return UnsafePointer<WCHAR>(bitPattern: 0)!
            }
            return baseAddress
        }
    }
}

// MARK: - Game Application
@main
struct GameApp {
    // MARK: - Static Properties
    private static let inputSystem = InputSystem.shared
    private static let windowClassName = "GameWindow"
    private static let windowTitle = "Gama Game Engine"
    private static let defaultWindowSize = (width: 800, height: 600)

    // MARK: - Error Types
    enum GameError: Error {
        case moduleHandleFailure(code: DWORD)
        case windowClassRegistrationFailure(code: DWORD)
        case windowCreationFailure(code: DWORD)
        case messageLoopFailure(code: DWORD)
        case inputSystemSetupFailure(Error)

        var localizedDescription: String {
            switch self {
            case .moduleHandleFailure(let code):
                return "Failed to get module handle: \(code)"
            case .windowClassRegistrationFailure(let code):
                return "Failed to register window class: \(code)"
            case .windowCreationFailure(let code):
                return "Failed to create window: \(code)"
            case .messageLoopFailure(let code):
                return "Message loop failure: \(code)"
            case .inputSystemSetupFailure(let error):
                return "Input system setup failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Input Setup
    private static func setupInputHandlers() throws {
        let playerController = PlayerController()
        try inputSystem.registerHandler(playerController)

        // Optional: Debug input logging in development
        #if DEBUG
        let debugController = DebugInputController()
        try inputSystem.registerHandler(debugController)
        #endif
    }

    // MARK: - Window Procedure
    private static func windowProc(
        hwnd: HWND?,
        uMsg: UINT,
        wParam: WPARAM,
        lParam: LPARAM
    ) -> LRESULT {
        // Async input processing with error handling
        Task {
            do {
                if let inputEvent = try await inputSystem.translateWindowsMessage(
                    msg: uMsg,
                    wParam: wParam,
                    lParam: lParam
                ) {
                    await inputSystem.processEvent(inputEvent)
                }
            } catch {
                #if DEBUG
                print("Input processing error: \(error)")
                #endif
            }
        }

        switch uMsg {
        case UINT(WM_DESTROY):
            Task {
                await inputSystem.shutdown()
                PostQuitMessage(0)
            }
            return 0

        case UINT(WM_CLOSE):
            handleWindowClose(hwnd)
            return 0

        default:
            return DefWindowProcW(hwnd, uMsg, wParam, lParam)
        }
    }

    // MARK: - Window Management
    private static func handleWindowClose(_ hwnd: HWND?) {
        let result = MessageBoxW(
            hwnd,
            "Do you want to exit the game?".windowsUTF16,
            "Exit Game".windowsUTF16,
            UINT(MB_OKCANCEL | MB_ICONQUESTION)
        )

        if result == IDOK {
            DestroyWindow(hwnd)
        }
    }

    // MARK: - Main Entry Point
    static func main() async throws {
        // Initialize systems
        try await setupInputHandlers()

        // Get module handle
        guard let hInstance = GetModuleHandleW(nil) else {
            throw GameError.moduleHandleFailure(code: GetLastError())
        }

        // Configure window class
        let windowClass = try configureWindowClass(hInstance: hInstance)

        // Register window class
        guard RegisterClassExW(&windowClass) != 0 else {
            throw GameError.windowClassRegistrationFailure(code: GetLastError())
        }

        // Create and show window
        guard let hwnd = try createGameWindow(hInstance: hInstance) else {
            throw GameError.windowCreationFailure(code: GetLastError())
        }

        ShowWindow(hwnd, SW_SHOW)
        UpdateWindow(hwnd)

        // Enhanced message loop with error handling
        try await runMessageLoop()
    }

    // MARK: - Helper Methods
    private static func configureWindowClass(hInstance: HMODULE) -> WNDCLASSEXW {
        var wc = WNDCLASSEXW()
        wc.cbSize = UINT(MemoryLayout<WNDCLASSEXW>.size)
        wc.style = UINT(CS_HREDRAW | CS_VREDRAW)
        wc.lpfnWndProc = { windowProc(hwnd: $0, uMsg: $1, wParam: $2, lParam: $3) }
        wc.hInstance = hInstance
        wc.lpszClassName = windowClassName.windowsUTF16
        wc.hCursor = LoadCursorW(nil, UnsafePointer<UInt16>(bitPattern: 32512))
        wc.hbrBackground = HBRUSH(bitPattern: UInt(COLOR_WINDOW + 1))
        return wc
    }

    private static func createGameWindow(hInstance: HMODULE) throws -> HWND? {
        CreateWindowExW(
            0,
            windowClassName.windowsUTF16,
            windowTitle.windowsUTF16,
            DWORD(WS_OVERLAPPEDWINDOW),
            CW_USEDEFAULT, CW_USEDEFAULT,
            Int32(defaultWindowSize.width),
            Int32(defaultWindowSize.height),
            nil, nil, hInstance, nil
        )
    }

    private static func runMessageLoop() async throws {
        var msg = MSG()
        while true {
            let result = GetMessageW(&msg, nil, 0, 0)

            switch result {
            case -1:
                throw GameError.messageLoopFailure(code: GetLastError())
            case 0:
                return // WM_QUIT received
            default:
                TranslateMessage(&msg)
                DispatchMessageW(&msg)
            }
        }
    }
}

// Add GamepadId type alias
typealias GamepadId = Int
