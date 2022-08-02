import PackageDescription


let platformTargets: [Target] = [
    .target(name: "symswi")
    
]

let platformProducts: [Product] =  [
  .library(name: "symswi", targets: ["symswi"])
]


let package = Package(
    name: "symswi",
    products: platformProducts,
    targets: platformTargets,
    cxxLanguageStandard: .cxx11
)