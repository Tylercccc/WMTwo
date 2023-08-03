using TMPro;
using UnityEngine;

/*  keep the appropriate elements of a chat message in order
    this can get complex depending on how you want to structure your messages.
    for the purposes this was originally developed for, this is sufficient. 
    You can change the color (as done in ChatSystem.cs) and text of each message. 
    When you first get this, MessageText will always be white, and PlayerNameText will vary depending on the channel it was sent to.
*/
namespace LlamaSoftware.UNET.Chat
{
    public class UIChatMessage : MonoBehaviour
    {
        public TextMeshProUGUI MessageText;

        // These are used to lower performance impact and garbage of generating and destroying objects, see: https://en.wikipedia.org/wiki/Object_pool_pattern
        [HideInInspector]
        public ChatSystem.MessagePool Pool;
        [HideInInspector]
        public int Key;

        public void OnDisable()
        {
            Pool.ReAddInstanceToAvailable(this);
        }
    }
}
