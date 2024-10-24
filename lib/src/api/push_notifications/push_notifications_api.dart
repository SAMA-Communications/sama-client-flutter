import '../api.dart';
import 'models/models.dart';

const String pushSubscriptionCreate = 'push_subscription_create';
const String pushSubscriptionList = 'push_subscription_list';
const String pushSubscriptionDelete = 'push_subscription_delete';
const String pushEventCreate = 'push_event_create';

Future<PushSubscription> createSubscription(
  String platform,
  String deviceId,
  String token,
) async {
  return SamaConnectionService.instance.sendRequest(pushSubscriptionCreate, {
    'platform': platform,
    'device_udid': deviceId,
    'device_token': token,
  }).then((response) {
    return PushSubscription.fromJson(response['subscription']);
  });
}

Future<List<PushSubscription>> getSubscriptions(String userId) async {
  return SamaConnectionService.instance
      .sendRequest(pushSubscriptionList, {'user_id': userId}).then((response) {
    return List.of(response['subscriptions'])
        .map((subscription) => PushSubscription.fromJson(subscription))
        .toList();
  });
}

Future<bool> deleteSubscription(String deviceId) async {
  return SamaConnectionService.instance.sendRequest(
      pushSubscriptionDelete, {'device_udid': deviceId}).then((response) {
    return bool.tryParse(response['success']?.toString() ?? 'false') ?? false;
  });
}

Future<PushEvent> createEvent(
    List<String> usersIds, String title, String body) async {
  return SamaConnectionService.instance.sendRequest(pushEventCreate, {
    'recipients_ids': usersIds,
    'message': {'title': title, 'body': body}
  }).then((response) {
    return PushEvent.fromJson(response['event']);
  });
}
