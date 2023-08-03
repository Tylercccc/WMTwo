using System.Collections.Generic;
using UnityEngine;
#if MIRROR
using Mirror;
#else
using UnityEngine.Networking;
#endif
using UnityEngine.UI;

namespace LlamaSoftware.UNET.Chat.Demo
{
    [RequireComponent(typeof(Toggle))]
    public class TeamJoiner : NetworkBehaviour
    {
        [SerializeField]
        private uint Channel = 0;
        private ChatPlayer Player = null;
        private Toggle toggle = null;

        private void Awake()
        {
            toggle = GetComponent<Toggle>();
        }

        private void Start()
        {
            Player = new List<ChatPlayer>(GameObject.FindObjectsOfType<ChatPlayer>()).Find(player => player.isLocalPlayer);
        }

        public void ToggleChannel()
        {
            if (Player == null)
            {
                Start();
            }

            if (toggle.isOn)
            {
                Player.JoinChannel(Channel);
            }
            else
            {
                Player.LeaveChannel(Channel);
            }
        }
    }
}
