//
//  MockGeneratorController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 05/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public protocol MocksGeneratorController {
    func run(texts: [String])
}

public class MocksGeneratorControllerImpl {

    fileprivate let output: GeneratorOutput
    fileprivate let visibility: String?

    public init(output: GeneratorOutput, visibility: String? = nil) {
        self.output = output
        self.visibility = visibility
    }

}

extension MocksGeneratorControllerImpl: MocksGeneratorController {

    public func run(texts: [String]) {
        for text in texts {
            guard text.contains("protocol") else {
                continue
            }

            let parser = Parser()
            let tokens = parser.parse(text)

            guard let storage = try? Storage(tokens: tokens) else {
                continue
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
    }

    private func processProtocol(storage: Storage) {
        let protocolParser = ProtocolParser()

        do {
            let protocolType = try protocolParser.parse(storage: storage)
            let generator = ProtocolSpyGeneratorController()
            let text = generator.generate(from: protocolType, visibility: visibility)
            output.save(text: text)
        } catch {
            output.save(text: "")
        }
    }

}
