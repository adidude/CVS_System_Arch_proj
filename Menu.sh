source ./Repository1

source ./usersAndGroups.sh
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

currentDir=null

#Command to open a directory. $1 determines if the current directory is a repo.
openDir()
{
	#Loops as long as a directory has not been selected or exits if there are no directories to open.
	selectDir=0
		while [[ selectDir -ne 1 ]]; do
			#If folder is not empty get user input and test if the directory exists.
			if [[ "$(ls -d *)" ]]; then
				echo ""
				echo "Directory list:"
				ls -d *
				echo ""
				dir=null
				echo "Type the name of the directory to open."
				read dir
				echo ""
				if test -d $dir; then
					#Open directory and display contents as well as current directory location.
					cd $dir
					pwd
					echo ""
					selectDir=1
					projectMenu
					
				else
					echo "Directory not found. Try again."
					echo ""
				fi
			else
				echo "No directories found to open."
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
			#If directory is a repo following makes a directory to track the history of the repo. 
			if [[ $1 -eq 1 ]]; then
				unlockHistory
				mkdir ~/CVS/.History/$reponame
				lockHistory
			fi
			createdDir=1
			echo ""
		fi
	done	
	createGroup
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
				echo "Are you sure you want to delete the directory and all of its files(This is irreversible) [y/n]"
				read del

				#Ensures the user wishes to delete the repository.
				if [[ del = "y" ]]; then
					#Deletes the directory along with the files and sub directories within it.
					rm -Rf $dir
					#If directory is a repo following deletes history of repo. 
					if [[ $1 -eq 1 ]]; then
						unlockHistory
						rm -Rf ~/CVS/.History/$dir
						lockHistory
					fi
					deletedir=1
					echo "Successfully deleted repository."
					echo ""
				else
					deletedir=1
					echo "Deleting cancelled."
				fi
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

lockHistory()
{
	chmod 440 ~/CVS/.History
}

unlockHistory()
{
	chmod 770 ~/CVS/.History
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

#Will commit changes.
commit()
{
	#Adds information of commit to log file.
	echo "=========================" >> log
	echo "Task:	Commit Files." >> log
	echo "User:	$USER" >> log
	echo "Time:	$(date)" >> log
	echo "Repo:	$(pwd)" >> log

	#if repository is empty print error otherwise continue with commiting files.
	if [[ $(ls) ]]; then
		#Opens the .History directory to make a directory with the time/date within the relevant repo.
		unlockHistory
		cd ~/CVS/.History/$currentRepo
		#Stores the date/time in a variable, then makes a directory with the date/time as its name.
		time=$(date +%Y%m%d%H%M%S)
		mkdir "$time"

		#Return to the current working directory.
		cd ~/CVS/$currentRepo
		#Copy Repo to current version folder.
		cp -r -f -t ~/CVS/.History/$currentRepo/$time $(pwd)

		echo "Commit Summary:" >> log
		echo "" >> log

		latestDir=0
		secondLatestDir=0
		#read each entry and compare it to the largest value.
		for entry in ~/CVS/.History/$currentRepo
		do
			#If the entry is greater than the newest directory.
			if [[ $entry -gt latestDir ]]; then
				secondLatestDir=$latestDir
				latestDir=$entry
			fi
		done

		#If there exists a folder for the second latest directory.
		if [[ -d ~/CVS/.History/$currentRepo/$secondLatestDir ]]; then
			#For each entry in the second latest directory in the history directory for the current repo.
			for entry in ~/CVS/.History/$currentRepo/$secondLatestDir
			do
				#If that entry exists in the newly committed directory.
				if [[ -e ~/CVS/.History/$currentRepo/$latestDir/$entry ]]; then
					#Append changes between files to the log file.
					echo "Changes to $entry :" >> log
					diff $entry ~/CVS/.History/$currentRepo/$latestDir/$entry >> log
				else
					echo "File $entry has been deleted." >> log
				fi			
			done
		else
			#For each entry append the files added to log.
			for entry in ~/CVS/.History/$currentRepo/$latestDir
			do
				echo "Added $entry" >> log
			done
		fi
		lockHistory
	else
		echo "Unable to commit files due to empty repository."
	fi
}

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
	echo "Task:			Open text file for possible edits." >> log.txt
	echo "User:			$USER" >> log.txt
	echo "Time:			$(date)" >> log.txt
	echo "File:			$1" >> log.txt
	echo "Directory:	$(pwd)" >> log.txt
}

#Will allow user to return to an older version of the current repo.
rollBack()
{
	loopExit=0
	#While the repo has not been rolled back.
	while [[ loopExit -eq 0 ]]; do
		#If there are pre existing versions of the current repo.
		unlockHistory
		if [[ $(ls ~/CVS/.History/$currentRepo) ]]; then
			echo "Past versions of $currentRepo (YYYYMMDDHHmmSS):"
			ls ~/CVS/.History/$currentRepo
			echo "Enter the name of the version you would like to return to."
			read ver
			#If the directory specified by the user exists
			if [[ -d ~/CVS/.History/$currentRepo/$ver ]]; then
				#Add details to log file.
				echo "=========================" >> log
				echo "Task:	Roll repo back." >> log
				echo "User:	$USER" >> log
				echo "Time:	$(date)" >> log
				echo "Repo:	$currentRepo" >> log


				#Moves log file to CVS directory
				mv -t ~/CVS ~/CVS/$currentRepo/log
				#Delete contents of currentRepo.
				rm -Rf ~/CVS/$currentRepo/*
				#Copy files from History to current repo.
				cp -r -f -t ~/CVS/$currentRepo ~/CVS/.History/$currentRepo/$ver
				#Move log file back to its directory.
				mv -f -t ~/CVS/$currentRepo ~/CVS/log
				lockHistory
				echo "Roll back Successfully executed."
				loopExit=1
			else
				echo "Directory does not exist. Try again. "
			fi
		else
			#Exits loop due to inability to roll back.
			echo "No older versions to return to."
			loopExit=1
		fi
	done
}

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
		echo "6) Mange Permissions"
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
	echo "5) "
	echo "0) Exit Program"

	#Handles user input.
	option=999
	read option
	if [[ option -eq 0 ]]; then
		exit=1
	elif [[ option -eq 1 ]]; then
		openDir
	elif [[ option -eq 2 ]]; then
		createDir 1
	elif [[ option -eq 3 ]]; then
		deleteDir 1
	elif [[ option -eq 4 ]]; then
		Archive
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

