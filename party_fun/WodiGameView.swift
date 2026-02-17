import SwiftUI

struct WodiGameView: View {
    let game: Game
    @Binding var showPurchaseView: Bool 
    @State private var playerCount: Int = 4
    @State private var gameStage: WodiGameStage = .selectPlayers
    @State private var currentWodiCard: WodiCard?
    @State private var playerWords: [(index: Int, word: String, isSpy: Bool, isFlipped: Bool, isHidden: Bool)] = []
    @State private var rotationY: [Double] = []
    
    var body: some View {
     
         
                
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
                                Text("选择玩的人数")
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
                }
    }
    
    private func startGame() {
        guard !game.wodiCards.isEmpty else { return }
        
        currentWodiCard = game.wodiCards.randomElement()
        
        var words: [(index: Int, word: String, isSpy: Bool, isFlipped: Bool, isHidden: Bool)] = []
        
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
                words.append((index: i, word: word, isSpy: true, isFlipped: false, isHidden: false))
            } else {
                words.append((index: i, word: currentWodiCard!.normalWord, isSpy: false, isFlipped: false, isHidden: false))
            }
        }
        
        playerWords = words
        rotationY = Array(repeating: 0.0, count: playerCount)
        gameStage = .viewingCards
    }
    
    private func flipCard(at index: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
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
    
    private func checkAllCardsFlipped() {
        let allFlipped = playerWords.allSatisfy { $0.isHidden }
        if allFlipped {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gameStage = .selectPlayers
            }
        }
    }
    
    private func restartGame() {
        gameStage = .selectPlayers
        playerWords = []
        rotationY = []
    }
}

enum WodiGameStage {
    case selectPlayers
    case viewingCards
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
                    .frame(width: AppConfigs.cardWidth / 2 - 10, height: AppConfigs.cardHeight / 2)
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
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
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
