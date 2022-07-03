import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool choolCheckDone = false;
  GoogleMapController? mapController;

  // latitude - 위도, longitude - 경도
  // LatLng에 위도 경도를 하나의 클래스로 넣어줄수 있다.
  static final LatLng companyLatLng = LatLng(
    35.855789798029723,
    128.4887949295878,
  );

  static final double okDistance = 100;

  static final Circle withinDistanceCircle = Circle(
    circleId: CircleId('withinDistanceCircle'),
    // 여러개의 Circle을 사용하는경우 중복처리를 피하기위해 다른 이름으로 해야함
    center: companyLatLng,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: okDistance,
    // radius는 미터 단위로 받음
    strokeColor: Colors.blue,
    //원의 둘레 색상
    strokeWidth: 1,
  );

  static final Circle notWithinDistanceCircle = Circle(
    circleId: CircleId('notWithinDistanceCircle'),
    // 여러개의 Circle을 사용하는경우 중복처리를 피하기위해 다른 이름으로 해야함
    center: companyLatLng,
    fillColor: Colors.red.withOpacity(0.5),
    radius: okDistance,
    // radius는 미터 단위로 받음
    strokeColor: Colors.red,
    //원의 둘레 색상
    strokeWidth: 1,
  );

  static final Circle checkDoneCircle = Circle(
    circleId: CircleId('checkDoneCircle'),
    // 여러개의 Circle을 사용하는경우 중복처리를 피하기위해 다른 이름으로 해야함
    center: companyLatLng,
    fillColor: Colors.green.withOpacity(0.5),
    radius: okDistance,
    // radius는 미터 단위로 받음
    strokeColor: Colors.green,
    //원의 둘레 색상
    strokeWidth: 1,
  );

  static final Marker marker = Marker(
    markerId: MarkerId('marker'), // Circle과 마찬가지로 다른 아이디를 가지고 있어야함
    position: companyLatLng,
  );

  // 우주에서 지구를 내려다보는 시점
  static final CameraPosition initialPosition = CameraPosition(
    target: companyLatLng,
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppbar(),
      body: FutureBuilder(
        // 함수의 상태가 변경될 떄 마다 (로딩중, 로딩끝, 데이터 리턴, 에러) 빌더를 다시 실행해서 화면을 다시 그림
        future: checkPermission(),
        // future안에 들어간 함수가 리턴해준 값을 스탭샷에서 받을수 있다. (Future함수만 가능)

        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 만약 로딩중이면 로딩 로고를 띄워준다
            return Center(
              child: CircularProgressIndicator(), // 로딩중 로고
            );
          }

          if (snapshot.data == '위치 권한이 허가되었습니다.') {
            // 위치 권한이 허가된경우 지도 출력
            return StreamBuilder<Position>(
                stream: Geolocator.getPositionStream(),
                // Position이 바뀔때마다 새로운 위치가 yield 된다.
                // 그러면 snapshot.data가 바뀌므로 빌더가 재실행 된다.
                builder: (context, snapshot) {
                  bool isWithinRange = false;

                  if (snapshot.hasData) {
                    // 데이터가 있으면 true, 없으면 false 리턴해줌
                    final start = snapshot.data!;
                    final end = companyLatLng;

                    final distance = Geolocator.distanceBetween(
                      start.latitude,
                      start.longitude,
                      end.latitude,
                      end.longitude,
                    );

                    if (distance < okDistance) {
                      isWithinRange = true;
                    }
                  }

                  return Column(
                    children: [
                      _CustomGoogleMap(
                        initialPosition: initialPosition,
                        circle: choolCheckDone
                            ? checkDoneCircle
                            : isWithinRange
                                ? withinDistanceCircle
                                : notWithinDistanceCircle,
                        marker: marker,
                        onMapCreated: onMapCreated,
                      ),
                      _ChoolCheckButton(
                        isWithinRange: isWithinRange,
                        choolCheckDone: choolCheckDone,
                        onPressed: onChoolCheckPressed,
                      )
                    ],
                  );
                });
          }

          return Center(
            child: Text(snapshot.data),
          );
        },
      ),
    );
  }

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  onChoolCheckPressed() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // 다이얼로그를 쉽게 만들수 있는 위젯
          title: Text('출근하기'),
          content: Text('출근을 하시겠습니까?'), // 내용
          actions: [
            // 실제로 선택할 수 있는 버튼
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('출근하기'),
            ),
          ],
        );
      },
    );

    if (result) {
      setState(() {
        choolCheckDone = true;
      });
    }
  }

  // 권한관련된 작업은 무조건 async 유저의 응답을 기다려야하므로
  Future<String> checkPermission() async {
    // 권환을 얻는 함수
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    // 현재 휴대폰의 위치 서비스가 활성화가 되어 있는지 확인 -> 활성화 안되있으면  false 반환

    if (!isLocationEnabled) {
      // 위치 서비스가 비활성화상태면 활성화 요청 메시지 던짐
      return '위치 서비스를 활성화 해주세요.';
    }

    // 현재 앱이 가지고 있는 위치 서비스 권한이 어떻게 되는지 확인
    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) {
      // 서비스 권한 거부된 상태
      checkedPermission =
          await Geolocator.requestPermission(); // 서비스 권한 요청하는 다이얼로그 출력

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요';
      }
    }
    if (checkedPermission == LocationPermission.deniedForever) {
      // deneidForever 상태가되면 개발자가 다이얼로그를 띄워 요청을 할 방법이 없음
      return '앱의 위치 권한을 세팅에서 허가해주세요';
    }

    return '위치 권한이 허가되었습니다.';
  }

  AppBar renderAppbar() {
    return AppBar(
      title: Text(
        '오늘도 출근',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () async {
            if (mapController == null) {
              return;
            }
            final location =
                await Geolocator.getCurrentPosition(); // 현재 위치를 받아옴
            mapController!.animateCamera(CameraUpdate.newLatLng(
              LatLng(
                location.latitude,
                location.longitude,
              ),
            ));
          },
          color: Colors.blue,
          icon: Icon(Icons.my_location),
        )
      ],
    );
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final CameraPosition initialPosition;
  final Circle circle;
  final Marker marker;
  final MapCreatedCallback onMapCreated;

  const _CustomGoogleMap({
    required this.initialPosition,
    required this.circle,
    required this.marker,
    required this.onMapCreated,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 2,
        child: GoogleMap(
          initialCameraPosition: initialPosition,
          mapType: MapType.normal,
          // 값에 따라 지도 종류가 달라짐
          myLocationEnabled: true,
          // 현재 내위치 출력
          myLocationButtonEnabled: false,
          // 내 위치로 가기 버튼
          circles: Set.from([
            circle,
          ]),
          // set<Circle> 타입이 들어감
          markers: Set.from([marker]),
          onMapCreated: onMapCreated,
        ));
  }
}

class _ChoolCheckButton extends StatelessWidget {
  final bool isWithinRange;
  final VoidCallback onPressed;
  final bool choolCheckDone;

  const _ChoolCheckButton({
    required this.isWithinRange,
    required this.onPressed,
    required this.choolCheckDone,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timelapse_outlined,
            size: 50,
            color: choolCheckDone
                ? Colors.green
                : isWithinRange
                    ? Colors.blue
                    : Colors.red,
          ),
          const SizedBox(height: 20),
          if (!choolCheckDone && isWithinRange)
            TextButton(
              onPressed: onPressed,
              child: Text('출근하기'),
            ),
        ],
      ),
    );
  }
}
