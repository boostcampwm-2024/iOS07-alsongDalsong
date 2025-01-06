import AVFoundation
import Foundation

public enum ASAudioAnalyzer {
    public static func analyze(data: Data, samplesCount: Int) async throws -> [CGFloat] {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
        try data.write(to: tempURL)
        let file = try AVAudioFile(forReading: tempURL)
        
        guard
            let format = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: file.fileFormat.sampleRate,
                channels: file.fileFormat.channelCount,
                interleaved: false
            ),
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))
        else {
            return []
        }

        try file.read(into: buffer)
        guard let floatChannelData = buffer.floatChannelData else {
            return []
        }

        let frameLength = Int(buffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: floatChannelData[0], count: frameLength))
        var result = [CGFloat]()
        let chunkedSamples = samples.chunked(into: samples.count / samplesCount)

        for chunk in chunkedSamples {
            let squaredSum = chunk.reduce(0) { $0 + $1 * $1 }
            let averagePower = squaredSum / Float(chunk.count)
            let decibels = 10 * log10(max(averagePower, Float.ulpOfOne))

            let newAmplitude = 1.8 * pow(10.0, decibels / 20.0)
            let clampedAmplitude = min(max(CGFloat(newAmplitude), 0), 1)
            result.append(clampedAmplitude)
        }

        try? FileManager.default.removeItem(at: tempURL)

        return result
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
