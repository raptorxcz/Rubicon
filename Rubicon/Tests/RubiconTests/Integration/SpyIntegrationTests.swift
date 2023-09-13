import Rubicon
import XCTest

final class SpyIntegrationTests: XCTestCase {
    func test_givenProtocol_whenMakeDummy_thenReturnStub() {
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

        let result = sut.makeSpy(code: code, accessLevel: .internal, indentStep: "-")

        equal(string: result.first ?? "", rows: [
            "final class CarSpy: Car {",
            "-struct Load {",
            "--let stuff: Int",
            "--let label: String",
            "-}",
            "",
            "-struct IsFull {",
            "--let validate: () -> Void",
            "-}",
            "",
            "-var name: String?",
            "-var color: Int",
            "-var loadThrowBlock: () -> Void?",
            "-var loadReturn: Int",
            "-var isFullReturn: Bool",
            "-var downloadThrowBlock: () -> Void?",
            "-var downloadReturn: [String]",
            "",
            "-var goCount = 0",
            "-var load = [Load]()",
            "-var isFull = [IsFull]()",
            "-var downloadCount = 0",
            "",
            "-init(color: Int, loadReturn: Int, isFullReturn: Bool, downloadReturn: [String]) {",
            "--self.color = color",
            "--self.loadReturn = loadReturn",
            "--self.isFullReturn = isFullReturn",
            "--self.downloadReturn = downloadReturn",
            "-}",
            "",
            "-func go() {",
            "--goCount += 1",
            "-}",
            "",
            "-func load(with stuff: Int, label: String) throws -> Int {",
            "--let item = Load(stuff: stuff, label: label)",
            "--load.append(item)",
            "--try loadThrowBlock?()",
            "--return loadReturn",
            "-}",
            "",
            "-func isFull(validate: @escaping () -> Void) -> Bool {",
            "--let item = IsFull(validate: validate)",
            "--isFull.append(item)",
            "--return isFullReturn",
            "-}",
            "",
            "-func download() async throws -> [String] {",
            "--downloadCount += 1",
            "--try downloadThrowBlock?()",
            "--return downloadReturn",
            "-}",
            "}",
            ""
        ])
    }
}
