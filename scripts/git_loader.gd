extends Node


# constants
const _REPO_PATH = "https://github.com/tillmii/one-button-games.git"


func _ready():
	pull_git_folders()


func pull_git_folders():
	
	# create list of directories
	var output = []
	OS.execute("cmd.exe", ["/C", "dir /ad /b"], output, true, true)
	var list_of_directories = output[0].split("\r\n")
	
	# create git command
	var git_command = "git clone %s" % _REPO_PATH
	if list_of_directories.has("one-button-games"):
		git_command = "cd one-button-games && git pull %s" % _REPO_PATH
	
	# use git command
	output = []
	OS.execute("cmd.exe", ["/C", str(git_command, " && echo Finished")], output, true, true)
	# awaits command by queueing echo command
