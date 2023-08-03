using System.Collections.Generic;
using TMPro;
using UnityEngine;
using LlamaSoftware.UNET.Chat.Model;
#if MIRROR
using Mirror;
#else
using UnityEngine.Networking;
#endif

namespace LlamaSoftware.UNET.Chat.Demo
{
    public class ChannelUpdater : NetworkBehaviour
    {
        [SerializeField]
        private ChatSystem chatSystem = null;
        [SerializeField]
        private TextMeshProUGUI text = null;
        private ChatPlayer Player = null;
        private ChatChannel ActiveChannel = new ChatChannel();

        public void Start()
        {
            Player = new List<ChatPlayer>(FindObjectsOfType<ChatPlayer>()).Find(player => player.isLocalPlayer);

            if (Player == null)
            {
                Invoke("Start", 0.5f);
                return;
            }

            Player.OnChannelChange.AddListener(OnChannelChange);
        }

        private string ChannelFormat = "Channel: {0}";

        public void OnChannelChange()
        {
            ActiveChannel = chatSystem.ChatChannels.Find((channel) => channel.Channel.Equals(Player.ActiveChannel));
            text.text = string.Format(ChannelFormat, ActiveChannel.Name);
        }
    }
}