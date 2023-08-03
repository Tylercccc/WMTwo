using UnityEngine;
using UnityEngine.UI;

namespace LlamaSoftware.UNET.Chat.Demo
{
    [RequireComponent(typeof(Toggle))]
    public class LanguageFilterToggle : MonoBehaviour
    {
        [SerializeField]
        private ChatSystem chatSystem = null;
        [SerializeField]
        private Toggle toggle = null;

        private void Start()
        {
            toggle = GetComponent<Toggle>();
        }

        public void onToggle()
        {
            chatSystem.ToggleWordFilter(toggle.isOn);
        }
    }
}
