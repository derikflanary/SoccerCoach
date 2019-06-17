//
//  TextRecognitionEngine.swift
//  soccer-coach
//
//  Created by Derik Flanary on 6/17/19.
//  Copyright © 2019 Derik Flanary. All rights reserved.
//

import Foundation
import Vision
import VisionKit

@available(iOS 13.0, *)
class TextRecognitionEngine {
    
    private var requests = [VNRequest]()
    private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private var resultingText = ""
    private var strings = [String]()
    
    init(recognitionLevel: VNRequestTextRecognitionLevel = .accurate, languageCorrection: Bool = true, customWords: [String] = []) {
        let textRecognitionRequest = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // Concatenate the recognised text from all the observations.
            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else { continue }
                self.resultingText += candidate.string + "\n"
                self.strings.append(candidate.string)
            }
        }
        textRecognitionRequest.recognitionLevel = recognitionLevel
        textRecognitionRequest.usesLanguageCorrection = languageCorrection
        textRecognitionRequest.customWords = customWords
        requests = [textRecognitionRequest]
    }
    
    func process(_ scan: VNDocumentCameraScan, completion: @escaping (([String]) -> Void)) {
        let images = scan.images()
        let handlers = images.map { VNImageRequestHandler(cgImage: $0, options: [:]) }
        performRequest(on: handlers, completion: completion)
    }
    
}


// MARK: - Private

@available(iOS 13.0, *)
private extension TextRecognitionEngine {
    
    func performRequest(on handlers: [VNImageRequestHandler], completion: @escaping (([String]) -> Void)) {
        resultingText = ""
        textRecognitionWorkQueue.async {
            for handler in handlers {
                do {
                    try handler.perform(self.requests)
                } catch {
                    dump(error)
                }
                self.resultingText += "\n\n"
            }
            completion(self.strings)
        }
    }
    
}


// MARK: - VNDocumentCameraScan
@available(iOS 13.0, *)
extension VNDocumentCameraScan {
    
    func images() -> [CGImage] {
        var allImages = [UIImage]()
        for pageIndex in 0 ..< pageCount {
            allImages.append(imageOfPage(at: pageIndex))
        }
        return allImages.compactMap { $0.cgImage }
    }
    
}
