import Rubicon
import XCTest

final class StructStubIntegrationTests: XCTestCase {
    func test_givenStruct_whenMakeStructStub_thenReturnStub() {
        let code = """
        struct Car {
            let lenght: Int
            let name: String
            let isRed: Bool
            let seats: [Seat]
            let driver: Driver
            let trunk: Trunk
        """
        let sut = Rubicon()

        let result = sut.makeStructStub(code: code, configuration: .makeStub())

        print(result)
        equal(string: result.first ?? "", rows: [
            "public extension Car {",
            "-public static func makeStub(",
            "--lenght: Int = 0,",
            "--name: String = \"name\",",
            "--isRed: Bool = false,",
            "--seats: [Seat] = [],",
            "--driver: Driver = Carl,",
            "--trunk: Trunk = .makeStub()",
            "-) -> Car {",
            "--return Car(",
            "---lenght: lenght,",
            "---name: name,",
            "---isRed: isRed,",
            "---seats: seats,",
            "---driver: driver,",
            "---trunk: trunk",
            "--)",
            "-}",
            "}",
            "",
        ])
    }
}


extension StructStubConfiguration {
    static func makeStub() -> StructStubConfiguration {
        StructStubConfiguration(
            accessLevel: .public,
            indentStep: "-",
            functionName: "makeStub",
            defaultValue: ".makeStub()",
            customDefaultValues: ["Driver": "Carl"]
        )
    }
}
