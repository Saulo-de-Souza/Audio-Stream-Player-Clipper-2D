# AudioStreamPlayerClipper2D: Advanced Audio Control for Godot

Maximize your control over audio in your Godot projects with **AudioStreamPlayerClipper2D**, a solution for audio clipping that goes beyond the engine's native capabilities. Precisely set the start and end points of your audio clips quickly and intuitively through the editor.

**Full support for all platforms, including web** (the audio loop with offset in Godot currently does not work for web). **AudioStreamPlayerClipper2D** ensures that your audio cuts and adjustments are maintained accurately across all platforms.

Additionally, streamline your workflow with the ability to test audio directly in the editor inspector, without needing to run the game. Simplify the process of fine-tuning and refining your sounds quickly and efficiently.

## Settings

- **Start Time**
- **End Time**
- **Apply Cut**
- **Audio Stream**
- **AutoPlay**
- **Loop**
- **Volume DB**
- **Pitch Scale**
- **Max Distance**
- **Attenuation**
- **Panning Strength**
- **Editor Play Test**

```php
$AudioStreamPlayerClipper2D.loop = false
$AudioStreamPlayerClipper2D.auto_play = false
$AudioStreamPlayerClipper2D.start_time = 0.0
$AudioStreamPlayerClipper2D.end_time = 0.0
$AudioStreamPlayerClipper2D.apply_cut = false
$AudioStreamPlayerClipper2D.volume_db = 0.0
$AudioStreamPlayerClipper2D.pitch_scale = 1
$AudioStreamPlayerClipper2D.max_distance = 2000.0
$AudioStreamPlayerClipper2D.attenuation = 1.0
$AudioStreamPlayerClipper2D.panning_strength = 1.0
$AudioStreamPlayerClipper2D.play()
$AudioStreamPlayerClipper2D.stop()
```

## ![Screen Shoot](screen_shoot_1.png)

## Installation

1. Download the plugin and place the `AudioStreamPlayerClipper2D` folder inside the `addons` folder of your Godot project.
2. Enable the plugin in **Project Settings** > **Plugins**.

## Usage

1. Select the audio node you want to adjust in your project.
2. In the Inspector, locate the **AudioStreamPlayerClipper2D** section.
3. Configure the desired parameters, including start and end time, cut, loop, and autoplay.
4. Test the audio directly in the inspector for quick and precise adjustments.

## Support

For any questions or additional support, contact [saulocoexi@gmail.com](mailto:saulocoexi@gmail.com).

---

Enjoy **AudioStreamPlayerClipper2D** for complete and efficient control over audio in your Godot projects!
