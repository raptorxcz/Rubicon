//
//  FunctionDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

struct FunctionDeclaration: Equatable {
    let name: String
    let arguments: [ArgumentDeclaration]
    let isThrowing: Bool
    let isAsync: Bool
    let returnType: TypeDeclaration?
}
