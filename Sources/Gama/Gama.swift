import SwiftWin32
import SwiftWin32UI
import GamaEngine

struct GameConfig {
    var title: String
    var width: Int
    var height: Int
}

class Game {
    var config: GameConfig

    init(config: GameConfig) {
        self.config = config
    }

    func run() {
        // Game running logic here
    }
}

@main
struct GameApp {
    static func main() {
        let config = GameConfig(
            title: "Gama Demo",
            width: 800,
            height: 600
        )

        let game = Game(config: config)
        game.run()
    }
}
