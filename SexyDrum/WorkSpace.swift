//
//  WorkSpace.swift
//  SexyDrum
//
//  Created by Mitstuya.WATANABE on 2016/12/27.
//  Copyright © 2016年 Mitstuya.WATANABE. All rights reserved.
//

import UIKit
import AVFoundation

class WorkSpace: CanvasController, AVAudioPlayerDelegate {

    var oscServer: F53OSCServer!
    var audioPlayer : AVAudioPlayer!
    var petris = [Circle]()
    
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var bellBtn: UIButton!
    @IBOutlet weak var clapBtn: UIButton!
    @IBOutlet weak var cymbalBtn: UIButton!
    @IBOutlet weak var bellThumb: UIImageView!
    @IBOutlet weak var clapThumb: UIImageView!
    @IBOutlet weak var cymbalThumb: UIImageView!
    @IBOutlet weak var voiceThumb: UIImageView!
    @IBOutlet weak var bellTitle: UIImageView!
    @IBOutlet weak var clapTitle: UIImageView!
    @IBOutlet weak var cymbalTitle: UIImageView!
    @IBOutlet weak var voiceTitle: UIImageView!
    @IBOutlet weak var balloonContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var selectedBtn : UIButton!
    
    var timer: Timer!
    let messages : [String] = ["Hit Me!", "I'm feeling...", "Please softer...", "Please harder..."]
    var messageCnt = 0
    var lockAnimation = false
    
    override func setup() {
        //Work your magic here.
        
        oscServer = F53OSCServer.init()
        oscServer.port = 9999
        oscServer.delegate = self
        if oscServer.startListening() {
            print("Listening for messages on port \(oscServer.port)")
        } else {
            print("Error: Server was unable to start listening on port \(oscServer.port)")
        }
        
        
        // 再生する音源のURLを生成
        let soundFilePath : String = Bundle.main.path(forResource: "Chin-Bell", ofType: "mp3")!
        let fileURL : URL = URL(fileURLWithPath: soundFilePath)
        
        
        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            
            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self
            
            
        } catch {}
        
        canvas.addTapGestureRecognizer { (locations, center, state) -> () in
        }
        
        
        canvas.backgroundColor = Color(UIColor.white.cgColor)
        
        roundView.layer.cornerRadius = roundView.frame.size.width / 2
        button.layer.cornerRadius = button.frame.size.width / 2
        
        
        initMenuButton(btn: clapBtn)
        initMenuButton(btn: cymbalBtn)
        initMenuButton(btn: bellBtn)
        initMenuButton(btn: voiceBtn)
        
        
        // Initialaze button layout
        view.bringToFront(button)

        bellBtn.isSelected = true
        view.bringToFront(bellBtn)
        view.bringToFront(bellThumb)
        view.bringToFront(bellTitle)
        
        clapThumb.alpha = 0
        clapBtn.frame.origin.x += 60
        view.bringToFront(clapBtn)
        view.bringToFront(clapThumb)
        view.bringToFront(clapTitle)
        
        cymbalBtn.frame.origin.x += 60
        cymbalThumb.alpha = 0
        view.bringToFront(cymbalBtn)
        view.bringToFront(cymbalThumb)
        view.bringToFront(cymbalTitle)
        
        voiceBtn.frame.origin.x += 60
        voiceThumb.alpha = 0
        view.bringToFront(voiceBtn)
        view.bringToFront(voiceThumb)
        view.bringToFront(voiceTitle)
        
        selectedBtn = bellBtn
        
        balloonContainer.alpha = 0
        view.bringToFront(balloonContainer)
        
        timer = Timer.init(interval: 1, count: 3, action: {
            if (self.timer.step == 2) {
                // Show balloon
                self.showBalloon()
            }
        })

        timer.start()
    }
    
    func showBalloon() {
        let msg = messages[messageCnt]
        messageLabel.text = msg
        UIView.animate(withDuration: 0.2, animations: {
            self.balloonContainer.alpha = 1
        }, completion: { (completed) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                // your code here
                UIView.animate(withDuration: 0.2, animations: {
                    self.balloonContainer.alpha = 0
                }, completion: { (completed) in
                    self.timer.start()
                })
            }
        })

        messageCnt += 1
        if (messageCnt > messages.count - 1) {
            messageCnt = 0
        }
    }
    
    func initMenuButton(btn : UIButton) {
        let bounds = btn.bounds
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: [.bottomLeft, .topLeft],
                                    cornerRadii: CGSize(width: 3, height: 3))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        btn.layer.mask = maskLayer
        
        view.bringToFront(btn)
    }
    
    func playSound() {
        if audioPlayer.isPlaying {
            audioPlayer.currentTime = 0
        } else {
            audioPlayer.play()
        }
        
        
        messageCnt += 1
        if (messageCnt > messages.count - 1) {
            messageCnt = 0
        }
        let msg = messages[messageCnt]
        messageLabel.text = msg

        
        /*
        let a = ViewAnimation(duration: 0.3) {
            self.button.transform = CGAffineTransform(scaleX: 3, y: 3);
        }
        a.addCompletionObserver { () -> Void in
            self.button.transform = CGAffineTransform.identity
        }
         a.autoreverses = false
         a.repeats = false
         a.animate()
         
         */
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = NSNumber(value: 1.05)
        animation.duration = 0.1
        animation.repeatCount = 2
        animation.autoreverses = true
        self.button.layer.add(animation, forKey: nil)
    }
    
    @IBAction func tappedButton(_ sender: UIButton) {
        playSound()
    }
    
    
    
    @IBAction func tappedSoundChangeButton(_ sender: UIButton) {
        // 再生する音源のURLを生成
        var soundFilePath : String = ""
        
        if (sender.tag == 100) {
            // Bell...
            soundFilePath = Bundle.main.path(forResource: "Ching", ofType: "wav")!
            
            
        } else if (sender.tag == 101) {
            // Clap...
            soundFilePath = Bundle.main.path(forResource: "Clap", ofType: "wav")!
        } else if (sender.tag == 102) {
            // Cymbal...
            soundFilePath = Bundle.main.path(forResource: "Cymbal", ofType: "wav")!
            
        } else if (sender.tag == 103) {
            // Voice...
            soundFilePath = Bundle.main.path(forResource: "Vox", ofType: "wav")!
        }
        
        let fileURL : URL = URL(fileURLWithPath: soundFilePath)
        
        
        do{
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            
            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self
        }
        catch{
        }
        
        if (sender.tag != self.selectedBtn.tag) {
            
            if (!lockAnimation) {
                lockAnimation = true
                
                // Show animation
                UIView.animate(withDuration: 0.2, animations: {
                    sender.frame.origin.x -= 60
                    self.selectedBtn.frame.origin.x += 60
                    sender.backgroundColor = UIColor(red: 255.0 / 255.0, green: 210.0 / 255.0, blue: 40.0 / 255.0 , alpha: 1.0)
                    
                    self.selectedBtn.backgroundColor = UIColor.white
                    
                    // Show thumnail
                    if (self.selectedBtn.tag == 100) {
                        // Bell
                        self.bellThumb.alpha = 0
                    } else if (self.selectedBtn.tag == 101) {
                        // Clap
                        self.clapThumb.alpha = 0
                    } else if (self.selectedBtn.tag == 102) {
                        // Cymbal
                        self.cymbalThumb.alpha = 0
                    } else if (self.selectedBtn.tag == 103) {
                        // Voice
                        self.voiceThumb.alpha = 0
                    }
                    
                }, completion: { (completed) in
                    UIView.animate(withDuration: 0.2, animations: {
                        // Show thumnail
                        if (sender.tag == 100) {
                            // Bell
                            self.bellThumb.alpha = 1
                        } else if (sender.tag == 101) {
                            // Clap
                            self.clapThumb.alpha = 1
                        } else if (sender.tag == 102) {
                            // Cymbal
                            self.cymbalThumb.alpha = 1
                        } else if (sender.tag == 103) {
                            // Voice
                            self.voiceThumb.alpha = 1
                        }
                    }, completion: { (completed) in
                        self.selectedBtn = sender
                        self.lockAnimation = false
                    })
                })

            }
            
        }
    }
    
    // 音楽再生が成功した時に呼ばれるメソッド
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Music Finish")
    }
    
    // デコード中にエラーが起きた時に呼ばれるメソッド
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error")
    }

    func moveToCenter(microbe: Circle, ofPetri petri: Circle) {
        let a = ViewAnimation(duration: random01() * 0.5 + 0.5) { () -> Void in
            microbe.center = self.canvas.center
        }
        a.addCompletionObserver { () -> Void in
            microbe.removeFromSuperview()
            microbe.center = petri.bounds.center
            petri.add(microbe)
            self.randomMove(microbe: microbe, inPetri: petri)
            self.fade(microbe: microbe)
        }
        a.animate()
    }
    
    func fade(microbe: Circle) {
        let a = ViewAnimation(duration: 0.25) {
//            microbe.opacity = 0.0
        }
        a.addCompletionObserver { () -> Void in
//            microbe.removeFromSuperview()
        }
        a.delay = random01() * 5 + 5
        a.animate()
    }
    
    func createMicrobe(center: Point) -> Circle {
        let microbe = Circle(center: center, radius: 2)
        microbe.lineWidth = 0
        microbe.fillColor = C4Pink
        
        let a = ViewAnimation(duration: 0.5) {
            microbe.fillColor = C4Blue
        }
        a.autoreverses = true
        a.repeats = true
        a.animate()
        
        return microbe
    }
    
    func randomMove(microbe: Circle, inPetri petri: Circle) {
        let anim = ViewAnimation(duration: random01() * 5 + 2.0) { () -> Void in
            let θ = random01() * 2 * M_PI
            let r = 150.0 * random01()
            let c = Point(r * sin(θ), r * cos(θ)) + Vector(petri.bounds.center)
            microbe.center = c
        }
        anim.delay = random01()
        anim.addCompletionObserver { () -> Void in
            self.randomMove(microbe: microbe, inPetri: petri)
        }
        anim.animate()
    }
    
    func createPetris() {
        let r = 150.0
        for _ in 0...5 {
            let petri = Circle(center: Point(Double(button.center.x), Double(button.center.y)), radius: r)
            petri.fillColor = clear
            petri.strokeColor = C4Pink
            petri.interactionEnabled = false
            randomRotate(petri: petri)
            petris.append(petri)
            canvas.add(petri)
        }
    }
    
    func randomRotate(petri: Circle) {
        let anim = ViewAnimation(duration: random01() * 5 + 2.0) { () -> Void in
            let θ = random01() * M_PI
            let d = round(random01()) == 0 ? -1.0 : 1.0
            petri.transform.rotate(θ * d)
        }
        anim.delay = random01()
        anim.addCompletionObserver { () -> Void in
            self.randomRotate(petri: petri)
        }
        anim.animate()
    }
}


extension WorkSpace : F53OSCPacketDestination {

    func take(_ message: F53OSCMessage!) {
        if (message.description == "/sexy/60") {
            playSound()
        }
    }
}
