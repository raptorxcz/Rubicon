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
            func `continue`(from id: String)
        }
        """
        let sut = Rubicon()

        let result = sut.makeSpy(code: code, configuration: .makeStub(isInitWithOptionalsEnabled: true))

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
            "-struct ContinueFromScreenId {",
            "--let screenId: String",
            "-}",
            "",
            "-struct ContinueFromId {",
            "--let id: String",
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
            "-var continueFromScreenId = [ContinueFromScreenId]()",
            "-var continueFromId = [ContinueFromId]()",
            "",
            "-init(name: String? = nil, color: Int, loadThrowBlock: (() throws -> Void)? = nil, loadReturn: Int, isFullReturn: Bool, downloadThrowBlock: (() throws -> Void)? = nil, downloadReturn: [String]) {",
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
            "--let item = ContinueFromScreenId(screenId: screenId)",
            "--continueFromScreenId.append(item)",
            "-}",
            "",
            "-func `continue`(from id: String) {",
            "--let item = ContinueFromId(id: id)",
            "--continueFromId.append(item)",
            "-}",
            "}",
            ""
        ])
    }

    func test_givenSingleSwiftKeywordEscapingFunction_whenMakeSpy_thenMakesSpy() {
        let code = """
        protocol Car: Vehicle {
            func `continue`(from id: String)
        }
        """
        let sut = Rubicon()

        let result = sut.makeSpy(code: code, configuration: .makeStub())

        equal(string: result.first ?? "", rows: [
            "final class CarSpy: VehicleSpy, Car {",
            "-struct Continue {",
            "--let id: String",
            "-}",
            "",
            "-var `continue` = [Continue]()",
            "",
            "-func `continue`(from id: String) {",
            "--let item = Continue(id: id)",
            "--`continue`.append(item)",
            "-}",
            "}",
            ""
        ])
    }
}

extension SpyConfiguration {
    static func makeStub(
        isInitWithOptionalsEnabled: Bool = false
    ) -> SpyConfiguration {
        SpyConfiguration(
            accessLevel: .internal,
            indentStep: "-",
            isInitWithOptionalsEnabled: isInitWithOptionalsEnabled
        )
    }
}
