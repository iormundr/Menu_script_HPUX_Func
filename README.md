# Menu_script_HPUX_Func
This is a very basic script for users who does not have full permission to the HPUX OS (without root).
There are couple of functionalities that you can find here in a menu based script:

 Check Menu by Iormundr


        Options: Check for...?
        ---------------------------------------------
        1) Kernel Parameters
        2) NDD Parameters
        3) Users existence
        4) File Systems
        5) Networks
        6) Under Construction


        Other Options:
        ----------------
        r) Refresh screen
        q) Quit

        Enter your selection: q

1. You can compare Kernel Parameters from within kctune command and from a different file.
The option is checking whether you can verify your list of input kernel tunables against kctune output.
If you don't have such option to get an output from kctune - Some Unix SA do it (Don't see the logic behind it) you will be
prompt to enter 2 lists of variables (one is the list from Unix SA with the current tunable and the second that list
that you want to verify against). - In progress , will be uploaded shortly.

2. Same for network tunables.

3. Same for users , you will need to provide a list of users and it will check it. ( will update what is the structure of the
file that you need to enter to check)

4. Same for file systems - will update soon.

5. Network cards , shows the speed of ALL your active network cards with the relevant IP. Found it very useful sometimes.

6. Didn't find any purpose for the 6th Option.

