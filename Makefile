# 生成pb文件
gen_protobuf:
	protoc --dart_out=. lib/models/pbs/dm.proto  # 弹幕

# 生成icon
gen_icons:
	dart run iconfont_convert --config iconfont.yaml