#Authors: Aditya Kumar Menon,   Mandar Tamhane,     Rauf Nawaz Tarar
#MatricNo.: 170025886           170021792           170012145
#Description: Will allow Groups and permissions to be set.

#Create a new group
createGroup()
{
    echo -n "Enter name of the new group you would like: "
    read groupName
    if [ "$(getent group $groupName)" ]; then
        echo "Group $groupName already exists"
    else
        sudo groupadd $groupName
        echo ""
    fi
}

#Add Users to Group
addToGroup()
{
    echo -n "Which group would you like to add users to?"
    read groupName
    if [ "$(getent group $groupName)" ]; then
        addUsers $groupName
    else
    {
        echo "Group doesn't exist. Create the group first."
    }
    fi
}

#Add users
addUsers()
{
    echo "How many users do you want to add to this group: "
    read noOfUsers

    while [ "$noOfUsers" != 0 ]
    do
        echo "Enter name of user"
        read newUser
        if [ -z "$(getent passwd $newUser)" ]; then
            sudo usermod -a -G $1 $newUser
            echo "User $newUser was added to group $1"
        else
            echo "User $newUser couldn't be added to the group because the user doesn't exist. Create user first? Y/N: "
            read decision
            if confirm $decision ; then
                echo "Enter the name for the user"
                    read userName
                    sudo useradd -m $userName
            fi
        fi
        noOfUsers--
    done
}

#View Members in Group
viewMembers()
{
    if [ "$(getent group $1)" ]; then
        grep $1 /etc/group
    else 
        echo "Group doesn't exist. Create the group first."
    fi
}

#View Owner of Directory
viewOwner()
{
    ls -l "$1"
}

#Share file with group
shareFile()
{
    echo "Which group would you like to share this file with?"
    read groupName;
    
    if [ "$(getent group $groupName)" ]; then
        echo "Which type of Permissions would you like to give to the file or folder?"
        echo "1. Read-Only"
        echo "2. Read & Write"
        echo "3. Read & Execute"
        echo "4. Read, Write & Execute"
        echo "Enter your choice: "
        read choice
        case $choice in
            1) chmod 7740 "$groupName" "$1"
                ;;
            2) chmod 7720 "$groupName" "$1"
                ;;
            3) chmod 7750 "$groupName" "$1"
                ;;
            4) chmod 7770 "$groupName" "$1"
                ;;
        esac
    else
        echo "Group doesn't exist. Create the group first? Y/N?"
        read decision
            if confirm $decision ; then
                createGroup
            else return
            fi
        
    fi     
}

#View files shared with group
viewFiles()
{
    find "$2" -group "$1"
}

#Check if Y or N
confirm()
{
    case $1 in
    [yY][eE][sS]|[yY])
        return 1
        ;;
    *)
        return 0
        ;;
    esac
}
