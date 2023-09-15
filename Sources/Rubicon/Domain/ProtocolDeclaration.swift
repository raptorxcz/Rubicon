//
//  ProtocolDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

struct ProtocolDeclaration: Equatable {
    var name: String
    var parents: [String]
    var variables: [VarDeclaration]
    var functions: [FunctionDeclaration]
}
