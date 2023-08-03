#if UNITY_EDITOR
using LlamaSoftware.UNET.Chat.Model;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace LlamaSoftware.UNET.Chat.Editors
{
    [CustomEditor(typeof(ChatSystem))]
    public class ChatSystemEditor : Editor
    {
        #region Serialized Properties
        private SerializedProperty ChatChannels;
        private SerializedProperty ChatMessagePrefab;
        private SerializedProperty MessageChannel;

        private SerializedProperty TargetedMessageFormat;
        private SerializedProperty MessageTemplate;
        private SerializedProperty HelpText;

        private SerializedProperty MaxMessages;
        private SerializedProperty HideChatDelay;
        private SerializedProperty ScrollToBottomDelay;
        private SerializedProperty AutoOpenChat;
        private SerializedProperty AutoCloseChat;

        private SerializedProperty ContentPanel;
        private SerializedProperty InputField;

        private SerializedProperty IsOpen;

        private SerializedProperty EnableWordFilter;
        private SerializedProperty WordFilters;

        private SerializedProperty EnableCommands;
        private SerializedProperty Commands;

        private SerializedProperty OnChatOpen;
        private SerializedProperty OnChatClose;
        private SerializedProperty OnSendMessage;
        #endregion
        #region GUI Contents
        private GUIContent ContentPanelGUIContent = new GUIContent("Content Panel", "Where all the messages will go");
        private GUIContent InputFieldGUIContent = new GUIContent("Input Field", "The Chat System's input field, where the users will type");
        private GUIContent ChatMessagePrefabGUIContent = new GUIContent("Chat Message Prefab", "The message prefab to create when sending/receiving messages");
        private GUIContent TargetedMessageFormatGUIContent = new GUIContent("Placeholder Message", "The placeholder text to display to the user per channel. \"{0}\" will be replaced by the channel name");
        private GUIContent MessageTemplateGUIContent = new GUIContent("Message Template", "The template string that messages will be formatted with. {0} is the color of the channel. {1} is the Channel Name. {2} is the Sending Player Name. {3} is the message content.");
        private GUIContent HelpTextGUIContent = new GUIContent("Help text (optional)", "Can be displayed to the user when they type /help if commands are enabled by binding GenerateHelpContent to a help command");
        private GUIContent MessageChannelGUIContent = new GUIContent("Network Message Channel", "The Network Channel the messages will be sent over the network on. Leave it alone unless you are managing many messages outside of this system");
        private GUIContent HideChatDelayGUIContent = new GUIContent("Hide Chat Delay (seconds)", "Delay before making the Chat System fade out after a message has been received or sent");
        private GUIContent MaxMessagesGUIContent = new GUIContent("Max Messages", "Maximum number of messages to allow in the buffer before starting to remove old ones");
        private GUIContent AutoOpenChatGUIContent = new GUIContent("Auto Open Chat", "Whether or not to open the chat when a mesasge is received");
        private GUIContent AutoCloseChatGUIContent = new GUIContent("Auto Close Chat", "Whether or not to automatically close the chat after a period of inactivity");
        private GUIContent ScrollToBottomDelayGUIContent = new GUIContent("Scroll To Bottom Delay", "Delay after displaying a message before forcing the scroll view to go to the bottom. Setting too low a value can result in improper scrolling sometimes. Setting too high a value can result in a very noticeable delay between message creation and scrolling");
        private GUIContent IsOpenGUIContent = new GUIContent("Is Open", "Whether or not the chatSystem is open");
        private GUIContent EnableWordFilterGUIContent = new GUIContent("Enable", "Whether or not to filter message content based on regular expressions");
        private GUIContent EnableCommandsGUIContent = new GUIContent("Enable", "Whether or not allow users to type /[command name] to perform some actions");
        private GUIContent OnChatOpenGUIContent = new GUIContent("On Chat Open", "Actions to take when the user opens the chat panel");
        private GUIContent OnChatCloseGUIContent = new GUIContent("On Chat Close", "Actions to take when the chat panel closes");
        private GUIContent OnSendMessageGUIContent = new GUIContent("On Send Message", "Actions to take when the user sends a message");

        private GUIContent ChatChannelNameGUIContent = new GUIContent("Name", "Name of the channel. It will be displayed in the message");
        private GUIContent ChatChannelColorGUIContent = new GUIContent("Color", "Color the channel name will be displayed in");
        private GUIContent ChatChannelChannelGUIContent = new GUIContent("Channel", "Must be unique within the list of channels. Will be used to reference which Chat Channels the users have access to see/send on");

        private GUIContent RegularExpressionGUIContent = new GUIContent("Regular Expression", "Put any bad word regular expression here to prevent users from typing it");
        private GUIContent ReplaceWithGUIContent = new GUIContent("Replace With", "Any matched text will be replaced with this content");
        private GUIContent IgnoreCaseGUIContent = new GUIContent("Ignore Case", "Whether or not the matching should be case sensitive");

        private GUIContent CommandNameGUIContent = new GUIContent("Command", "The name of the command. Users will type /[Command] to activate the command");
        private GUIContent CallFunctionThenSendMessageGUIContent = new GUIContent("Send Message After Executing Command", "Whether the message should still be sent after executing the command. Useful for things like /team hi team!");
        private GUIContent FunctionToCallGUIContent = new GUIContent("Function", "What you would like this command to execute");
        #endregion

        #region Editor Internal Controls
        private List<bool> WordFiltersFoldoutStates = new List<bool>();
        private List<bool> ChatChannelsFoldoutStates = new List<bool>();
        private List<bool> CommandsFoldoutStates = new List<bool>();
        private string[] ToolbarOptions = new string[] { "Basic Configuration", "Adv. Configuration", "Events", "Debug Info" };
        private ChatSystem chatSystem;
        private int ToolbarState;

        private const int BASIC = 0;
        private const int ADVANCED = 1;
        private const int EVENTS = 2;
        private const int DEBUG_INFO = 3;

        private GUILayoutOption[] DefaultGUILayoutOptions = new GUILayoutOption[] { };
        private Texture2D Logo;
        #endregion

        private void OnEnable()
        {
            Logo = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Llama Software/Simple Chat/Images/logo.png");
            ChatChannels = serializedObject.FindProperty("ChatChannels");
            ChatMessagePrefab = serializedObject.FindProperty("ChatMessagePrefab");
            MessageChannel = serializedObject.FindProperty("MessageChannel");
            TargetedMessageFormat = serializedObject.FindProperty("TargetedMessageFormat");
            MessageTemplate = serializedObject.FindProperty("MessageTemplate");
            HelpText = serializedObject.FindProperty("HelpText");
            MaxMessages = serializedObject.FindProperty("MaxMessages");
            HideChatDelay = serializedObject.FindProperty("HideChatDelay");
            ScrollToBottomDelay = serializedObject.FindProperty("ScrollToBottomDelay");
            AutoOpenChat = serializedObject.FindProperty("AutoOpenChat");
            AutoCloseChat = serializedObject.FindProperty("AutoCloseChat");
            ContentPanel = serializedObject.FindProperty("ContentPanel");
            InputField = serializedObject.FindProperty("inputField");
            IsOpen = serializedObject.FindProperty("IsOpen");
            EnableWordFilter = serializedObject.FindProperty("EnableWordFilter");
            WordFilters = serializedObject.FindProperty("WordFilters");
            EnableCommands = serializedObject.FindProperty("EnableCommands");
            Commands = serializedObject.FindProperty("Commands");
            OnChatOpen = serializedObject.FindProperty("OnChatOpen");
            OnChatClose = serializedObject.FindProperty("OnChatClose");
            OnSendMessage = serializedObject.FindProperty("OnSendMessage");

            chatSystem = (ChatSystem)target;

            if (WordFiltersFoldoutStates.Count != WordFilters.arraySize)
            {
                WordFiltersFoldoutStates.Clear();
                for (int i = 0; i < WordFilters.arraySize; i++)
                {
                    WordFiltersFoldoutStates.Add(false);
                }
            }

            if (ChatChannelsFoldoutStates.Count != ChatChannels.arraySize)
            {
                ChatChannelsFoldoutStates.Clear();
                for (int i = 0; i < ChatChannels.arraySize; i++)
                {
                    ChatChannelsFoldoutStates.Add(false);
                }
            }
        }

        public override void OnInspectorGUI()
        {
            serializedObject.UpdateIfRequiredOrScript();

            if (Logo != null)
            {
                EditorGUILayout.BeginHorizontal();
                GUILayout.FlexibleSpace();
                GUILayout.Label(Logo);
                GUILayout.FlexibleSpace();
                EditorGUILayout.EndHorizontal();
            }

            ToolbarState = GUILayout.Toolbar(ToolbarState, ToolbarOptions, EditorStyles.toolbarButton);

            switch (ToolbarState)
            {
                case BASIC:
                    EditorGUILayout.Space();
                    EditorGUILayout.LabelField("Required Fields", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;

                    EditorGUILayout.PropertyField(ContentPanel, ContentPanelGUIContent, DefaultGUILayoutOptions);
                    EditorGUILayout.PropertyField(InputField, InputFieldGUIContent, DefaultGUILayoutOptions);
                    EditorGUILayout.PropertyField(ChatMessagePrefab, ChatMessagePrefabGUIContent, DefaultGUILayoutOptions);
                    EditorGUILayout.HelpBox("The Placeholder Message will be displayed to the user indicating where their message will be sent. The {0} will be replaced with the Channel Name.", MessageType.Info, true);
                    TargetedMessageFormat.stringValue = EditorGUILayout.TextField(TargetedMessageFormatGUIContent, TargetedMessageFormat.stringValue, DefaultGUILayoutOptions);
                    EditorGUILayout.HelpBox("The Message Template is the format messages will be displayed on the UI.\r\n{0} is the Channel Color.\r\n{1} is the Channel Name.\r\n{2} is the Sending Player Name.\r\n{3} is the message text.", MessageType.Info, true);
                    MessageTemplate.stringValue = EditorGUILayout.TextField(MessageTemplateGUIContent, MessageTemplate.stringValue, DefaultGUILayoutOptions);
                    EditorGUILayout.Space();
                    EditorGUI.indentLevel--;

                    EditorGUILayout.LabelField("Interactions", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;

                    EditorGUILayout.BeginHorizontal();
                    AutoOpenChat.boolValue = EditorGUILayout.Toggle(AutoOpenChatGUIContent, AutoOpenChat.boolValue, DefaultGUILayoutOptions);
                    MaxMessages.intValue = EditorGUILayout.IntField(MaxMessagesGUIContent, MaxMessages.intValue, DefaultGUILayoutOptions);
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    AutoCloseChat.boolValue = EditorGUILayout.Toggle(AutoCloseChatGUIContent, AutoCloseChat.boolValue, DefaultGUILayoutOptions);
                    if (AutoCloseChat.boolValue)
                    {
                        HideChatDelay.floatValue = EditorGUILayout.FloatField(HideChatDelayGUIContent, HideChatDelay.floatValue, DefaultGUILayoutOptions);
                    }
                    EditorGUILayout.EndHorizontal();

                    ScrollToBottomDelay.floatValue = EditorGUILayout.FloatField(ScrollToBottomDelayGUIContent, ScrollToBottomDelay.floatValue, DefaultGUILayoutOptions);

                    EditorGUILayout.Space();
                    EditorGUI.indentLevel--;

                    EditorGUILayout.LabelField("Chat Channels", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;

                    for (int i = 0; i < ChatChannels.arraySize; i++)
                    {
                        SerializedProperty Channel = ChatChannels.GetArrayElementAtIndex(i);

                        SerializedProperty ChannelName = Channel.FindPropertyRelative("Name");
                        SerializedProperty ChannelColor = Channel.FindPropertyRelative("color");
                        SerializedProperty ChannelChannel = Channel.FindPropertyRelative("Channel");

                        string channelName = string.IsNullOrEmpty(ChannelName.stringValue) ? "New Channel" : ChannelName.stringValue;

                        if (ChatChannelsFoldoutStates.Count <= i)
                        {
                            ChatChannelsFoldoutStates.Add(false);
                        }

                        ChatChannelsFoldoutStates[i] = EditorGUILayout.Foldout(ChatChannelsFoldoutStates[i], channelName);

                        if (ChatChannelsFoldoutStates[i])
                        {
                            ChannelName.stringValue = EditorGUILayout.TextField(ChatChannelNameGUIContent, ChannelName.stringValue, EditorStyles.textField);
                            EditorGUILayout.BeginHorizontal();
                            EditorGUILayout.PropertyField(ChannelColor, ChatChannelColorGUIContent, DefaultGUILayoutOptions);
                            ChannelChannel.longValue = EditorGUILayout.LongField(ChatChannelChannelGUIContent, ChannelChannel.longValue, EditorStyles.numberField);
                            EditorGUILayout.EndHorizontal();
                        }

                        EditorGUILayout.BeginHorizontal();
                        GUILayout.FlexibleSpace();
                        if (GUILayout.Button("Remove Chat Channel", EditorStyles.miniButton))
                        {
                            Undo.RecordObject(chatSystem, "Remove \"" + ChannelName.stringValue + "\"");
                            chatSystem.ChatChannels.RemoveAt(i);
                        }
                        EditorGUILayout.EndHorizontal();
                    }

                    EditorGUILayout.BeginHorizontal();
                    GUILayout.FlexibleSpace();
                    if (GUILayout.Button("Add Chat Channel", DefaultGUILayoutOptions))
                    {
                        Undo.RecordObject(chatSystem, "Add Chat Channel");

                        ChatChannel channel = new ChatChannel();

                        if (chatSystem.ChatChannels.Count >= 1)
                        {
                            channel.Name = chatSystem.ChatChannels[chatSystem.ChatChannels.Count - 1].Name;
                            channel.color = chatSystem.ChatChannels[chatSystem.ChatChannels.Count - 1].color;
                            channel.Channel = chatSystem.ChatChannels[chatSystem.ChatChannels.Count - 1].Channel + 1;
                        }
                        else
                        {
                            channel.Name = "New Chat Channel";
                            channel.color = Color.white;
                            channel.Channel = 0;
                        }
                        chatSystem.ChatChannels.Add(channel);


                        ChatChannelsFoldoutStates.Add(true);
                    }
                    GUILayout.FlexibleSpace();
                    EditorGUILayout.EndHorizontal();
                    break;
                case ADVANCED:
                    EditorGUILayout.Space();
                    MessageChannel.intValue = EditorGUILayout.IntField(MessageChannelGUIContent, MessageChannel.intValue, EditorStyles.numberField);

                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField("Language Filter", EditorStyles.boldLabel);
                    EnableWordFilter.boolValue = EditorGUILayout.Toggle(EnableWordFilterGUIContent, EnableWordFilter.boolValue, DefaultGUILayoutOptions);
                    GUILayout.FlexibleSpace();
                    EditorGUILayout.EndHorizontal();

                    if (EnableWordFilter.boolValue)
                    {
                        EditorGUI.indentLevel++;

                        EditorGUILayout.BeginHorizontal();
                        if (GUILayout.Button("Regular Expression Documentation", EditorStyles.miniButton))
                        {
                            Application.OpenURL("https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference");
                        }
                        if (GUILayout.Button("Regular Expression Tester", EditorStyles.miniButton))
                        {
                            Application.OpenURL("https://www.regexpal.com/");
                        }

                        EditorGUILayout.EndHorizontal();

                        for (int i = 0; i < WordFilters.arraySize; i++)
                        {
                            SerializedProperty Filter = WordFilters.GetArrayElementAtIndex(i);

                            SerializedProperty RegularExpression = Filter.FindPropertyRelative("RegularExpression");
                            SerializedProperty ReplaceWith = Filter.FindPropertyRelative("ReplaceWith");
                            SerializedProperty IgnoreCase = Filter.FindPropertyRelative("IgnoreCase");

                            string filterName = string.IsNullOrEmpty(RegularExpression.stringValue) ? "BadWordFilter" : RegularExpression.stringValue;

                            if (ChatChannelsFoldoutStates.Count <= i)
                            {
                                ChatChannelsFoldoutStates.Add(false);
                            }

                            WordFiltersFoldoutStates[i] = EditorGUILayout.Foldout(WordFiltersFoldoutStates[i], filterName);

                            if (WordFiltersFoldoutStates[i])
                            {
                                RegularExpression.stringValue = EditorGUILayout.TextField(RegularExpressionGUIContent, RegularExpression.stringValue, EditorStyles.textField);
                                EditorGUILayout.BeginHorizontal();
                                IgnoreCase.boolValue = EditorGUILayout.Toggle(IgnoreCaseGUIContent, IgnoreCase.boolValue, EditorStyles.toggle);
                                ReplaceWith.stringValue = EditorGUILayout.TextField(ReplaceWithGUIContent, ReplaceWith.stringValue, EditorStyles.textField);
                                EditorGUILayout.EndHorizontal();
                            }

                            EditorGUILayout.BeginHorizontal();
                            GUILayout.FlexibleSpace();
                            if (GUILayout.Button("Remove Word Filter", EditorStyles.miniButton))
                            {
                                Undo.RecordObject(chatSystem, "Remove \"" + RegularExpression.stringValue + "\"");
                                chatSystem.WordFilters.RemoveAt(i);
                            }
                            EditorGUILayout.EndHorizontal();
                        }

                        EditorGUILayout.BeginHorizontal();
                        GUILayout.FlexibleSpace();
                        if (GUILayout.Button("Add Filter", DefaultGUILayoutOptions))
                        {
                            Undo.RecordObject(chatSystem, "Add Filter");

                            WordFilter wordFilter = new WordFilter();
                            wordFilter.IgnoreCase = true;

                            if (chatSystem.WordFilters.Count >= 1)
                            {
                                wordFilter.RegularExpression = chatSystem.WordFilters[chatSystem.WordFilters.Count - 1].RegularExpression;
                                wordFilter.ReplaceWith = chatSystem.WordFilters[chatSystem.WordFilters.Count - 1].ReplaceWith;
                            }
                            else
                            {
                                wordFilter.RegularExpression = "New Word Filter";
                                wordFilter.ReplaceWith = "****";
                            }
                            chatSystem.WordFilters.Add(wordFilter);

                            WordFiltersFoldoutStates.Add(true);
                        }
                        GUILayout.FlexibleSpace();
                        EditorGUILayout.EndHorizontal();

                        EditorGUI.indentLevel--;
                    }

                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField("Chat Commands", EditorStyles.boldLabel);
                    EnableCommands.boolValue = EditorGUILayout.Toggle(EnableCommandsGUIContent, EnableCommands.boolValue, DefaultGUILayoutOptions);
                    GUILayout.FlexibleSpace();
                    EditorGUILayout.EndHorizontal();

                    if (EnableCommands.boolValue)
                    {
                        EditorGUILayout.HelpBox("Commands allow the users to invoke functions by typing /commandName. For example, adding a command \"help\" that executes ChatSystem.GenerateHelpContent() would be achieved by adding a new command with the \"Command\" of \"help\" and adding a \"Function\" then dragging the ChatSystem and selecting \"GenerateHelp()\"", MessageType.Info);

                        EditorGUI.indentLevel++;
                        EditorGUILayout.LabelField(HelpTextGUIContent, EditorStyles.label);
                        HelpText.stringValue = EditorGUILayout.TextArea(HelpText.stringValue, EditorStyles.textArea);

                        for (int i = 0; i < Commands.arraySize; i++)
                        {
                            SerializedProperty Command = Commands.GetArrayElementAtIndex(i);

                            SerializedProperty Name = Command.FindPropertyRelative("Name");
                            SerializedProperty FunctionToCall = Command.FindPropertyRelative("FunctionToCall");
                            SerializedProperty CallFunctionThenSendMessage = Command.FindPropertyRelative("CallFunctionThenSendMessage");

                            string commandName = string.IsNullOrEmpty(Name.stringValue) ? "New Command" : Name.stringValue;

                            if (CommandsFoldoutStates.Count <= i)
                            {
                                CommandsFoldoutStates.Add(false);
                            }

                            CommandsFoldoutStates[i] = EditorGUILayout.Foldout(CommandsFoldoutStates[i], commandName);

                            if (CommandsFoldoutStates[i])
                            {
                                EditorGUILayout.BeginHorizontal();
                                Name.stringValue = EditorGUILayout.TextField(CommandNameGUIContent, Name.stringValue, EditorStyles.textField);
                                CallFunctionThenSendMessage.boolValue = EditorGUILayout.Toggle(CallFunctionThenSendMessageGUIContent, CallFunctionThenSendMessage.boolValue, EditorStyles.toggle);
                                EditorGUILayout.EndHorizontal();

                                EditorGUILayout.PropertyField(FunctionToCall, FunctionToCallGUIContent, DefaultGUILayoutOptions);
                            }

                            EditorGUILayout.BeginHorizontal();
                            GUILayout.FlexibleSpace();
                            if (GUILayout.Button("Remove Command", EditorStyles.miniButton))
                            {
                                Undo.RecordObject(chatSystem, "Remove \"" + Name.stringValue + "\"");
                                chatSystem.Commands.RemoveAt(i);
                            }
                            EditorGUILayout.EndHorizontal();
                        }

                        EditorGUILayout.BeginHorizontal();
                        GUILayout.FlexibleSpace();
                        if (GUILayout.Button("Add Command", DefaultGUILayoutOptions))
                        {
                            Undo.RecordObject(chatSystem, "Add Command");

                            Command command = new Command();

                            command.CallFunctionThenSendMessage = false;
                            if (chatSystem.Commands.Count >= 1)
                            {
                                command.Name = chatSystem.Commands[chatSystem.Commands.Count - 1].Name;
                            }
                            else
                            {
                                command.Name = "help";
                            }
                            chatSystem.Commands.Add(command);

                            CommandsFoldoutStates.Add(true);
                        }
                        GUILayout.FlexibleSpace();
                        EditorGUILayout.EndHorizontal();

                        EditorGUI.indentLevel--;
                    }

                    EditorGUI.indentLevel--;
                    break;
                case EVENTS:
                    EditorGUILayout.Space();
                    EditorGUILayout.PropertyField(OnChatOpen, OnChatOpenGUIContent, DefaultGUILayoutOptions);
                    EditorGUILayout.PropertyField(OnChatClose, OnChatCloseGUIContent, DefaultGUILayoutOptions);
                    EditorGUILayout.PropertyField(OnSendMessage, OnSendMessageGUIContent, DefaultGUILayoutOptions);
                    break;
                case DEBUG_INFO:
                    EditorGUI.BeginDisabledGroup(true);
                    EditorGUILayout.Toggle(IsOpenGUIContent, IsOpen.boolValue, EditorStyles.toggle);
                    EditorGUILayout.LabelField("Number of Messages: " + chatSystem.MessagesOnUI.Count.ToString());
                    ChatChannel ActiveChannel = chatSystem.ChatChannels.Find((channel) => channel.Channel == chatSystem.ChannelToSend);
                    EditorGUILayout.LabelField("Active Channel: " + ActiveChannel.Name + "(" + ActiveChannel.Channel.ToString() + ")");
                    EditorGUILayout.LabelField("Language Filter Enabled: " + chatSystem.EnableWordFilter.ToString());
                    EditorGUILayout.LabelField("Object Pool Stats", EditorStyles.boldLabel);
                    if (chatSystem.Pool != null)
                    {
                        EditorGUI.indentLevel++;
                        EditorGUILayout.LabelField("Pool Size: " + chatSystem.Pool.PoolSize.ToString());
                        EditorGUILayout.LabelField("Available Objects: " + chatSystem.Pool.AvailableObjectsInPool.ToString());
                        EditorGUI.indentLevel--;
                    }
                    EditorGUI.EndDisabledGroup();
                    break;
            }

            serializedObject.ApplyModifiedProperties();
        }
    }
}
#endif