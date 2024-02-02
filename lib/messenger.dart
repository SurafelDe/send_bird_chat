
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class Messenger {
  final String appId = "BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF";
  String userId;
  String channelUrl = 'sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211';
  User? user;
  OpenChannel? openChannel;

  String title = '';
  bool hasPrevious = false;
  List<BaseMessage> messageList = [];
  int? participantCount;

  Messenger(this.userId);

  initialize() async {
    SendbirdChat.init(appId: appId);
    user = await SendbirdChat.connect(userId, nickname: "surafeld");
  }

  late PreviousMessageListQuery query;
}
