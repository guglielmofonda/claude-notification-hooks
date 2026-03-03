import AVFoundation
import Foundation

let onDuration: TimeInterval = 0.5
let offDuration: TimeInterval = 0.5
let blinks = 5

for i in 0..<blinks {
    let session = AVCaptureSession()
    guard let device = AVCaptureDevice.default(for: .video),
          let input = try? AVCaptureDeviceInput(device: device) else {
        exit(1)
    }
    session.addInput(input)
    session.startRunning()
    Thread.sleep(forTimeInterval: onDuration)
    session.stopRunning()
    session.removeInput(input)
    Thread.sleep(forTimeInterval: offDuration)
}

exit(0)
