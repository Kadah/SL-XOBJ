/*
	This is the listen manager for standard communications.
	In your CORE file you'll want to modify the getToken(key senderKey, key recipient, string saltrand) function
	It generates a hash specific to your project. You can replace it with any algorithm you want to help make your game more secure.
	
	Don't forget to run initiateListen() wherever you want to initiate the listener (usually state_entry)
	The following are definitions you can define right above your #include "xobj_core/_LISTEN.lsl"
	
	#define LISTEN_LIMIT_BY_NAME - Requires the customtarg to be this name
	#define LISTEN_LIMIT_ALLOW_WILDCARD - If used in combination with above, * will be allowed too
	#define REQUIRE_INIT - Will not raise events until BFL_INIT is set
	#define LISTEN_OVERRIDE (int)chan - Allows the owner to run override messages through the function onListenOverride(integer chan, key id, string message){} Use this only when you need to send lots of commands in rapid succession.
	#define DEBUG - Outputs all messages to owner
	#define ALLOW_USER_DEBUG 2=anyone - Lets anyone/owner raise events by saying debug script, method, arg1, arg2...
	#define LISTEN_LIMIT_FREETEXT - Lets you define freetext code to be injected into _LISTEN
	
*/



listen(integer chan, string name, key id, string message){
	debugCommon("COM received:\n"+message);
	
	#ifdef LISTEN_LIMIT_FREETEXT
	LISTEN_LIMIT_FREETEXT
	#endif
	
	#ifdef REQUIRE_INIT
	if(~BFL&BFL_INIT)return;
	#endif
	
	#ifdef LISTEN_OVERRIDE
	if(chan == LISTEN_OVERRIDE
		#ifndef LISTEN_OVERRIDE_ALLOW_ALL
		&& llGetOwnerKey(id) == llGetOwner()
		#endif
	){
		onListenOverride(chan, id, message);
		return;
	}
	#endif
	
	#ifdef ALLOW_USER_DEBUG
    if(chan == 0){
		#if ALLOW_USER_DEBUG!=2
		if(llGetOwnerKey(id) != llGetOwner())return;
		#endif
        if(llGetSubString(message, 0, 5) == "debug "){ // script, method, param1, param2...
			list split = llCSV2List(llGetSubString(message, 6, -1));
            list op = [llList2Integer(split,1), llList2Json(JSON_ARRAY, llDeleteSubList(split, 0, 1)), ""];
            llMessageLinked(LINK_SET, RUN_METHOD, llList2String(split,0)+llList2Json(JSON_ARRAY, op), id);
        }
        return;
    }
	#endif
	

	string expected = getToken(id, llGetOwner(), llGetSubString(message,0,15));
	if(llGetSubString(message, 0, llStringLength(expected)-1) != getToken(id, llGetOwner(), llGetSubString(message,0,15))){
		debugUncommon("Token rejected, call: "+message+" expected "+expected);
		return;
    } 
	message = llDeleteSubString(message, 0,llStringLength(expected)-1);
	
	debugCommon("COM passed: "+llGetSubString(message, llSubStringIndex(message, ":")+1, -1));
	
	//integer targ = LINK_SET;
	llMessageLinked(LINK_SET, (integer)llGetSubString(message, 0,llSubStringIndex(message, ":")-1), llGetSubString(message, llSubStringIndex(message, ":")+1, -1), id);
	//qd("Sent com");
}
