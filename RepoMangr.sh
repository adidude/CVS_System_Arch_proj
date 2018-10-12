#Authors: Aditya Kumar Menon,	Mandar Tamhane,		Rauf Nawaz Tarar
#MatricNo.: 170025886			170021792			170012145
currentRepo=null
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
					#If The directory is a repo it will be stored in the currentRepo variable.
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

#Will create a repo. $1 determines if the directory is a repo.
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

#Deletes a repo. $1 determines if the directory is a repo.
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
	echo "Please enter a comment with information on changes."
	read comment
	echo "Comment: $comment" >> log

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
	echo "===================================================="
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

#This function archives the project in three different formats.
Archive()
{
	ls ~/CVS/
	read -p "\nplease enter the repository you want to Archive: " SFOLDER1
	read -p "Please enter the location to save this zip file (e.g. /home/user/repository):" DFOLDER1
	read -p "Select archive type (zip or tar.gz,):" COMPRES1
	case $COMPRES1 in
		zip) zip -erj ${DFOLDER1}/$(SFOLDER1).zip ~/CVS/$SFOLDER1;; # for zip 
		tar.gz) tar cvfz ${DFOLDER1}/$(SFOLDER1).tar.gz ~/CVS/$SFOLDER1;; # for tar.gz
		

 # Error handling for entering wrong type, shows an error message
 *) echo "Please enter a valid compression type (zip or tar.gz)";
exit;;

#end of case statment
esac 
}


#This funtion edits the file and creates backup before editing
EditFile()
{
	ListFiles #Calls for list function for showing whats in the directory
	echo "Enter the file name you want to edit (e.g. file1):"
	read fileName
	cp $fileName "$fileName"_Backup # Creates a backup file
	nano $fileName # opens the file in nano editor for editing in terminal.
}

#This function lists all the files in directory
ListFiles()
{
	echo "Enter the name of repository you want to see:"
	ls ~/CVS
	listed=0
	while [[ listed -eq 0 ]]; do
		read repo_path
		if [[ -d ~/CVS/$(repo_path) ]]; then
			for entry in ~/CVS/$(repo_path)/*
			do
				echo "$entry"
			done
		fi
	done
}

#This funtion look for changes in file and log all the changes to new file with date, username and additional comments.
Difference()
{
	echo "========================"
	echo "please enter original file path (e.g. /home/user/file1):"
	read org_file
	echo "please enter new file path (e.g. /home/user/file2):"
	read new_file

	echo "              Changes             " > diff
	echo "--------------------------------------" > diff

	#compares two files side by side and log them on file.
	diff $org_file $new_file > diff

	echo "Differences can be viewed in diff file."
}