@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testPerformance() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "index")
    }
}


