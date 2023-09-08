//
//  FunctionDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct FunctionDeclaration {
    public let name: String
    public let arguments: [ArgumentDeclaration]
    public let isThrowing: Bool
    public let isAsync: Bool
    public let returnType: TypeDeclaration?

    public init(name: String, arguments: [ArgumentDeclaration] = [], isThrowing: Bool = false, isAsync: Bool = false, returnType: TypeDeclaration? = nil) {
        self.name = name
        self.arguments = arguments
        self.isThrowing = isThrowing
        self.isAsync = isAsync
        self.returnType = returnType
    }
}
