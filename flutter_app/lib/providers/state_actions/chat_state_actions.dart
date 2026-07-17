part of '../sport_zone_state.dart';

extension ChatStateActions on SportZoneState {
  Future<void> fetchMessages() async {
    final result = await ApiService.getMessages();
    if (result.isSuccess) {
      final raw = result.data;
      if (raw is List) {
        chatMessages.clear();
        chatMessages.addAll(
          raw.whereType<Map<String, dynamic>>().map(
            (json) => ChatMessage.fromJson(json, isCurrentUserAdmin: false),
          ),
        );
        notifyStateChanged();
      }
    }
  }

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add locally for instant UI update
    chatMessages.add(
      ChatMessage(message: message.trim(), isUser: true, isRead: false),
    );
    notifyStateChanged();

    final result = await ApiService.sendMessage(message);
    if (result.isSuccess) {
      await fetchMessages();
    }
  }

  void clearChat() {
    chatMessages.clear();
    notifyStateChanged();
  }
}
