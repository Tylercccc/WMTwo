#if MIRROR
using Mirror;
#else
using UnityEngine.Networking;
#endif

namespace LlamaSoftware.UNET.Chat.Model
{
#if MIRROR
    public struct ChatMessage : NetworkMessage
#else
    public class ChatMessage : MessageBase
#endif
    {
        public ChatEntry entry;
#if !MIRROR
        public ChatMessage()
        {
            entry = new ChatEntry();
        }
#endif

        public ChatMessage(ChatEntry entry)
        {
            this.entry = entry;
        }

#if !MIRROR
        public override void Serialize(NetworkWriter writer)
        {
            writer.WritePackedUInt32(entry.Channel);
            writer.Write(entry.Message);
            writer.Write(entry.SenderName);
        }

        public override void Deserialize(NetworkReader reader)
        {
            entry.Channel = reader.ReadPackedUInt32();
            entry.Message = reader.ReadString();
            entry.SenderName = reader.ReadString();
        }
#endif
    }

}
