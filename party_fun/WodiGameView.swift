import SwiftUI

struct WodiGameView: View {
    let game: Game
    @Binding var showPurchaseView: Bool 
    @State private var playerCount: Int = 4
    @State private var gameStage: WodiGameStage = .selectPlayers
    @State private var currentWodiCard: WodiCard?
    @State private var playerWords: [(index: Int, word: String, isSpy: Bool, isFlipped: Bool, isChecked: Bool, isHidden: Bool)] = []
    @State private var rotationY: [Double] = []
    @State private var winner: WodiWinner = .none
    
    private var titleText: String {
        switch gameStage {
        case .selectPlayers:
            return "选择玩家人数"
        case .viewingCards:
            return "查看词语"
        case .checkResult:
            return "卧底判定"
        case .gameComplete:
            return "游戏结束"
        }
    }
    
    var body: some View {
        // 标题栏
        HStack {
            Spacer()
            Text(titleText)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(.vertical, 10)
            Spacer()
        }
        .padding()
        Spacer()        
        switch gameStage {
            case .selectPlayers:
                VStack() {
                    
                    ZStack {
                        CardBackView(
                            game: game,
                            rotationY: 0.0
                        )
                        
                        VStack {
                            Spacer()
                            Text("选择人数")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            HStack(spacing: 10) {
                                Button(action: {
                                    if playerCount > 3 {
                                        playerCount -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.yellow)
                                }
                                
                                Text("\(playerCount)")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 80)
                                
                                Button(action: {
                                    if playerCount < 12 {
                                        playerCount += 1
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.red)
                                }
                            }
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(20)
                        }
                        .padding(.bottom, 30)
                    }
                    Spacer().frame(height: 40)
                
                    ButtonView(
                        isActive: false,
                        onButtonTap: {
                            InAppPurchaseManager.shared.increaseUseTimes()
                            if InAppPurchaseManager.shared.shouldShowPurchaseAlert() {
                                showPurchaseView = true
                            } else {
                                startGame()
                            }
                        }
                    )
                }

                
            case .viewingCards:
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(playerWords.indices, id: \.self) { index in
                            if !playerWords[index].isHidden {
                                WodiCardView(
                                    playerIndex: index + 1,
                                    word: playerWords[index].word,
                                    rotationY: rotationY[index],
                                    isFlipped: playerWords[index].isFlipped,
                                    onTap: {
                                        flipCard(at: index)
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                }

            case .checkResult:
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(playerWords.indices, id: \.self) { index in
                            AnswerCardView(
                                playerIndex: index + 1,
                                role: playerWords[index].isSpy ? "卧底" : "平民",
                                cardColor: playerWords[index].isSpy ? Color.red : Color.green,
                                isChecked: playerWords[index].isChecked,
                                onTap: {
                                    checkCard(at: index)
                                }
                            )
                        }
                    }
                    .padding()
                }

            case .gameComplete:
                ZStack {
                    if let image = AppConfigs.loadImage(name: winner == .pingmin ? "won_pingmin.jpg" : "won_wodi.jpg") {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: AppConfigs.cardWidth)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 10)
                            )
                    }
                }
        }
    }
    
    private func startGame() {
        guard !game.wodiCards.isEmpty else { return }
        
        currentWodiCard = game.wodiCards.randomElement()
        
        var words: [(index: Int, word: String, isSpy: Bool, isFlipped: Bool, isChecked: Bool, isHidden: Bool)] = []
        
        let maxSpies = max(1, playerCount / 3)
        let spyCount = Int.random(in: 1...maxSpies)
        
        var spyIndices = Set<Int>()
        while spyIndices.count < spyCount {
            spyIndices.insert(Int.random(in: 0..<playerCount))
        }
        
        let showBlank = Double.random(in: 0...1) < 0.2
        for i in 0..<playerCount {
            if spyIndices.contains(i) {
                let word = showBlank ? "" : currentWodiCard!.spyWord
                words.append((index: i, word: word, isSpy: true, isFlipped: false, isChecked: false, isHidden: false))
            } else {
                words.append((index: i, word: currentWodiCard!.normalWord, isSpy: false, isFlipped: false, isChecked: false, isHidden: false))
            }
        }
        
        playerWords = words
        rotationY = Array(repeating: 0.0, count: playerCount)
        gameStage = .viewingCards
    }
    
    private func flipCard(at index: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            MusicPlayer.shared.playAudio(named: "flip_paper.m4a")
            rotationY[index] += 180
            playerWords[index].isFlipped.toggle()
        }
        
        if playerWords[index].isFlipped {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                playerWords[index].isHidden = true
                checkAllCardsFlipped()
            }
        }
    }

    private func checkCard(at index: Int) {
        playerWords[index].isChecked = true
        if playerWords[index].isSpy {
            MusicPlayer.shared.playAudio(named: "check.m4a")
        } else {
            MusicPlayer.shared.playAudio(named: "fail.m4a")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            checkAllWodiFound()
        }
    }

    private func checkAllWodiFound() {
        let pingminWon = playerWords.allSatisfy { !$0.isSpy || $0.isChecked }
        let uncheckedCount = playerWords.filter { !$0.isChecked }.count
        let wodiWon: Bool
        if playerCount < 6 {
            wodiWon = uncheckedCount <= 2
        } else {
            wodiWon = uncheckedCount <= 3
        }
        
        if pingminWon || wodiWon {
            winner = pingminWon ? .pingmin : .wodi
            gameStage = .gameComplete
            MusicPlayer.shared.playAudio(named: "game_end.m4a")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                restartGame()
            }
        }
    }
    
    private func checkAllCardsFlipped() {
        let allFlipped = playerWords.allSatisfy { $0.isHidden }
        if allFlipped {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gameStage = .checkResult
            }
        }
    }
    
    private func restartGame() {
        gameStage = .selectPlayers
        playerWords = []
        rotationY = []
        winner = .none
    }
}

enum WodiGameStage {
    case selectPlayers
    case viewingCards
    case checkResult
    case gameComplete
}

enum WodiWinner {
    case none
    case pingmin
    case wodi
}

struct AnswerCardView: View {
    let playerIndex: Int
    let role: String
    let cardColor: Color
    let isChecked: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor)
                .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)
                .shadow(radius: 10)
                .opacity(isChecked ? 1 : 0)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 2)
                )

            if let image = AppConfigs.loadImage(name: "wodi_answer.jpg") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow, lineWidth: 0.3)
                        }
                    )
                    .shadow(radius: 10)
                    .opacity(isChecked ? 0 : 1)
                  
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue)
                    .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)
                    .shadow(radius: 10)
                    .opacity(isChecked ? 0 : 1)
            }
            
            VStack {
                Text("第 \(playerIndex) 位")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(isChecked ? 0 : 1)
                Spacer()
                Text(role)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .opacity(isChecked ? 1 : 0)
                Spacer()
                Text("点击判定")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(isChecked ? 0 : 1)
            }
            .padding(.vertical, 15)
        }
        .onTapGesture {
            onTap()
        }
    }
}


struct WodiCardView: View {
    let playerIndex: Int
    let word: String
    let rotationY: Double
    let isFlipped: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)
                .shadow(radius: 10)
                .rotation3DEffect(
                    Angle(degrees: rotationY),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isFlipped ? 1 : 0)

            if let image = AppConfigs.loadImage(name: "wodi_back.jpg") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.yellow, lineWidth: 0.3)
                        }
                    )
                    .shadow(radius: 10)
                    .rotation3DEffect(
                        Angle(degrees: rotationY),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(isFlipped ? 0 : 1)
                  
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue)
                    .frame(width: AppConfigs.gameCoverWidth, height: AppConfigs.gameCoverHeight)
                    .shadow(radius: 10)
                    .rotation3DEffect(
                        Angle(degrees: rotationY),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(isFlipped ? 0 : 1)
            }
            
            VStack(spacing: 10) {
                Text("第 \(playerIndex) 位")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .rotation3DEffect(
                        Angle(degrees: rotationY),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(isFlipped ? 0 : 1)
                
                Text(word.isEmpty ? "" : word)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .rotation3DEffect(
                        Angle(degrees: rotationY + 180),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(isFlipped ? 1 : 0)

                Text("点击查看")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .rotation3DEffect(
                        Angle(degrees: rotationY),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(isFlipped ? 0 : 1)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}
