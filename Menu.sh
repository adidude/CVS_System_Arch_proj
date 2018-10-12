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
	echo ""
fi

currentDir=null

#Command to open a directory.
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
					#If the directory is a repo the currentRepo var changes.
					if [[ $1 -eq 1 ]]; then
						currentRepo=$dir
					fi
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

#Will create a directory.
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
				mkdir ~/CVS/.History/$reponame
			fi
			createdDir=1
			echo ""
		fi
	done		
}

#Deletes a directory.
deleteDir()
{
	deletedir=0
	#As long as the directory is not deleted loop continues.
	while [[ deletedir -eq 0 ]]; do
		#Tests if there are any directories to delete.
		if [[ "$(ls -d *)" ]]; then
			echo "Directory list:"
			ls -d *
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
						rm -Rf ~/CVS/.History/$dir
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
			#Create file and exit loop.
			touch $file
			fileCreated=1
		fi
	done
}

#Will track the changes between last version of the file and the current one.
trackChanges()
{
	diff $1 $2 >> log
}

#INCOMPLETE
#Will commit changes.
commit()
{
	#Adds information of commit to log file.
	echo "Task:	Commit Files." >> log
	echo "User:	$USER" >> log
	echo "Time:	$(date)" >> log
	echo "Repo:	$(pwd)" >> log

	#if repository is empty print error otherwise continue with commiting files.
	if [[ $(ls) ]]; then
		#Opens the .History directory to make a directory with the time/date within the relevant repo.
		cd ~/CVS/.History/$currentRepo
		#Stores the date/time in a variable, then makes a directory with the date/time as its name.
		time=$(date +%Y%m%d%H%M%S)
		mkdir "$time"

		#Return to the current working directory.
		cd ~/CVS/$currentRepo
		#Copy Repo to current version folder.
		cp -r -f -t ~/CVS/.History/$currentRepo/$(date) $(pwd)

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
	echo "Task:			Open text file for possible edits." >> log
	echo "User:			$USER" >> log
	echo "Time:			$(date)" >> log
	echo "File:			$1" >> log
	echo "Directory:	$(pwd)" >> log
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