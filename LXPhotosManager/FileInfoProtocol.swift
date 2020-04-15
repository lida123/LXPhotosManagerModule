//
//  FileInfoProtocol.swift
//  LXPhotosView
//
//  Created by Mac on 2020/4/11.
//  Copyright © 2020 李响. All rights reserved.
//

import UIKit


@objc public protocol FileInfoProtocol {

   @objc var image:  UIImage { get set }
   @objc var height: CGFloat { get set }
   @objc var width:  CGFloat { get set }
   @objc var imgUrl: String  { get set }

}
