//
//  main.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 20/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation

let assembly = CommandLineAssembly()
let arguments = CommandLine.arguments
assembly.makeArguments(arguments: arguments)
