# LayerTreeInspector

## iOS-LayerTreeInspector
>  This is a tool to inspect your view hierarchys on your iphone at realtime,Provide two ways to view hierarchys：one is the general flat tree structure and anothe is three-dimensional form，So you can get out of Xcode and reach the result you want

> 这是一个可以在你的iphone手机上实时查看视图层级的工具，提供两种查看的方式，一种是平面的树形结构，另一种就是3D立体的查看方式，因此你可以脱离Xcode，达到你想要的结果。

#### [掘金地址：iOS-LayerTreeInspector](https://juejin.im/post/5a80372af265da4e8837a97b)

## 一、 功能简介

#### 1、支持两种查看视图层级的方式，一种是平面的面包屑形式，另一种是类似xcode的3D的形式。
#### 2、普通面包屑形式:
*  支持运行时修改任意`view`的`frame`、`alpha`、`backgroundColor`，并会实时展示修改后的值。
*  支持刷新层级树，并会优先展示当前topViewController的视图层级。
*  支持层级树的回退,可以一直回退至rootWindow。
*  查看过程中，view如果释放，会在层级树中进行展示，禁止用户操作已经释放的view。

#### 3D形式：
* 支持3D旋转与缩放
* 支持3D视图下，点击某一视图查看具体信息。所点击的视图会变色，下方的`debugview`中，会显示该视图在层级树中的位置和该视图的具体信息。

## 二、安装及使用
#### 安装
* 手动：将`LayerTreeInspector`文件夹下的所有文件拖入项目。
* `CocoaPod`:`podfile`中加入`pod 'LayerTreeInspector'`
#### 使用
```
//Appdelegate中，创建完rootWindow并makeKeyAndVisible后
[LayerTreeInspector showDebugView];
```
## 三、效果展示

#### 1、平面-基本操作

![平面-基本操作](https://user-gold-cdn.xitu.io/2018/2/11/16185101018246a8?w=369&h=621&f=gif&s=2339408)

#### 2、平面-回退与释放

![](https://user-gold-cdn.xitu.io/2018/2/11/16185143357302e7?w=345&h=583&f=gif&s=2623961)

#### 3、3D-旋转|缩放

![3D-旋转|缩放](https://user-gold-cdn.xitu.io/2018/2/11/161850a48b64817e?w=369&h=621&f=gif&s=3594387)

#### 4、3D-点击与重置

![3D-点击与重置](https://user-gold-cdn.xitu.io/2018/2/11/161850aba0e1c116?w=369&h=621&f=gif&s=3141368)

## 四、源码下载
Github:[LayerTreeInspector](https://github.com/sunday1990/LayerTreeInspector)


[![CI Status](https://img.shields.io/travis/sunday1990/LayerTreeInspector.svg?style=flat)](https://travis-ci.org/sunday1990/LayerTreeInspector)
[![Version](https://img.shields.io/cocoapods/v/LayerTreeInspector.svg?style=flat)](https://cocoapods.org/pods/LayerTreeInspector)
[![License](https://img.shields.io/cocoapods/l/LayerTreeInspector.svg?style=flat)](https://cocoapods.org/pods/LayerTreeInspector)
[![Platform](https://img.shields.io/cocoapods/p/LayerTreeInspector.svg?style=flat)](https://cocoapods.org/pods/LayerTreeInspector)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LayerTreeInspector is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LayerTreeInspector'
```

## Author

sunday1990, “935143023@qq.com”

## License

LayerTreeInspector is available under the MIT license. See the LICENSE file for more info.
