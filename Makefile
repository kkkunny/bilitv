# 生成pb文件
protobuf:
	protoc --dart_out=. lib/models/pbs/dm.proto  # 弹幕

#
icons:
	dart run iconfont_convert --config iconfont.yaml