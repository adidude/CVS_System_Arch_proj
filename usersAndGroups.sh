#Create a new group
createGroup()
{
    echo -n "Enter name of the new group you would like: "
    read groupName
    sudo groupadd $groupName
}

#Add Users to Group
addToGroup()
{
    echo -n "Which group would you like to add to?"
    read groupName;
    if [ $(getent group $groupName) ]; then
        addUsers($groupName)
    else 
        echo "Group doesn't exist. Create the group first."
    fi
}

#Add users
addUsers($groupName)
{
    echo "How many users do you want to add to this group: "
    read noOfUsers

    while [$noOfUsers!=0]
    do
        echo "Enter name of user"
        read newUser
        if [ grep -c $newUser /etc/passwd ]; then
            sudo usermod -a -G $groupName $newUser
            echo "User $newUser was added to group $groupName"
        else
            echo "User $newUser couldn't be added to the group because the user doesn't exist. Create user first? Y/N: "
            read decision
            if [ confirm($decision) ]; then
                echo "Enter the name for the user"
                    read userName
                    sudo useradd -m $userName
            fi
        fi
        noOfUsers--
    done
}

#View Members in Group
viewMembers($groupName)
{
    if [ $(getent group $groupName) ]; then
        grep $groupName /etc/group
    else 
        echo "Group doesn't exist. Create the group first."
    fi
}

#View Owner of Directory
viewOwner($path)
{
    ls -l $path
}

#Share file with group
shareFile($path)
{
    echo "Which group would you like to share this file with?"
    read groupName;
    
    if [ $(getent group $groupName) ]; then
        echo "Which type of Permissions would you like to give to the file or folder?"
        echo "1. Read-Only"
        echo "2. Read & Write"
        echo "3. Read & Execute"
        echo "4. Read, Write & Execute"
        echo "Enter your choice: "
        read choice
        case $choice in
            1) chmod 5740 $groupName $path
                ;;
            2) chmod 5720 $groupName $path
                ;;
            3) chmod 5750 $groupName $path
                ;;
            4) chmod 5770 $groupName $path
                ;;
        esac
    else echo "Group doesn't exist"
    fi     
}

#View files shared with group
viewFiles($groupName)
{
    find $directoryLocation -group {$groupName}
}

#Check if Y or N
confirm ($decision)
{
    case $decision in
    [yY][eE][sS]|[yY])
        true
        ;;
    *)
        false
        ;;
    esac
}