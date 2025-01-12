import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:support/common.dart';
import 'package:support/consts.dart';
import 'package:support/models/desktop_render_texture.dart';
import 'package:support/models/platform_model.dart';
import 'package:get/get.dart';

customImageQualityWidget(
    {required double initQuality,
    required double initFps,
    required Function(double) setQuality,
    required Function(double) setFps,
    required bool showFps,
    required bool showMoreQuality}) {
  if (initQuality < kMinQuality ||
      initQuality > (showMoreQuality ? kMaxMoreQuality : kMaxQuality)) {
    initQuality = kDefaultQuality;
  }
  if (initFps < kMinFps || initFps > kMaxFps) {
    initFps = kDefaultFps;
  }
  final qualityValue = initQuality.obs;
  final fpsValue = initFps.obs;

  final RxBool moreQualityChecked = RxBool(qualityValue.value > kMaxQuality);
  final debouncerQuality = Debouncer<double>(
    Duration(milliseconds: 1000),
    onChanged: (double v) {
      setQuality(v);
    },
    initialValue: qualityValue.value,
  );
  final debouncerFps = Debouncer<double>(
    Duration(milliseconds: 1000),
    onChanged: (double v) {
      setFps(v);
    },
    initialValue: fpsValue.value,
  );

  onMoreChanged(bool? value) {
    if (value == null) return;
    moreQualityChecked.value = value;
    if (!value && qualityValue.value > 100) {
      qualityValue.value = 100;
    }
    debouncerQuality.value = qualityValue.value;
  }

  return Column(
    children: [
      Obx(() => Row(
            children: [
              Expanded(
                flex: 3,
                child: Slider(
                  value: qualityValue.value,
                  min: kMinQuality,
                  max: moreQualityChecked.value ? kMaxMoreQuality : kMaxQuality,
                  divisions: moreQualityChecked.value
                      ? ((kMaxMoreQuality - kMinQuality) / 10).round()
                      : ((kMaxQuality - kMinQuality) / 5).round(),
                  onChanged: (double value) async {
                    qualityValue.value = value;
                    debouncerQuality.value = value;
                  },
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Text(
                    '${qualityValue.value.round()}%',
                    style: const TextStyle(fontSize: 15),
                  )),
              Expanded(
                  flex: isMobile ? 2 : 1,
                  child: Text(
                    translate('Bitrate'),
                    style: const TextStyle(fontSize: 15),
                  )),
              // mobile doesn't have enough space
              if (showMoreQuality && !isMobile)
                Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Checkbox(
                          value: moreQualityChecked.value,
                          onChanged: onMoreChanged,
                        ),
                        Expanded(
                          child: Text(translate('More')),
                        )
                      ],
                    ))
            ],
          )),
      if (showMoreQuality && isMobile)
        Obx(() => Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Checkbox(
                      value: moreQualityChecked.value,
                      onChanged: onMoreChanged,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(translate('More')),
                )
              ],
            )),
      if (showFps)
        Obx(() => Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Slider(
                    value: fpsValue.value,
                    min: kMinFps,
                    max: kMaxFps,
                    divisions: ((kMaxFps - kMinFps) / 5).round(),
                    onChanged: (double value) async {
                      fpsValue.value = value;
                      debouncerFps.value = value;
                    },
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Text(
                      '${fpsValue.value.round()}',
                      style: const TextStyle(fontSize: 15),
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      translate('FPS'),
                      style: const TextStyle(fontSize: 15),
                    ))
              ],
            )),
    ],
  );
}

customImageQualitySetting() {
  final qualityKey = 'custom_image_quality';
  final fpsKey = 'custom-fps';

  var initQuality =
      (double.tryParse(bind.mainGetUserDefaultOption(key: qualityKey)) ??
          kDefaultQuality);
  var initFps = (double.tryParse(bind.mainGetUserDefaultOption(key: fpsKey)) ??
      kDefaultFps);

  return customImageQualityWidget(
      initQuality: initQuality,
      initFps: initFps,
      setQuality: (v) {
        bind.mainSetUserDefaultOption(key: qualityKey, value: v.toString());
      },
      setFps: (v) {
        bind.mainSetUserDefaultOption(key: fpsKey, value: v.toString());
      },
      showFps: true,
      showMoreQuality: true);
}

List<Widget> ServerConfigImportExportWidgets(
  List<TextEditingController> controllers,
  List<RxString> errMsgs,
) {
  import() {
    Clipboard.getData(Clipboard.kTextPlain).then((value) {
      importConfig(controllers, errMsgs, value?.text);
    });
  }

  export() {
    final text = ServerConfig(
            idServer: controllers[0].text.trim(),
            relayServer: controllers[1].text.trim(),
            apiServer: controllers[2].text.trim(),
            key: controllers[3].text.trim())
        .encode();
    debugPrint("ServerConfig export: $text");
    Clipboard.setData(ClipboardData(text: text));
    showToast(translate('Export server configuration successfully'));
  }

  return [
    Tooltip(
      message: translate('Import server config'),
      child: IconButton(
          icon: Icon(Icons.paste, color: Colors.grey), onPressed: import),
    ),
    Tooltip(
        message: translate('Export Server Config'),
        child: IconButton(
            icon: Icon(Icons.copy, color: Colors.grey), onPressed: export))
  ];
}

List<(String, String)> otherDefaultSettings() {
  List<(String, String)> v = [
    ('View Mode', 'view_only'),
    if (isDesktop) ('show_monitors_tip', kKeyShowMonitorsToolbar),
    if (isDesktop) ('Collapse toolbar', 'collapse_toolbar'),
    ('Show remote cursor', 'show_remote_cursor'),
    if (isDesktop) ('Zoom cursor', 'zoom-cursor'),
    ('Show quality monitor', 'show_quality_monitor'),
    ('Mute', 'disable_audio'),
    if (isDesktop) ('Enable file copy and paste', 'enable_file_transfer'),
    ('Disable clipboard', 'disable_clipboard'),
    ('Lock after session end', 'lock_after_session_end'),
    ('Privacy mode', 'privacy_mode'),
    if (isMobile) ('Touch mode', 'touch-mode'),
    ('True color (4:4:4)', 'i444'),
    ('Reverse mouse wheel', 'reverse_mouse_wheel'),
    ('swap-left-right-mouse', 'swap-left-right-mouse'),
    if (isDesktop && useTextureRender)
      (
        'Show displays as individual windows',
        kKeyShowDisplaysAsIndividualWindows
      ),
    if (isDesktop && useTextureRender)
      (
        'Use all my displays for the remote session',
        kKeyUseAllMyDisplaysForTheRemoteSession
      )
  ];

  return v;
}
