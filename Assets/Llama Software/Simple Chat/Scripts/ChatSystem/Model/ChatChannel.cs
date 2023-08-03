using System;
using UnityEngine;

namespace LlamaSoftware.UNET.Chat.Model
{
    /// <summary>
    /// Model for Chat Channels. 
    /// </summary>
    [Serializable]
    public struct ChatChannel
    {
        /// <summary>
        /// Name of the channel.
        /// </summary>
        public string Name;
        /// <summary>
        /// Color the channel.
        /// </summary>
        public Color color;
        /// <summary>
        /// Unique identifier for teh channel.
        /// </summary>
        public uint Channel;
    }
}
