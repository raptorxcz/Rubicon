//
//  VarDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 22/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

struct VarDeclaration: Equatable {
    var isConstant: Bool
    var identifier: String
    var type: TypeDeclaration

    init(isConstant: Bool, identifier: String, type: TypeDeclaration) { 
        self.isConstant = isConstant
        self.identifier = identifier
        self.type = type
    }
}
