//
//  VideoLauncher.swift
//  chats
//
//  Created by Andy Fang on 6/9/20.
//  Copyright © 2020 Andy Fang. All rights reserved.
//

import UIKit
import AVFoundation

class VideoLauncher: NSObject {
    
    
    
    func showVideoPlayer(cellFrame: CGRect, urlString: String) {
        print("Showing video")
        
        if let keyWindow = UIApplication.shared.keyWindow {
        
            let view = UIView(frame: keyWindow.frame)
            
            let videoPlayer = VideoPlayerView(frame: keyWindow.frame, urlString: urlString)
            view.addSubview(videoPlayer)
            
            view.backgroundColor = UIColor.black
            
            view.frame = cellFrame
            
            keyWindow.addSubview(view)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                view.frame = keyWindow.frame
                
            }) { (completedAnimation) in
                UIApplication.shared.setStatusBarHidden(true, with: .fade)
            }
        }
        
    }
    
}


class VideoPlayerView: UIView {
    
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        return view
    }()
    
    let controlsContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    var isPlaying = false
    
    lazy var playbackButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "pause")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handlePause() {
        if isPlaying {
            player?.pause()
            let image = UIImage(named: "play")
            playbackButton.setImage(image, for: .normal)
        } else {
            if scrubber.value >= 1 {
                let restart = CMTime(value: 0, timescale: 1)
                player?.seek(to: restart, completionHandler: { (completed) in
                    print("restarted")
                })
            }
            player?.play()
            let image = UIImage(named: "pause")
            playbackButton.setImage(image, for: .normal)
        }
        isPlaying = !isPlaying

        
    }
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    lazy var scrubber: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = UIColor(r: 122, g: 197, b: 254)
        slider.maximumTrackTintColor = .white
        slider.thumbTintColor = UIColor(r: 122, g: 197, b: 254)
        slider.addTarget(self, action: #selector(handleScrubbing), for: .valueChanged)
        return slider
    }()
    
    @objc func handleScrubbing() {
        
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let time = Float64(scrubber.value) * totalSeconds
            let seekTime = CMTime(value: Int64(time), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completeSeek) in
                print("Hi")
            })
        }
    }
    
    init(frame: CGRect, urlString: String) {
        super.init(frame: frame)
        
        setupPlayerView(urlString: urlString)
        
        controlsContainerView.frame = frame
        addSubview(controlsContainerView)
        
        
        controlsContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        controlsContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        controlsContainerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        controlsContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        controlsContainerView.addSubview(videoLengthLabel)
        videoLengthLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -8).isActive = true
        videoLengthLabel.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor).isActive = true
        videoLengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        controlsContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -8).isActive = true
        currentTimeLabel.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: 8).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        controlsContainerView.addSubview(playbackButton)
        playbackButton.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -6).isActive = true
        playbackButton.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor, constant: 3).isActive = true
        playbackButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        playbackButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        controlsContainerView.addSubview(scrubber)
        scrubber.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
        scrubber.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -6).isActive = true
        scrubber.leftAnchor.constraint(equalTo: playbackButton.rightAnchor, constant: 6).isActive = true
        
        controlsContainerView.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor).isActive = true
        
        backgroundColor = UIColor.black
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var player: AVPlayer?
    
    func setupPlayerView(urlString: String) {
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            
            let playerLayer = AVPlayerLayer(player: player)
            self.layer.addSublayer(playerLayer)
            playerLayer.frame = self.frame
            playerLayer.videoGravity = .resizeAspectFill
            player?.play()
            
            player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
            
            let interval = CMTime(value: 1, timescale: 2)
            player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progress) in
                
                let seconds = CMTimeGetSeconds(progress)
                let secText = Int(seconds) % 60 < 10 ? "0\(Int(seconds) % 60)" : "\(Int(seconds) % 60)"
                let minText =  Int(floor(seconds/60)) < 10 ? "0\(Int(floor(seconds/60)))" : "\(Int(floor(seconds/60)))"
                
                self.currentTimeLabel.text = "\(minText):\(secText)"
                
                if let duration = self.player?.currentItem?.duration {
                    let durSec = CMTimeGetSeconds(duration)
                    self.scrubber.value = Float(seconds/durSec)
                    if self.scrubber.value >= 1 {
                        self.isPlaying = false
                        self.playbackButton.setImage(UIImage(named: "play"), for: .normal)
                    }
                }
            })
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clear
            isPlaying = true
            
            if let duration = player?.currentItem?.duration {
                let totalSeconds = CMTimeGetSeconds(duration)
                
                let seconds = Int(totalSeconds) % 60
                let minutes = Int(floor(totalSeconds / 60))
                
                let secText = seconds < 10 ? "0\(seconds)" : "\(seconds)"
                let minText = minutes < 10 ? "0\(minutes)" : "\(minutes)"
                
                videoLengthLabel.text = "\(minText):\(secText)"
            }
        }
    }
    
}
