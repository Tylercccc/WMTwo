#if MIRROR
using Mirror;

namespace LlamaSoftware.UNET.Chat.Model
{
    public static class ChatMessageFunctions
    {
        public static void Serialize(this NetworkWriter writer, ChatMessage chatMessage)
        {
            writer.Write(chatMessage.entry.Channel);
            writer.Write(chatMessage.entry.Message);
            writer.Write(chatMessage.entry.SenderName);
        }

        public static ChatMessage Deserialize(this NetworkReader reader)
        {
            return new ChatMessage()
            {
                entry = new ChatEntry()
                {
                    Channel = reader.Read<uint>(),
                    Message = reader.Read<string>(),
                    SenderName = reader.Read<string>()
                }
            };
        }
    }
}

#endif