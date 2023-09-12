import Rubicon
import XCTest

final class DummyIntegrationTests: XCTestCase {
    func test_givenProtocol_whenMakeDummy_thenReturnDummy() {
        let code = """
        protocol Car {
            var name: String? { get }
            var color: Int { get set }

            func go()
            func load(with stuff: Int, label: String) throws -> Int
            func isFull(validate: @escaping () -> Void) -> Bool
            func download() async throws -> [String]
        }
        """
        let sut = Rubicon()

        let result = sut.makeDummy(code: code, accessLevel: .public, indentStep: "-")

        equal(string: result.first ?? "", rows: [
            "public final class CarDummy: Car {",
            "-public var name: String? {",
            "--get {",
            "---fatalError()",
            "--}",
            "--set {",
            "---fatalError()",
            "--}",
            "-}",
            "-public var color: Int {",
            "--get {",
            "---fatalError()",
            "--}",
            "--set {",
            "---fatalError()",
            "--}",
            "-}",
            "",
            "-public init() {",
            "-}",
            "",
            "-public func go() {",
            "--fatalError()",
            "-}",
            "",
            "-public func load(with stuff: Int, label: String) throws -> Int {",
            "--fatalError()",
            "-}",
            "",
            "-public func isFull(validate: @escaping () -> Void) -> Bool {",
            "--fatalError()",
            "-}",
            "",
            "-public func download() async throws -> [String] {",
            "--fatalError()",
            "-}",
            "}",
            "",
        ])
    }
}
