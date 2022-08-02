// swift-tools-version:5.0
//
//  Package.swift
//  symswi
//
//  Created by Károly Lőrentey on 2016-01-12.
//  Copyright © 2016-2017 Károly Lőrentey.
//

import PackageDescription

let package = Package(
    name: "symswi",
    products: [ 
        .library(name: "symswi", targets: ["symswi"])
    ],
    targets: [
        .target(name: "symswi", path: "Sources")
    ]
)
