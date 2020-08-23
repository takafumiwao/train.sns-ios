//
//  CustomPresentationController.swift
//  TRAIN
//
//  Created by 岩男高史 on 2020/05/06.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {
    // 呼び出し元のView Controller の上に重ねるオーバレイView
    private let overlayView = UIView()
    private var margin = (x: CGFloat(30), y: CGFloat(220))

    // 表示トランジション開始前に呼ばれる
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        overlayView.frame = containerView.bounds
        overlayView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.overlayViewDidTouch(_:)))]
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, at: 0)

        // トランジションを実行
        guard let psTransition = presentingViewController.transitionCoordinator else {
            return
        }
        psTransition.animate(alongsideTransition: { [weak self] _ in
            self?.overlayView.alpha = 0.7
        }, completion: nil)
    }

    // 非表示トランジション開始前に呼ばれる
    override func dismissalTransitionWillBegin() {
        guard let psTransition = presentingViewController.transitionCoordinator else {
            return
        }
        psTransition.animate(alongsideTransition: { [weak self] _ in
            self?.overlayView.alpha = 0.0
        }, completion: nil)
    }

    // 非表示トランジション開始後に呼ばれる
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
        }
    }

    // 子のコンテナサイズを返す
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let top = overlayView.safeAreaInsets.top
        let bottom = overlayView.safeAreaInsets.bottom
        return CGSize(width: parentSize.width - margin.x, height: parentSize.height - margin.y - top - bottom)
    }

    // 呼び出し先のView Controllerのframeを返す
    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect()
        let containerBounds = containerView!.bounds
        let childContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.size = childContentSize
        presentedViewFrame.origin.x = margin.x / 2.0
        presentedViewFrame.origin.y = margin.y / 2.0

        return presentedViewFrame
    }

    // レイアウト開始前に呼ばれる
    override func containerViewWillLayoutSubviews() {
        overlayView.frame = containerView!.bounds
        guard let psView = presentedView else { return }
        psView.frame = frameOfPresentedViewInContainerView
        psView.layer.cornerRadius = 10
        psView.clipsToBounds = true
    }

    // レイアウト開始後に呼ばれる
    override func containerViewDidLayoutSubviews() {
        let top = overlayView.safeAreaInsets.top
        let bottom = overlayView.safeAreaInsets.bottom
        margin.y = 220 + top + bottom
    }

    // overlayViewをタップした時に呼ばれる
    @objc private func overlayViewDidTouch(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
