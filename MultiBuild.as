void main(MultiBuild::Workspace& workspace) {
	auto project = workspace.create_project(".");
	auto properties = project.properties();

	project.name("SDL");
	project.license("./LICENSE.txt");

	properties.binary_object_kind(MultiBuild::BinaryObjectKind::eStaticLib)
			  // Note: SDL uses ANSI too, it defines `UNICODE` and `_UNICODE` itself when it needs it
			  .character_set(MultiBuild::CharacterSet::eDefault);

	// SDL is C, but it also contains a few .cpp files (GameInput, Windows video/core)
	properties.tags("utf8");

	// Public include directory, users include <SDL3/SDL.h>
	project.include_own_required_includes(true);
	project.add_required_project_include({
		"./include"
	});

	// Headers (only so they show up in the generated solution)
	properties.files({
		"./include/SDL3/*.h",
		"./include/build_config/*.h",
		"./src/**.h"
	});

	// Private include directories
	// Note: SDL_internal.h lives in ./src and SDL_build_config.h (which picks the
	//       prebuilt SDL_build_config_<platform>.h) in ./include/build_config.
	//       USING_GENERATED_CONFIG_H must NOT be defined, we have no CMake generated config.
	properties.include_directories({
		"./src",
		"./include/build_config",
		"./src/video/khronos",
		"./src/core/windows/gameinput"
	});

	properties.defines({
		"SDL_BUILD_MAJOR_VERSION=3",
		"SDL_BUILD_MINOR_VERSION=5",
		"SDL_BUILD_MICRO_VERSION=0",
		// "DLL_EXPORT"
	});

	{
		MultiBuild::ScopedFilter _(project, "project.compiler:VisualCpp");
		// 4244/4267: conversions, 4996: deprecated CRT, 4100/4204/4221: noisy in SDL C code
		properties.disable_warnings({ "4244", "4267", "4996", "4005" });
		// Note: CET compatibility, same as the CMake build does for SDL3.dll
		// properties.link_options("/CETCOMPAT");
	}

	{
		MultiBuild::ScopedFilter _(project, "config.platform:Windows");

		properties.defines("_CRT_SECURE_NO_WARNINGS");

		// Libraries SDL needs on Windows (from the CMake "base" link dependency + joystick)
		properties.library_links({
			"kernel32", "user32", "gdi32", "winmm", "imm32", "ole32", "oleaut32",
			"version", "uuid", "advapi32", "setupapi", "shell32", "hid", "mincore",
			"dinput8"
		});

		properties.files({
			// ---- Generic (platform independent) sources ----
			"./src/*.c",
			"./src/atomic/*.c",
			"./src/audio/*.c",
			"./src/camera/*.c",
			"./src/core/*.c",
			"./src/cpuinfo/*.c",
			"./src/dynapi/*.c",
			"./src/events/*.c",
			"./src/filesystem/*.c",
			"./src/gpu/*.c",
			"./src/gpu/xr/*.c",
			"./src/haptic/*.c",
			"./src/io/*.c",
			"./src/io/generic/*.c",
			"./src/joystick/*.c",
			"./src/libm/*.c",
			"./src/locale/*.c",
			"./src/main/*.c",
			"./src/main/generic/*.c",
			"./src/misc/*.c",
			"./src/notification/*.c",
			"./src/power/*.c",
			"./src/process/SDL_process.c",
			"./src/render/*.c",
			"./src/sensor/*.c",
			"./src/stdlib/*.c",
			"./src/storage/*.c",
			"./src/thread/*.c",
			"./src/time/*.c",
			"./src/timer/*.c",
			"./src/tray/*.c",
			"./src/video/*.c",
			"./src/video/yuv2rgb/*.c",
			"./src/dialog/SDL_dialog.c",
			"./src/dialog/SDL_dialog_utils.c",

			// ---- Joystick / gamepad ----
			// Note: ./src/hidapi/SDL_hidapi.c #includes the platform hid.c itself,
			//       so do NOT glob the hidapi subdirectories.
			"./src/hidapi/*.c",
			"./src/joystick/hidapi/*.c",
			"./src/haptic/hidapi/*.c",
			"./src/joystick/virtual/*.c",
			"./src/joystick/windows/*.c",
			"./src/joystick/gdk/*.cpp",

			// ---- Windows platform ----
			"./src/core/windows/*.c",
			"./src/core/windows/*.cpp",
			"./src/core/windows/gameinput/gameinput.cpp",
			"./src/main/windows/*.c",
			"./src/io/windows/*.c",
			"./src/filesystem/windows/*.c",
			"./src/storage/generic/*.c",
			"./src/storage/steam/*.c",
			"./src/loadso/windows/*.c",
			"./src/locale/windows/*.c",
			"./src/misc/windows/*.c",
			"./src/power/windows/*.c",
			"./src/time/windows/*.c",
			"./src/timer/windows/*.c",
			"./src/haptic/windows/*.c",
			"./src/sensor/windows/*.c",
			"./src/tray/windows/*.c",
			"./src/notification/windows/*.c",
			"./src/dialog/windows/SDL_windowsdialog.c",
			"./src/process/windows/*.c",

			// Threads (Windows + the generic cond/rwlock fallbacks CMake adds)
			"./src/thread/generic/SDL_syscond.c",
			"./src/thread/generic/SDL_sysrwlock.c",
			"./src/thread/windows/SDL_syscond_cv.c",
			"./src/thread/windows/SDL_sysmutex.c",
			"./src/thread/windows/SDL_sysrwlock_srw.c",
			"./src/thread/windows/SDL_syssem.c",
			"./src/thread/windows/SDL_systhread.c",
			"./src/thread/windows/SDL_systls.c",

			// Video (Windows + the dummy/offscreen drivers SDL always has)
			"./src/video/windows/*.c",
			"./src/video/windows/*.cpp",
			"./src/video/dummy/*.c",
			"./src/video/offscreen/*.c",

			// Audio
			"./src/audio/dummy/*.c",
			"./src/audio/disk/*.c",
			"./src/audio/directsound/*.c",
			"./src/audio/wasapi/*.c",

			// Camera
			"./src/camera/dummy/*.c",
			"./src/camera/mediafoundation/*.c",

			// Render + GPU backends enabled by SDL_build_config_windows.h
			"./src/render/software/*.c",
			"./src/render/direct3d/*.c",
			"./src/render/direct3d11/*.c",
			"./src/render/direct3d12/*.c",
			"./src/render/opengl/*.c",
			"./src/render/opengles2/*.c",
			"./src/render/vulkan/*.c",
			"./src/render/gpu/*.c",
			"./src/gpu/d3d12/*.c",
			"./src/gpu/vulkan/*.c"
		});
	}
}
