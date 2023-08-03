namespace LlamaSoftware.UNET.Chat.Model
{
    /// <summary>
    /// Model for a chat message entry. Contains the <see cref="Message"/>, <see cref="Channel"/>, <see cref="SenderName"/>. 
    /// You may extend this if you require additional information to be sent over the network. You will likely have to also update <see cref="ChatMessageFunctions"/> serialize functions as well if you do.
    /// </summary>
    public struct ChatEntry
    {
        /// <summary>
        /// The actual message to be sent over the network
        /// </summary>
        public string Message;
        /// <summary>
        /// The Chat Channel the message is being sent on.
        /// </summary>
        public uint Channel;
        /// <summary>
        /// The name of the player sending the message.
        /// </summary>
        public string SenderName;
    }
}
