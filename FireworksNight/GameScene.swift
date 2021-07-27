//
//  GameScene.swift
//  FireworksNight
//
//  Created by Igor Chernyshov on 27.07.2021.
//

import SpriteKit
import GameplayKit

final class GameScene: SKScene {

	// MARK: - Nodes
	private var fireworks = [SKNode]()

	private lazy var scoreLabel: SKLabelNode = {
		let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
		scoreLabel.fontSize = 48
		scoreLabel.position = CGPoint(x: 512, y: 724)
		scoreLabel.text = "Score: 0"
		return scoreLabel
	}()

	// MARK: - Properties
	private var gameTimer: Timer?

	private let leftEdge = -22
	private let bottomEdge = -22
	private let rightEdge = 1046

	private var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}

	// MARK: - Lifecycle
	override func didMove(to view: SKView) {
		addBackground()
		addChild(scoreLabel)

		gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
	}

	// MARK: - UI Configuration
	private func addBackground() {
		let background = SKSpriteNode(imageNamed: "background")
		background.position = CGPoint(x: 512, y: 384)
		background.blendMode = .replace
		background.zPosition = -1
		addChild(background)
	}

	// MARK: - Game Logic
	private func createFirework(xMovement: CGFloat, x: Int, y: Int) {
		let node = SKNode()
		node.position = CGPoint(x: x, y: y)

		let firework = SKSpriteNode(imageNamed: "rocket")
		firework.colorBlendFactor = 1
		firework.name = "firework"
		node.addChild(firework)

		switch Int.random(in: 0...2) {
		case 0: firework.color = .cyan
		case 1: firework.color = .green
		case 2: firework.color = .red
		default: break
		}

		let path = UIBezierPath()
		path.move(to: .zero)
		path.addLine(to: CGPoint(x: xMovement, y: 1000))

		let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
		node.run(move)

		if let emitter = SKEmitterNode(fileNamed: "fuse") {
			emitter.position = CGPoint(x: 0, y: -22)
			node.addChild(emitter)
		}

		fireworks.append(node)
		addChild(node)
	}

	@objc private func launchFireworks() {
		let movementAmount: CGFloat = 1800

		switch Int.random(in: 0...3) {
		case 0:
			// fire five, straight up
			createFirework(xMovement: 0, x: 312, y: bottomEdge)
			createFirework(xMovement: 0, x: 412, y: bottomEdge)
			createFirework(xMovement: 0, x: 512, y: bottomEdge)
			createFirework(xMovement: 0, x: 612, y: bottomEdge)
			createFirework(xMovement: 0, x: 712, y: bottomEdge)
		case 1:
			// fire five, in a fan
			createFirework(xMovement: -200, x: 312, y: bottomEdge)
			createFirework(xMovement: -100, x: 412, y: bottomEdge)
			createFirework(xMovement: 0, x: 512, y: bottomEdge)
			createFirework(xMovement: 100, x: 612, y: bottomEdge)
			createFirework(xMovement: 200, x: 712, y: bottomEdge)
		case 2:
			// fire five, from the left to the right
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
			createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
		case 3:
			// fire five, from the right to the left
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
			createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
		default:
			break
		}
	}

	override func update(_ currentTime: TimeInterval) {
		for (index, firework) in fireworks.enumerated().reversed() {
			if firework.position.y > 900 {
				fireworks.remove(at: index)
				firework.removeFromParent()
			}
		}
	}

	// MARK: - Touches Handling
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		checkTouches(touches)
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		checkTouches(touches)
	}

	private func checkTouches(_ touches: Set<UITouch>) {
		guard let touch = touches.first else { return }

		let location = touch.location(in: self)
		let nodesAtPoint = nodes(at: location)

		for case let node as SKSpriteNode in nodesAtPoint {
			guard node.name == "firework" else { continue }

			fireworks.forEach {
				guard let firework = $0.children.first as? SKSpriteNode else { return }

				if firework.name == "selected" && firework.color != node.color {
					firework.name = "firework"
					firework.colorBlendFactor = 1
				}
			}

			node.name = "selected"
			node.colorBlendFactor = 0
		}
	}
}
