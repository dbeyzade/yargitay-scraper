import Cocoa
import FlutterMacOS
import Vision

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
        
        let ocrChannel = FlutterMethodChannel(
            name: "com.avukat_portal/ocr",
            binaryMessenger: controller.engine.binaryMessenger
        )
        
        ocrChannel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "recognizeText" {
                guard let args = call.arguments as? [String: Any],
                      let imagePath = args["imagePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "imagePath required", details: nil))
                    return
                }
                
                self?.recognizeText(imagePath: imagePath, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func recognizeText(imagePath: String, result: @escaping FlutterResult) {
        let url = URL(fileURLWithPath: imagePath)
        
        guard let cgImage = loadCGImage(from: url) else {
            result(FlutterError(code: "IMAGE_LOAD_ERROR", message: "Could not load image", details: nil))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                result(FlutterError(code: "OCR_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                result(FlutterError(code: "OCR_ERROR", message: "No text found", details: nil))
                return
            }
            
            var recognizedText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string + "\n"
            }
            
            result(recognizedText)
        }
        
        // Türkçe ve İngilizce dil desteği
        request.recognitionLanguages = ["tr-TR", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "OCR_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
    
    private func loadCGImage(from url: URL) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }
}
