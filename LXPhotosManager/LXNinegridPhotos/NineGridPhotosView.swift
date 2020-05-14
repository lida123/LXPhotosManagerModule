//
//  LXNinegridPhotosView.swift
//  LXPhotosManagerModule
//
//  Created by Mac on 2020/4/16.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit

//点击 回调协议
public protocol NineGridPhotosViewDelegate: AnyObject {
    
    ///数据源回调
    func nineGridPhotosView(with index: Int,photoViews: [SinglePhotoView],datasource: [FileInfoProtocol])
}

public class NineGridPhotosView: UIView {

    //MARK: - 私有属性
    ///存放所有图片的集合
    private var photoViews = [SinglePhotoView]()
    
     //MARK: - 公共属性
    ///图片文件数据源
    public var datasource =  [FileInfoProtocol](){
        didSet {
            if  datasource.count >= photoMaxCount{
                var datas = [FileInfoProtocol]()
                for (index,photo) in datasource.enumerated() {
                    if index >= photoMaxCount {
                        break
                    }else{
                        datas.append(photo)
                    }
                }
               datasource = datas
            }
            
            //初始化UI界面
            setUI()
        }
    }
    
    /// 加载图片方式
    public var loadBlock: ((FileInfoProtocol,UIImageView) -> ())?
    
    /// 加载最大高度回调
    public var loadCurrentViewMaxY: ((CGFloat) -> ())?

    /// 图片最大个数（默认最大个数是9个）
    public var photoMaxCount: Int = 9
    
    /// 代理协议
    public weak var delegate: NineGridPhotosViewDelegate?
    
    /// 只有一张图片的时候设置（多张不用设置）
    public var singleViewH: CGFloat = 163
    public var singleViewW: CGFloat = 163

    /// 多张图片的间隔
    public var marginRol: CGFloat = 5.0
    public var marginCol: CGFloat = 5.0

    
}

extension NineGridPhotosView {
    /// 初始化UI
    private func setUI() {
        var photoView: SinglePhotoView
        for (index,photo) in self.datasource.enumerated() {
            
            if index >= photoViews.count  { //判断是否在缓存里取
                photoView = SinglePhotoView()
                photoView.delegate = self
                photoView.type = .nineGrid
                photoView.tag = index
                addSubview(photoView)
                photoViews.append(photoView)
            }else {
                photoView = photoViews[index]
            }
            //SinglePhotoView 信息配置
            photoView.isHidden = false
            photoView.loadBlock = loadBlock
            photoView.photo = photo
        }
        
        //SinglePhotoView 视图控制
        for index in datasource.count..<photoViews.count {
            let photoView = photoViews[index]
            photoView.isHidden = true
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if (datasource.count == 1) {
            let photo = datasource[0]
            let photoW = photo.width
            let photoH = photo.height
            var imgW: CGFloat = 0.0
            var imgH: CGFloat = 0.0
            if photoW != 0.0 && photoH != 0.0 {
                if photoH > photoW {
                    imgH = min(photoH, 163)
                    imgW = imgH * photoW / photoH
                }else{
                    imgW = min(photoW, 163)
                    imgH = imgW * photoH / photoW
                }
            }
            
            let photoView = photoViews[0]
            photoView.frame = CGRect(x: 0, y: 0, width: imgW, height: imgH)
            
            }else if(datasource.count > 1){
                // 总列数
                var totalCols = 3;
                if (datasource.count == 4) {
                    totalCols = 2
                }
            
                let imgW = (self.frame.width - CGFloat((totalCols - 1)) * marginRol) / CGFloat(totalCols)
                let imgH = imgW;

                for i in 0..<datasource.count {
                     let col = i % totalCols
                     let rol = i / totalCols
                     let photoView = photoViews[i]
                     photoView.frame = CGRect(x: (imgW + marginCol) * CGFloat(col), y: (imgH + marginRol) * CGFloat(rol), width: imgW, height: imgH)
                }
           }
        
        if datasource.count > 0 {
            //设置当前view最大高度
            self.frame.size.height = photoViews[datasource.count - 1].frame.maxY
        }else {
            self.frame.size.height = 0
        }
        
        // 最大高度回调
        loadCurrentViewMaxY?(self.frame.maxY)
    }
}

//MARK: - 类扩展（代理回调）
extension NineGridPhotosView: SinglePhotoViewDelegate {

    public func singlePhotoView(with photoViewTapType: SinglePhotoViewTapType) {

        switch photoViewTapType {
        case let .tapImgView(_, singlePhotoView):
            let photoViews = self.photoViews.filter { (photoView) -> Bool in
                return photoView.tag < datasource.count
            }
            delegate?.nineGridPhotosView(with: singlePhotoView.tag, photoViews: photoViews, datasource: datasource)
        default:
            break
        }
    }
}
