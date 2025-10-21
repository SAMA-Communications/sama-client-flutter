
//here can be all remote requests like in api folder
// Future<List<Conversation>> fetchConversations([int startIndex = 0]) async {
//   return SamaConnectionService.instance
//       .sendRequest(conversationsRequest, {}).then((response) {
//     List<Conversation> conversations;
//     List<dynamic> items = List.of(response['conversations']);
//     if (items.isEmpty) {
//       conversations = [];
//     } else {
//       conversations =
//           items.map((element) => Conversation.fromJson(element)).toList();
//     }
//     return conversations;
//   });
// }