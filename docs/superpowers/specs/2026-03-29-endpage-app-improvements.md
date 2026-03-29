# ENDPAGE App 改进设计文档

> 日期：2026-03-29
> 状态：已批准

---

## 1. 时区修复

后端 `check_time` 使用 `datetime.now(timezone.utc)` 存储 UTC 时间。前端 `CheckRecord.fromJson` 中 `DateTime.parse()` 未转换时区，导致显示时间比本地时间差 8 小时（UTC+8）。

**修复方案：** 在 `CheckRecord.fromJson` 中将 UTC 时间转为本地时间：`DateTime.parse(json['check_time']).toLocal()`

**影响范围：** 打卡页签到/签退时间、历史页所有记录时间。

---

## 2. 打卡页精简

移除打卡页底部的"工时"StatCard，只保留签到时间 + 签退时间两个卡片（2列布局）。

---

## 3. 历史页增加工时统计

在历史页顶部统计区域增加**本月总工时**卡片，按签到-签退配对计算。计算逻辑已在 `CheckState.workedMinutes` 中实现，复用到历史页。

---

## 4. 头像系统

### 4.1 预设头像
- 6 张 Micah 风格卡通插画（已下载到 `assets/avatars/`）
- 文件：avatar_1.png ~ avatar_6.png

### 4.2 相册选图
- 使用 `image_picker` 包从相册选择照片
- 裁剪为正方形显示为圆形

### 4.3 存储
- 头像选择纯本地存储（SharedPreferences 存储选择的预设头像索引或自定义图片路径）
- 不上传服务器

### 4.4 个人中心布局
- 头像区域内容居中（Column crossAxisAlignment: center）
- 点击头像弹出 BottomSheet 选择面板
- 删除之前的"拍照换人脸"逻辑（人脸重录保留在系统设置里）

### 4.5 头像全局生效
- 打卡页右上角用户头像同步显示
- 使用 Riverpod Provider 管理头像状态

---

## 5. 已完成项

- ✅ 底部导航栏：改为 Expanded 均分 + 底部圆点指示器
- ✅ 位置距离显示：Haversine 公式计算并显示"距离 XXX 米"
- ✅ 个人中心：已删除本月工时和考勤评分
