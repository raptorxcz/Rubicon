//
//  File.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 16/02/2019.
//  Copyright © 2019 Kryštof Matěj. All rights reserved.
//

public protocol CreateMockInteractor {
    func generate(from protocolType: ProtocolDeclaration) -> String
}
