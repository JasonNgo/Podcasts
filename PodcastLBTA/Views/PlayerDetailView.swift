//
//  PlayerDetailView.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-13.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailView: UIView {
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate let shrinkTransformation = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
            
            playEpisode()
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var durationTimeLabel: UILabel!
    @IBOutlet var currentTimeSlider: UISlider!
    
    @IBOutlet var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            episodeImageView.transform = shrinkTransformation
        }
    }
    
    @IBOutlet var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPausePressed), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPausePressed() {
        print("play/pause button pressed")
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkImageVIew()
        } // if
    } // handlePlayPausedPressed
    
    // MARK: - IBActions
    
    @IBAction func handleCurrentTimeValueChanged(_ sender: UISlider) {
        guard let duration = player.currentItem?.duration else { return }
        
        let percentage = currentTimeSlider.value
        let durationSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = durationSeconds * Float64(percentage)
        let seekTime = CMTime(seconds: seekTimeInSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleRewindPressed(_ sender: UIButton) {
        seekToCurrentTimeWith(delta: -10)
    }
    
    @IBAction func handleFastForwardPressed(_ sender: UIButton) {
        seekToCurrentTimeWith(delta: 10)
    }
    
    @IBAction func handleVolumeValueChanged(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func handleDismissPressed(_ sender: UIButton) {
        let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        tabBarController?.minimizePlayerDetails()
    } // handleDismissPressed
    
    // MARK: - Lifecycle functions
    
    static func initFromNib() -> PlayerDetailView {
        return Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Started playing")
            self?.enlargeImageView()
        }
        
        observePlayerTime()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleExpand)))
    }
    
    @objc func handleExpand() {
        let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        tabBarController?.maximizePlayerDetails(episode: nil)
    }
    
    // MARK: Helper functions
    
    fileprivate func playEpisode() {
        print("Playing episode")
        
        guard let url = URL(string: episode.streamUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    } // playEpisode
    
    fileprivate func enlargeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    fileprivate func shrinkImageVIew() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrinkTransformation
        })
    }
    
    fileprivate func observePlayerTime() {
        let interval = CMTimeMake(1, 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            let displayString = time.toDisplayString()
            self?.currentTimeLabel.text = displayString
            self?.durationTimeLabel.text = self?.player.currentItem?.duration.toDisplayString()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
        
        let percentage = currentTimeSeconds / durationSeconds
        currentTimeSlider.value = Float(percentage)
    }
    
    fileprivate func seekToCurrentTimeWith(delta: Int64) {
        let currentTime = player.currentTime()
        let deltaTime = CMTimeMake(delta, 1)
        
        let seekTime = CMTimeAdd(currentTime, deltaTime)
        player.seek(to: seekTime)
    }

} // PlayerDetailView
