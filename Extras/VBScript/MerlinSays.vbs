'*******************************************************************************
' Script Name: MerlinSays.vbs
'     Version: 1.0
'      Author: Jason Fossen, Enclave Consulting LLC 
'Last Updated: 18.Mar.05
'     Purpose: Use Microsoft Agent to speak a message.
'       Notes: http://www.microsoft.com/msagent/
'              http://www.microsoft.com/technet/scriptcenter/funzone/agent.mspx
'       Legal: Public Domain.  Modify and redistribute freely.  No rights reserved.
'*******************************************************************************
On Error Resume Next
sText = "Make me say anything you want!"
sText = WScript.Arguments.Item(0)


MerlinSays sText



Sub MerlinSays(sLine)
    If Not IsObject(oWshShell) Then Set oWshShell = WScript.CreateObject("WScript.Shell") 
    sPath = oWshShell.ExpandEnvironmentStrings("%WinDir%\msagent\chars\Merlin.acs")
        
    Set oAgent = CreateObject("Agent.Control.2")    
    oAgent.Connected = TRUE
    oAgent.Characters.Load "Merlin", sPath
    
    Set oCharacter = oAgent.Characters.Character("Merlin")
    oCharacter.MoveTo 0,0
    oCharacter.Show
    oCharacter.MoveTo 500, 400, 700  'FROM-LEFT, FROM-TOP, SPEED (bigger is slower)
    oCharacter.Play "Announce"
    oCharacter.Speak sLine
    oCharacter.Play "Wave"
    oCharacter.Hide True     'True to just disappear, no pull-hat-down animation.
    
    Do While oCharacter.Visible = True
        Wscript.Sleep 100
    Loop

    oAgent.Connected = False
End Sub


'END OF SCRIPT******************************************************************





'-------------------------------------------------
'  Options for the oCharacter.Play method:
'  (Looping requires explicit .Stop call)
'-------------------------------------------------
'Acknowledge	    Nods head
'Alert	            Straightens and raises eyebrows
'Announce	        Raises trumpet and plays
'Blink	            Blinks eyes
'Confused	        Scratches head
'Congratulate	    Displays trophy
'Congratulate_2	    Applauds
'Decline	        Raises hands and shakes head
'DoMagic1	        Raises magic wand
'DoMagic2	        Lowers wand, clouds appear
'DontRecognize	    Holds hand to ear
'Explain	        Extends arms to side
'GestureDown	    Gestures down
'GestureLeft	    Gestures to his Left
'GestureRight	    Gestures to his Right
'GestureUp	        Gestures up
'GetAttention	    Leans forward and knocks
'GetAttentionContinued	Leaning forward, knocks again
'GetAttentionReturn	    Returns to neutral position
'Hearing_1	        Ears extend (looping animation)
'Hearing_2	        Tilts head left (looping animation)
'Hearing_3	        Turns head left (looping animation)
'Hearing_4	        Turns head right (looping animation)
'Hide	            Disappears under cap
'Idle1_1	        Takes breath
'Idle1_2	        Glances left and blinks
'Idle1_3	        Glances Right
'Idle1_4	        Glances up to the right and blinks
'Idle2_1	        Looks at wand and blinks
'Idle2_2	        Holds hands and blinks
'Idle3_1	        Yawns
'Idle3_2	        Falls asleep (looping animation)
'LookDown	        Looks down
'LookDownBlink	    Blinks looking down
'LookDownReturn	    Returns to neutral position
'LookLeft	        Looks Left
'LookLeftBlink	    Blinks looking Left
'LookLeftReturn	    Returns to neutral position
'LookRight	        Looks Right
'LookRightBlink	    Blinks looking Right
'LookRightReturn	Returns to neutral position
'LookUp	            Looks up
'LookUpBlink	    Blinks looking up
'LookUpReturn	    Returns to neutral position
'MoveDown	        Flies down
'MoveLeft	        Flies to his Left
'MoveRight	        Flies to his Right
'MoveUp	            Flies up
'Pleased	        Smiles and holds his hands together
'Process	        Stirs cauldron
'Processing	        Stirs cauldron (looping animation)
'Read	            Opens book, reads and looks up
'ReadContinued	    Reads and looks up
'ReadReturn	        Returns to neutral position
'Reading	        Reads (looping animation)
'RestPose	        Neutral position
'Sad	            Sad expression
'Search	            Looks into crystal ball
'Searching	        Looks into crystal ball (looping animation)
'Show	            Appears out of cap
'StartListening	    Puts hand to ear
'StopListening	    Puts hands over ear
'Suggest	        Displays light bulb
'Surprised	        Looks surprised
'Think	            Looks up with hand on chin
'Thinking	        Looks up with hand on chin (looping animation)
'Uncertain	        Leans forward and raises eyebrows
'Wave	            Waves
'Write	            Opens book, writes and looks up
'WriteContinued	    Writes and looks up
'WriteReturn	    Returns to neutral position
'Writing	        Writes (looping animation)


