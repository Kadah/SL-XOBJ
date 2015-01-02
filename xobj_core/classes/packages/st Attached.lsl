

#define AttachedMethod$remove 0			// (str)objName or "*" for all

// Preprocessor shortcuts
#define DISREGARD_SHARED
#include "xobj_core/classes/st Remoteloader.lsl" 
// Include local head and class type
#include "xobj_core/_CLASS_STATIC.lsl"

#define TIMER_CHECK_ATTACH "a"

timerEvent(string id, string data){
    if(id == TIMER_CHECK_ATTACH){
        if(llGetAttached()){
            multiTimer([id]);
        }else{
            llOwnerSay("@acceptpermission=add");
            llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
        }
    }
}

integer DIE;

default
{ 
    on_rez(integer start){
        if(start == 1){
			llSleep(.25);
            llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_TEMP_ON_REZ, TRUE]);
            integer pin = llFloor(llFrand(0xFFFFFFF));
			llSetRemoteScriptAccessPin(pin);
            runMethod(llGetOwner(), "st Remoteloader", RemoteloaderMethod$load, [cls$name, pin, 2], TNN);
        } 
    }
    
    state_entry()
    {
		llListen(playerChan(llGetOwner()), "", "", "");
		llListen(0, "", llGetOwner(), "");
        llSetStatus(STATUS_PHANTOM, TRUE);
        initShared();
        memLim(1.5);
		
		if(llGetStartParameter() == 2){
            llOwnerSay("@acceptpermission=add");
            runOmniMethod(cls$name, AttachedMethod$remove, [llGetObjectName()], TARG_NULL, NORET, llGetObjectName());
            raiseEvent(evt$SCRIPT_INIT, "");
            multiTimer([TIMER_CHECK_ATTACH, "", 1, TRUE]);
        }
    }
	
	#define LISTEN_LIMIT_BY_NAME
	#define LISTEN_LIMIT_ALLOW_WILDCARD
	#include "xobj_core/_LISTEN.lsl"
    
    run_time_permissions(integer perm){
        if(perm & PERMISSION_ATTACH){
			if(DIE)llDetachFromAvatar();
            else llAttachToAvatarTemp(0);
        }
    }

    timer(){multiTimer([]);}

    #include "xobj_core/_LM.lsl"
        /*
            Included in all these calls:
            METHOD - (int)method
            INDEX - (int)obj_index
            PARAMS - (var)parameters
            SENDER_SCRIPT - (var)parameters
            CB - The callback you specified when you sent a task
        */
		if(method$byOwner){
			if(METHOD == AttachedMethod$remove){
                llDie();
				DIE = TRUE;
                if(llGetAttached())llRequestPermissions(llGetOwner(), PERMISSION_ATTACH);
            }
		}
        
        if(nr == METHOD_CALLBACK){ 
            
        }
    
    #define LM_BOTTOM  
    #include "xobj_core/_LM.lsl" 
}
 







