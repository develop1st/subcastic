settings.log.stdout := true
settings.log.file := true
settings.log.file.path := "/state/liquidsoap.log"
settings.server.telnet := true
settings.server.telnet.bind_addr := "0.0.0.0"

music_dir = environment.get("LIQ_MUSIC_DIR", default="/media/music")
inserts_dir = environment.get("LIQ_INSERTS_DIR", default="/media/inserts")
icecast_host = environment.get("LIQ_ICECAST_HOST", default="icecast")
icecast_port = int_of_string(environment.get("LIQ_ICECAST_PORT", default="8000"))
icecast_mount = environment.get("LIQ_ICECAST_MOUNT", default="/radio.mp3")
icecast_password = environment.get("LIQ_ICECAST_PASSWORD", default="sourcepass")
bitrate = int_of_string(environment.get("LIQ_BITRATE", default="128"))
server_port = int_of_string(environment.get("LIQ_SERVER_PORT", default="1234"))
settings.server.telnet.port := server_port

log("Watching music directory: #{music_dir}")
log("Watching inserts directory: #{inserts_dir}")
log("Insert queue id: insert_queue")
log("If no playable files are found, the stream falls back to silence until media is added.")

music = playlist(mode="randomize", reload_mode="watch", music_dir)

insert_queue = request.queue(id="insert_queue", interactive=true)
inserts = fallback(track_sensitive=false, [insert_queue, music])

radio = rotate(weights=[2, 1], [music, inserts])
radio = crossfade(radio)
bitrate_k = "#{bitrate}k"

output.icecast(
  %ffmpeg(format="mp3", %audio(codec="libmp3lame", b=bitrate_k)),
  host=icecast_host,
  port=icecast_port,
  password=icecast_password,
  mount=icecast_mount,
  fallible=true,
  name="Subcastic",
  description="Subcastic Phase 2 Radio",
  genre="Radio",
  url="http://localhost:8000",
  radio
)
