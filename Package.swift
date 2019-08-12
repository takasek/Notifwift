// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Notifwift",
    products: [
        .library(name: "Notifwift", targets: ["Notifwift"]),
    ],
    targets: [
        .target(name: "Notifwift", path: "Notifwift"),
    ]
)
