import 'package:flutter/material.dart';
import 'package:smart_diary/comm/asset_manager.dart';

class LoadingView extends StatefulWidget {
  Widget child;

  Widget? idleWidget;

  Widget? emptyWidget;

  Function? todoAfterError;

  Function? todoAfterNetworkBlocked;

  String? networkBlockedDesc;

  String? errorDesc;

  LoadingStatus loadingStatus;

  /// 构造方法
  LoadingView({
    Key? key,
    required this.child, // 需要加载的Widget
    this.todoAfterError, // 错误点击重试
    this.todoAfterNetworkBlocked, // 网络错误点击重试
    this.networkBlockedDesc = "网络连接超时，请检查你的网络环境",
    this.errorDesc = "加载失败",
    this.loadingStatus = LoadingStatus.idle,
    this.emptyWidget,
    this.idleWidget,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LoadingViewState();
  }
}

class _LoadingViewState extends State<LoadingView> {
  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  ///根据不同状态展示不同Widget
  Widget _buildBody() {
    switch (widget.loadingStatus) {
      case LoadingStatus.idle:
        if (widget.idleWidget != null) {
          return widget.idleWidget!;
        }
        return const SizedBox();
      case LoadingStatus.loading:
        return _buildLoadingView();
      case LoadingStatus.loadingSuc:
        return widget.child;
      case LoadingStatus.loadingSucButEmpty:
        return _buildLoadingSucButEmptyView();
      case LoadingStatus.error:
        return _buildErrorView();
      case LoadingStatus.networkBlocked:
        return _buildNetworkBlockedView();
    }
    return widget.child;
  }

  /// 加载中 View
  Widget _buildLoadingView() {
    return  Container(
      color: Theme.of(context).primaryColor,
      width: double.maxFinite,
      height: double.maxFinite,
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  /// 编译通用页面
  Container _buildGeneralTapView({
    required String desc,
    required Function onTap,
  }) {
    return Container(
      color: Theme.of(context).primaryColor,
      width: double.maxFinite,
      height: double.maxFinite,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  onTap();
                },
                child: Image(image: AssetImage(AssetManager.png('empty')), width: 230.0, color: Theme.of(context).buttonColor)),
            Text(
              desc,
              style: TextStyle(color: Theme.of(context).textSelectionColor, fontSize: 25),
            )
          ],
        ),
      ),
    );
  }

  /// 加载成功但数据为空 View
  Widget _buildLoadingSucButEmptyView() {
    if (widget.emptyWidget == null) {
      return _buildGeneralTapView(
        desc: "空空如也",
        onTap: () {},
      );
    } else {
      return widget.emptyWidget!;
    }
  }

  /// 网络加载错误页面
  Widget _buildNetworkBlockedView() {
    return _buildGeneralTapView(
        desc: widget.networkBlockedDesc ?? '网络错误',
        onTap: () {
          widget.todoAfterNetworkBlocked?.call();
        });
  }

  /// 加载错误页面
  Widget _buildErrorView() {
    return _buildGeneralTapView(
        desc: widget.errorDesc ?? '加载错误',
        onTap: () {
          widget.todoAfterError?.call();
        });
  }
}

/// 状态枚举
enum LoadingStatus {
  idle, // 初始化
  loading, // 加载中
  loadingSuc, // 加载成功
  loadingSucButEmpty, // 加载成功但是数据为空
  networkBlocked, // 网络加载错误
  error, // 加载错误
}
