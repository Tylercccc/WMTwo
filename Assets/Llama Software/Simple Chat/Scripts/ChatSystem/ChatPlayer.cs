using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
#if MIRROR
using Mirror;
#else
using UnityEngine.Networking;
#endif

namespace LlamaSoftware.UNET.Chat
{
    public class ChatPlayer : NetworkBehaviour
    {
        [SyncVar]
        public string Name;
        [SyncVar]
        public string Id;
        public List<uint> Channels = new List<uint>(new uint[] { 0 });
        public uint ActiveChannel;
        public bool UseForInputHandling;

        public UnityEvent OnChannelChange;

        private ChatSystem chatSystem;
        private int Index;

        private void Start()
        {
            if (isServer)
            {
                Id = System.Guid.NewGuid().ToString();
            }

            if (isLocalPlayer)
            {
                chatSystem = GameObject.FindObjectOfType<ChatSystem>();
                ActiveChannel = Channels[0];
                this.name = Name;
            }
            else
            {
                enabled = false;
            }
        }

        public void JoinChannel(uint Channel)
        {
            if (!Channels.Contains(Channel))
            {
                Channels.Add(Channel);
            }
        }

        public void LeaveChannel(uint Channel)
        {
            if (Channels.Contains(Channel))
            {
                Channels.Remove(Channel);
            }
        }

        private void Update()
        {
            if (UseForInputHandling)
            {
                if (Input.GetKeyUp(KeyCode.Return) && (!chatSystem.IsOpen || string.IsNullOrEmpty(chatSystem.inputField.text)))
                {
                    chatSystem.OpenChat(true, ActiveChannel);
                }
                else if (chatSystem.IsOpen && string.IsNullOrEmpty(chatSystem.inputField.text) && Input.GetKeyUp(KeyCode.Tab))
                {
                    Index = Channels.FindIndex((item) => item == ActiveChannel) + 1;
                    if (Index == -1 || Index == Channels.Count)
                    {
                        ActiveChannel = Channels[0];
                    }
                    else
                    {
                        ActiveChannel = Channels[Index];
                    }

                    if (OnChannelChange != null)
                    {
                        OnChannelChange.Invoke();
                    }

                    chatSystem.OpenChat(true, ActiveChannel);
                }
                else if (Input.GetKeyUp(KeyCode.Escape))
                {
                    chatSystem.ForceCloseChat();
                    chatSystem.inputField.text = string.Empty;
                }
            }
        }

        /// <summary>
        /// Sets the player's name
        /// </summary>
        /// <param name="Name"></param>
        [Command]
        public void CmdSetName(string Name)
        {
            name = Name;
            this.Name = Name;
        }
    }
}
