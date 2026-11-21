# PS4 Homebrew Lab

A small original PS4 **homebrew demo** intended to be installed on a jailbroken PS4 with GoldHEN.

**Important:** This project is **not a PS5 emulator**, is **not GTA 6**, and cannot run PS5 games. The first goal is to prove that a real PS4 homebrew `.pkg` can be built and launched. The demo draws a simple animated screen using the PS4's VideoOut API.

## Get the PKG

1. Open the **Actions** tab in this repository.
2. Choose **Build PS4 PKG** and run it (or look for the build triggered by a push).
3. Wait for the build to finish with a green check. If it fails, read the workflow logs instead of downloading anything.
4. Open the completed run, then download its **ps4-homebrew-pkg** artifact.
5. Extract the ZIP: it should contain `IV0000-EMLB00001_00-EMULATORLAB00001.pkg`.
6. Copy the PKG to an exFAT USB drive and install it using GoldHEN's Package Installer.

**Builds are generated in GitHub Actions; a successful build does not guarantee the app works on every PS4 firmware.** There is no PKG checked into the source repository.

## Contents

- `src/main.c`: simple frame-buffer display demo
- `Makefile`: OpenOrbis compilation and packaging
- `tools/make_icon.py`: generates an original placeholder icon
- `tools/make_gp4.py`: writes the GP4 package manifest
- `.github/workflows/build.yml`: compiles and publishes a .pkg artifact

## Build locally

Use a Linux installation of [OpenOrbis PS4 Toolchain](https://github.com/OpenOrbis/OpenOrbis-PS4-Toolchain), and set `OO_PS4_TOOLCHAIN` to its installed root. Then run `make`. You need Clang/LLD, Python 3, PkgTool.Core and the toolchain's required .NET runtime libraries.

## Next milestones

Once a real PS4 test app launches successfully, add a toy CPU interpreter, debug screen, and a homebrew software renderer. That is an educational emulator lab—not an emulator for PS5 retail games.

## Credits

Build based on the public OpenOrbis SDK documentation and the general workflow of open-source PS4 homebrew projects. No Sony/Rockstar software or retail game files are included.
