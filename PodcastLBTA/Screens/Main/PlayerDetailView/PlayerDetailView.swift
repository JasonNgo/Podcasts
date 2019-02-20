/***
 Copyright (c) 2018 Jason Ngo
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 ***/

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
    // MARK: - Subviews
    
    // MARK: Mini Player
    @IBOutlet var minimizedPlayerView: UIView!
    @IBOutlet var miniPlayerImageView: UIImageView!
    @IBOutlet var miniPlayerTitleLabel: UILabel!
    @IBOutlet var miniPlayerRewindButton: UIButton!
    @IBOutlet var miniPlayerPlayPauseButton: UIButton!

    // MARK: Full Player
    @IBOutlet var maximizedStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var durationTimeLabel: UILabel!
    @IBOutlet var currentTimeSlider: UISlider!
    @IBOutlet var episodeImageView: UIImageView!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var playPauseButton: UIButton!
    
    // MARK: - AVPlayer
    private let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    // MARK: - Gestures
    private var panGesture: UIPanGestureRecognizer!
    private var maximizedPlayerViewPanGesture: UIPanGestureRecognizer!
    private let shrinkTransformation = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    // MARK: - Model
    var playlistEpisodes = [Episode]()
    
    var episode: Episode! {
        didSet {
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            
            setupNowPlaying()
            
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
            
            // mini player
            miniPlayerTitleLabel.text = episode.title
            miniPlayerImageView.sd_setImage(with: url) { (image, _, _, _) in
                let image = self.episodeImageView.image ?? UIImage()
                let artwork = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (_) -> UIImage in
                    return image
                })
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
            }
            
            setupAVAudioSession()
            playEpisode()
        }
    }
    
    // MARK: - Initializer
    
    static func initFromNib() -> PlayerDetailView {
        return Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupSubviews()
        setupTargets()
        setupGestures()
        setupRemoteControlPlayer()
        setupPlayerBoundaryTimeObserver()
        setupPlayerPeriodicTimeObserver()
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        episodeImageView.layer.cornerRadius = 5
        episodeImageView.transform = shrinkTransformation
        
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    private func setupTargets() {
        dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(handlePlayPausePressed), for: .touchUpInside)
        
        // mini player
        miniPlayerRewindButton.addTarget(self, action: #selector(handleRewindPressed(_:)), for: .touchUpInside)
        miniPlayerPlayPauseButton.addTarget(self, action: #selector(handlePlayPausePressed), for: .touchUpInside)
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        maximizedPlayerViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleMaximizedPan))
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleExpand)))
        minimizedPlayerView.addGestureRecognizer(panGesture)
        maximizedStackView.addGestureRecognizer(maximizedPlayerViewPanGesture)
    }
    
    private func setupPlayerBoundaryTimeObserver() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("Started playing")
            self?.enlargeImageView()
            self?.updateLockScreenDurationTime()
        }
    }
    
    private func setupPlayerPeriodicTimeObserver() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            let displayString = time.toDisplayString()
            self?.currentTimeLabel.text = displayString
            self?.durationTimeLabel.text = self?.player.currentItem?.duration.toDisplayString()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    private func setupAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .interruptSpokenAudioAndMixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("There was an error activating the av audio session:", error)
        }
    }
    
    private func setupRemoteControlPlayer() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.updateLockScreenElapsedTime(playbackRate: 1)
            self.player.play()
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.player.pause()
            self.updateLockScreenElapsedTime(playbackRate: 0)
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPausePressed()
            return .success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrackPressed))
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrackPressed))
    }
    
    private func setupNowPlaying() {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification , object: nil)
    }
    
    // MARK: - IB Actions
    
    @IBAction private func handleCurrentTimeValueChanged(_ sender: UISlider) {
        guard let duration = player.currentItem?.duration else { return }
        
        let percentage = currentTimeSlider.value
        let durationSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = durationSeconds * Float64(percentage)
        let seekTime = CMTime(seconds: seekTimeInSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        
        player.seek(to: seekTime)
    }
    
    @IBAction private func handleRewindPressed(_ sender: UIButton) {
        seekToCurrentTimeWith(delta: -10)
    }
    
    @IBAction private func handleFastForwardPressed(_ sender: UIButton) {
        seekToCurrentTimeWith(delta: 10)
    }
    
    @IBAction private func handleVolumeValueChanged(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    // MARK: - Selector Functions
    
    @objc func handleDismiss() {
        NotificationCenter.default.post(name: .minimizePlayer, object: nil, userInfo: nil)
    }
    
    // MARK: Player Selectors
    
    @objc private func handlePlayPausePressed() {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            updateLockScreenElapsedTime(playbackRate: 1)
            enlargeImageView()
        } else {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            updateLockScreenElapsedTime(playbackRate: 0)
            shrinkImageVIew()
        }
    }
    
    @objc func handleNextTrackPressed() {
        print("Next track pressed")
        
        guard playlistEpisodes.count > 0 else { return }
        let currentEpisodeIndex = playlistEpisodes.index(of: self.episode)
        
        guard var index = currentEpisodeIndex else { return }
        if index == playlistEpisodes.count - 1 {
            index = 0
        }
        
        episode = playlistEpisodes[index]
    }
    
    @objc func handlePrevTrackPressed() {
        print("Prev track pressed")
        
        guard playlistEpisodes.count > 0 else { return }
        let currentEpisodeIndex = playlistEpisodes.index(of: self.episode)
        
        guard var index = currentEpisodeIndex else { return }
        if index == 0 {
            index = playlistEpisodes.count - 1
        }
        
        let newEpisode = playlistEpisodes[index]
        episode = newEpisode
    }
    
    @objc func handleInterruption(notification: Notification) {
        print("handle interruption")
        
        guard
            let userInfo = notification.userInfo,
            let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt
            else {
                return
        }
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                miniPlayerPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func playEpisode() {
        print("Playing episode")
        
        var playerItem: AVPlayerItem?
        
        if let fileUrlString = episode.fileUrl {
            guard let fileUrl = URL(string: fileUrlString) else { return }
            let fileName = fileUrl.lastPathComponent
            
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            trueLocation.appendPathComponent(fileName)
            
            playerItem = AVPlayerItem(url: trueLocation)
        } else {
            guard let url = URL(string: episode.streamUrl) else { return }
            playerItem = AVPlayerItem(url: url)
        }
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    // MARK: LockScreen Helpers
    
    private func updateLockScreenDurationTime() {
        guard let currentItemDuration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(currentItemDuration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }
    
    private func updateLockScreenElapsedTime(playbackRate: Float) {
        let elapsedTime = player.currentTime()
        let elapsedSeconds = CMTimeGetSeconds(elapsedTime)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedSeconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    // MARK: Thumbnail Helpers
    
    private func enlargeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    private func shrinkImageVIew() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrinkTransformation
        })
    }
    
    // MARK: AV Player Helper Functions
    
    private func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        currentTimeSlider.value = Float(percentage)
    }
    
    private func seekToCurrentTimeWith(delta: Int64) {
        let currentTime = player.currentTime()
        let deltaTime = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(currentTime, deltaTime)
        player.seek(to: seekTime)
    }
    

}
