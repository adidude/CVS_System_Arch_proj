#Authors: Aditya Kumar Menon,	Mandar Tamhane,		Rauf Nawaz Tarar
#MatricNo.: 170025886			170021792			170012145
source ./Repository1.sh
source ./usersAndGroups.sh
source ./RepoMangr.sh

exit=0

#Will open and/or create the directory containing the repositories being worked with.
if test -d ~/CVS; then
	cd ~/CVS
else
	mkdir ~/CVS
	cd ~/CVS
fi

#Will create the directory containing the older versions of projects if History does not exist.
if test -d ./.History; then
	echo ""
else
	mkdir .History
	lockHistory
	echo ""
fi

#Menu for once a project has been opened.
projectMenu()
{
	exitMenu=0
	while [[ exitMenu -eq 0 ]]; do
		echo "Please select a task with relevant number." 
		echo "1) Create file"
		echo "2) Edit text file in sublime text"
		echo "3) Edit text file in terminal"
		echo "3) Commit Changes"
		echo "4) Open directory"
		echo "5) Manage Permissions"
		echo "0) Exit repository"

		#Handles user input.
		option=999
		read option
		if [[ option -eq 0 ]] ; then
			exitMenu=1
		elif [[ option -eq 1 ]]; then
			createFile
		elif [[ option -eq 2 ]]; then
			openFile
		elif [[ option -eq 3 ]]; then
			EditFile
		elif [[ option -eq 4 ]]; then
			commit
		elif [[ option -eq 5 ]]; then
			openDir
		elif [[ option -eq 6 ]]; then
			dirMenu
		else
			echo "Invalid value. Try again."
			echo ""
		fi
	done
	cd ..
}

echo "Welcome to myCVS software, a CVS solution."

#Main program loop.
while [[ exit -ne 1 ]]; do
	echo "Please select a task with relevant number." 
	echo "1) Open Repository"
	echo "2) Create Repository"
	echo "3) Delete Repository"
	echo "4) Archive Repository"
	echo "5) Peek at files in Repository"
	echo "0) Exit Program"

	#Handles user input.
	option=999
	read option
	if [[ option -eq 0 ]]; then
		exit=1
	elif [[ option -eq 1 ]]; then
		openDir 1
	elif [[ option -eq 2 ]]; then
		createDir 1
	elif [[ option -eq 3 ]]; then
		deleteDir 1
	elif [[ option -eq 4 ]]; then
		Archive
	elif [[ option -eq 5 ]]; then
		ListFiles
	else
		echo "Invalid value. Try again."
		echo ""
	fi
done

dirMenu()
{
	exitMenu=0
	while [[ exitMenu -eq 0 ]]; do
		echo "Please select a task with relevant number." 
		echo "The Current group is" stat -c "%G" $pwd
		echo "1) View Owner"
		echo "2) View Members"
		echo "3) Add Members to Group"
		echo "4) Share Repository"
		echo "0) Exit Menu"

		#Handles user input.
		option=999
		read option
		if [[ option -eq 0 ]]; then
			exitMenu=1
		elif [[ option -eq 1 ]]; then
			viewOwner
		elif [[ option -eq 2 ]]; then
			viewMembers
		elif [[ option -eq 3 ]]; then
			addToGroup
		elif [[ option -eq 4 ]]; then
			shareFile "$pwd"
		else
			echo "Invalid value. Try again."
			echo ""
		fi
	done
	cd ..
}

