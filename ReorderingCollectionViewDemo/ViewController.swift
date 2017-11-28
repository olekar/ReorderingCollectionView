//
//  ViewController.swift
//  ReorderingCollectionViewDemo
//
//  Created by Oleksii Karzov on 11/28/17.
//  Copyright © 2017 olekar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: ReorderingCollectionView!
    
    fileprivate var dataArray = [1, 2, nil, nil, 3, 4, nil, 5, nil, 6, nil, 7, 8, 9, 10, nil, nil, nil, 11, nil, nil]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logDataArray()
        
        collectionView.reorderingDataSource = self
//        collectionView.isCustomReordering = false
        setupCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupCollectionView()
    }
    
    fileprivate func setupCollectionView() {
        let baseSize = collectionView.bounds
        let numberOfCellsInRow = (UIDevice.current.userInterfaceIdiom == .pad) ? 6 : 4
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let emptySpaceInRow = layout.sectionInset.left + layout.sectionInset.right + CGFloat(numberOfCellsInRow - 1) * layout.minimumInteritemSpacing
        let cellWidth = (baseSize.width - emptySpaceInRow) / CGFloat(numberOfCellsInRow)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        collectionView.collectionViewLayout = layout
    }
    
    func logDataArray() {
        var logStr = "["
        for value in dataArray {
            if let value = value {
                logStr += " \(value),"
            } else {
                logStr += " nil,"
            }
        }
        
        logStr.remove(at: logStr.index(logStr.startIndex, offsetBy: logStr.characters.count - 1))
        logStr += "]"
        
        print(logStr)
    }

}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let value = dataArray[indexPath.item] {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            
            if let label = cell.contentView.subviews.first as? UILabel {
                label.text = "\(value)"
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = dataArray.remove(at: sourceIndexPath.item)
        dataArray.insert(item, at: destinationIndexPath.item)
        
        logDataArray()
    }
    
    func collectionView(_ collectionView: UICollectionView, swapItemAt indexPath1: IndexPath, withItemAt indexPath2: IndexPath) {
        let tmpItem = dataArray[indexPath1.item]
        dataArray[indexPath1.item] = dataArray[indexPath2.item]
        dataArray[indexPath2.item] = tmpItem
        
//        logDataArray()
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

extension ViewController: ReorderingCollectionViewDataSource {
    
    func reorderingCollectionView(_ collectionView: UICollectionView, isEmptyItemAt indexPath: IndexPath) -> Bool {
        return (dataArray[indexPath.item] == nil)
    }
    
    func reorderingCollectionView(_ collectionView: UICollectionView, swapItemAt indexPath1: IndexPath, withItemAt indexPath2: IndexPath) {
        let tmp = dataArray[indexPath1.item]
        dataArray[indexPath1.item] = dataArray[indexPath2.item]
        dataArray[indexPath2.item] = tmp
    }
    
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let longPress = gestureRecognizer as? UILongPressGestureRecognizer {
            let location = longPress.location(in: collectionView)
            
            if let indexPath = collectionView.indexPathForItem(at: location) {
                return (dataArray[indexPath.item] != nil)
            }
            
            return false
        }
        
        return true
    }
    
    @IBAction func onLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: collectionView)
        
        switch(sender.state) {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: location) else {
                break
            }
            
            let res = collectionView.beginInteractiveMovementForItem(at: indexPath)
            
            print("Dragging for item at index \(indexPath) has started - \(res)")
            
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(location)
            
        case .ended:
            collectionView.updateInteractiveMovementTargetPosition(location)
            collectionView.endInteractiveMovement()
            
            logDataArray()
            
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
}
