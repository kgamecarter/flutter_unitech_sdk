# unitech_sdk_example

這個範例保留兩個 Dart 檔案，示範掃描器、時間設定及應用程式管理：

- `lib/main.dart`：畫面、文字輸入框，以及建立／釋放 ViewModel。
- `lib/demo_view_model.dart`：呼叫 SDK、接收掃描資料、處理執行中與錯誤狀態。

資料流是 `畫面 → DemoViewModel → UnitechSdk → Android`。
SDK 本身已封裝裝置存取，因此範例不再增加 Repository、Use Case、
依賴注入容器或程式碼產生器。

## 執行

在此目錄執行：

```sh
flutter pub get
flutter run
```

裝置功能需要 Unitech Android 手持裝置；安裝 APK、系統指令及時間設定
可能需要裝置提供的系統權限。

## 閱讀重點

1. `main.dart` 建立 `DemoViewModel(sdk: UnitechSdk())`，再呼叫 `initialize()`。
2. `ListenableBuilder` 在 ViewModel 狀態變動時更新畫面。
3. 按鈕只傳入輸入內容；驗證、等待結果與錯誤處理由 ViewModel 負責。
4. 畫面離開時釋放 ViewModel，取消掃描訂閱並關閉其 SDK 接收器。

掃描開關初始值是範例預設值；後續表示最後成功送出的設定，
不是從硬體讀回的狀態。「Command sent」表示 API 呼叫完成，
不代表 APK 已安裝完成或所有裝置動作都已完成。

## 測試

```sh
flutter test
```

測試注入 `FakeSdk`，不需要真實裝置，也不會安裝 APK 或執行系統指令。