extends Node


# constants
const _REPO_PATH = "https://github.com/tillmii/one-button-games.git"


func _ready():
	pull_git_folders()


func pull_git_folders():
	
	# create list of directories
	var output = []
	var path: String = OS.get_user_data_dir()
	#print(path)
	OS.execute("cmd.exe", ["/C", str("cd ", path, " && dir /ad /b")], output, true, true)
	var list_of_directories = output[0].split("\r\n")
	#print(list_of_directories)
	
	# create git command
	var git_command = str("cd ", path, " && git clone ", _REPO_PATH)
	if list_of_directories.has("one-button-games"):
		git_command = "cd one-button-games && git pull %s" % _REPO_PATH
	
	# use git command
	output = []
	OS.execute("cmd.exe", ["/C", str(git_command, " && echo Finished")], output, true, true)
	# awaits command by queueing echo command
