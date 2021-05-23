//
//  ViewController.swift
//  VideoTicker
//
//  Created by Paul Derbyshire on 23/05/2021.
//

import Cocoa
import AVFoundation
import AVKit
import Speech


class ViewController: NSViewController, DCDroppableImageWellDelegate {
	
	@IBOutlet var startButton: NSButton!
	@IBOutlet var tickerLabel: NSTextField!
	@IBOutlet var videoPlayerView: AVPlayerView!
//	@IBOutlet var progressBar: NSProgressIndicator!
	
	private var fileURL: URL!
	private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))!
	private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
	private var recognitionTask: SFSpeechRecognitionTask?
	
//	private var player = AVPlayerView
//	private let playerLayer = AVPlayerLayer()
	
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	func droppableImageWellDroppedFiles(files: Array<URL>) {
		startButton.isEnabled = true
		fileURL = files.first
	}

	@IBAction func startButtonPressed(_ sender: NSButton) {
//		setUpRecognition(url: fileURL)
		extractAudioFromVideo(url: fileURL)
	}
	
	func setUpRecognition(url: URL!) {
		let asset = AVAsset(url: url)
		guard let audioTrack = asset.tracks(withMediaType: .audio).first else { return }
		
		recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
		recognitionRequest?.shouldReportPartialResults = true
		recognitionRequest?.taskHint = .dictation
		
		
		
	}
	
//	private func setupVideoPlayer() {
//		playerLayer.removeFromSuperlayer()
//		playerLayer = nil
//
//		guard playerLayer == nil else {
//			return
//		}
//		let playerLayer = AVPlayerLayer()
//
//		playerLayer.videoGravity = .resizeAspect
//		playerLayer.frame = playerView.bounds
//		playerView.clipsToBounds = true
//		playerView.layer.addSublayer(playerLayer)
//
//		self.playerLayer = playerLayer
//	}

	
	
	private func extractAudioFromVideo(url: URL) {
		let cacheURL = FileManager().getAppSupportDirectory()
		
		let asset = AVAsset(url: url)
//		guard let audioTrack = asset.tracks(withMediaType: .audio).first else { return }
		
		let preset = AVAssetExportPresetAppleM4A
		let outputFileType = AVFileType.m4a
		let filename = String(UUID().uuidString.split(separator: "-")[0])
		
		let outputFileURL = cacheURL.appendingPathComponent("\(filename).m4a")
		AVAssetExportSession.determineCompatibility(ofExportPreset: preset, with: asset, outputFileType: outputFileType) {[weak self] (isCompatible) in
			guard let self = self, isCompatible, let export = AVAssetExportSession(asset: asset, presetName: preset) else { return}
			export.outputFileType = outputFileType
			export.outputURL = outputFileURL
			export.exportAsynchronously {
				print(export.status)
				switch export.status {
					case .cancelled:
						print("cancelled")
					case .exporting:
						print("exporting")
					case .failed:
						print("failed")
					case .completed:
						DispatchQueue.main.async {
							self.handleCompletedAudioAssetExportSession(export)
							self.playVideo(url: url)
						}
					default:
						print("Default: \(export.status)")
						
				}
			}
		}
	}
	
	private func playVideo(url: URL) {
		videoPlayerView.isHidden = false
		let player = AVPlayer(url: url)
		videoPlayerView.player = player
		videoPlayerView.player?.play()
	}

	private func handleCompletedAudioAssetExportSession(_ exportSession: AVAssetExportSession) {
		guard let url = exportSession.outputURL else { return }
		performSpeechAnalysis(url: url)
	}

	private func performSpeechAnalysis(url: URL) {
		let request = SFSpeechURLRecognitionRequest(url: url)
		
		recognitionTask = speechRecognizer.recognitionTask(with: request) { (result, error) in
			if let error = error {
//				self.speechResultsViewController?.update(error as NSError)
				return
			}
			
			guard let result = result else {
				return
			}
			
			DispatchQueue.main.async {
				self.tickerLabel.stringValue = result.bestTranscription.formattedString
//				self.speechResultsViewController?.update(result.bestTranscription.formattedString, isFinal: result.isFinal)
			}
			
		}
	}

	
	
	
	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

