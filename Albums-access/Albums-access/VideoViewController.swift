//
//  VideoViewController.swift
//  Albums-access
//
//  Created by Solaborate on 1/28/20.
//  Copyright © 2020 Solaborate. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation


class VideoViewController: UIViewController {
    
    var videoURL:URL?
//12
    
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoDurationLabel: UILabel!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var isPlaying = false
    var player:AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoURL = videoURL else {
            return
        }
        player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        videoView.layer.addSublayer(playerLayer)
        player?.play()
        isPlaying = true

        player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
        let interval = CMTime(value: 1, timescale: 2)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
            let seconds = CMTimeGetSeconds(progressTime)
            if let duration = self.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                self.videoSlider.value = Float(seconds / durationSeconds)
                if seconds == durationSeconds {
                    self.isPlaying = false
                    self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                }
            }
        })
        }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == "currentItem.loadedTimeRanges" {
            playPauseButton.isHidden = false
            isPlaying = true

            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let seconsText = Int(seconds)%60
                let minutesText = String(format:"%02d", Int(seconds)/60)
                videoDurationLabel.text = "\(minutesText):\(seconsText)"
            }
        }
    }
    
    
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.player?.pause()
        }
    }
    @IBAction func playPauseHandler(_ sender: Any) {
        if isPlaying {
            player?.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal )
        } else {
            player?.play()
            playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    @IBAction func sliderHandler(_ sender: Any) {
        if isPlaying {
            self.player?.pause()
        }
    }
    
    @IBAction func didFinishDraggingSlider(_ sender: UISlider) {
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Double(videoSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime)
        }
        if isPlaying {
            player?.play()
        }
    }
    
}
