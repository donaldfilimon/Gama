# Gama

A Swift-based game engine for Windows.

## Features

- Modern Swift-based game development API
- Native Windows UI and graphics
- Game state management
- Event handling and input processing
- High-performance game loop
- Scene graph system

## Quick Start

```swift
import GamaEngine

@main
struct MyGame {
    static func main() {
        let config = GameConfig(
            title: "My Game",
            width: 800,
            height: 600
        )

        let game = Game(config: config)
        game.run()
    }
}
```

## Requirements

- Windows 10 SDK (10.0.18362.0 or later)
- Swift for Windows toolchain
- Visual Studio 2019 or later

## Installation

Add Gama as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/gama.git", from: "1.0.0")
]
```

## Documentation

Visit our [documentation](docs/README.md) for detailed guides and API reference.
