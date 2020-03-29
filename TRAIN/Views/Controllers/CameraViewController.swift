//
//  CameraViewController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/03/23.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    // カメラ等のキャプチャに関連するニュ出力を管理するクラス
    var session: AVCaptureSession!
    // 写真データを取得するクラス
    var output: AVCapturePhotoOutput?
    // カメラでキャプチャした映像をプレビューするクラス
    var previewLayer: AVCaptureVideoPreviewLayer?
    // カメラでキャプチャした映像をプレビューするエリア
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var shutterButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        // 　キャプチャー入出力と写真データ取得のクラスの初期化
        session = AVCaptureSession()
        output = AVCapturePhotoOutput()

        // 解像度の設定
        session.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
        // カメラの選択(背面・前面)
        let camera = AVCaptureDevice.default(for: AVMediaType.video)

        do {
            // 指定したデバイスをセッションに入力
            let input = try AVCaptureDeviceInput(device: camera!)

            // 入力
            if session.canAddInput(input) {
                session.addInput(input)

                // 出力
                if session.canAddOutput(output!) {
                    session.addOutput(output!)
                    session.startRunning() // カメラ起動

                    // プレビューレイヤーを生成
                    previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    // cameraViewの境界をプレビューレイヤーのフレームに設定
                    previewLayer?.frame = cameraView.bounds
                    // アスペクト比変更とレイヤー収納の有無
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill // アスペクト比を変ない。レイヤーからはみ出した部分は隠す。
                    // previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect  // アスペクト比を変えない。はみ出さないようにレイヤー内に収める。

                    // cameraViewのサブレイヤーにプレビューレイヤーを追加
                    cameraView.layer.addSublayer(previewLayer!)
                }
            }
        } catch {
            print(error)
        }
    }

    @IBAction func takePhoto(_ sender: Any) {
        // 撮影設定
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto // フラッシュモード
        settingsForMonitoring.isHighResolutionPhotoEnabled = false

        // シャッターを切る
        output?.capturePhoto(with: settingsForMonitoring, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            // JPEG形式で画像データを取得
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            // UIImage型に変換
            let image = UIImage(data: photoData!)

            // フォトライブラリに保存
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
