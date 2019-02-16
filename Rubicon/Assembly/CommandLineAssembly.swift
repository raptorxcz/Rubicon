//
//  CommandLineAssembly.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 06/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

class CommandLineAssembly {

    func makeArguments(arguments: [String]) {
        let fileReader = FileReaderImpl()
        let output = StandardGeneratorOutput()
        let helpController = HelpControllerImpl(output: output)
        let spyMocksController = MocksGeneratorControllerImpl(output: output, interactor: ProtocolSpyGeneratorController())
        let dummyMocksController = MocksGeneratorControllerImpl(output: output, interactor: CreateDummyInteractor())

        let argumentsController = ArgumentsController(fileReader: fileReader, helpController: helpController, spyMocksController: spyMocksController, dummyMocksController: dummyMocksController)
        argumentsController.run(arguments: arguments)
    }
}
