using System;
using UnityEngine.Events;

namespace LlamaSoftware.UNET.Chat.Model
{
    /// <summary>
    /// Model for commands.
    /// Model for commands. See inspector documentation
    /// Commands allow the users to invoke functions by typing /commandName. 
    /// For example, adding a command help that executes <see cref="ChatSystem.GenerateHelp" /> would be achieved by adding a new command with the Command of help and adding a Function then dragging the ChatSystem and selecting GenerateHelp()
    /// </summary>
    [Serializable]
    public struct Command
    {
        /// <summary>
        /// Text the user will have to enter to execute the command. Do not include any leading "/" characters. That is inferred by the Chat System.
        /// </summary>
        public string Name;
        /// <summary>
        /// If this is true, the /[name] will be stripped out of the message, and sent after FunctionToCall.Invoke() has been called.
        /// </summary>
        public bool CallFunctionThenSendMessage;
        /// <summary>
        /// Bind the function to execute when user enters a designated command here.
        /// </summary>
        public UnityEvent FunctionToCall;
    }
}
