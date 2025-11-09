// This is a generated file - do not edit.
//
// Generated from lib/models/pbs/dm.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'dm.pb.dart' as $0;
import 'dm.pbjson.dart';

export 'dm.pb.dart';

abstract class DMServiceBase extends $pb.GeneratedService {
  $async.Future<$0.DmSegMobileReply> dmSegMobile(
      $pb.ServerContext ctx, $0.DmSegMobileReq request);
  $async.Future<$0.DmViewReply> dmView(
      $pb.ServerContext ctx, $0.DmViewReq request);
  $async.Future<$0.Response> dmPlayerConfig(
      $pb.ServerContext ctx, $0.DmPlayerConfigReq request);
  $async.Future<$0.DmSegOttReply> dmSegOtt(
      $pb.ServerContext ctx, $0.DmSegOttReq request);
  $async.Future<$0.DmSegSDKReply> dmSegSDK(
      $pb.ServerContext ctx, $0.DmSegSDKReq request);
  $async.Future<$0.DmExpoReportRes> dmExpoReport(
      $pb.ServerContext ctx, $0.DmExpoReportReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'DmSegMobile':
        return $0.DmSegMobileReq();
      case 'DmView':
        return $0.DmViewReq();
      case 'DmPlayerConfig':
        return $0.DmPlayerConfigReq();
      case 'DmSegOtt':
        return $0.DmSegOttReq();
      case 'DmSegSDK':
        return $0.DmSegSDKReq();
      case 'DmExpoReport':
        return $0.DmExpoReportReq();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'DmSegMobile':
        return dmSegMobile(ctx, request as $0.DmSegMobileReq);
      case 'DmView':
        return dmView(ctx, request as $0.DmViewReq);
      case 'DmPlayerConfig':
        return dmPlayerConfig(ctx, request as $0.DmPlayerConfigReq);
      case 'DmSegOtt':
        return dmSegOtt(ctx, request as $0.DmSegOttReq);
      case 'DmSegSDK':
        return dmSegSDK(ctx, request as $0.DmSegSDKReq);
      case 'DmExpoReport':
        return dmExpoReport(ctx, request as $0.DmExpoReportReq);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => DMServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => DMServiceBase$messageJson;
}
