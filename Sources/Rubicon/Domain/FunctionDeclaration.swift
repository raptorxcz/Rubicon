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
    let isStatic: Bool
    let returnType: TypeDeclaration?

    init(
        name: String,
        arguments: [ArgumentDeclaration],
        isThrowing: Bool,
        isAsync: Bool,
        isStatic: Bool = false,
        returnType: TypeDeclaration?
    ) {
        self.name = name
        self.arguments = arguments
        self.isThrowing = isThrowing
        self.isAsync = isAsync
        self.isStatic = isStatic
        self.returnType = returnType
    }
}
