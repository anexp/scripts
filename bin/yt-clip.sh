#!/bin/bash

#DECLARATIONS

# USER INPUTS:
# link: takes the URL of the video to be downloaded
# start_time: takes the starting point of the video from where to download
# length: takes the length of the clip desired
# name_output: takes the name of the output file to be made (without the extension)
# video_length: takes a binary input for whether the full video is desired, or merely a portion of it
# file_type: binary input for if audio or video is desired

check_dependencies() {
	dependencies_installed=true

	# Check dependencies
	if ! command -v yt-dlp >/dev/null 2>&1; then
		printf "[Error] yt-dlp is needed for downloading \n"
		dependencies_installed=false
	fi

	if ! command -v ffmpeg >/dev/null 2>&1; then
		printf "[Error] ffmpeg is needed for transcoding \n"
		dependencies_installed=false
	fi

	if ! ${dependencies_installed}; then
		printf "[Error] Dependencies missing : Abort \n"
		exit 1
	fi

}

check_dependencies

#INPUT
printf "Enter link to video: "
read -r link

# Check if the link starts with "https://www.youtube.com"
# if ! [ $link == https://www.youtube.com* ]; then
# 	echo "Link does not start with https://www.youtube.com"
# 	echo "Please provide a valid link"
# 	exit 1
# fi

printf "Enter 1 for the full video, enter 2 for a portion\n"
read -r video_length

case "$video_length" in
# FULL VIDEO
1)

	printf "Enter 1 for audio, 2 for video\n"
	read -r file_type
	case "$file_type" in
	1)
		# AUDIO
		yt-dlp -x --audio-format mp3 --prefer-ffmpeg "$link"
		;;
	2)
		#  VIDEO
		yt-dlp "$link" -S res,ext:mp4:m4a --recode mp4
		;;
	esac
	;;

2)
	# PORTION OF THE FULL VIDEO
	printf "Enter starting point (in seconds or hours:minutes:seconds): "
	read -r start_time
	printf "Enter length of clip: "
	read -r length
	printf "Enter name of output file: "
	read -r name_output

	printf "Enter 1 for audio, 2 for video\n"
	read -r file_type

	# SETTING SENSIBLE DEFAULTS
	start_time=${start_time:-"00:00:00"}
	length=${length:-"30"}
	name_output=${name_output:-"unnamed_$(date +"%B_%d_%Y_%T")"}

	# GENERATING THE TRUE URLs FOR THE VIDEO
	read -d'\n' video_url audio_url <<<$(yt-dlp --youtube-skip-dash-manifest -g "$link")

	case "$file_type" in
	1)
		# AUDIO
		ffmpeg -ss "$start_time" -i "$audio_url" -t "$length" "$name_output.mp3"
		;;
	2)
		# VIDEO
		ffmpeg -ss "$start_time" -i "$video_url" -ss "$start_time" -i "$audio_url" -map 0:v -map 1:a -t "$length" -c:v libx264 -c:a aac "$name_output.mp4"
		;;
	esac
	;;
esac
