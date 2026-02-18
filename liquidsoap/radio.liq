set("log.stdout", true)
set("log.file", true)
set("log.file.path", "/state/liquidsoap.log")

music_dir = environment.get("LIQ_MUSIC_DIR", default="/media/music")
icecast_host = environment.get("LIQ_ICECAST_HOST", default="icecast")
icecast_port = int_of_string(environment.get("LIQ_ICECAST_PORT", default="8000"))
icecast_mount = environment.get("LIQ_ICECAST_MOUNT", default="/radio.mp3")
icecast_password = environment.get("LIQ_ICECAST_PASSWORD", default="sourcepass")
bitrate = int_of_string(environment.get("LIQ_BITRATE", default="128"))

log("Watching music directory: #{music_dir}")
log("If no playable files are found, the stream falls back to silence until media is added.")

music = playlist(mode="randomize", reload_mode="watch", music_dir)
music = mksafe(music)
music = crossfade(music)
radio = fallback(track_sensitive=false, [music, blank()])
bitrate_k = "#{bitrate}k"

output.icecast(
  %ffmpeg(format="mp3", %audio(codec="libmp3lame", b=bitrate_k)),
  host=icecast_host,
  port=icecast_port,
  password=icecast_password,
  mount=icecast_mount,
  name="Subcastic",
  description="Subcastic Phase 1 Radio",
  genre="Radio",
  url="http://localhost:8000",
  radio
)
