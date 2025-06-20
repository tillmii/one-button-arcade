extends Node


# constants
const _REPO_PATH = "https://github.com/tillmii/one-button-games.git"


func _ready():
	pull_git_folders()


func pull_git_folders():
	
	# create list of directories
	var output = []
	var user_data_path: String = OS.get_user_data_dir()
	var cd_and_dir = "cd %s && dir /ad /b" % user_data_path
	OS.execute("cmd.exe", ["/C", cd_and_dir], output, true, true)
	var list_of_directories = output[0].split("\r\n")
	
	# create git command
	var git_command = "cd %s && git clone %s" % [user_data_path, _REPO_PATH]
	if list_of_directories.has("one-button-games"):
		git_command = "cd %s/one-button-games && git pull %s" % [user_data_path, _REPO_PATH]
	
	# use git command
	output = []
	OS.execute("cmd.exe", ["/C", str(git_command, " && echo Finished")], output, true, true)
	# awaits command by queueing echo command
