//
//  FileReaderImpl.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 06/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public protocol FileReader {
    func readFiles(at path: String) -> [String]
}
