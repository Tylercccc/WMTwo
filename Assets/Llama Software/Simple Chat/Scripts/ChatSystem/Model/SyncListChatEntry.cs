using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if MIRROR
using Mirror;
#else
using UnityEngine.Networking;
#endif

namespace LlamaSoftware.UNET.Chat.Model
{
#if MIRROR
    public class SyncListChatEntry : SyncList<ChatEntry> { }
#else
    //you can't directly just do SyncListStruct<YourClass>
    public class SyncListChatEntry : SyncListStruct<ChatEntry> { }
#endif
}