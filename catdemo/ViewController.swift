//
//  ViewController.swift
//  catdemo
//
//  Created by Justin Brady on 11/11/22.
//

import UIKit
import AVKit
import FirebaseAnalytics

class ViewController: UICollectionViewController {
    
    let viewModel: CatsViewModelProtocol = CatsViewModel()
    var player: AVAudioPlayer!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [:])
        
        collectionView.register(CatsViewCell.self, forCellWithReuseIdentifier: "collectionViewReuseId")
        
        // adjust collectionView spacing to fit cells into grid
        collectionView.contentInset = .init(top: 8, left: 8, bottom: 8, right: 8)//layoutMargins = .init(top: 16, left: 8, bottom: view.frame.height - 16, right: view.frame.width - 8)
        let len = view.frame.width / 5
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: len, height: len)
        
        viewModel.prepareGame()
        
        collectionView.reloadData()
        
        viewModel.onTick() {
            [weak self] in
            self?.collectionView.reloadData()
        }
        
        initScoreView()
        
        initBtnView()
    }
    
    func initScoreView() {
        let l = UILabel(frame: CGRect(x: 0, y: collectionView.frame.height-256, width: collectionView.frame.width, height: 48))

        collectionView.insertSubview(l, at: 0)
        
        l.textAlignment = .center
        
        viewModel.onScore { vm in
            l.text = vm.countdown < 0 ? "Score: \(vm.score)" : "Matching begins in \(vm.countdown)..."
        }
    }
    
    func initBtnView() {
        let b = UIButton(frame: CGRect(x: 0, y: collectionView.frame.height - 200, width: collectionView.frame.width, height: 64))
        b.addTarget(self, action: #selector(onRestartTap), for: .touchDown)
        b.setTitle("Restart", for: .normal)
        b.setTitleColor(UIColor.blue, for: .normal)
        collectionView.insertSubview(b, at: 0)
    }
    
    @objc func onRestartTap() {
        viewModel.restart()
    }
}

// UICollectionViewDataSource
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.n
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewReuseId", for: indexPath) as! CatsViewCell
        
        let shufIdx = viewModel.catsShuffled[indexPath.item]
        
        if let bucket = viewModel.cats[shufIdx] {

            if !viewModel.catsRevealed.contains(shufIdx) {
                cell.imageView.image = UIImage(named: "cardback")
            }
            else {
                cell.imageView.image = bucket.image
            }
        }
        
        return cell
    }
}

// UICollectionViewDelegate
extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let result = viewModel.selectItem(indexPath.item)
        if result == .MATCHED {
            // success
            player = try? AVAudioPlayer(contentsOf: URL(string: Bundle.main.path(forResource: "yay.mp3", ofType: nil)!)!)
            player.play()
        }
        else if result == .NOMATCH {
            // womp womp
            player = try? AVAudioPlayer(contentsOf: URL(string: Bundle.main.path(forResource: "fail.mp3", ofType: nil)!)!)
            player.play()
        }
        else {
            return
        }
    }
}
