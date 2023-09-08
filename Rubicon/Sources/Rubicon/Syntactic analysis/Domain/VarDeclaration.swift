//
//  VarDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 22/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

struct VarDeclaration: Equatable {
    var prefix: String?
    var isConstant: Bool
    var identifier: String
    var type: TypeDeclaration

    init(prefix: String? = nil, isConstant: Bool, identifier: String, type: TypeDeclaration) {
        self.prefix = prefix
        self.isConstant = isConstant
        self.identifier = identifier
        self.type = type
    }
}
