using System;
using System.Text.RegularExpressions;
using UnityEngine;

namespace LlamaSoftware.UNET.Chat.Model
{
    /// <summary>
    /// Word Filter Model.
    /// 
    /// Example Setup:
    /// Filter = new Regex("cats")
    /// ReplaceWith = "*"
    /// IgnoreCase = true
    ///
    /// User inputs: "I love cats!"
    /// Message sent over network: "I love ****!"
    /// 
    /// Example Setup 2:
    /// Filter = new Regex("cats")
    /// ReplaceWith = "*"
    /// IgnoreCase = false
    ///
    /// User inputs: "I love CATS!"
    /// Message sent over network: "I love CATS!"
    /// </summary>
    [Serializable]
    public class WordFilter
    {
        /// <summary>
        /// this is the regular expression that will be tested against
        /// </summary>
        public string RegularExpression;
        /// <summary>
        /// The text to replace a matched word against. 
        /// For example if set <see cref="RegularExpression"/> to "cats", and <see cref="ReplaceWith"/> is set to "****". "****" will be sent over the network in place of "cats".
        /// </summary>
        public string ReplaceWith;
        /// <summary>
        /// If the <see cref="RegularExpression"/> you entered should match case insensitive.
        /// </summary>
        public bool IgnoreCase;
        /// <summary>
        /// The constructed <see cref="Regex"/>
        /// </summary>
        public Regex regex;
    }
}
