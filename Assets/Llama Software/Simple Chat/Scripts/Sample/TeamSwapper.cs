using UnityEngine;
using System.Collections.Generic;

namespace LlamaSoftware.UNET.Chat.Demo
{
    public class TeamSwapper : MonoBehaviour
    {
        [SerializeField]
        private ChatSystem chatSystem = null;
        private int Index = 0;
        private ChatPlayer localPlayer = null;

        private void FindLocalPlayer()
        {
            localPlayer = new List<ChatPlayer>(GameObject.FindObjectsOfType<ChatPlayer>()).Find(player => player.isLocalPlayer);
        }

        public void IncrementTeamForLocalPlayer()
        {
            if (localPlayer == null)
            {
                FindLocalPlayer();
            }

            if (localPlayer.ActiveChannel >= chatSystem.ChatChannels.Count - 1)
            {
                Index = 0;
            }
            else
            {
                Index++;
            }

            localPlayer.ActiveChannel = chatSystem.ChatChannels[Index].Channel;
        }
    }
}
