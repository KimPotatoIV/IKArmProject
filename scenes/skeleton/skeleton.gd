extends Node2D

##################################################
const ITERATIONS: int = 10
# 최대 반복 횟수
const TOLERANCE: float = 0.1
# 목표 위치와의 오차 범위

var upper_arm_node: Sprite2D
var lower_arm_node: Sprite2D
var hand_node: Sprite2D
var shoulder_marker_node: Marker2D
var elbow_marker_node: Marker2D
var wrist_marker_node: Marker2D
var hand_end_marker_node: Marker2D

##################################################
func _ready() -> void:
	upper_arm_node = $UpperArm
	lower_arm_node = $UpperArm/LowerArm
	hand_node = $UpperArm/LowerArm/Hand
	shoulder_marker_node = $ShoulderMarker
	elbow_marker_node = $UpperArm/ElbowMarker
	wrist_marker_node = $UpperArm/LowerArm/WristMarker
	hand_end_marker_node = $UpperArm/LowerArm/Hand/HandMarker
	# 상완과 하완, 마커 노드를 가져옴

##################################################
func _process(delta: float) -> void:
	var target_position: Vector2 = get_global_mouse_position()
	# 마우스 위치를 목표 위치로 설정
	ccd_ik(target_position)
	# CCD IK 알고리즘 적용

##################################################
func ccd_ik(target_position: Vector2) -> void:
	for i in range(ITERATIONS):
	# 최대 반복 횟수만큼 수행
		var hand_end_position: Vector2 = hand_end_marker_node.global_position
		# 현재 끝점(손끝의 마커)의 위치를 계산
		
		var distance: float = hand_end_position.distance_to(target_position)
		# 손끝부터 목표 지점까지의 거리 계산

		if distance < TOLERANCE:
			break
		# 목표 위치와 충분히 가까우면 반복 종료
		
		'''
		▶ 1차 회전
		 ㄴ 손목부터 목표점까지의 정규 벡터를 구한다
		 ㄴ 손목부터 손끝까지의 정규 벡터를 구한다
		 ㄴ 두 각도 차이를 구한다
		 ㄴ 구한 각도만큼 회전한다
		
		▶ 2차 회전
		 ㄴ 팔꿈치부터 목표점까지의 정규 벡터를 구한다
		 ㄴ 팔꿈치부터 손끝까지의 정규 벡터를 구한다
		 ㄴ 두 각도 차이를 구한다
		 ㄴ 구한 각도만큼 회전한다
		
		▶ 3차 회전
		 ㄴ 어깨부터 목표점까지의 정규 벡터를 구한다
		 ㄴ 어깨부터 손끝까지의 정규 벡터를 구한다
		 ㄴ 두 각도 차이를 구한다
		 ㄴ 구한 각도만큼 회전한다
		'''
		
		var hand_to_target: Vector2 = \
			(target_position - wrist_marker_node.global_position).normalized()
		var hand_to_direction: Vector2 =\
			(hand_end_position - wrist_marker_node.global_position).normalized()
		var hand_angle: float = hand_to_direction.angle_to(hand_to_target)
		hand_node.rotation += hand_angle
		# 손목 회전 적용
		hand_end_position = hand_end_marker_node.global_position
		# 새로운 끝점 위치 계산

		var lower_arm_to_target: Vector2 = \
			(target_position - elbow_marker_node.global_position).normalized()
		var lower_arm_direction: Vector2 = \
			(hand_end_position - elbow_marker_node.global_position).normalized()
		var lower_arm_angle: float = lower_arm_direction.angle_to(lower_arm_to_target)
		# 하완(Lower Arm) 회전 계산
		lower_arm_node.rotation += lower_arm_angle
		# 하완 회전 적용
		hand_end_position = hand_end_marker_node.global_position
		# 새로운 끝점 위치 계산
		
		var upper_arm_to_target: Vector2 = \
			(target_position - shoulder_marker_node.global_position).normalized()
		var upper_arm_direction: Vector2 = \
			(hand_end_position - shoulder_marker_node.global_position).normalized()  # 팔꿈치가 아닌 손끝으로부터의 방향
		var upper_arm_angle: float = upper_arm_direction.angle_to(upper_arm_to_target)
		# 상완(Upper Arm) 회전 계산
		upper_arm_node.rotation += upper_arm_angle
		# 상완 회전 적용
