

import UIKit

@objc public class NinePatch: NSObject {
    @objc public static func ninePatchImage(withData data: Data?, scale: CGFloat = 3.0) -> UIImage? {
        guard let data = data, data.count > 8 else { return nil }
        let sign = data.prefix(8)

        // https://filesig.search.org/
        if sign != Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]) {
            return UIImage(data: data, scale: scale)
        }

        // 跳过 PNG 签名
        var offset = 8
        while offset < data.count - 8 {
            // 读取 Chunk 长度 (4 bytes, Big Endian)
            let chunkLengthUI32 = data.subdata(in: offset ..< offset + 4).withUnsafeBytes { $0.load(as: UInt32.self) }
            let chunkLength = Int(chunkLengthUI32.bigEndian)

            // 读取 Chunk 类型 (4 bytes)
            let chunkType = String(data: data.subdata(in: offset + 4 ..< offset + 8), encoding: .ascii)

            // 寻找 npTc Chunk
            if chunkType == "npTc" {
                let npTcChunk = data.subdata(in: offset + 8 ..< offset + 8 + chunkLength)
                if let originalImg = UIImage(data: data, scale: 1), let imgCapInsets = imageCapInsets(originalImg, npTcChunk: npTcChunk, scale: scale) {
                    return UIImage(data: data, scale: scale)?.resizableImage(withCapInsets: imgCapInsets, resizingMode: .stretch)
                }

                // 只要找到了 `npTc` 就终止循环
                break
            }

            // 移动到下一个 Chunk (Length + Type + Data + CRC = 4+4+Length+4)
            offset += (12 + chunkLength)
        }

        return UIImage(data: data, scale: scale)
    }

    // https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/libs/androidfw/ResourceTypes.cpp
    private static func imageCapInsets(_ originalImg: UIImage, npTcChunk: Data, scale: CGFloat) -> UIEdgeInsets? {
        if npTcChunk.count < 32 { return nil }

        var offset = 0
        let _ = Int(npTcChunk[offset]) // wasDeserialized
        offset += 1
        let numXDivs = Int(npTcChunk[offset])
        offset += 1
        let numYDivs = Int(npTcChunk[offset])
        offset += 1
        let _ = Int(npTcChunk[offset]) // numColors
        offset += 1

        // 忽略 `padding`，直接读取 `xDivs` 和 `yDivs`
        var xDivs: [Int] = [], yDivs: [Int] = []
        offset = 32

        // xDivs
        for _ in 0 ..< numXDivs {
            let valueUI32 = npTcChunk.subdata(in: offset ..< offset + 4).withUnsafeBytes { $0.load(as: UInt32.self) }
            let value = Int(valueUI32.bigEndian)
            xDivs.append(value)
            offset += 4
        }

        // yDivs
        for _ in 0 ..< numYDivs {
            let valueUI32 = npTcChunk.subdata(in: offset ..< offset + 4).withUnsafeBytes { $0.load(as: UInt32.self) }
            let value = Int(valueUI32.bigEndian)
            yDivs.append(value)
            offset += 4
        }

        // 通过 `xDivs` 和 `yDivs` 确定拉伸区域
        var result: UIEdgeInsets = .zero
        if xDivs.count >= 2 {
            result.left = CGFloat(xDivs[0])
            result.right = originalImg.size.width - CGFloat(xDivs[1])
        }

        if yDivs.count >= 2 {
            result.top = CGFloat(yDivs[0])
            result.bottom = originalImg.size.height - CGFloat(yDivs[1])
        }

        if scale > 0, originalImg.scale != scale {
            let r = originalImg.scale / scale
            result.top *= r
            result.left *= r
            result.bottom *= r
            result.right *= r
        }

        return result
    }
}
