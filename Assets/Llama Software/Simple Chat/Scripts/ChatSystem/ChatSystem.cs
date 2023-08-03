using System.Collections.Generic;
using System.Text.RegularExpressions;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using LlamaSoftware.UNET.Chat.Model;
#if MIRROR
using Mirror;
#else
using UnityEngine.Networking;
#endif
using UnityEngine.UI;

namespace LlamaSoftware.UNET.Chat
{
    /// <summary>
    /// The primary manager of the chat system.
    /// Check out the quickstart documentation for prerequisites.
    /// To use, simply drag into a Canvas, Configure the <see cref="ChatChannels"/> to your game's needs, and attach <see cref="ChatPlayer"/> to your root Player objects and configure the default channels.
    /// </summary>
    public class ChatSystem : NetworkBehaviour
    {
        private SyncListChatEntry ChatMessages = new SyncListChatEntry();
        public List<ChatChannel> ChatChannels = new List<ChatChannel>();

        public ContentSizeFitter ContentPanel;
        public TMP_InputField inputField;
        public UIChatMessage ChatMessagePrefab;

        public string TargetedMessageFormat = "Enter message ({0})...";
        public string MessageTemplate = "<color=\"{0}\">({1})</color> {2}: {3}";
        public string HelpText = "Enter Help content here. Rich Text is supported.";
        public List<UIChatMessage> MessagesOnUI = new List<UIChatMessage>();

#if !MIRROR
        private NetworkClient networkClient;
#endif
        public short MessageChannel = 100;

        public int MaxMessages = 100;
        public float HideChatDelay = 10f; //in seconds
        public bool AutoOpenChat = true;
        public bool AutoCloseChat = true;
        public float ScrollToBottomDelay = 0.05f;

        public bool IsOpen;

        //it's magic! not really. This is used to generate hex values for the color specified in the Editor. There's no simple Color.toHex() in 5.4.4
        private const string hexValues = "0123456789ABCDEF";

        public bool EnableWordFilter;
        public List<WordFilter> WordFilters = new List<WordFilter>();
        public bool EnableCommands;
        public List<Command> Commands = new List<Command>();

        public UnityEvent OnChatOpen;
        public UnityEvent OnChatClose;
        public UnityEvent OnSendMessage;

        public MessagePool Pool;

        #region Cached objects to avoid gc allocs which cause stuttering (especially on mobile)
        private const string HideChatMethodName = "HideChat";
        private const string ScrollToBottomMethodName = "ScrollToBottom";
        private const string ColorFormat = "#{0}";
        private const string CommandFormat = "/{0}";
        private const string FadeIn = "FadeIn";
        private const string FadeInNoFocus = "FadeInNoFocus";
        private const string FadeOut = "FadeOut";
        private string replacedText;
        private float RedFloat;
        private float GreenFloat;
        private float BlueFloat;
        private string localPlayerName;
        private ChatEntry entryToSend;
        private UIChatMessage newMessage;
        #endregion

        #region Other cached objects
        private Animator ChatAnimator;
        private TextMeshProUGUI PlaceholderText;
        private ScrollRect ScrollView;
        public uint ChannelToSend;
        private ChatPlayer LocalPlayer;

        #endregion

        #region called by Unity
        private void Awake()
        {
            Pool = MessagePool.CreatePool(MaxMessages, ChatMessagePrefab);
            PlaceholderText = inputField.placeholder.GetComponent<TextMeshProUGUI>();
        }

        private void Start()
        {
#if MIRROR
            NetworkServer.RegisterHandler<ChatMessage>(ReceivedMessage);
#else
            networkClient = NetworkManager.singleton.client;
            NetworkServer.RegisterHandler(MessageChannel, ReceivedMessage);
#endif
            if (isClient)
            {
                ChatMessages.Callback += OnChatMessagesUpdated;
            }

            ChatAnimator = GetComponent<Animator>();
            ScrollView = GetComponentInChildren<ScrollRect>();

            for (int i = 0; i < WordFilters.Count; i++)
            {
                WordFilters[i].regex = new Regex(WordFilters[i].RegularExpression, WordFilters[i].IgnoreCase ? RegexOptions.IgnoreCase : RegexOptions.None);
            }

            FindLocalPlayer();
        }

#if MIRROR
        private void OnChatMessagesUpdated(SyncList<ChatEntry>.Operation op, int itemIndex, ChatEntry oldItem, ChatEntry newItem)
        {
            if (SyncList<ChatEntry>.Operation.OP_ADD.ToString().Equals(op.ToString()))
#else
        /// <summary>
        /// Bound by chatMessages.Callback += OnChatMessagesUpdated.
        /// Adds message to the UI
        /// </summary>
        /// <param name="op"></param>
        /// <param name="itemIndex"></param>
        private void OnChatMessagesUpdated(SyncListStruct<ChatEntry>.Operation op, int itemIndex)
            {
            if (SyncListStruct<ChatEntry>.Operation.OP_ADD.ToString().Equals(op.ToString()))
#endif
            {
                FindLocalPlayer();
                //if you are in the wrong channel, do not create text prefab for that message
                if (LocalPlayer.Channels.Contains(ChatMessages[itemIndex].Channel))
                {
                    CancelInvoke(HideChatMethodName);

                    CreatePrefabAndAddToScreen(ChatMessages[itemIndex]);
                    if (AutoOpenChat)
                    {
                        OpenChat(false, LocalPlayer.ActiveChannel);
                    }

                    TryToHideChat();
                }
            }
            else if (SyncList<string>.Operation.OP_REMOVEAT.ToString().Equals(op.ToString()) && !isServer && MessagesOnUI.Count > MaxMessages)
            {
                // Remove the item from the UI
                MessagesOnUI[itemIndex].gameObject.SetActive(false);
                MessagesOnUI.RemoveAt(itemIndex);
            }
        }

#if MIRROR
        private void ReceivedMessage(NetworkConnectionToClient connection, ChatMessage chatMessage)
        {

#else

        /// <summary>
        /// Bound by NetworkServer.RegisterHandler(messageChannel, ReceivedMessage). 
        /// Reads a message from the network and adds it to the UI.
        /// </summary>
        /// <param name="message"></param>
        private void ReceivedMessage(NetworkMessage message)
        {
            ChatMessage chatMessage = message.ReadMessage<ChatMessage>();
#endif

            ChatMessages.Add(chatMessage.entry);

            //since we only get 1 message at a time, removing the 0 index = the oldest message. 
            //if you have max messages per channel...requires a tad of work on your end :(...  
            //you should filter chatMessages per channel and see if any exceed the limit, and remove the oldest from that channel.
            if (ChatMessages.Count > MaxMessages)
            {
                ChatMessages.RemoveAt(0);
                if (!isServerOnly)
                {
                    MessagesOnUI[0].gameObject.SetActive(false);
                    MessagesOnUI.RemoveAt(0);
                }
            }
        }

        #endregion

        #region Utilities
        #region Public Utilities
        /// <summary>
        /// Enables or disables the word filter.
        /// </summary>
        /// <param name="enabled">Whether or not the word filter should be enabled.</param>
        public void ToggleWordFilter(bool enabled)
        {
            EnableWordFilter = enabled;
        }

        /// <summary>
        /// This is now the preferred way to open the chat. Specify the channel (a valid one) and we will notify the user which channel name their message will go to.
        /// </summary>
        /// <param name="focusInputField">If true, focuses the input field after making the Chat Panel visible</param>
        /// <param name="channel">Default <see cref="ChatChannel"/> to send the message on. Pressing Tab will change this</param>
        public void OpenChat(bool focusInputField, uint channel)
        {
            //note that with 5.3 there is some undesirable behavior here. The message is updated, but placeholders disappear before user starts typing.
            //This was fixed in 5.4. However the chat system is still working fine on 5.3 so I didn't want to force a version upgrade on anyone currently on 5.3. 
            //This feature is quirky until you upgrade to 5.4.
            PlaceholderText.text = string.Format(TargetedMessageFormat, ChatChannels.Find(chatChannel => chatChannel.Channel == channel).Name);
            inputField.ForceLabelUpdate();
            if (!IsOpen)
            {
                IsOpen = true;
                if (focusInputField)
                {
                    ChatAnimator.SetTrigger(FadeIn);
                }
                else
                {
                    ChatAnimator.SetTrigger(FadeInNoFocus);
                }
            }
            else if (focusInputField)
            {
                FocusInputField();
            }

            ChannelToSend = channel;

            if (OnChatOpen != null)
            {
                OnChatOpen.Invoke();
            }
        }

        /// <summary>
        /// Forces the input field to be selected.
        /// </summary>
        public void FocusInputField()
        {
            inputField.ActivateInputField();
            inputField.Select();
        }

        /// <summary>
        /// Sends the messages in the input field over the network, or executes commands if applicable. 
        /// Could be also seen as "SendMessage"
        /// </summary>
        public void UpdateChatMessages()
        {
            CancelInvoke(HideChatMethodName);

            FindLocalPlayer();

            if (!string.IsNullOrEmpty(inputField.text))
            {
                bool isCommand = false;

                if (EnableCommands)
                {
                    // See if the user typed a command
                    foreach (Command command in Commands)
                    {
                        if (inputField.text.StartsWith(string.Format(CommandFormat, command.Name)))
                        {
                            isCommand = true;
                            command.FunctionToCall.Invoke();

                            //if we've selected to send the message after FunctionToCall.Invoke(), we will try to send it. But if the user didn't type anything after the command, then it doesn't make sense to send an empty message 
                            if (command.CallFunctionThenSendMessage && !string.IsNullOrEmpty(inputField.text.Trim()))
                            {
                                isCommand = false; //setting this to false will ensure the chat message is sent, since as you can see below, if(!isCommand) is required to send a message.
                                inputField.text = inputField.text.Substring(command.Name.Length + 1).Trim(); //trimming it clears any additional spaces left at the beginning or end
                            }

                            break;
                        }
                    }
                }
                if (!isCommand)
                {
                    if (LocalPlayer != null)
                    {
                        localPlayerName = LocalPlayer.name;
                    }

                    entryToSend = new ChatEntry();

                    entryToSend.Channel = ChannelToSend;
                    entryToSend.Message = inputField.text;
                    entryToSend.SenderName = localPlayerName;
#if MIRROR
                    NetworkClient.Send(new ChatMessage(entryToSend));
#else
                    networkClient.Send(MessageChannel, new ChatMessage(entryToSend));
#endif

                    if (OnSendMessage != null)
                    {
                        OnSendMessage.Invoke();
                    }
                }

                inputField.text = string.Empty;
            }
            else
            {
                TryToHideChat();
            }
        }

        /// <summary>
        /// Example code to generate help. This can be safely removed.
        /// </summary>
        public void GenerateHelp()
        {
            CancelInvoke(HideChatMethodName);
            newMessage = Pool.GetMessageInstance();
            newMessage.transform.SetParent(ContentPanel.transform, false); // make sure correct parenting exists
            newMessage.transform.SetAsLastSibling(); // since we're using a pool, make sure it's the last message

            newMessage.MessageText.color = Color.yellow;
            newMessage.MessageText.text = HelpText;
            MessagesOnUI.Add(newMessage);

            TryToHideChat();

            //frequently the last message is not properly scrolled into view due to some internals of Unity UI, putting a brief delay ensures proper scrolling
            Invoke(ScrollToBottomMethodName, ScrollToBottomDelay);
        }

        private void TryToHideChat()
        {
            if (AutoCloseChat)
            {
                Invoke(HideChatMethodName, HideChatDelay);
            }
        }

        /// <summary>
        /// Use this to target a specific, known channel
        /// </summary>
        /// <param name="channel">Chat Channel to open chat on</param>
        public void ChangeTargetChannel(int channel)
        {
            OpenChat(true, (uint)channel);
        }

        /// <summary>
        /// Example code.
        /// Called to reach current user's team chat. Since there are 3 team chat channels, we need to find which one the current user is in.
        /// </summary>
        public void ChangeToCurrentUserTeamChannel()
        {
            if (LocalPlayer != null)
            {
                OpenChat(false, LocalPlayer.ActiveChannel);
                string text = inputField.text.Trim();
                if (!text.Contains(" ")) //if user types "/team " or "/team" then presses enter, we should clear the text, but if they type "/team hello" then we should send hello to that channel.
                {
                    inputField.text = string.Empty;
                }
            }
        }

        /// <summary>
        /// Forces the chat panel to close without delay.
        /// </summary>
        public void ForceCloseChat()
        {
            EventSystem.current.SetSelectedGameObject(null);

            HideChat();
        }

        /// <summary>
        /// Add a given chat channel to the list of available channels.
        /// </summary>
        /// <param name="Channel"></param>
        public void AddChatChannel(ChatChannel Channel)
        {
            ChatChannels.Add(Channel);
        }

        /// <summary>
        /// Removes a given chat channel from the list of available channels.
        /// </summary>
        /// <param name="Channel"></param>
        public void RemoveChatChannel(ChatChannel Channel)
        {
            ChatChannels.Remove(Channel);
        }

        /// <summary>
        /// Removes a given chat channel from the list of available channels.
        /// </summary>
        /// <param name="Channel"></param>
        public void RemoveChatChannelWithChannel(uint Channel)
        {
            int index = ChatChannels.FindIndex((channel) => channel.Channel == Channel);

            if (index != -1)
            {
                ChatChannels.RemoveAt(index);
            }
        }

        #endregion

        #region Internal Utilities
        private void CreatePrefabAndAddToScreen(ChatEntry message)
        {
            CancelInvoke(HideChatMethodName);
            newMessage = Pool.GetMessageInstance();
            newMessage.transform.SetParent(ContentPanel.transform, false); // make sure correct parenting exists
            newMessage.transform.SetAsLastSibling(); // since we're using a pool, make sure it's the last message

            ChatChannel ReceivedMessageChannel = ChatChannels.Find(channel => channel.Channel.Equals(message.Channel));

            newMessage.MessageText.text = string.Format(MessageTemplate, GetHexValueForColor(ReceivedMessageChannel.color), ReceivedMessageChannel.Name, message.SenderName, EnableWordFilter ? ReplaceFilteredWords(message.Message) : message.Message);
            newMessage.MessageText.color = Color.white;
            MessagesOnUI.Add(newMessage);

            TryToHideChat();

            //frequently the last message is not properly scrolled into view due to some internals of Unity UI, putting a brief delay ensures proper scrolling
            Invoke(ScrollToBottomMethodName, ScrollToBottomDelay);
        }

        private void HideChat()
        {
            if (IsOpen)
            {
                if (!inputField.gameObject.Equals(EventSystem.current.currentSelectedGameObject))
                {
                    ChatAnimator.SetTrigger(FadeOut);
                    IsOpen = false;

                    if (OnChatClose != null)
                    {
                        OnChatClose.Invoke();
                    }
                }
                else
                {
                    CancelInvoke(HideChatMethodName);
                    Invoke(HideChatMethodName, HideChatDelay);
                }
            }
        }

        private string ReplaceFilteredWords(string rawText)
        {
            replacedText = rawText;

            foreach (WordFilter filter in WordFilters)
            {
                if (filter.regex.IsMatch(replacedText))
                {
                    replacedText = filter.regex.Replace(replacedText, filter.ReplaceWith);
                }
            }

            return replacedText;
        }

        private void ScrollToBottom()
        {
            ScrollView.verticalNormalizedPosition = 0f;
        }

        private void ReactivatePlayerAndDeselectInputField()
        {
            inputField.DeactivateInputField();
        }

        //some magic to convert the rgb to hex value we can use in RichText (eliminates need for secondary text element for player name)
        private string GetHexValueForColor(Color color)
        {
            RedFloat = color.r * 255f;
            GreenFloat = color.g * 255f;
            BlueFloat = color.b * 255f;

            return string.Format(ColorFormat, GetHex(Mathf.FloorToInt(RedFloat / 16)) + GetHex(Mathf.FloorToInt(RedFloat) % 16) + GetHex(Mathf.FloorToInt(GreenFloat / 16)) + GetHex(Mathf.FloorToInt(GreenFloat) % 16) + GetHex(Mathf.FloorToInt(BlueFloat / 16)) + GetHex(Mathf.FloorToInt(BlueFloat) % 16));
        }

        //helper for the above
        private string GetHex(int value)
        {
            return hexValues[value].ToString();
        }
        private void FindLocalPlayer()
        {
            if (LocalPlayer == null)
            {
                LocalPlayer = new List<ChatPlayer>(FindObjectsOfType<ChatPlayer>()).Find(player => player.isLocalPlayer);
            }
        }
        #endregion
        #endregion

        /// <summary>
        /// A simple pool for UI Chat Messages to minimize object creation at runtime and garbage generation by destroying old messages
        /// </summary>
        public class MessagePool
        {
            private Dictionary<int, UIChatMessage> Pool;
            private List<int> AvailableObjects;
            private UIChatMessage Prefab;

            /// <summary>
            /// Number of objects currently available in the pool.
            /// </summary>
            public int AvailableObjectsInPool
            {
                get
                {
                    return AvailableObjects.Count;
                }
            }

            /// <summary>
            /// Current size of the pool.
            /// </summary>
            public int PoolSize
            {
                get
                {
                    return Pool.Count;
                }
            }

            private MessagePool(int size, UIChatMessage Prefab)
            {
                this.Prefab = Prefab;
                Pool = new Dictionary<int, UIChatMessage>(size);
                AvailableObjects = new List<int>();
                for (int i = 0; i < size; i++)
                {
                    Pool.Add(i, CreateObject(i));
                }
            }

            private UIChatMessage CreateObject(int key)
            {
                UIChatMessage instance = GameObject.Instantiate(Prefab);

                instance.Key = key;
                instance.Pool = this;
                instance.gameObject.SetActive(false);

                return instance;
            }

            /// <summary>
            /// Create a new pool with the provided size that will construct objects with the specifed prefab. Returns an instance of the pool.
            /// </summary>
            /// <param name="size">Size of the pool</param>
            /// <param name="Prefab">Prefab to instantiate</param>
            /// <returns>New instance of a message pool.</returns>
            public static MessagePool CreatePool(int size, UIChatMessage Prefab)
            {
                return new MessagePool(size, Prefab);
            }

            /// <summary>
            /// Get an instance of the UIChatMessage prefab from the pool. Will Expand pool size if necessary.
            /// </summary>
            /// <returns>An instantiated prefab from the pool.</returns>
            public UIChatMessage GetMessageInstance()
            {
                if (AvailableObjects.Count == 0)
                {
                    ExpandPoolSize();
                }

                UIChatMessage instance = Pool[AvailableObjects[0]];
                AvailableObjects.RemoveAt(0);

                instance.gameObject.SetActive(true);
                return instance;
            }

            private void ExpandPoolSize()
            {
                Pool.Add(Pool.Keys.Count, CreateObject(Pool.Keys.Count));
            }

            /// <summary>
            /// When discarding a pool object, instead of destroying it, this method should be called after disabling it. 
            /// </summary>
            /// <param name="chatMessage">Instance that should be reallocated into the available pool items.</param>
            public void ReAddInstanceToAvailable(UIChatMessage chatMessage)
            {
                AvailableObjects.Add(chatMessage.Key);
            }
        }
    }


}
