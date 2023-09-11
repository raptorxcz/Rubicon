import Rubicon
import XCTest

final class IntegrationTests: XCTestCase {
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

        let result = sut.makeDummy(code: code, accessLevel: .public)

        equal(string: result.first ?? "", rows: [
            "public final class CarDummy: Car {",
            "\tpublic var name: String? {",
            "\t\tget {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t\tset {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t}",
            "\tpublic var color: Int {",
            "\t\tget {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t\tset {",
            "\t\t\tfatalError()",
            "\t\t}",
            "\t}",
            "",
            "\tpublic init() {",
            "\t}",
            "",
            "\tpublic func go() {",
            "\t\tfatalError()",
            "\t}",
            "",
            "\tpublic func load(with stuff: Int, label: String) throws -> Int {",
            "\t\tfatalError()",
            "\t}",
            "",
            "\tpublic func isFull(validate: @escaping () -> Void) -> Bool {",
            "\t\tfatalError()",
            "\t}",
            "",
            "\tpublic func download() async throws -> [String] {",
            "\t\tfatalError()",
            "\t}",
            "",
            "}",
            "",
        ])
    }
}
