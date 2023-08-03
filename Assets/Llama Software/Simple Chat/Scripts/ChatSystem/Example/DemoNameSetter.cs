using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace LlamaSoftware.UNET.Chat.Demo
{
    [RequireComponent(typeof(ChatPlayer))]
    public class DemoNameSetter : MonoBehaviour
    {
        /// <summary>
        /// Name to override the player's name with
        /// </summary>
        public string Name = "Llama Lover Name";
        /// <summary>
        /// After this delay, the name will be updated on the server.
        /// </summary>
        [Tooltip("Name will be set after this many seconds")]
        public float SetNameDelay = 2;

        IEnumerator Start()
        {
            yield return new WaitForSeconds(SetNameDelay);
            GetComponent<ChatPlayer>().CmdSetName(Name);
        }
    }
}
