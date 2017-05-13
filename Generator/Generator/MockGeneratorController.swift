//
//  MockGeneratorController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public protocol MocksGeneratorController {
    func run(text: String)
}

public class MocksGeneratorControllerImpl {

    fileprivate let output: GeneratorOutput

    public init(output: GeneratorOutput) {
        self.output = output
    }

}

extension MocksGeneratorControllerImpl: MocksGeneratorController {

    public func run(text: String) {
        let parser = Parser()
        let tokens = parser.parse(text)

        guard let storage = try? Storage(tokens: tokens) else {
            output.save(text: "")
            return
        }

        var isTextSearched = true

        while isTextSearched {
            do {
                try storage.moveToNext(.protocol)
                processProtocol(storage: storage)
            } catch {
                isTextSearched = false
            }
        }
    }

    private func processProtocol(storage: Storage) {
        let protocolParser = ProtocolParser()

        do {
            let protocolType = try protocolParser.parse(storage: storage)
            let generator = ProtocolSpyGeneratorController()
            let text = generator.generate(from: protocolType)
            output.save(text: text)
        } catch {
            output.save(text: "")
        }
    }

}
