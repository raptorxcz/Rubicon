import Rubicon
import XCTest

final class StubIntegrationTests: XCTestCase {
    func test_givenProtocol_whenMakeStub_thenReturnStub() {
        let code = """
        protocol Car {
            var name: String? { get }
            var color: Int { get set }

            func go()
            func load(with stuff: Int, label: String) throws -> Int
            func isFull(validate: @escaping () -> Void) -> Bool
            func download() async throws -> [String]
            func `continue`(from screenId: String)
        }
        """
        let sut = Rubicon()

        let result = sut.makeStub(code: code, configuration: .makeStub(isInitWithOptionalsEnabled: true))

        equal(string: result.first ?? "", rows: [
            "final class CarStub: Car {",
            "-var name: String?",
            "-var color: Int",
            "-var loadThrowBlock: (() throws -> Void)?",
            "-var loadReturn: Int",
            "-var isFullReturn: Bool",
            "-var downloadThrowBlock: (() throws -> Void)?",
            "-var downloadReturn: [String]",
            "",
            "-init(name: String? = nil, color: Int, loadThrowBlock: @escaping (() throws -> Void)? = nil, loadReturn: Int, isFullReturn: Bool, downloadThrowBlock: @escaping (() throws -> Void)? = nil, downloadReturn: [String]) {",
            "--self.name = name",
            "--self.color = color",
            "--self.loadThrowBlock = loadThrowBlock",
            "--self.loadReturn = loadReturn",
            "--self.isFullReturn = isFullReturn",
            "--self.downloadThrowBlock = downloadThrowBlock",
            "--self.downloadReturn = downloadReturn",
            "-}",
            "",
            "-func go() {",
            "-}",
            "",
            "-func load(with stuff: Int, label: String) throws -> Int {",
            "--try loadThrowBlock?()",
            "--return loadReturn",
            "-}",
            "",
            "-func isFull(validate: @escaping () -> Void) -> Bool {",
            "--return isFullReturn",
            "-}",
            "",
            "-func download() async throws -> [String] {",
            "--try downloadThrowBlock?()",
            "--return downloadReturn",
            "-}",
            "",
            "-func `continue`(from screenId: String) {",
            "-}",
            "}",
            ""
        ])
    }
}


extension StubConfiguration {
    static func makeStub(isInitWithOptionalsEnabled: Bool = false) -> StubConfiguration {
        StubConfiguration(
            accessLevel: .internal,
            indentStep: "-",
            nameSuffix: "Stub",
            isInitWithOptionalsEnabled: isInitWithOptionalsEnabled
        )
    }
}
