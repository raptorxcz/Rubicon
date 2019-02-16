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
    fileprivate let interactor: CreateMockInteractor

    public init(output: GeneratorOutput, interactor: CreateMockInteractor) {
        self.output = output
        self.interactor = interactor
    }
}

extension MocksGeneratorControllerImpl: MocksGeneratorController {
    public func run(texts: [String]) {
        for text in texts {
            process(text: text)
        }
    }

    private func process(text: String) {
        if text.contains("protocol"), let storage = try? parseStorage(from: text) {
            processAllProtocols(in: storage)
        }
    }

    private func parseStorage(from text: String) throws -> Storage {
        let parser = Parser()
        let tokens = parser.parse(text)
        return try Storage(tokens: tokens)
    }

    private func processAllProtocols(in storage: Storage) {
        var isTextSearched = true

        while isTextSearched {
            do {
                try processNextProtocol(storage: storage)
            } catch {
                isTextSearched = false
            }
        }
    }

    private func processNextProtocol(storage: Storage) throws {
        try storage.moveToNext(.protocol)
        processProtocol(storage: storage)
    }

    private func processProtocol(storage: Storage) {
        do {
            try parseProtocol(storage: storage)
        } catch {
            output.save(text: "")
        }
    }

    func parseProtocol(storage: Storage) throws {
        let protocolParser = ProtocolParser()
        let protocolType = try protocolParser.parse(storage: storage)
        let text = interactor.generate(from: protocolType)
        output.save(text: text)
    }
}
