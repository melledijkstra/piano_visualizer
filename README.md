# Piano Visualizer

## Requirements
- ffmpeg installed

## Recording with Godot movie maker

1. Make sure that project settings are correctly set to PNG. This allows for loseless frame captures.
[Project Settings](./project.godot)
`movie_writer/movie_file="/Users/dijksmel/projects/piano-visualizer/output/output.png"`
2. Run the movie maker to capture frames.
3. Use ffmpeg to convert the PNG frames to a video file.
  - For mp4: 
  `ffmpeg -framerate 60 -i output/output%08d.png -c:v libx264 -preset veryslow -crf 15 -pix_fmt yuv420p output/output.mp4`
  - For .mov: 
  `ffmpeg -framerate 60 -i output/output%08d.png -c:v prores_ks -profile:v 3 -vendor apl0 -pix_fmt yuv422p10le output/output.mov`
  - From .avi to .mp4:
  `ffmpeg -i output/output.avi -c:v copy -c:a copy output/output.mp4`
  - From .avi to share on whatsapp (.mp4):
  `ffmpeg -i output/output.avi -c:v libx264 -profile:v main -level 3.1 -preset medium -crf 23 -c:a aac -b:a 128k -movflags +faststart -pix_fmt yuv420p output/output.mp4`