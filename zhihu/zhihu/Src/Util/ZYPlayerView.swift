//
//  ZYPlayerView.swift
//  ZYLight
//
//  Created by yfm on 2023/1/30.
//

import UIKit
import AVFoundation

enum ZYPlayerStatus {
    case unknow
    case playing
    case pause
    case fail
    case finished
}

typealias TimeDidChanged = (_ currentTime: TimeInterval, _ duration: TimeInterval) -> ()
typealias BufferTimeDidChanged = (_ bufferTime: TimeInterval, _ duration: TimeInterval) -> ()
typealias PlayStatusDidChanged = (_ status: ZYPlayerStatus) -> ()
typealias BuffingBlock = (_ buffing: Bool) -> ()

class ZYPlayerView: UIView {
    var repeatPlay: Bool = true
    var silenceVolume: Bool = false
    var enableCloseBackAwaken: Bool = false
    var shouldAutoPlay: Bool = true
    var timeDidChanged: TimeDidChanged?
    var bufferTimeDidChanged: BufferTimeDidChanged?
    var playStatusDidChanged: PlayStatusDidChanged?
    var buffingBlock: BuffingBlock?
    var isFirstPlay: Bool = false
    var timeObserver: Any?
    
    fileprivate var urlAsset: AVURLAsset?
    fileprivate var playerItem: AVPlayerItem?
    fileprivate var player: AVPlayer?
    fileprivate var playerLayer: AVPlayerLayer?
    
    fileprivate var videoUrl: URL?
    
    var isPlaying: Bool {
        return playStatus == .playing
    }
    
    var volume: Float = 0.4 {
        didSet {
            player?.volume = volume
        }
    }
    
    var videoGravity: AVLayerVideoGravity = .resizeAspect {
        didSet {
            playerLayer?.videoGravity = videoGravity
        }
    }
    
    var asset: AVURLAsset? {
        didSet {
            if asset == nil || asset == urlAsset { return }
            videoUrl = asset?.url
            urlAsset = asset
            isFirstPlay = true
            reset()
            prepareToPlay()
        }
    }
    
    var playStatus: ZYPlayerStatus = .unknow {
        didSet {
            playStatusDidChanged?(playStatus)
        }
    }
    
    deinit {
        reset()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    func commonInit() {
        addNoti()
    }
    
    func reset() {
        player?.pause()
        removeObserver()
        playerItem = nil
        playerLayer?.removeFromSuperlayer()
        player?.cancelPendingPrerolls()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    func prepareToPlay() {
        guard let asset = urlAsset else { return }
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.preferredForwardBufferDuration = 5
        addObserver()
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        player?.automaticallyWaitsToMinimizeStalling = false
        guard let playerLayer = playerLayer else { return }
        layer.insertSublayer(playerLayer, at: 0)
        player?.volume = silenceVolume ? 0.0 : 0.4
        addPlayerItemTimeObserver()
    }
    
    func play() {
        if player?.currentItem?.status == .failed, let url = videoUrl {
            let asset = AVURLAsset(url: url)
            self.asset = asset
            player?.play()
        }
        playStatus = .playing
        player?.play()
    }
    
    func pause() {
        if playStatus == .playing {
            playStatus = .pause
            player?.pause()
        }
    }
    
    func seekToTime(time: TimeInterval) {
        guard let timescale = playerItem?.asset.duration.timescale else { return }
        playerItem?.cancelPendingSeeks()
        player?.seek(to: CMTimeMakeWithSeconds(time, preferredTimescale: timescale))
    }
    
    func isRemoteVideo() -> Bool {
        guard let scheme = self.asset?.url.scheme else { return false }
        if scheme.contains("http") ||
            scheme.contains("https") ||
            scheme.contains("scheming") {
            return true
        }
        return false
    }
    
    func availableDuration() -> TimeInterval {
        guard let player = player, let playerItem = playerItem else { return 0.0 }
        let timeRangeArray = playerItem.loadedTimeRanges
        let currentTime = player.currentTime()
        var foundRange = false
        var aTimeRange: CMTimeRange = .zero
        if timeRangeArray.count > 0 {
            aTimeRange = timeRangeArray[0].timeRangeValue
            if CMTimeRangeContainsTime(aTimeRange, time: currentTime) {
                foundRange = true
            }
        }
        
        if foundRange {
            let maxTime = CMTimeRangeGetEnd(aTimeRange)
            let playableDuration = CMTimeGetSeconds(maxTime)
            if playableDuration > 0 {
                return playableDuration
            }
        }
        
        return 0.0
    }
}

extension ZYPlayerView {
    func addObserver() {
        playerItem?.addObserver(self, forKeyPath: "status",options: [.new, .old], context: nil)
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges",options: [.new, .old], context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty",options: [.new, .old], context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp",options: [.new, .old], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playDidFinished), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func removeObserver() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if UIApplication.shared.applicationState != .active { return }
        guard let keyPath = keyPath else { return }
        if keyPath == "status" {
            let item = object as? AVPlayerItem
            if let status = item?.status {
                switch status {
                case .unknown:
                    playStatus = .unknow
                case .readyToPlay:
                    if shouldAutoPlay {
                        if isFirstPlay {
                            play()
                            isFirstPlay = false
                        }
                    }
                case .failed:
                    playStatus = .fail
                    if let error = playerItem?.error {
                        print("播放失败：\(error.localizedDescription)")
                    }
                default:
                    playStatus = .unknow
                }
            }
        } else if keyPath == "loadedTimeRanges" {
            if let timeRanges = playerItem?.loadedTimeRanges,
                let timeRange = timeRanges.first?.timeRangeValue {
                let bufferTime = CMTimeRangeGetEnd(timeRange)
                let duration = CMTimeGetSeconds(playerItem?.duration ?? .zero)
                let curBufferTime = CMTimeGetSeconds(bufferTime)
                bufferTimeDidChanged?(TimeInterval(curBufferTime), TimeInterval(duration))
            }
        } else if keyPath == "playbackBufferEmpty" {
            if playerItem?.isPlaybackLikelyToKeepUp == true {
                play()
                if playerItem?.isPlaybackLikelyToKeepUp == false {
                    pause()
                }
            }
        } else if keyPath == "playbackLikelyToKeepUp" {
            if playerItem?.isPlaybackLikelyToKeepUp == true {
                if isPlaying { play() }
            }
        }
    }
    
    func addPlayerItemTimeObserver() {
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(self?.playerItem?.duration ?? CMTime.zero)
//            print("time=\(currentTime), duration=\(duration)")
            self?.timeDidChanged?(TimeInterval(currentTime), TimeInterval(duration))
        })
    }
    
    @objc func playDidFinished() {
        playStatus = .finished
        seekToTime(time: 0)
        if repeatPlay { play() }
    }
    
    func addNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func willResignActive() {
        pause()
    }
    
    @objc func didBecomeActive() {
        if !enableCloseBackAwaken { play() }
    }
}
