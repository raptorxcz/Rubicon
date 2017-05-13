//
//  StandardGeneratorOutput.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 06/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation

public protocol GeneratorOutput {

    func save(text: String)
    
}

public protocol ErrorGeneratorOutput {

    func showError(text: String)

}
