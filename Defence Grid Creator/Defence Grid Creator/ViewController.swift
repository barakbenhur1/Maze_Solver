//
//  ViewController.swift
//  Defence Grid Creator
//
//  Created by Interactech on 14/05/1021.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
        
    private var numOfBlocks = 0
    
    private let minNumOfBlocks = 90
    
    private var blocksRange = 10...70
   
    private let numOfX = 10
    
    private let yStartIndex = 2
    
    private var blocks: [CGPoint : Block?]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let widthRemoval: CGFloat = 2
        let sizeX = (view.frame.width / CGFloat(numOfX)) - widthRemoval
        let sizeY = (view.frame.width / CGFloat(numOfX))
        
        let label = scoreLabel(size: sizeY)
        
        view.addSubview(label)
        
        numOfBlocks = Int.random(in: blocksRange)
        var leftBlocks = Int.random(in: blocksRange)
        
        let totalBlocks = numOfBlocks + leftBlocks
        
        if totalBlocks < minNumOfBlocks {
            let addNumOfBlocks = Int.random(in: 0...minNumOfBlocks - totalBlocks)
            numOfBlocks += addNumOfBlocks
            leftBlocks = minNumOfBlocks - addNumOfBlocks
        }
        
        var leftBlocksCount: Int = 0 {
            didSet {
                let total = (numOfBlocks + leftBlocks)
                let precent: CGFloat = (CGFloat(leftBlocksCount) / CGFloat(total))
                UIView.animate(withDuration: 0.2) {
                    label.backgroundColor = precent > 0.75 ? UIColor.green.withAlphaComponent(0.3) : (precent > 0.5 ? UIColor.orange.withAlphaComponent(0.3) : (precent > 0.25 ? UIColor.systemYellow.withAlphaComponent(0.3) : UIColor.red.withAlphaComponent(0.3)))
                    label.layoutIfNeeded()
                }
            }
        }
        
        leftBlocksCount = leftBlocks
        
        label.text = "\(leftBlocksCount) Out Of \(numOfBlocks + leftBlocks) Blocks Left"
        
        print("numOfBlocks: \(numOfBlocks)\nleftBlocks: \(leftBlocks)")
        
        blocks = [CGPoint : Block]()
        
        let size2D = CGSize(width: sizeX, height: sizeY)
        let numOfY = Int(view.frame.height / CGFloat(sizeY))
        
        let point = CGPoint(x: numOfX, y: numOfY)
        let startPoint = CGPoint(x: 0, y: yStartIndex)
        let winPoint = CGPoint(x: point.x - 1, y: point.y - 1)
        let padding = CGFloat(numOfX) *  widthRemoval / 2
        let squareSizeRemoval: CGFloat = 0.9
        
        let container = UIView(frame: CGRect(origin: CGPoint(x: padding + startPoint.x * size2D.width, y: startPoint.y * size2D.height), size: CGSize(width: size2D.width * (winPoint.x - startPoint.x + 1), height: size2D.height * (winPoint.y - startPoint.y + 1))))
//        container.backgroundColor = .systemGray3
        container.layer.borderWidth = squareSizeRemoval
        container.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.8).cgColor
        
        for i in 0...Int(winPoint.x) {
            for j in 0...Int(winPoint.y) {
                let origin = CGPoint(x: CGFloat(i) * size2D.width, y: CGFloat(j) * size2D.height)
                let frame = CGRect(origin: origin, size: CGSize(width: size2D.width, height: size2D.height))
                let square: UIView = UIView(frame: frame)
                square.backgroundColor = .init(hexString: "#6082B6", alpha: 0.34)
                square.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.8).cgColor
                square.layer.borderWidth = squareSizeRemoval
//                square.layer.shadowColor = UIColor.black.cgColor
//                square.layer.shadowOpacity = 1
//                square.layer.shadowOffset = .init(width: 0.3, height: 0.3)
//                square.layer.shadowRadius = 10
                
                container.addSubview(square)
                square.clipsToBounds = true
            }
            view.addSubview(container)
            container.layer.cornerRadius = 14
            container.clipsToBounds = true
        }
        
        while blocks.count < numOfBlocks {
            let randomX = Int.random(in: 0...numOfX - 1)
            let randomY = Int.random(in: yStartIndex...numOfY - 1)
            
            let key = CGPoint(x: randomX, y: randomY)
            guard !key.equalTo(startPoint), blocks[key] == nil, !key.equalTo(winPoint) else { continue }
            blocks[key] = Block(name: "block", state: .solid)
        }
        
        let board = Board(blocks: blocks, view: view, size: point, sizeOfItem: size2D, gameParams: (startPoint, winPoint), padding: CGFloat(numOfX) *  widthRemoval / 2)
        
        board.start()
        
        board.startOver = { text in
            let alert = UIAlertController(title: text, message:  "Start Over", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Start", style: .default, handler: { [self] action in
                blocks = [CGPoint : Block]()
                numOfBlocks = Int.random(in: blocksRange)
                leftBlocks = Int.random(in: blocksRange)
                
                let totalBlocks = numOfBlocks + leftBlocks
                
                if totalBlocks < minNumOfBlocks {
                    let addNumOfBlocks = Int.random(in: 0...minNumOfBlocks - totalBlocks)
                    numOfBlocks += addNumOfBlocks
                    leftBlocks = minNumOfBlocks - addNumOfBlocks
                }
                leftBlocksCount = leftBlocks
                print("numOfBlocks: \(numOfBlocks)\nleftBlocks: \(leftBlocks)")
                label.text = "\(leftBlocksCount) Out Of \(numOfBlocks + leftBlocks) Blocks Left"
                while blocks.count < numOfBlocks {
                    let randomX = Int.random(in: 0...numOfX - 1)
                    let randomY = Int.random(in: yStartIndex...numOfY - 1)
                    
                    let key = CGPoint(x: randomX, y: randomY)
                    guard !key.equalTo(startPoint), blocks[key] == nil, !key.equalTo(CGPoint(x: point.x - 1, y: point.y - 1)) else { continue }
                    blocks[key] = Block(name: "block", state: .solid)
                }
                DispatchQueue.main.async {
                    board.reset()
                    board.setBlocks(blocks: blocks)
                    board.start()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        board.addBlock = { [self] point, player in
            guard leftBlocksCount > 0 else {
                board.cantAddEffect?(CGRect(x: CGFloat(numOfX) *  widthRemoval / 2 + CGFloat(Int(point.x / CGFloat(sizeX))) * CGFloat(sizeX), y: CGFloat(Int(point.y / CGFloat(sizeY))) * CGFloat(sizeY), width: CGFloat(sizeX), height: CGFloat(sizeY)))
                return
            }
            let key = CGPoint(x: Int(point.x / CGFloat(sizeX)), y: Int(point.y / CGFloat(sizeY)))
            guard !player.location.equalTo(key), !key.equalTo(winPoint), blocks[key] == nil || (blocks[key] as? Block)?.state == .empty else {
                board.cantAddEffect?(CGRect(x: CGFloat(numOfX) *  widthRemoval / 2 + CGFloat(Int(point.x / CGFloat(sizeX))) * CGFloat(sizeX), y: CGFloat(Int(point.y / CGFloat(sizeY))) * CGFloat(sizeY), width: CGFloat(sizeX), height: CGFloat(sizeY)))
                return
            }
            blocks = board.getBlocks()
            blocks[key] = Block(name: "block", state: .solid)
            board.setBlocks(blocks: blocks)
            blocks[key]?!.frame = blocks[key]!!.image!.frame
            player.calcGameState()
            board.addEffect?(blocks[key]!!)
            leftBlocksCount -= 1
            label.text = "\(leftBlocksCount) Out Of \(numOfBlocks + leftBlocks) Blocks Left"
        }
        
        board.addEffect = { [self] block in
            smokeEffect(block: block)
        }
        
        board.cantAddEffect = { [self] frame in
            let block = Block(state: .empty)
            block.frame = frame
            smokeEffect(block: block, effectType: .cant)
        }
    }
    
    enum EffectType {
        case add, cant
        
        func getTextureName() -> String {
            switch self {
            case .add:
                return "block"
            case .cant:
                return "enemy"
            default:
                return "block"
            }
        }
        
        func getNumParticlesToEmit() -> Int {
            switch self {
            case .add:
                return 0
            case .cant:
                return 3
            default:
                return 0
            }
        }
    }
    
    private func smokeEffect(block: Block, effectType: EffectType = .add) {
        if let fireParticles = SKEmitterNode(fileNamed: "Smoke") {
            fireParticles.particleTexture = SKTexture(imageNamed: effectType.getTextureName())
            block.image?.alpha = 0
            fireParticles.numParticlesToEmit = effectType.getNumParticlesToEmit()
            fireParticles.particleScale = 0.6
            fireParticles.particleScaleRange = 0.3
            fireParticles.particleScaleSpeed = -0.2
            let skView = SKView(frame: block.frame)
            skView.backgroundColor = .clear
            let scene = SKScene(size: CGSize(width: 10, height: 10))
            scene.backgroundColor = .clear
            skView.presentScene(scene)
            skView.isUserInteractionEnabled = false
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            scene.addChild(fireParticles)
            scene.backgroundColor = .clear
            
            view.addSubview(skView)
            skView.layer.cornerRadius = 10
            skView.clipsToBounds = true
            
            skView.backgroundColor = .clear
            
            let peDelay = SKAction.wait(forDuration: Block.timeToBuild)
            
            let peRemove = SKAction.removeFromParent()
            
            fireParticles.run(SKAction.sequence([peDelay , peRemove]))
            
            fireParticles.targetNode?.removeFromParent()
            fireParticles.targetNode = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Block.timeToBuild) {
                skView.removeFromSuperview()
                block.image?.alpha = 1
            }
        }
    }
    
    private func scoreLabel(size: CGFloat) -> UILabel {
        let spaceY = 40
        let spaceX = 30
        let height = 30
        let width = Int(CGFloat(numOfX) * size) - (spaceX * 2)
        let label = UILabel(frame: CGRect(x: spaceX, y: spaceY, width: width, height: height))
        label.textColor = .init(hexString: "#2f2f2f")
        label.textAlignment = .center
        label.layer.cornerRadius = 14
        label.numberOfLines = 1
        label.clipsToBounds = true
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        
        return label
    }
}

public class Board {
    private var blocks: [CGPoint : Block?]!

    private var player: Enemy!
    
    private var container: UIView!
    
    private var size: CGPoint = .zero
    
    private var win: CGPoint = .zero
    
    private var sizeOfItem: CGSize = .zero
    
    private var startLocation: CGPoint = .zero
    
    private var padding: CGFloat = 0
    
    private var clickAllowed = true
    
    var startOver: ((String) -> ())?
    
    var addEffect: ((Block) -> ())?
    
    var cantAddEffect: ((CGRect) -> ())?
    
    var addBlock: ((CGPoint, Enemy) -> ())?
    
    init(blocks: [CGPoint : Block?], view: UIView?, size: CGPoint, sizeOfItem: CGSize, gameParams: (startLocation: CGPoint, winLocation: CGPoint), padding: CGFloat) {
        self.blocks = blocks
        container = view
        let tap = UITapGestureRecognizer(target: self, action: #selector(addBlockTap(gestureRecognizer:)))
        container.addGestureRecognizer(tap)
        let winImage = UIImageView(image: UIImage(named: "win"))
        view?.addSubview(winImage)
        winImage.frame = CGRect(x: padding + (size.x - 1) *  sizeOfItem.width, y: (size.y - 1) *  sizeOfItem.height, width: sizeOfItem.width, height: sizeOfItem.height)
        
        self.sizeOfItem = sizeOfItem
        
        self.size = size
        
        self.padding = padding
        
        self.startLocation = gameParams.startLocation
        self.win = gameParams.winLocation
        
        if view != nil {
            for key in blocks.keys {
                guard let block = blocks[key] as? Block else { return }
                block.image?.removeFromSuperview()
                container.addSubview(block.image ?? UIImageView())
                block.image?.frame = CGRect(x: padding + sizeOfItem.width * key.x, y: sizeOfItem.height * key.y, width: sizeOfItem.width, height: sizeOfItem.height)
            }
        }
    }
    
    func getBlocks() ->  [CGPoint : Block?] {
        return blocks
    }
    
    @objc private func addBlockTap(gestureRecognizer: UITapGestureRecognizer) {
        
        guard clickAllowed else { return }
        
        let point = gestureRecognizer.location(in: container)
        
        guard point.x <= size.x * sizeOfItem.width, point.x >= startLocation.x * sizeOfItem.width, point.y <= size.y * sizeOfItem.height, point.y >= startLocation.y * sizeOfItem.height else { return }
        
        clickAllowed = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Block.timeToBuild) {
            self.clickAllowed = true
        }

        addBlock?(point, player)
    }
    
    func setBlocks(blocks: [CGPoint : Block?]) {
        for key in self.blocks.keys {
            guard let block = self.blocks[key] as? Block else { return }
            block.image?.removeFromSuperview()
        }
        self.blocks = blocks
        
        for key in blocks.keys {
            guard let block = blocks[key] as? Block else { return }
            block.image?.frame = CGRect(x: padding + sizeOfItem.width * key.x, y: sizeOfItem.height * key.y, width: sizeOfItem.width, height: sizeOfItem.height)
            
            container.addSubview(block.image ?? UIImageView())
        }
    }
    
    private var startDelay: Double = 0.1
    private var playerMoveTime: Double = 0.38
    private var playerMoveAnimationTime: Double = 0.4
    
    func start() {
        clickAllowed = true
        self.player = Enemy(start: startLocation, win: win, padding: padding, playerSpeed: playerMoveTime)
        
        container.addSubview(player.image)
        player.image.frame = CGRect(x: padding + startLocation.x * sizeOfItem.width, y: startLocation.y * sizeOfItem.height , width: sizeOfItem.width, height: sizeOfItem.height)
        
        player.moveInformer = { [self] location in
            clickAllowed = clickAllowed && !location.equalTo(win)
            print("===============Animate")
            UIView.animate(withDuration: playerMoveAnimationTime) {
                let image = UIImage(cgImage: player.image.image!.cgImage!, scale: 1.0, orientation: player.image.frame.origin.x > padding + sizeOfItem.width * location.x ? .upMirrored : .up)
                player.image.image = image
                player.image.frame = CGRect(x: padding + sizeOfItem.width * location.x, y: sizeOfItem.height * location.y , width: sizeOfItem.width , height: sizeOfItem.height)
                
                if player.think != nil {
                    let size = CGSize(width: player.image.frame.size.width - 15, height: player.image.frame.size.height - 15)
                    let origin = CGPoint(x: player.image.frame.origin.x + size.width / 0.8 , y: player.image.frame.origin.y - size.height / 1.6)
                    player.think.frame = CGRect(origin: origin, size: size)
                }
            }
        }
        
        player.attachBoardInformer(boardInformer: { () -> (Board?) in
            return self
        })
        
        self.player.startOver = { text in
            self.startOver?(text)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) { [self] in
            player.start()
        }
    }
    
    func reset() {
        guard self.player != nil else { return }
        self.player.image.removeFromSuperview()
        for key in self.blocks.keys {
            guard let block = self.blocks[key] as? Block else { return }
            block.image?.removeFromSuperview()
        }
        self.blocks = [CGPoint : Block?]()
    }
    
    private func getSurroundingsBlocks(location: CGPoint) ->  [CGPoint : (Block?, index: Int)] {
        var blocksAround: [CGPoint : (Block?, Int)] = [CGPoint : (Block?, Int)]()
        
        for j in Int(location.y - 1)...Int(location.y + 1) {
            for i in Int(location.x - 1)...Int(location.x + 1) {
                
                guard i >= Int(startLocation.x) && i < Int(size.x), j >= Int(startLocation.y) && j < Int(size.y)  else { continue }
                
                let point: CGPoint = CGPoint(x: i, y: j)
                
                guard !point.equalTo(location) else { continue }
                
                let fixY = j - Int(location.y - 1)
                let fixI = i - Int(location.x - 1)
                blocksAround[point] = (blocks[point] ?? Block(state: .empty), 8 - ((2 * fixY) + (fixI + fixY)))
            }
        }
        
        return blocksAround
    }
    
    func getSurroundingsFor(location: CGPoint) -> [CGPoint : (block: Block?, index: Int)] {
        return getSurroundingsBlocks(location: location)
    }
    
    func getClosestToWin() -> CGPoint? {
        
        for i in Int(startLocation.x)..<Int(size.x) {
            for j in Int(startLocation.y)..<Int(size.y) {
                let key = CGPoint(x: i, y: j)
                guard !key.equalTo(win) else { continue }
                self.blocks[key] = self.blocks[key] ?? Block(state: .empty)
            }
        }
        
        var best: CGPoint? = nil
        var bestDistance: CGFloat = distance(from: player.location, to: win)
        for tuple in blocks {
            if tuple.value?.state == .empty {
                let distanceCompere = distance(from: tuple.key, to: win)
                
                if distanceCompere < bestDistance && !player.lookForWay(location: player.location, winLocation: tuple.key).real.isEmpty() {
                    bestDistance = distanceCompere
                    best = tuple.key
                }
            }
        }
        
        return best
    }
    
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }
    
    func getBlockLocations() -> [CGPoint] {
        return Array(blocks.keys)
    }
    
    func getBlockState(key: CGPoint) -> State {
        return (blocks[key] as? Block)!.state
    }
}

class Enemy {
    
    enum Condition {
        case move, lose, win
    }
    
    var location: CGPoint!
    var think: UIImageView!
    private var winLocation: CGPoint!
    private var boardInformer: (() -> (Board?))?
    var moveInformer: ((CGPoint) -> ())?
    var startOver: ((String) -> ())?
    var image: UIImageView!
    
    private var playerMoveSpeed: Double = 0
    
    private var stack: Stack<Vertex<CGPoint>>!
    
    private var lose = false
    
    private var timer: Timer!
    
    private var xPadding: CGFloat = 0
    
    init(start: CGPoint ,win: CGPoint, padding: CGFloat, playerSpeed: Double) {
        location = start
        image = UIImageView(image: UIImage(named: "enemy"))
        winLocation = win
        xPadding = padding
        playerMoveSpeed = playerSpeed
        
        moveInformer?(location)
    }
    
    func start() {
        stack = Stack<Vertex<CGPoint>>()
        timerControl(start: true, initial: true)
    }
    
    func timerControl(start: Bool, initial: Bool = false) {
        if start {
            calcGameState(initial: initial)
            timer = Timer(timeInterval: playerMoveSpeed, repeats: true) { (timer) in
                self.checkWhereToGo()
            }
            if initial {
                timer.fire()
            }
            if timer != nil {
                RunLoop.current.add(timer, forMode: .common)
            }
        }
        else if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    func attachBoardInformer(boardInformer: @escaping () -> (Board?)) {
        self.boardInformer = boardInformer
    }
    
    func calcGameState(initial: Bool = false) {
        if initial {
            calcState()
        }
        else {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                print("===============Calc")
                strongSelf.calcState()
            }
        }
    }
    
    private func calcState() {
        let way = lookForWay(location: location, winLocation: winLocation)
        
        lose = way.real.isEmpty()
        
        if lose {
            if think == nil {
                think = UIImageView(image: UIImage(named: "bubble"))
                let size = CGSize(width: image.frame.size.width - 15, height: image.frame.size.height - 15)
                let origin = CGPoint(x: image.frame.origin.x + size.width / 0.8 , y: image.frame.origin.y - size.height / 1.6)
                think.frame = CGRect(origin: origin, size: size)
                
                image.superview?.addSubview(think)
            }
            let bestWay = lookForWay(location: location, winLocation: boardInformer!()!.getClosestToWin() ?? location).real
            stack = bestWay
            print("lose: \(stack.description)")
            return
        }
        
        stack = way.real
    }
    
    private var delay: Double = 0.3
    private var restartDelay: Double = 0.5
    
    private func checkWhereToGo() {
        print("...........check where to go............")
        
        var condition: Condition = stack.isEmpty() ? .lose : .move
//        var skip: Bool = false
        if !lose || condition != .lose {
            let next = stack.queuePop()?.data
//            if next != nil {
//                skip = next!.equalTo(location)
//            }
            location = next ?? location
            condition = location.equalTo(winLocation) ? .win : .move
        }
        
        print("\(stack.isEmpty())")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.think != nil {
                self.think.removeFromSuperview()
                self.think = nil
            }
        }
        
        switch condition {
        case .lose:
            print("move to \(location!)")
            print("WINNER WINNER")
            if timer != nil {
                timer.invalidate()
            }
            timer = nil
            startOver?("You Win")
        case .win:
            moveInformer?(location)
            if timer != nil {
                timer.invalidate()
            }
            timer = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [self] in
                image.alpha = 0.6
                print("move to \(location!)")
                print("LOASER LOASER")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + restartDelay) {
                    self.startOver?("You Lose")
                }
            }
        default:
//            guard !skip else { return }
            print("move to \(location!) !!!!!")
            moveInformer?(location)
        }
    }
    
    func lookForWay(location: CGPoint, winLocation: CGPoint) -> (list: AdjacencyList<CGPoint>, real: Stack<Vertex<CGPoint>>) {
        guard let boardInformer = boardInformer else { return (AdjacencyList<CGPoint>(), Stack<Vertex<CGPoint>>())}
        let list = AdjacencyList<CGPoint>()
        var checkPoints: [CGPoint] = [location]
        var doneCheckPoints: [CGPoint] = [CGPoint]()
        while !checkPoints.isEmpty {
            let checkPoint = checkPoints.remove(at: 0)
            doneCheckPoints.append(checkPoint)
            guard let playSpace = boardInformer()?.getSurroundingsFor(location: checkPoint) else { continue }
            var addPoints = [CGPoint]()
            
            for tuple in playSpace {
                if tuple.value.block?.state == .empty && !checkPoints.contains(tuple.key) && !doneCheckPoints.contains(tuple.key) {
                    addPoints.append(tuple.key)
                }
            }
            checkPoints.append(contentsOf: addPoints)
            for point in addPoints {
                list.add(.directed, from: Vertex(data: checkPoint), to: Vertex(data: point), weight: Double(playSpace[point]!.index))
            }
        }
        
        let result = depthFirstSearch(from: Vertex(data: location), to: Vertex(data: winLocation), graph: list)
        
        let stack = (list, result)
       
        print(stack)
        
        return stack
    }
    
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }

    func depthFirstSearch(from start: Vertex<CGPoint>, to end: Vertex<CGPoint>, graph: AdjacencyList<CGPoint>) -> Stack<Vertex<CGPoint>> { // 1
        var visited = Set<Vertex<CGPoint>>() // 2
        var stack = Stack<Vertex<CGPoint>>() // 3
        var stackTrack = Stack<Vertex<CGPoint>>() // 3
        
        stack.push(start)
        visited.insert(start)
        
        outer: while let vertex = stack.peek(), vertex != end { // 1
            
            guard let neighbors = graph.edges(from: vertex), neighbors.count > 0 else { // 2
                print("backtrack from \(vertex)")
                stack.pop()
                continue
            }
            
            for edge in neighbors { // 3
                if !visited.contains(edge.destination) {
                    visited.insert(edge.destination)
                    stack.push(edge.destination)
                    print(stack.description)
                    if stack.count() > stackTrack.count() {
                        stackTrack = stack
                    }
                    continue outer
                }
            }
            
            print("backtrack from \(vertex)") // 4
            stack.pop()
        }
    
        return stack // 4
    }
}

public enum State {
    case empty, solid
}

class Block {
    static var timeToBuild: Double = 0.4
    
    var image: UIImageView?
    var state: State = .solid
    var frame: CGRect = .zero
    
    init(name: String? = nil, state: State) {
        if name != nil {
            self.image = UIImageView(image: UIImage(named: name!))
        }
        self.state = state
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
