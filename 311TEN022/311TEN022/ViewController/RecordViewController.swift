//
//  RecordViewController.swift
//  311TEN022
//
//  Created by leeyeon2 on 11/7/23.
//

import UIKit

class RecordViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var Picker = UIImagePickerController()
    @IBOutlet weak var objectImageView: UIImageView!
    var tagButtonArray = [UIButton]()
    var buyList = ["메ㅗㄹ","ㅇㅇㅇ"]
    @IBOutlet weak var tagListView: UIView!
    @IBOutlet weak var tagListViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        objectImageView.isUserInteractionEnabled = true
        objectImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        showActionSheet()
    }
    
    /// 이미지 변경 버튼 클릭시 생성되는 action sheet
    func showActionSheet() {
        
        // 액션 시트 초기화
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // UIAlertAction 설정
        // handler : 액션 발생시 호출
        let actionAlbum = UIAlertAction(title: "앨범에서 선택할래요", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openGallery()
        })
        let actionCamera = UIAlertAction(title: "사진 찍을래요", style: .default, handler: {(alert:UIAlertAction!) -> Void in
            self.openCamera()
        })

        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(actionAlbum)
        actionSheet.addAction(actionCancel)
        
        self.present(actionSheet, animated: true)
    }
    /// actionsheet1. 카메라 촬영
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            self.Picker.sourceType = UIImagePickerController.SourceType.camera;
            self .present(self.Picker, animated: true, completion: nil)
            self.Picker.allowsEditing = false
            self.Picker.delegate = self
        }
    }
    
    /// actionsheet2. 앨범에서 가져오기
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum){
            self.Picker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum;
            self.Picker.allowsEditing = false
            self.Picker.delegate = self
            self.present(self.Picker, animated: true, completion: nil)
        }
    }
    
    /// 태그뷰 초기화
    private func initTagView() {
        // 태그버튼들 생성
        var tagStringArray = [String]()
        
        for i in buyList {
            tagStringArray.append(i)
        }
        
        tagButtonArray = tagStringArray.map { createButton(with: $0) }
        
        // 태그뷰에 태그버튼들 붙이기
        let frame = CGRect(x: 0, y: 0, width: tagListView.frame.width, height: tagListView.frame.height)
        let tagView = UIView(frame: frame)
        attachTagButtons(at: tagView, tagButtonArray)
        
        // addSubview
        tagListView.addSubview(tagView)
        tagListViewHeight.constant = tagView.frame.height
    }
    
    private func createButton(with title: String) -> UIButton {
        let font = UIFont.systemFont(ofSize: 15)
        let fontAttributes: [NSAttributedString.Key: Any] = [.font: font]
        let fontSize = title.size(withAttributes: fontAttributes)
        
        let tag = UIButton(type: .custom)
        tag.setTitle(title, for: .normal)
        tag.titleLabel?.font = font
        tag.setTitleColor(.darkGray, for: .normal)
        tag.layer.borderColor = UIColor.darkGray.cgColor
        tag.layer.borderWidth = 1
        tag.layer.cornerRadius = 14
        tag.frame = CGRect(x: 0.0, y: 0.0, width: fontSize.width + 30.0, height: fontSize.height + 13.0)
        tag.contentEdgeInsets = UIEdgeInsets(top: 6.5, left: 15, bottom: 6.5, right: 15)
        
        return tag
    }
    
    private func attachTagButtons(at view: UIView, _ tagButtons: [UIButton]) {
        var lineCount: CGFloat = 1
        let marginX: CGFloat = 5
        let marginY: CGFloat = 8
        
        var positionX: CGFloat = 0
        var positionY: CGFloat = 0
        
        for (index, tagButton) in tagButtons.enumerated() {
            tagButton.tag = index
            tagButton.frame = CGRect(x: positionX, y: positionY, width: tagButton.frame.width, height: tagButton.frame.height)
            view.addSubview(tagButton)
            
            if index < tagButtons.count - 1 {
                // 다음 태그버튼 좌표 설정
                positionX += tagButton.frame.width + marginX
                
                // 현재 줄에 공간이 부족해 다음 태그버튼이 붙을 수 없으면 다음 줄로 내리기
                if positionX + tagButtons[index + 1].frame.width > view.frame.width {
                    positionX = 0
                    positionY += tagButton.frame.height + marginY
                    lineCount += 1
                }
            }
        }
        
        // 태그뷰 높이 계산
        let height = view.subviews.first?.frame.height ?? 0
        let margins: CGFloat = (lineCount - 1) * marginY
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (lineCount * height) + margins)
    }
}
