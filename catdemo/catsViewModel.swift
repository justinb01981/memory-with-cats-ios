//
//  catsViewModel.swift
//
//
//  Created by Justin Brady on 11/11/22.
//

import Foundation
import UIKit
import AVKit

fileprivate let countdownStart = 10

enum SelectResult: Int {
    case INVALID
    case MATCHED
    case NOMATCH
}

protocol CatsViewModelProtocol: UICollectionViewDelegate {
    func asyncFetchCat(then thenDo: @escaping (UIImage) -> Void)
    func onTick(_ thenDo: @escaping () -> Void)
    func prepareGame()
    func restart()
    func onScore(_ doThis: @escaping (CatsViewModelProtocol) -> Void)
    func selectItem(_ at: Int) -> SelectResult
    
    var n: Int{ get }
    var cats: [Int: CatCard] { get }
    var catsShuffled: [Int] { get }
    var catsRevealed: Set<Int> { get }
    var score: Int { get }
    var countdown: Int { get }
}

class CatsViewModel: NSObject, CatsViewModelProtocol {
    
    var n = 16
    var cats: [Int: CatCard] = [:]
    var catsShuffled: [Int] = []
    var catsRevealed: Set<Int> = []
    var score = 0
    var countdown = countdownStart
    
    private var tickDo: (() -> Void)?
    private var selectionCount = 0
    private var lastReveal: Int?
    private var onScoreNotify: ((CatsViewModelProtocol) -> Void)?
    
    func asyncFetchCat(then thenDo: @escaping (UIImage) -> Void) {
        //https://cataas.com/
        
        URLSession.shared.downloadTask(with: URLRequest(url: URL(string: "https://cataas.com/cat")!), completionHandler: {
            optUrlToFile, optResponse, optError in
            
            let reportFail: () -> Void = {
                DispatchQueue.main.async {
                    thenDo(UIImage())
                }
            }
            
            guard let urlToFile = optUrlToFile
                else {
                reportFail()
                return
            }
            
            var pendingData = Data()
            
            if let data = try? Data(contentsOf: urlToFile) {
                pendingData.append(data)
            }
            else {
                reportFail()
            }
                
            DispatchQueue.main.async {
                if let img = UIImage(data: pendingData) {
                    thenDo(img)
                }
                else {
                    thenDo(UIImage())
                    
                }
            }
        }).resume()
    }

    func prepareGame() {
        
        cats.removeAll()
        catsShuffled.removeAll()
        for k in 0..<n {
            catsRevealed = catsRevealed.union([k])
        }

        selectionCount = 0
        score = 0
        
        for idx in 0..<n/2 {
            // same image + ID, shuffled later
            cats[idx] = CatCard()
            cats[idx%n + (n/2)] = cats[idx]
        }
        
        while catsShuffled.count != n {
            let idx = Int(arc4random()) % n
            if !catsShuffled.contains(Int(idx)) {
                catsShuffled += [ Int(idx) ]
            }
        }
        
        countdown = countdownStart
    }
    
    func onTick(_ thenDo: @escaping () -> Void) {
        
        if tickDo == nil {
            tickDo = thenDo
        }
        
        DispatchQueue(label: "timer").asyncAfter(deadline: .now()+1) { [weak self] in
            
            self?.onTick() {
                // HACK: ignored after first call
            }
            
            if self?.countdown == 0 {
                self?.catsRevealed = []
                
                self?.countdown = -1
                
                if let strongSelf = self {
                    DispatchQueue.main.async {
                        strongSelf.onScoreNotify?(strongSelf)
                    }
                }
            }
            else {
                self?.countdown -= 1
            }
            
            DispatchQueue.main.async {
                self?.tickDo?()
            }
        }
    }
    
    func onScore(_ doThis: @escaping (CatsViewModelProtocol) -> Void) {
        onScoreNotify = doThis
        
        onScoreNotify?(self)
    }
    
    func restart() {
        prepareGame()
        
        onScoreNotify?(self)
    }
    
    func selectItem(_ idx: Int) -> SelectResult {
        let shuff = catsShuffled[idx] // 0-16 shuffled slots for 8 unique cards in shuff + catsRevealed
        
        if catsRevealed.contains(shuff) {
            // item already selected, ignore
            return SelectResult.INVALID
        }
        
        for revealIdx in catsRevealed {
            if cats[revealIdx] == cats[shuff] {
                if selectionCount%2 == 0 {
                    
                    print("FAIL (already flipped)")
                    
                    selectionCount = 0
                    catsRevealed = catsRevealed.union([shuff])
                    lastReveal = shuff
                    return SelectResult.NOMATCH
                }
            }
        }
        
        catsRevealed = catsRevealed.union([shuff])
        
        var result: SelectResult = .INVALID
        
        if selectionCount % 2 != 0 {
            
            if cats[lastReveal!]!.id == cats[shuff]!.id {
                // on odd taps, award points
                score += 1
                print("YES! score: \(score)")
                result = .MATCHED
            }
            else {
                // womp womp
                print("FAIL!")
                result = .NOMATCH
            }
        }
        
        lastReveal = shuff
        
        // TODO: reload cell
        
        selectionCount += 1
        
        self.onScoreNotify?(self)
        
        return result
    }
}
