import Rubicon
import XCTest

final class SpyIntegrationTests: XCTestCase {
    func test_givenProtocol_whenMakeSpy_thenReturnSpy() {
        let code = """
        protocol Car: Vehicle {
            var name: String? { get }
            var color: Int { get set }

            @MainActor
            func go()
            func load(with stuff: Int, label: String) throws -> Int
            func isFull(_ validate: @escaping () -> Void) -> Bool
            func download() async throws -> [String]
            func `continue`(from screenId: String)
        }
        """
        let sut = Rubicon()

        let result = sut.makeSpy(code: code, accessLevel: .internal, indentStep: "-")

        equal(string: result.first ?? "", rows: [
            "final class CarSpy: VehicleSpy, Car {",
            "-struct Load {",
            "--let stuff: Int",
            "--let label: String",
            "-}",
            "",
            "-struct IsFull {",
            "--let validate: () -> Void",
            "-}",
            "",
            "-struct Continue {",
            "--let screenId: String",
            "-}",
            "",
            "-var name: String?",
            "-var color: Int",
            "",
            "-var loadThrowBlock: (() throws -> Void)?",
            "-var loadReturn: Int",
            "-var isFullReturn: Bool",
            "-var downloadThrowBlock: (() throws -> Void)?",
            "-var downloadReturn: [String]",
            "-var goCount = 0",
            "-var load = [Load]()",
            "-var isFull = [IsFull]()",
            "-var downloadCount = 0",
            "-var `continue` = [Continue]()",
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
            "-func isFull(_ validate: @escaping () -> Void) -> Bool {",
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
            "",
            "-func `continue`(from screenId: String) {",
            "--let item = Continue(screenId: screenId)",
            "--`continue`.append(item)",
            "-}",
            "}",
            ""
        ])
    }
}
