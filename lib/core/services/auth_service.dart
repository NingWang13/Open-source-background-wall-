import 'dart:async';
import 'package:flutter/material.dart';

/// 用户模型
class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

/// 认证服务 - 简化版（无 Firebase）
class AuthService {
  static AppUser? _currentUser;
  static final _userController = StreamController<AppUser?>.broadcast();
  
  static Stream<AppUser?> get userStream => _userController.stream;
  static AppUser? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  /// 初始化
  static Future<void> initialize() async {
    // 检查本地存储的登录状态
    // 这里可以后续对接 SharedPreferences 等
  }

  /// 邮箱密码登录
  static Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    // 模拟登录
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = AppUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
    );
    
    _userController.add(_currentUser);
    return _currentUser!;
  }

  /// 注册
  static Future<AppUser> createUserWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = AppUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
    );
    
    _userController.add(_currentUser);
    return _currentUser!;
  }

  /// Google 登录
  static Future<AppUser> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = AppUser(
      uid: 'google_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@gmail.com',
      displayName: 'Google User',
      photoUrl: 'https://via.placeholder.com/100',
    );
    
    _userController.add(_currentUser);
    return _currentUser!;
  }

  /// GitHub 登录
  static Future<AppUser> signInWithGitHub() async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = AppUser(
      uid: 'github_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@github.com',
      displayName: 'GitHub User',
    );
    
    _userController.add(_currentUser);
    return _currentUser!;
  }

  /// 微信登录
  static Future<AppUser> signInWithWeChat() async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = AppUser(
      uid: 'wechat_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@wechat.com',
      displayName: 'WeChat User',
    );
    
    _userController.add(_currentUser);
    return _currentUser!;
  }

  /// 登出
  static Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
  }

  /// 发送密码重置邮件
  static Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Password reset email sent to $email');
  }

  /// 更新用户名
  static Future<void> updateDisplayName(String name) async {
    if (_currentUser != null) {
      _currentUser = AppUser(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        displayName: name,
        photoUrl: _currentUser!.photoUrl,
      );
      _userController.add(_currentUser);
    }
  }
}
