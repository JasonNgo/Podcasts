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
    
    var panGesture: UIPanGestureRecognizer!
    var maximizedPlayerViewPanGesture: UIPanGestureRecognizer!
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
            
            // mini player
            miniPlayerTitleLabel.text = episode.title
            miniPlayerImageView.sd_setImage(with: url, completed: nil)
            
            playEpisode()
        }
    }
    
    // MARK: IBOutlets
    
    // Mini player
    @IBOutlet var minimizedPlayerView: UIView!
    @IBOutlet var maximizedStackView: UIStackView!
    
    @IBOutlet var miniPlayerImageView: UIImageView!
    @IBOutlet var miniPlayerTitleLabel: UILabel!
    
    @IBOutlet var miniPlayerRewindButton: UIButton! {
        didSet {
            miniPlayerRewindButton.addTarget(self, action: #selector(handleRewindPressed(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet var miniPlayerPlayPauseButton: UIButton! {
        didSet {
            miniPlayerPlayPauseButton.addTarget(self, action: #selector(handlePlayPausePressed), for: .touchUpInside)
        }
    }
    
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
    
    @IBOutlet var dismissButton: UIButton! {
        didSet {
            dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        }
    }
    
    @IBOutlet var playPauseButton: UIButton! {
        didSet {
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseButton.addTarget(self, action: #selector(handlePlayPausePressed), for: .touchUpInside)
        }
    }
    
    @objc func handlePlayPausePressed() {
        print("play/pause button pressed")
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            shrinkImageVIew()
        } // if
    } // handlePlayPausedPressed
    
    // MARK: - IB Actions
    
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
    
    // MARK: - Lifecycle Functions
    
    static func initFromNib() -> PlayerDetailView {
        return Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestures()
        setupPlayerTimeObserver()
    }
    
    // MARK: - Setup Functions
    
    fileprivate func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        maximizedPlayerViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMaximizedPan))
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleExpand)))
        minimizedPlayerView.addGestureRecognizer(panGesture)
        maximizedStackView.addGestureRecognizer(maximizedPlayerViewPanGesture)
    }
    
    fileprivate func setupPlayerTimeObserver() {
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Started playing")
            self?.enlargeImageView()
        }
        
        let interval = CMTimeMake(1, 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            let displayString = time.toDisplayString()
            self?.currentTimeLabel.text = displayString
            self?.durationTimeLabel.text = self?.player.currentItem?.duration.toDisplayString()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    // MARK: - Helper Functions
    
    fileprivate func playEpisode() {
        print("Playing episode")
        
        guard let url = URL(string: episode.streamUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    } // playEpisode
    
    // MARK: ImageView Helper Functions
    
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
    
    // MARK: AV Player Helper Functions
    
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
    
    // MARK: Selector Functions
    
    @objc func handleDismiss() {
        UIApplication.mainTabBarController()?.minimizePlayerDetails()
    } // handleDismissPressed
    

} // PlayerDetailView
