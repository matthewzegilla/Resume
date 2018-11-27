#Created by Matthew Zegilla
#11/27/2017
#This was created to address a process in a project that involved migrating Windows redirected profiles from a 2008 R2 File Server to a 2016 File Server
#The issue was that the users(100+) had one of three options inside of their root profile (D:\Profiles$\*username*\)
#The three options were that they had their Desktop,Documents,AppData, etc. in their root, or they existed inside of another folder (profile.v2 for windows 7 users, or profile.v6 for windows 10 users)
#This script goes through an array that consists of all usernames, a for loop to increment through the array, checking which of the three options that user had, and doing a robocopy of the files depending on which option it was.


        #declare the array of users we have
            $userArray = @('User1','User2','User3')

        #loop to cycle through our users
For ($i=0; $i -lt $userArray.Length; $i++){

        #set temp variable to the user we want to run against
            $temp = $userArray[$i]
        #assign directories to values to run Test-Path against
            $TARGETDIR = "\\FS1\Profiles$\$temp\profile.V6"
            $TARGETDIR2 = "\\FS1\Profiles$\$temp\profile.V2"
        #Assign Test-Path "True or False" value to a variable to run later
            $TARGETDIRVALUE = Test-Path -path $TARGETDIR
            $TARGETDIR2VALUE = Test-Path -path $TARGETDIR2
            
        #below is for testing to return if profile.v2 or profile.v6 exists for a user in plain text.
        #echo "For user $temp : profile.v6 exists value is $TARGETDIRVALUE" >> Output.txt
        #echo "For user $temp : profile.v2 exists value is $TARGETDIR2VALUE" >> Output.txt

    if((-Not $TARGETDIRVALUE -AND -Not $TARGETDIR2VALUE)){
        #this will copy everything we need(desktop, my documents, pictures, etc) from the old root profile folder to the root of their new profile folder.
        #using the array that we have declared to fill in the username portion
        #this if runs if there is neither a profile.v6 or profile.v2 meaning the profile folders are in the root of the users folder
            echo "$temp doesn't have profile.v6 or profile.v2, migrating entire root directory" >> Output.txt
            robocopy \\FS1\Profiles$\$temp\ \\JF-FS01\Profiles\$temp\ /e /copyall
        
    }#endif
        #If there is no windows 10 profile this elseif runs
    elseif (!(Test-Path -path $TARGETDIR)){
        #this will copy everything we need(desktop, my docuemts, pictures, etc) from the profile.v6 folder to the root of their profile folder.
        #using the array that we have declared to fill in the username portion.
        #this means there are one of the two folders, but .v6 doesnt exist
            echo "$temp is using profile.v2" >> Output.txt
            robocopy \\FS1\Profiles$\$temp\profile.v2 \\JF-FS01\Profiles\$temp\ /e /copyall
    }#endelseif
    else{
        #this means that one of the folders existed, and .v6 existed
            echo "$temp is using profile.v2" >> Output.txt
            robocopy \\FS1\Profiles$\$temp\profile.v6 \\JF-FS01\Profiles\$temp\ /e /copyall
        
    }#endelse

}#endfor