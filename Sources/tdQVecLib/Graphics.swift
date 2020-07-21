//
//  Graphics.swift
//
//
//  Created by Niall Ó Broin on 21/07/2020.
//

import Foundation



//https://gist.github.com/KrisYu/abf3d03a76b781ffc2a26848d713b11e
@discardableResult func writeCGImage(_ image: CGImage, to destinationURL: URL) -> Bool {
    guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypePNG, 1, nil) else { return false }
    CGImageDestinationAddImage(destination, image, nil)
    return CGImageDestinationFinalize(destination)
}




func mask(from data: Data) -> CGImage? {
    //https://stackoverflow.com/questions/38229027/how-to-create-a-bitmap-image-from-the-byte-array-in-swift
    guard data.count >= 8 else {
        print("data too small")
        return nil
    }

    let width: Int = Int(sqrt(Double(data.count)))
    let height: Int = width

    let colorSpace = CGColorSpaceCreateDeviceGray()
    //    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard
        data.count >= width * height,
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue),
        let buffer = context.data?.bindMemory(to: UInt8.self, capacity: width * height)
    else {
        return nil
    }


    let UIntData = data.toArray(type: UInt8.self)

    for index in 0 ..< width * height {
        buffer[index] = UInt8(UIntData[index])
    }


    let url = URL(fileURLWithPath: "Jimmy")
    writeCGImage(context.makeImage()!, to: url)


    return context.makeImage()

}




let _ = mask(from: writeBuffer)


