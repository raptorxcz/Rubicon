import Rubicon
import XCTest

final class SpyExtensionIntegrationTests: XCTestCase {
    func test_givenProtocol_whenMakeSpy_thenReturnSpy() {
        let code = """
        protocol Car: Vehicle {
            var name: String? { get }
            var color: Int { get set }

            @MainActor
            func go()
            func load(with stuff: Int, label: String) throws -> Int
            func isFull(_ validate: @MainActor @escaping () -> Void) -> Bool
            func download() async throws -> [String]
            func `continue`(from screenId: String)
            func `continue`(from id: String)
        }
        """
        let sut = Rubicon()

        let result = sut.makeExtensionSpy(code: code, configuration: .makeStub(isInitWithOptionalsEnabled: true))

        equal(string: result.first ?? "", rows: [
            "extension CarSpy {",
            "-static func makeSpy(",
            "--name: String? = nil,",
            "--color: Int,",
            "--loadThrowBlock: (() throws -> Void)? = nil,",
            "--loadReturn: Int,",
            "--isFullReturn: Bool,",
            "--downloadThrowBlock: (() throws -> Void)? = nil,",
            "--downloadReturn: [String]",
            "-) -> CarSpy {",
            "--return CarSpy(",
            "---name: name,",
            "---color: color,",
            "---loadThrowBlock: loadThrowBlock,",
            "---loadReturn: loadReturn,",
            "---isFullReturn: isFullReturn,",
            "---downloadThrowBlock: downloadThrowBlock,",
            "---downloadReturn: downloadReturn",
            "--)",
            "-}",
            "}",
            ""
        ])
    }
}
