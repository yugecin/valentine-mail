source of a "4KB executable graphics" entry (3504 bytes)

https://demozoo.org/graphics/367428/  
https://www.pouet.net/prod.php?which=103684

this time with a (kinda) cleaned up c program :)

`. makeall` to build

`valentine-mail-720p-windowed-debug-watch.exe` watches the working
directory and reloads the shaders if `a.glsl` or `b.glsl` are written to

<img src=./reference.png width=400px>

```
> type valentine-mail.nfo


  ___________________________________
/ released in the combined graphics   \
\ compo at MountainBytes 2025         /
  -----------------------------------
         \   ^__^ 
          \  (oo)\_______
             (__)\       )\/\
                 ||----w |
                 ||     ||

99% partycoded (1% at the airport)

I wanted to not-partycode this but days, weeks, months
passed and the only thing I managed to do a few days before
the party was working on tooling[1] instead of the entry :D

This time with some form of anti aliasing :D

Shader source is /still/ not minified :^)
(except whitepsace and comments being trimmed)

Crinkler was used to link & compress the exe.

[1]: tooling: the debug-watch executable watches the directory
and reloads the shaders if a.glsl or b.glsl are written to.
This was really necessary now because I used to write the
shader in a different tool which also live reloaded but all
the font/texture things were not implemented there. So to
test the font stuff I had to push the export button, recompile
the exe, and run the exe to test it. With so much usage of
font textures here, that would've been ridiculous
```
