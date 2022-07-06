import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart'
    as RtcLocalView; // 현재 내가 찍는 영상에 관한거
import 'package:agora_rtc_engine/rtc_remote_view.dart'
    as RtcRmoteView; // 상대방이 찍는 영상에 관한거
import '../const/agora.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({Key? key}) : super(key: key);

  @override
  State<CamScreen> createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? engine; // 아고라 api를 쓸때 컨트롤러같은 역할을 해준다.
  int? uid;
  int? otherUid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIVE'),
      ),
      body: FutureBuilder(
          future: init(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // 에러가 있는 경우
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            if (!snapshot.hasData) {
              // 데이터가 없는 경우
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: Stack(
                  children: [
                    renderMainView(),
                    Align(
                      // 어디에 child 위젯을 배치할지 정해주는 위젯
                      alignment: Alignment.topLeft,
                      child: Container(
                        color: Colors.grey,
                        height: 160,
                        width: 120,
                        child: renderSubView(),
                      ),
                    ),
                  ],
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                      onPressed: () async {
                        if (engine != null) {
                          await engine!.leaveChannel(); // 채널 나가기
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text('채널 나가기')),
                ),
              ],
            );
          }),
    );
  }

  Widget renderSubView() {
    if (otherUid == null) {
      // 상대방이 채널에 들어오지 않은경우
      return Center(
        child: Text('채널에 유저가 없습니다.'),
      );
    } else {
      return RtcRmoteView.SurfaceView(
        // 어떤 채널의 어떤 유저의 화면을 띄울지 알려주기위해
        // renderMainView()와 달리 파라미터 넣어준다.
        uid: otherUid!,
        channelId: CHANNEL_NAME,
      );
    }
  }

  Widget renderMainView() {
    if (uid == null) {
      return Center(
        child: Text('채널에 참여 해주세요'),
      );
    } else {
      return RtcLocalView.SurfaceView();
    }
  }

  Future<bool> init() async {
    final resp = await [Permission.camera, Permission.microphone]
        .request(); // 카메라, 마이크 권한 요청

    final cameraPermission = resp[Permission.camera];
    final micPermission = resp[Permission.microphone];

    // 권한이 없는 경우
    if (cameraPermission != PermissionStatus.granted ||
        micPermission != PermissionStatus.granted) {
      throw '카메라 또는 마이크 권한이 없습니다.';
    }

    if (engine == null) {
      // 만약 엔진이 없으면 엔진 생성
      RtcEngineContext context = RtcEngineContext(APP_ID);

      engine = await RtcEngine.createWithContext(context); // 엔진 생성

      engine!.setEventHandler(
        // Stream의 addListener처럼 특정 기능이 실행되면 특정 함수를 실행
        RtcEngineEventHandler(
            joinChannelSuccess: (String channel, int uid, int elapsed) {
          // joinChannel이 성공적으로 되면 불리는 함수
          print('채널에 입장했습니다. uid: $uid');
          setState(() {
            this.uid = uid;
          });
        }, leaveChannel: (state) {
          print('채널 퇴장');
          setState(() {
            uid = null;
          });
        }, userJoined: (int uid, int elapsed) {
          // 상대가 들어왔을때
          print('상대가 채널에 입장했습니다. uid: $uid');
          setState(() {
            otherUid = uid;
          });
        }, userOffline: (int uid, UserOfflineReason reason) {
          // 상대가 나간경우
          print('상대가 채널에서 나갔습니다. uid : $uid');
          setState(() {
            otherUid = null;
          });
        }),
      );

      // 비디오 활성화
      await engine!.enableVideo();
      // 채널에 들어가기
      await engine!.joinChannel(
        TEMP_TOKEN,
        CHANNEL_NAME,
        null, // optionalInfo
        0, // int값 넣어줄수 있음 (무조건 유니크한 값) -> 0을 넣으면 아고라API가 알아서 유니크 키값 배정해준다.
      );
    }

    // 권한이 있는 경우
    return true;
  }
}
