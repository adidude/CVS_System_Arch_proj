exit=0

#Will open and/or create the directory containing the repositories being worked with.
if test -d ~/CVS; then
	cd ~/CVS
else
	mkdir ~/CVS
	cd ~/CVS
fi

#Command to open a repo.
openDir()
{
	#Loops as long as a directory has not been selected or exits if there are no directories to open.
	selectDir=0
		while [[ selectDir -ne 1 ]]; do
			#If folder is not empty get user input and test if the directory exists.
			if [[ "$(ls -d *)" ]]; then
				echo "Directory list:"
				ls -d *
				dir=null
				echo "Type the name of the directory to open."
				read dir
				if test -d $dir; then
					#Open directory and display contents as well as current directory location.
					cd $dir
					pwd
					echo "File list:"
					ls
					selectDir=1
					projectMenu
				else
					echo "Directory not found. Try again."
				fi
			else
				echo "No directory found."
				echo ""
				selectDir=1
			fi
		done
}

#Will create a repo.
createDir()
{
	createdDir=0
	#Will loop as long as directory has not been created.
	while [[ createdDir -eq 0 ]]; do
		echo "Type the name of the new directory:"
		reponame=null
		read reponame
		if [[ -d $reponame ]]; then
			echo "directory with that name already exists."
			echo ""
		else
			mkdir $reponame
			createdDir=1
			echo ""
		fi
	done		
}

#Deletes a repo.
deleteDir()
{
	deletedir=0
	#As long as the directory is not deleted loop continues.
	while [[ deletedir -eq 0 ]]; do
		#Tests if there are any directories to delete.
		if [[ "$(ls -d *)" ]]; then
			echo "Directory list:"
			ls -d *
			dir=null
			echo "Type the name of the directory to delete."
			read dir
			#Tests if directory exists.
			if test -d $dir; then
				rm -Rf $dir
				deletedir=1
				echo "Successfully deleted repository."
				echo ""
			else
				echo "Directory not found. Try again." 
			fi
		else
			echo "No directories found to delete."
			echo ""
			deletedir=1
		fi
	done
}

#Will create a file specified by the user.
createFile()
{
	fileCreated=0
	#As long as the file has not been created the loop continues.
	while [[ fileCreated -eq 0 ]]; do
		echo "Type the name of the file you wish to create."
		file=null
		read file
		echo ""
		#If the file exists
		if [[ -e $file ]]; then
			echo "File already exists."
			echo ""
		else
			#Create file
			touch $file
			fileCreated=1
		fi
	done
}

#REQUIRES LOG IMPLEMENTATION
#Will open a text file in sublime text.
openFile()
{
	fileOpened=0
	#While a file has not been opened the loop continues or if there are not files it exits prematurely.
	while [[ fileOpened -eq 0 ]]; do
		#If there are files in the current directory print them.
		if [[ $(find -maxdepth 1 -type f) ]]; then
			echo "File list:"
			#Displays files in current folder.
			find -maxdepth 1 -type f
			echo "Type the file name you want to open."
			read file
			#If the file exists, it will be opened.
			if [[ -e $file ]]; then
				subl $file
				logFileEdit $file
				fileOpened=1
			else
				echo "File not found."
			fi	
		else
			echo "No files found to open."
			fileOpened=1
		fi
	done
}

#Will append information to a log file when a text file is opened.
logFileEdit()
{
	echo "Task: Open text file for possible edits." >> log.txt
	echo "User: $USER" >> log.txt
	echo "Time: $(date)" >> log.txt
	echo "File: $1" >> log.txt
	echo "Directory: $(pwd)" >> log.txt
}

#Will commit files
#commit()
#{

#}

#INCOMPLETE
#Menu for once a project has been opened.
projectMenu()
{
	exitMenu=0
	while [[ exitMenu -eq 0 ]]; do
		echo "Please select a task with relevant number." 
		echo "1) Create file"
		echo "2) Open text file"
		echo "3) Commit file"
		echo "4) Commit all changes"
		echo "5) Open directory"
		echo "0) Exit repository"

		#Handles user input.
		option=999
		read option
		if [[ option -eq 0 ]]; then
			exitMenu=1
		elif [[ option -eq 1 ]]; then
			createFile
		elif [[ option -eq 2 ]]; then
			openFile
		#elif [[ option -eq 3 ]]; then
			
		elif [[ option -eq 5 ]]; then
			openDir
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
	echo "5) Clone Repository"
	echo "0) Exit Program"

	#Handles user input.
	option=999
	read option
	if [[ option -eq 0 ]]; then
		exit=1
	elif [[ option -eq 1 ]]; then
		openDir
	elif [[ option -eq 2 ]]; then
		createDir
	elif [[ option -eq 3 ]]; then
		deleteDir
	#elif [[ option -eq 4 ]]; then
		#statements
	else
		echo "Invalid value. Try again."
		echo ""
	fi
done