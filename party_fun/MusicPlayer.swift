import AVFoundation

class MusicPlayer: NSObject, AVAudioPlayerDelegate {
    // 单例实例
    static let shared = MusicPlayer()
    
    // 私有化初始化方法，确保只能通过shared访问
    private override init() {
        super.init()
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    // 播放指定名字的音频文件
    func playAudio(named fileName: String) {
        // 确保文件名有效
        guard !fileName.isEmpty else {
            print("音频文件名不能为空")
            return
        }

        // 解析文件名和扩展名
        let components = fileName.split(separator: ".")
        if components.count != 2 {
            print("无效的音频名称格式: \(fileName)")
            return
        }
        
        let name = String(components[0])
        let ext = String(components[1])
        
        if let path = Bundle.main.path(forResource: name, ofType: ext) {
            initializePlayer(withFilePath: path)
        } else {
            print("找不到名为\(fileName)的音频文件")
            return
        }  
    }
    
    // 初始化音频播放器
    private func initializePlayer(withFilePath filePath: String) {
        do {
            // 先停止当前正在播放的音频，防止干扰
            stopAudio()
            
            // 设置音频会话类别，允许在后台播放
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 创建音频播放器
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            audioPlayer?.delegate = self
            
            // 准备并播放音频
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            //print("开始播放音频文件")
        } catch {
            print("初始化音频播放器失败: \(error.localizedDescription)")
            audioPlayer = nil
        }
    }
    
    // 停止播放
    func stopAudio() {
        if let player = audioPlayer, player.isPlaying {
            player.stop()
            //print("停止播放音频")
        }
        
        // 重置音频会话状态
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("关闭音频会话失败: \(error.localizedDescription)")
        }
    }
    
    // 暂停播放
    func pauseAudio() {
        if let player = audioPlayer, player.isPlaying {
            player.pause()
            //print("暂停播放音频")
        }
    }
    
    // 继续播放
    func resumeAudio() {
        if let player = audioPlayer, !player.isPlaying {
            player.play()
            //print("继续播放音频")
        }
    }
    
    // 检查是否正在播放
    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    // AVAudioPlayerDelegate 方法
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("音频播放完成")
        } else {
            print("音频播放未成功完成")
        }
        
        // 播放完成后重置音频会话状态
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("关闭音频会话失败: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("音频解码错误: \(error.localizedDescription)")
        }
    }
}
