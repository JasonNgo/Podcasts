//
//  PlayerDetailView.swift
//  PodcastLBTA
//
//  Created by Jason Ngo on 2018-08-13.
//  Copyright © 2018 Jason Ngo. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

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
            
            setupNowPlaying()
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
            
            // mini player
            miniPlayerTitleLabel.text = episode.title
            // miniPlayerImageView.sd_setImage(with: url, completed: nil)
            
            miniPlayerImageView.sd_setImage(with: url) { (image, _, _, _) in
                
                let image = self.episodeImageView.image ?? UIImage()
                
                let artwork = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (_) -> UIImage in
                    return image
                })
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            }
            
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
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
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
        setupRemoteControlPlayer()
        setupAVAudioSession()
        setupPlayerBoundaryTimeObserver()
        setupPlayerPeriodicTimeObserver()
    }
    
    // MARK: - Setup Functions
    
    fileprivate func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        maximizedPlayerViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMaximizedPan))
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleExpand)))
        minimizedPlayerView.addGestureRecognizer(panGesture)
        maximizedStackView.addGestureRecognizer(maximizedPlayerViewPanGesture)
    }
    
    fileprivate func setupPlayerBoundaryTimeObserver() {
        let time = CMTimeMake(1, 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Started playing")
            self?.enlargeImageView()
            self?.updateLockScreenDurationTime()
        }
    }
    
    fileprivate func setupPlayerPeriodicTimeObserver() {
        let interval = CMTimeMake(1, 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            let displayString = time.toDisplayString()
            self?.currentTimeLabel.text = displayString
            self?.durationTimeLabel.text = self?.player.currentItem?.duration.toDisplayString()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func setupAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("There was an error activating the av audio session:", error)
        }
    }
    
    fileprivate func setupRemoteControlPlayer() {
        // start remote control observer
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // play button
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.updateLockScreenElapsedTime()
            self.player.play()

            return .success
        }
        
        // pause button
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.player.pause()
            self.updateLockScreenElapsedTime()
            
            return .success
        }
        
        // headphone play/pause
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPausePressed()
            return .success
        }
    }
    
    fileprivate func setupNowPlaying() {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func updateLockScreenDurationTime() {
        guard let currentItemDuration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(currentItemDuration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }
    
    fileprivate func updateLockScreenElapsedTime() {
        let elapsedTime = player.currentTime()
        let elapsedSeconds = CMTimeGetSeconds(elapsedTime)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedSeconds
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
