//
//  CommandLineAssembly.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 06/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Rubicon

class CommandLineAssembly {

    func makeArguments(arguments: [String]) {
        let fileReader = FileReaderImpl()
        let output = StandardGeneratorOutput()
        let helpController = HelpControllerImpl(output: output)
        let spyMocksController = MocksGeneratorControllerImpl(output: output, interactor: CreateSpyInteractor(accessLevel: .internal))
        let stubMocksController = MocksGeneratorControllerImpl(output: output, interactor: CreateStubInteractor(accessLevel: .internal))
        let dummyMocksController = MocksGeneratorControllerImpl(output: output, interactor: CreateDummyInteractor(accessLevel: .internal))

        let argumentsController = ArgumentsController(fileReader: fileReader, helpController: helpController, spyMocksController: spyMocksController, stubMocksController: stubMocksController, dummyMocksController: dummyMocksController)
        argumentsController.run(arguments: arguments)
    }
}
